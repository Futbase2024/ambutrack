-- Indica si el vehículo tiene soporte (anclaje) para silla eléctrica.
-- Campo manual, independiente de si lleva la silla en el stock.
ALTER TABLE public.tvehiculos
  ADD COLUMN IF NOT EXISTS tiene_soporte_silla_electrica boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.tvehiculos.tiene_soporte_silla_electrica IS 'El vehículo tiene soporte para silla eléctrica (campo manual)';
