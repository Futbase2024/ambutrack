-- Realtime para la dotación de los vehículos (equipamiento + caducidades)
-- La app móvil escucha cambios de stock_vehiculo filtrados por vehiculo_id
-- para refrescar al instante las pantallas de Equipamiento y Caducidades.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'stock_vehiculo'
  ) then
    alter publication supabase_realtime add table public.stock_vehiculo;
  end if;
end $$;
