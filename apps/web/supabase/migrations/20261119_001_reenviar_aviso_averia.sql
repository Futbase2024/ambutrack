-- =====================================================
-- Reenviar el aviso de una avería ya creada (historial de averías)
--
-- - fn_aviso_averia_contenido: título/mensaje/metadata del aviso (compartido)
-- - fn_notificar_nueva_averia: trigger de alta, ahora usa el helper (mismo texto)
-- - reenviar_aviso_averia: crea un aviso NUEVO para los gestores de flota.
--   No pasa por crear_notificacion_gestores_flota, que descarta a quien ya
--   tiene aviso de esa avería (eso evita duplicados al crear, no al reenviar).
--   Cada fila nueva en tnotificaciones dispara el push (trg_encolar_push_notificacion).
-- =====================================================

create or replace function public.fn_aviso_averia_contenido(
  p_inc public.incidencias_vehiculos,
  out titulo text,
  out mensaje text,
  out metadata jsonb
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_matricula text;
  v_reportante text;
  v_emoji text;
  v_prioridad text;
  v_km text;
begin
  select v.matricula into v_matricula from tvehiculos v where v.id = p_inc.vehiculo_id;

  v_reportante := coalesce(
    nullif(trim(p_inc.reportado_por_nombre), ''),
    (select nullif(trim(concat_ws(' ', u.nombre, u.apellidos)), '') from usuarios u
      where u.id = coalesce(p_inc.reportado_por, auth.uid())),
    'Alguien'
  );

  v_emoji := case p_inc.prioridad when 'critica' then '🚨' when 'alta' then '⚠️' when 'media' then '🔧' else 'ℹ️' end;
  v_prioridad := case p_inc.prioridad when 'critica' then 'CRÍTICA' when 'alta' then 'Alta' when 'media' then 'Media' else 'Baja' end;
  v_km := case when p_inc.kilometraje_reporte is null then 'km no especificados'
               else round(p_inc.kilometraje_reporte)::text || ' km' end;

  titulo := v_emoji || ' Nueva Incidencia de Vehículo - Prioridad ' || v_prioridad;
  mensaje := v_reportante || ' reportó: ' || p_inc.titulo || '. ' || coalesce(p_inc.descripcion, '')
    || E'\n\n🚗 Vehículo: ' || coalesce(v_matricula, 'Vehículo')
    || E'\n📏 Kilometraje: ' || v_km;
  metadata := jsonb_build_object(
    'vehiculo_id', p_inc.vehiculo_id,
    'matricula', coalesce(v_matricula, 'Vehículo'),
    'kilometraje', p_inc.kilometraje_reporte,
    'reportado_por', p_inc.reportado_por,
    'reportado_por_nombre', v_reportante,
    'tipo', p_inc.tipo,
    'prioridad', p_inc.prioridad,
    'titulo', p_inc.titulo,
    'descripcion', p_inc.descripcion,
    'fecha_reporte', p_inc.fecha_reporte
  );
end;
$$;

revoke all on function public.fn_aviso_averia_contenido(public.incidencias_vehiculos) from public, anon, authenticated;

-- Trigger de alta: mismo comportamiento, contenido desde el helper
create or replace function public.fn_notificar_nueva_averia()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  c record;
begin
  select * into c from public.fn_aviso_averia_contenido(new);

  perform public.crear_notificacion_gestores_flota(
    'incidencia_vehiculo_reportada',
    c.titulo,
    c.mensaje,
    'incidencia_vehiculo',
    new.id::text,
    c.metadata,
    coalesce(auth.uid(), new.reportado_por) -- quien la registra no se avisa a sí mismo
  );
  return new;
exception when others then
  -- Un fallo en el aviso nunca debe impedir guardar la avería
  raise warning 'fn_notificar_nueva_averia: no se pudo notificar la avería %: %', new.id, sqlerrm;
  return new;
end;
$$;

-- Reenvío manual desde el historial de averías. Devuelve a cuántos gestores se avisó.
create or replace function public.reenviar_aviso_averia(p_incidencia_id uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_inc public.incidencias_vehiculos;
  c record;
  v_count integer;
begin
  if auth.uid() is null
     or not exists (select 1 from usuarios u where u.id = auth.uid() and u.activo = true) then
    raise exception 'Sesión no válida' using errcode = '42501';
  end if;

  select * into v_inc from public.incidencias_vehiculos where id = p_incidencia_id;
  if not found then
    raise exception 'La avería no existe' using errcode = 'P0002';
  end if;

  select * into c from public.fn_aviso_averia_contenido(v_inc);

  insert into tnotificaciones (
    usuario_destino_id, tipo, titulo, mensaje, entidad_tipo, entidad_id,
    metadata, leida, fecha_lectura, created_at
  )
  select u.id, 'incidencia_vehiculo_reportada', '🔁 ' || c.titulo, c.mensaje,
         'incidencia_vehiculo', v_inc.id::text,
         c.metadata || jsonb_build_object('reenviado', true, 'reenviado_por', auth.uid()),
         false, null, now()
  from usuarios u
  where u.activo = true
    and u.rol in ('admin', 'jefe_mantenimiento')
    and u.id <> auth.uid(); -- quien reenvía no se avisa a sí mismo

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke all on function public.reenviar_aviso_averia(uuid) from public, anon;
grant execute on function public.reenviar_aviso_averia(uuid) to authenticated;
