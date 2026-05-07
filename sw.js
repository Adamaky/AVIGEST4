/* ============================================================
   AviGest v24 — Service Worker
   Gère : cache offline + notifications push OneSignal
   ============================================================ */

/* Import SDK OneSignal — obligatoire pour les notifications push */
importScripts('https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.sw.js');

const CACHE_NAME  = 'avigest-v24';
const STATIC_URLS = [
  '/AVIGEST4/',
  '/AVIGEST4/index.html'
];

/* ── Installation : mise en cache des ressources statiques ── */
self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(STATIC_URLS)).then(() => self.skipWaiting())
  );
});

/* ── Activation : suppression des anciens caches ── */
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

/* ── Fetch : réseau d'abord, cache si hors ligne ── */
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  if (e.request.url.includes('script.google.com')) return;
  if (e.request.url.includes('fonts.googleapis.com')) return;
  e.respondWith(
    fetch(e.request)
      .then(resp => {
        const clone = resp.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(e.request, clone));
        return resp;
      })
      .catch(() => caches.match(e.request))
  );
});

/* ── Notifications push OneSignal ── */
self.addEventListener('push', e => {
  if (!e.data) return;
  let payload;
  try { payload = e.data.json(); } catch(_) { payload = { title:'AviGest', body: e.data.text() }; }
  const title   = payload.headings?.fr || payload.title || 'AviGest';
  const options = {
    body   : payload.contents?.fr || payload.body || '',
    icon   : '/AVIGEST4/icons/icon-192.png',
    badge  : '/AVIGEST4/icons/icon-192.png',
    vibrate: [200, 100, 200],
    data   : { url: payload.url || '/AVIGEST4/' },
    actions: [{ action:'ouvrir', title:'Ouvrir AviGest' }]
  };
  e.waitUntil(self.registration.showNotification(title, options));
});

/* ── Clic sur notification : ouvre l'app ── */
self.addEventListener('notificationclick', e => {
  e.notification.close();
  const target = e.notification.data?.url || '/AVIGEST4/';
  e.waitUntil(
    clients.matchAll({ type:'window', includeUncontrolled:true }).then(list => {
      const existing = list.find(c => c.url.includes('AVIGEST4'));
      if (existing) return existing.focus();
      return clients.openWindow(target);
    })
  );
});
