-- Número de carros del vehículo (1 a 4). NULL = sin indicar.
ALTER TABLE public.tvehiculos
  ADD COLUMN IF NOT EXISTS numero_carros smallint;

ALTER TABLE public.tvehiculos
  DROP CONSTRAINT IF EXISTS tvehiculos_numero_carros_check;

ALTER TABLE public.tvehiculos
  ADD CONSTRAINT tvehiculos_numero_carros_check CHECK (numero_carros BETWEEN 1 AND 4);

COMMENT ON COLUMN public.tvehiculos.numero_carros IS 'Número de carros del vehículo (1 a 4; NULL = sin indicar)';
