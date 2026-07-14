-- 037_check_type_client.sql
-- Fige les valeurs autorisées de clients.type_client

ALTER TABLE clients
  DROP CONSTRAINT IF EXISTS clients_type_client_check;

ALTER TABLE clients
  ADD CONSTRAINT clients_type_client_check
  CHECK (type_client IN (
    'PARTICULIER',
    'REVENDEUR',
    'ACHETEUR_VIF',
    'RESTAURANT',
    'INSTITUTION'
  ));