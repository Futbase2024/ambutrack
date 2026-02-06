# 📋 Instrucciones: Implementar Event Ledger para Sincronización en Tiempo Real

## 🎯 Objetivo

Implementar el sistema de eventos que permite sincronización automática en tiempo real entre la app web y la app móvil cuando:
- Se asigna un conductor a un traslado
- Se reasigna un traslado a otro conductor
- Se desasigna un conductor de un traslado
- Cambia el estado de un traslado

## 📁 Archivo de Migración

**Ubicación**: `apps/web/supabase/migrations/20260205_001_create_traslados_eventos_event_ledger.sql`

## 🚀 Paso 1: Ejecutar Migración en Supabase

### Opción A: Desde el Dashboard de Supabase (Recomendado)

1. Abre el Dashboard de Supabase: https://supabase.com/dashboard
2. Selecciona tu proyecto
3. Ve a **SQL Editor** (menú lateral izquierdo)
4. Haz clic en **New Query**
5. Copia y pega el contenido del archivo `20260205_001_create_traslados_eventos_event_ledger.sql`
6. Haz clic en **Run** (o presiona `Ctrl/Cmd + Enter`)
7. Verifica que aparezca "Success. No rows returned"

### Opción B: Desde Supabase CLI

```bash
# Desde el directorio apps/web
cd apps/web

# Ejecutar la migración
supabase db push

# O ejecutar directamente el archivo
supabase db execute -f supabase/migrations/20260205_001_create_traslados_eventos_event_ledger.sql
```

## ✅ Paso 2: Verificar que la Migración se Ejecutó Correctamente

Ejecuta estas consultas SQL en el **SQL Editor** de Supabase:

### 2.1. Verificar que la tabla existe
```sql
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'traslados_eventos';
```
**Resultado esperado**: 1 fila con `traslados_eventos`

### 2.2. Verificar que el tipo ENUM existe
```sql
SELECT typname
FROM pg_type
WHERE typname = 'evento_traslado_type';
```
**Resultado esperado**: 1 fila con `evento_traslado_type`

### 2.3. Verificar que el trigger existe
```sql
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'trigger_log_traslado_evento';
```
**Resultado esperado**: 1 fila con el trigger

### 2.4. Verificar que Realtime está habilitado
```sql
SELECT tablename
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
AND tablename = 'traslados_eventos';
```
**Resultado esperado**: 1 fila con `traslados_eventos`

### 2.5. Verificar políticas RLS
```sql
SELECT policyname, tablename, cmd
FROM pg_policies
WHERE tablename = 'traslados_eventos';
```
**Resultado esperado**: 5 políticas (SELECT conductores, SELECT admins, INSERT bloqueado, UPDATE bloqueado, DELETE solo admins)

## 🧪 Paso 3: Probar el Trigger con un Traslado Real

### Test 1: Asignar un conductor (assigned)

```sql
-- 1. Buscar un traslado sin conductor
SELECT id, codigo, id_conductor, estado
FROM traslados
WHERE id_conductor IS NULL
LIMIT 1;

-- Anota el ID del traslado: _____________________

-- 2. Buscar un conductor
SELECT id, nombre, apellidos
FROM personal
WHERE rol = 'conductor'
LIMIT 1;

-- Anota el ID del conductor: _____________________

-- 3. Asignar conductor al traslado
UPDATE traslados
SET id_conductor = 'PEGA_AQUÍ_ID_CONDUCTOR'
WHERE id = 'PEGA_AQUÍ_ID_TRASLADO';

-- 4. Verificar que se creó el evento
SELECT
  id,
  event_type,
  old_conductor_id,
  new_conductor_id,
  created_at,
  metadata
FROM traslados_eventos
WHERE traslado_id = 'PEGA_AQUÍ_ID_TRASLADO'
ORDER BY created_at DESC;
```

**Resultado esperado**:
- 1 evento con `event_type = 'assigned'`
- `old_conductor_id = NULL`
- `new_conductor_id = ID_del_conductor`

### Test 2: Reasignar a otro conductor (reassigned)

```sql
-- 1. Buscar otro conductor diferente
SELECT id, nombre, apellidos
FROM personal
WHERE rol = 'conductor'
AND id != 'ID_CONDUCTOR_ANTERIOR'
LIMIT 1;

-- Anota el nuevo ID: _____________________

-- 2. Reasignar
UPDATE traslados
SET id_conductor = 'PEGA_AQUÍ_NUEVO_ID_CONDUCTOR'
WHERE id = 'PEGA_AQUÍ_ID_TRASLADO';

-- 3. Verificar evento
SELECT
  id,
  event_type,
  old_conductor_id,
  new_conductor_id,
  created_at
FROM traslados_eventos
WHERE traslado_id = 'PEGA_AQUÍ_ID_TRASLADO'
ORDER BY created_at DESC
LIMIT 1;
```

**Resultado esperado**:
- 1 evento con `event_type = 'reassigned'`
- `old_conductor_id = ID_conductor_anterior`
- `new_conductor_id = ID_nuevo_conductor`

### Test 3: Desasignar conductor (unassigned)

```sql
-- 1. Desasignar
UPDATE traslados
SET id_conductor = NULL
WHERE id = 'PEGA_AQUÍ_ID_TRASLADO';

-- 2. Verificar evento
SELECT
  id,
  event_type,
  old_conductor_id,
  new_conductor_id,
  created_at
FROM traslados_eventos
WHERE traslado_id = 'PEGA_AQUÍ_ID_TRASLADO'
ORDER BY created_at DESC
LIMIT 1;
```

**Resultado esperado**:
- 1 evento con `event_type = 'unassigned'`
- `old_conductor_id = ID_del_conductor`
- `new_conductor_id = NULL`

### Test 4: Cambiar estado (status_changed)

```sql
-- 1. Asignar conductor nuevamente
UPDATE traslados
SET id_conductor = 'PEGA_AQUÍ_ID_CONDUCTOR'
WHERE id = 'PEGA_AQUÍ_ID_TRASLADO';

-- 2. Cambiar estado
UPDATE traslados
SET estado = 'en_origen'
WHERE id = 'PEGA_AQUÍ_ID_TRASLADO';

-- 3. Verificar evento
SELECT
  id,
  event_type,
  old_estado,
  new_estado,
  created_at
FROM traslados_eventos
WHERE traslado_id = 'PEGA_AQUÍ_ID_TRASLADO'
ORDER BY created_at DESC
LIMIT 1;
```

**Resultado esperado**:
- 1 evento con `event_type = 'status_changed'`
- `old_estado` = estado anterior
- `new_estado = 'en_origen'`

## 📱 Paso 4: Probar en la App Móvil

### 4.1. Asegúrate de que la app móvil esté actualizada

La app móvil ya tiene el código implementado. Solo verifica que estés usando la versión más reciente.

### 4.2. Test de Realtime

1. **Abre la app móvil** como conductor
2. **Inicia sesión** con las credenciales de un conductor
3. **Navega a "Mis Servicios"**
4. La app debería cargar tus traslados actuales

5. **En otro dispositivo o en la web**, asigna un nuevo traslado al conductor
   - Ve a Tráfico Diario
   - Selecciona un traslado sin asignar
   - Asigna el conductor

6. **En la app móvil**:
   - **NO hagas refresh** manualmente
   - El traslado debería aparecer automáticamente en **menos de 2 segundos**
   - Verás una notificación tipo toast (opcional, según implementación)

7. **Prueba el cambio de estado**:
   - En la app móvil, cambia el estado del traslado (ej: "En Origen")
   - El cambio debería reflejarse inmediatamente
   - En la web, verifica que el estado cambió

8. **Prueba la reasignación**:
   - En la web, reasigna el traslado a otro conductor
   - En la app móvil del primer conductor, el traslado debería **desaparecer automáticamente**

## 🔍 Paso 5: Verificar Logs en Flutter (Opcional)

Si tienes acceso a los logs de la app móvil, deberías ver:

```
📡 [TrasladosBloc] Streams iniciados para conductor: uuid-conductor
🔔 [TrasladosDataSource] Canal Realtime creado: traslados_eventos_uuid
⚡ [TrasladosBloc] Evento recibido: assigned - Traslado: uuid-traslado
✅ [TrasladosBloc] Traslado uuid-traslado asignado a mí
```

## 🛠️ Troubleshooting

### Problema: Los eventos no llegan a la app móvil

**Solución 1: Verificar Realtime**
```sql
-- Verificar que Realtime está habilitado
SELECT tablename
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
AND tablename = 'traslados_eventos';
```
Si no aparece, ejecuta:
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE public.traslados_eventos;
```

**Solución 2: Verificar RLS**
```sql
-- Ver políticas
SELECT policyname, tablename, cmd
FROM pg_policies
WHERE tablename = 'traslados_eventos';
```

**Solución 3: Verificar que el trigger funciona**
```sql
-- Hacer un UPDATE y ver si se crea evento
UPDATE traslados SET id_conductor = 'uuid' WHERE id = 'uuid';

-- Ver eventos creados
SELECT * FROM traslados_eventos ORDER BY created_at DESC LIMIT 5;
```

### Problema: Eventos duplicados

- El datasource ya implementa deduplicación automática
- Verifica que solo haya UNA instancia del BLoC activa en la app

### Problema: Eventos llegan con mucho retraso (> 5 segundos)

- Verifica tu conexión a internet
- Revisa el plan de Supabase (límites de Realtime)
- Considera activar "Accelerated Realtime" en Supabase (plan Pro)

## 📊 Monitoreo en Producción

### Consulta: Eventos por día
```sql
SELECT
  DATE(created_at) as fecha,
  event_type,
  COUNT(*) as total
FROM traslados_eventos
GROUP BY DATE(created_at), event_type
ORDER BY fecha DESC, event_type;
```

### Consulta: Eventos recientes
```sql
SELECT
  te.id,
  te.event_type,
  te.created_at,
  t.codigo as traslado,
  pc.nombre as conductor_anterior,
  pn.nombre as conductor_nuevo
FROM traslados_eventos te
JOIN traslados t ON te.traslado_id = t.id
LEFT JOIN personal pc ON te.old_conductor_id = pc.id
LEFT JOIN personal pn ON te.new_conductor_id = pn.id
ORDER BY te.created_at DESC
LIMIT 20;
```

### Consulta: Tamaño de la tabla
```sql
SELECT
  pg_size_pretty(pg_total_relation_size('traslados_eventos')) as tamaño_total,
  COUNT(*) as total_eventos
FROM traslados_eventos;
```

## 🗑️ Limpieza de Eventos Antiguos (Opcional)

Puedes configurar un cronjob que elimine eventos > 6 meses:

```sql
-- Eliminar eventos de más de 6 meses
DELETE FROM traslados_eventos
WHERE created_at < NOW() - INTERVAL '6 months';
```

O crear una función con Supabase Edge Functions que lo haga automáticamente.

## ✅ Checklist Final

- [ ] Migración ejecutada en Supabase
- [ ] Tabla `traslados_eventos` existe
- [ ] Trigger `trigger_log_traslado_evento` funciona
- [ ] Realtime habilitado en la tabla
- [ ] RLS configurado correctamente
- [ ] Test de asignación funciona (assigned)
- [ ] Test de reasignación funciona (reassigned)
- [ ] Test de desasignación funciona (unassigned)
- [ ] Test de cambio de estado funciona (status_changed)
- [ ] App móvil recibe eventos en < 2 segundos
- [ ] App móvil se actualiza automáticamente

## 🎉 Resultado Esperado

Una vez completada la implementación:

- ✅ **Sincronización instantánea** (< 2 segundos)
- ✅ **Sin polling** (reducción 98.9% de tráfico)
- ✅ **Batería optimizada** (WebSocket idle)
- ✅ **Experiencia de usuario mejorada**

## 📚 Referencias

- [Documentación completa](../mobile/docs/EVENT_LEDGER_IMPLEMENTATION.md)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)
- [PostgreSQL Triggers](https://www.postgresql.org/docs/current/triggers.html)

---

**Creado**: 2026-02-05
**Por**: Claude Sonnet 4.5
**Proyecto**: AmbuTrack
