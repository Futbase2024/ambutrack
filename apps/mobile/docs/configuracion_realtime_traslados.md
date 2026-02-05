# 🔄 Configuración de Sincronización en Tiempo Real - Traslados

## 📋 Resumen

Este documento explica cómo configurar la sincronización en tiempo real entre **ambutrack_web** (donde se asignan traslados) y **ambutrack_mobile** (donde los conductores reciben los traslados).

## ✅ Estado Actual

### ✅ Ya Implementado en ambutrack_mobile

1. **DataSource con Supabase Realtime**
   - Archivo: `lib/core/datasources/traslados/implementations/supabase_traslados_datasource.dart`
   - Método: `watchActivosByIdConductor()` (línea 321-344)
   - Usa: `_client.from('traslados').stream(primaryKey: ['id'])`

2. **BLoC con manejo de streams**
   - Archivo: `lib/features/servicios/presentation/bloc/traslados_bloc.dart`
   - Evento: `IniciarStreamTrasladosActivos` (línea 129-159)
   - Maneja actualizaciones automáticas del stream

3. **UI con BlocBuilder**
   - Archivo: `lib/features/servicios/presentation/pages/servicios_page.dart`
   - Se inicia el stream automáticamente al crear el BLoC (línea 31)

## 🔧 Configuración Requerida

### 1. ✅ Habilitar Realtime en Supabase

**Opción A: Dashboard de Supabase**
```
1. Ve a https://supabase.com/dashboard/project/[tu-proyecto]
2. Navega a: Database → Replication
3. Busca la tabla "traslados"
4. Activa el toggle de "Realtime"
5. Haz clic en "Save"
```

**Opción B: SQL (Recomendado para producción)**
```sql
-- Habilitar Realtime para la tabla traslados
ALTER PUBLICATION supabase_realtime ADD TABLE traslados;

-- Verificar que está habilitado
SELECT tablename
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime';
```

### 2. ✅ Configurar Row Level Security (RLS)

Las políticas RLS determinan qué traslados puede ver cada conductor.

```sql
-- ============================================================================
-- POLÍTICAS RLS PARA TRASLADOS
-- ============================================================================

-- 1. Política para que conductores LEAN sus traslados asignados
CREATE POLICY "conductores_leen_sus_traslados"
ON traslados
FOR SELECT
TO authenticated
USING (
  -- Caso 1: El id_conductor es directamente el usuario autenticado
  id_conductor = auth.uid()
  OR
  -- Caso 2: El id_conductor es un registro de tpersonal vinculado al usuario
  id_conductor IN (
    SELECT id
    FROM tpersonal
    WHERE id_usuario = auth.uid()
  )
);

-- 2. Política para que conductores ACTUALICEN el estado de sus traslados
CREATE POLICY "conductores_actualizan_estado_traslados"
ON traslados
FOR UPDATE
TO authenticated
USING (
  id_conductor = auth.uid()
  OR
  id_conductor IN (
    SELECT id FROM tpersonal WHERE id_usuario = auth.uid()
  )
)
WITH CHECK (
  -- Solo pueden modificar ciertos campos (estado, ubicaciones, fechas)
  -- Los campos críticos como id_paciente, origen, destino no pueden cambiar
  id_conductor = auth.uid()
  OR
  id_conductor IN (
    SELECT id FROM tpersonal WHERE id_usuario = auth.uid()
  )
);

-- 3. Política para que administradores/web LEAN todos los traslados
CREATE POLICY "admin_leen_todos_traslados"
ON traslados
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM tpersonal
    WHERE id_usuario = auth.uid()
    AND rol IN ('admin', 'coordinador', 'supervisor')
  )
);

-- 4. Política para que administradores/web CREEN traslados
CREATE POLICY "admin_crean_traslados"
ON traslados
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM tpersonal
    WHERE id_usuario = auth.uid()
    AND rol IN ('admin', 'coordinador', 'supervisor')
  )
);

-- 5. Política para que administradores/web ACTUALICEN traslados
CREATE POLICY "admin_actualizan_traslados"
ON traslados
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM tpersonal
    WHERE id_usuario = auth.uid()
    AND rol IN ('admin', 'coordinador', 'supervisor')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM tpersonal
    WHERE id_usuario = auth.uid()
    AND rol IN ('admin', 'coordinador', 'supervisor')
  )
);
```

### 3. ✅ Verificar Índices para Performance

Los índices mejoran el rendimiento de las queries en tiempo real:

```sql
-- Índice para filtrar por conductor
CREATE INDEX IF NOT EXISTS idx_traslados_id_conductor
ON traslados(id_conductor);

-- Índice para filtrar por estado
CREATE INDEX IF NOT EXISTS idx_traslados_estado
ON traslados(estado);

-- Índice compuesto para queries comunes
CREATE INDEX IF NOT EXISTS idx_traslados_conductor_fecha
ON traslados(id_conductor, fecha DESC, hora_programada DESC);

-- Índice para traslados activos
CREATE INDEX IF NOT EXISTS idx_traslados_activos
ON traslados(id_conductor, estado)
WHERE estado NOT IN ('finalizado', 'cancelado', 'no_realizado', 'suspendido');
```

### 4. ✅ Verificar tablas relacionadas

Si usas joins en el stream, también necesitas habilitar Realtime para esas tablas:

```sql
-- Habilitar Realtime para tablas relacionadas
ALTER PUBLICATION supabase_realtime ADD TABLE pacientes;
ALTER PUBLICATION supabase_realtime ADD TABLE tpersonal;
```

## 🧪 Cómo Probar

### Test 1: Asignación de nuevo traslado

1. **En ambutrack_web:**
   - Crea un nuevo traslado
   - Asigna un conductor (`id_conductor = 'xxx'`)
   - Asigna un vehículo (`id_vehiculo = 'yyy'`)
   - Guarda el traslado

2. **En ambutrack_mobile:**
   - Abre la app con el conductor asignado
   - Ve a "Mis Servicios"
   - El traslado debería aparecer **automáticamente sin refrescar**

### Test 2: Cambio de estado

1. **En ambutrack_web:**
   - Cambia el estado de un traslado (ej: de "Pendiente" a "Asignado")

2. **En ambutrack_mobile:**
   - El badge del traslado debería actualizarse **en tiempo real**

### Test 3: Reasignación de conductor

1. **En ambutrack_web:**
   - Reasigna un traslado a otro conductor

2. **En ambutrack_mobile:**
   - El traslado debería **desaparecer** de la lista del conductor anterior
   - Y **aparecer** en la lista del nuevo conductor

## 🐛 Troubleshooting

### Problema: Los traslados no aparecen en mobile

**Posibles causas:**

1. ✅ **Realtime no habilitado**
   ```sql
   -- Verificar si Realtime está habilitado
   SELECT tablename
   FROM pg_publication_tables
   WHERE pubname = 'supabase_realtime'
   AND tablename = 'traslados';
   -- Debe devolver 1 fila
   ```

2. ✅ **RLS bloqueando acceso**
   ```sql
   -- Verificar políticas RLS
   SELECT * FROM pg_policies WHERE tablename = 'traslados';

   -- Probar query directa (como lo haría el stream)
   SELECT * FROM traslados WHERE id_conductor = 'xxx';
   ```

3. ✅ **Campo `personal` es null en AuthState**
   ```dart
   // En ServiciosPage, agregar debug:
   final authState = context.read<AuthBloc>().state;
   if (authState is AuthAuthenticated) {
     debugPrint('🔍 User ID: ${authState.user.id}');
     debugPrint('🔍 Personal: ${authState.personal}');
     debugPrint('🔍 Personal ID: ${authState.personal?.id}');
   }
   ```

4. ✅ **Error en el stream**
   - Revisa los logs en el datasource (línea 342 en `supabase_traslados_datasource.dart`)
   - Verifica que no haya errores de serialización JSON

### Problema: El stream se desconecta

**Solución:**
```dart
// El BLoC ya maneja reconexión automática en el método _onIniciarStreamTrasladosActivos
// Si el stream falla, emite RefrescarTraslados
```

### Problema: Alto consumo de batería

**Optimización:**
```dart
// El stream ya está optimizado:
// 1. Solo escucha traslados del conductor actual
// 2. Filtra por estados activos
// 3. Se cancela automáticamente cuando se cierra el BLoC (línea 232-235)
```

## 📊 Métricas y Monitoreo

### Logs importantes

```dart
// En supabase_traslados_datasource.dart
📡 [TrasladosDataSource] Iniciando stream de traslados activos
📡 [TrasladosDataSource] Stream actualizado: X traslados activos

// En traslados_bloc.dart
🎯 [TrasladosBloc] Iniciando stream de traslados activos
📡 [TrasladosBloc] Stream actualizado: X traslados
🔄 [TrasladosBloc] Actualizando desde stream
✅ [TrasladosBloc] Estado actualizado desde stream
```

### Verificar en Supabase Dashboard

1. Ve a "Logs" → "Realtime"
2. Deberías ver conexiones activas de clientes
3. Cada vez que cambies un traslado, verás un evento broadcast

## 🔐 Seguridad

### Importante

- ✅ Las políticas RLS aseguran que cada conductor solo vea sus propios traslados
- ✅ No es posible que un conductor vea traslados de otros conductores
- ✅ Los cambios de estado se validan en el servidor mediante RLS
- ✅ Los tokens JWT se verifican automáticamente por Supabase

### Mejores prácticas

```sql
-- Auditoría: Registrar cambios en traslados
CREATE TABLE IF NOT EXISTS traslados_audit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_traslado UUID NOT NULL REFERENCES traslados(id),
  campo_modificado TEXT NOT NULL,
  valor_anterior TEXT,
  valor_nuevo TEXT,
  modificado_por UUID REFERENCES auth.users(id),
  modificado_en TIMESTAMPTZ DEFAULT now()
);

-- Trigger para auditar cambios
CREATE OR REPLACE FUNCTION audit_traslados_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    -- Auditar solo cambios importantes
    IF OLD.estado IS DISTINCT FROM NEW.estado THEN
      INSERT INTO traslados_audit (id_traslado, campo_modificado, valor_anterior, valor_nuevo, modificado_por)
      VALUES (NEW.id, 'estado', OLD.estado::text, NEW.estado::text, auth.uid());
    END IF;

    IF OLD.id_conductor IS DISTINCT FROM NEW.id_conductor THEN
      INSERT INTO traslados_audit (id_traslado, campo_modificado, valor_anterior, valor_nuevo, modificado_por)
      VALUES (NEW.id, 'id_conductor', OLD.id_conductor::text, NEW.id_conductor::text, auth.uid());
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER audit_traslados_trigger
AFTER UPDATE ON traslados
FOR EACH ROW
EXECUTE FUNCTION audit_traslados_changes();
```

## ✅ Checklist de Implementación

- [ ] Habilitar Realtime en tabla `traslados`
- [ ] Habilitar Realtime en tabla `pacientes` (para joins)
- [ ] Habilitar Realtime en tabla `tpersonal` (para joins)
- [ ] Crear políticas RLS para conductores
- [ ] Crear políticas RLS para administradores
- [ ] Crear índices de performance
- [ ] Probar asignación de traslado desde web
- [ ] Probar cambio de estado desde web
- [ ] Probar reasignación de conductor
- [ ] Verificar logs en mobile
- [ ] Verificar logs en Supabase Dashboard
- [ ] (Opcional) Configurar auditoría de cambios

## 📚 Referencias

- **Supabase Realtime Docs**: https://supabase.com/docs/guides/realtime
- **Código mobile**:
  - DataSource: `lib/core/datasources/traslados/implementations/supabase_traslados_datasource.dart`
  - BLoC: `lib/features/servicios/presentation/bloc/traslados_bloc.dart`
  - UI: `lib/features/servicios/presentation/pages/servicios_page.dart`
