# Diagnóstico: Notificaciones Móvil no aparecen en Web

**Fecha:** 2026-02-09
**Problema:** Las notificaciones creadas desde la app móvil no aparecen en la aplicación web
**Project ID:** ycmopmnrhrpnnzkvnihr

---

## 🔍 Análisis del Código

### 1. Estructura de la Tabla `tnotificaciones`

Según el script SQL (`docs/database/notificaciones_table.sql`), la tabla tiene esta estructura:

```sql
CREATE TABLE IF NOT EXISTS tnotificaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id TEXT NOT NULL DEFAULT 'ambutrack',
    usuario_destino_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL CHECK (tipo IN (...)),
    titulo TEXT NOT NULL,
    mensaje TEXT NOT NULL,
    entidad_tipo TEXT,
    entidad_id TEXT,
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_lectura TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 2. Configuración Realtime

El script SQL habilita Realtime correctamente:

```sql
ALTER PUBLICATION supabase_realtime ADD TABLE tnotificaciones;
```

### 3. Implementación del DataSource

El archivo `packages/ambutrack_core/lib/src/datasources/notificaciones/implementations/supabase/supabase_notificaciones_datasource.dart` implementa:

- ✅ **Stream de notificaciones** con `watchNotificaciones(usuarioId)`
- ✅ **Suscripción Realtime** con filtro por `usuario_destino_id`
- ✅ **Carga inicial de datos** antes del stream

```dart
_channel!.onPostgresChanges(
  event: PostgresChangeEvent.all,
  schema: 'public',
  table: _tableName,
  filter: PostgresChangeFilter(
    type: PostgresChangeFilterType.eq,
    column: 'usuario_destino_id',
    value: usuarioId,
  ),
  callback: (payload) {
    // Manejo de eventos INSERT, UPDATE, DELETE
  },
).subscribe();
```

### 4. Implementación del BLoC

El BLoC en `lib/features/notificaciones/presentation/bloc/notificacion_bloc.dart`:

- ✅ Se suscribe al stream del repositorio
- ✅ Maneja eventos de actualización
- ✅ Carga datos iniciales

---

## 🐛 Posibles Causas del Problema

### 1. **Usuario ID Diferente** ⚠️ MÁS PROBABLE

Las notificaciones se crean con un `usuario_destino_id` específico. Si el usuario en la app móvil y el usuario en la web tienen IDs diferentes, las notificaciones no aparecerán.

**Verificación necesaria:**
```sql
-- Verificar usuarios en auth.users
SELECT id, email, created_at FROM auth.users;

-- Verificar correspondencia en tpersonal
SELECT id, usuario_id, email, nombre, apellidos FROM tpersonal;
```

**Diagnóstico:**
- La app móvil puede estar creando notificaciones con un UUID incorrecto
- La app web puede estar suscrita a un UUID diferente

### 2. **Tabla no Creada o Realtime no Habilitado**

El script SQL puede no haberse ejecutado completamente.

**Verificación en Supabase Dashboard:**
```sql
-- Verificar que la tabla existe
SELECT * FROM information_schema.tables WHERE table_name = 'tnotificaciones';

-- Verificar datos en la tabla
SELECT COUNT(*) FROM tnotificaciones;

-- Verificar que Realtime está habilitado
SELECT * FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
AND tablename = 'tnotificaciones';
```

### 3. **Políticas RLS Restrictivas**

Las políticas RLS pueden estar bloqueando el acceso.

**Políticas actuales:**
- ✅ Usuarios pueden ver sus propias notificaciones
- ✅ Admins/jefes pueden ver todas
- ❌ **Posible problema:** Si el usuario no tiene registro en `tpersonal`, las queries fallarán

**Verificación:**
```sql
-- Verificar políticas RLS
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'tnotificaciones';
```

### 4. **Problema de Autenticación**

El usuario en la web puede no estar autenticado correctamente, causando que `auth.uid()` retorne `NULL`.

**Verificación en consola del navegador:**
```javascript
// En la consola de DevTools
supabase.auth.getUser()
```

### 5. **Suscripción Realtime no Funciona**

El canal de Realtime puede no estar conectándose correctamente.

**Síntomas:**
- Las notificaciones aparecen al recargar la página
- Pero no aparecen en tiempo real cuando se crean desde el móvil

---

## 📋 Plan de Diagnóstico

### Paso 1: Verificar Existencia de Datos

Ejecutar en Supabase SQL Editor:

```sql
-- 1. Verificar si hay notificaciones
SELECT
    id,
    empresa_id,
    usuario_destino_id,
    tipo,
    titulo,
    leida,
    created_at
FROM tnotificaciones
ORDER BY created_at DESC
LIMIT 20;

-- 2. Contar notificaciones por usuario
SELECT
    usuario_destino_id,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE leida = false) as no_leidas
FROM tnotificaciones
GROUP BY usuario_destino_id;
```

**Si no hay datos:** El problema es que la app móvil no está creando notificaciones correctamente.

**Si hay datos:** El problema está en la visualización en la web.

### Paso 2: Verificar Realtime

```sql
-- Verificar publicación realtime
SELECT * FROM pg_publication_tables
WHERE pubname = 'supabase_realtime';

-- Debe incluir tnotificaciones
```

### Paso 3: Verificar Usuario Autenticado

En la aplicación web, abrir DevTools → Console:

```javascript
// Verificar usuario autenticado
const { data: { user } } = await supabase.auth.getUser();
console.log('Usuario autenticado:', user);

// Verificar ID del usuario
console.log('User ID:', user?.id);
```

Luego comparar con los `usuario_destino_id` de las notificaciones.

### Paso 4: Verificar Conexión Realtime en el DataSource

Agregar logs adicionales en `supabase_notificaciones_datasource.dart`:

```dart
@override
Stream<List<NotificacionEntity>> watchNotificaciones(String usuarioId) {
  debugPrint('🔔 DataSource: Suscribiendo a realtime para usuario $usuarioId');
  debugPrint('🔔 DataSource: Tabla $_tableName');

  _channel = _client.channel("notificaciones:$usuarioId");

  _channel!.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: _tableName,
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'usuario_destino_id',
      value: usuarioId,
    ),
    callback: (payload) {
      debugPrint('🔔 DataSource: Evento recibido: ${payload.eventType}');
      debugPrint('🔔 DataSource: Payload: ${payload.newRecord}');
      // ... resto del código
    },
  ).subscribe((status) {
    debugPrint('🔔 DataSource: Status de suscripción: $status');
  });

  return _notificacionesController.stream;
}
```

### Paso 5: Verificar Política RLS para el Usuario

```sql
-- Verificar si el usuario tiene permiso de lectura
-- Reemplazar YOUR_USER_ID con el ID real
SELECT
    auth.uid() as current_user_id,
    EXISTS (
        SELECT 1 FROM tpersonal
        WHERE usuario_id = auth.uid()
        AND categoria IN ('admin', 'jefe_personal', 'jefe_trafico')
    ) as is_admin,
    EXISTS (
        SELECT 1 FROM tpersonal
        WHERE usuario_id = auth.uid()
    ) as exists_in_personal;
```

---

## 🔧 Soluciones Propuestas

### Solución 1: Verificar Usuario ID en App Móvil

Asegurar que la app móvil esté usando el mismo `usuario_destino_id` que la web.

**En la app móvil:**
```dart
// Verificar que se está usando el ID correcto
final user = supabase.auth.currentUser;
final userId = user?.id; // Este debe coincidir con tpersonal.usuario_id

// Al crear notificación
final notificacion = NotificacionEntity(
  usuarioDestinoId: userId, // Debe ser el ID del usuario auth
  // ...
);
```

### Solución 2: Añadir Logs de Depuración

Añadir logs para rastrear el flujo completo:

1. **En el móvil:** Log cuando se crea la notificación
2. **En Supabase:** Verificar que el INSERT llega a la base de datos
3. **En el web:** Log cuando se recibe el evento Realtime

### Solución 3: Verificar Configuración de Empresa

El repository usa `empresaId: 'ambutrack'` hardcodeado:

```dart
// lib/features/notificaciones/data/repositories/notificaciones_repository_impl.dart
NotificacionesRepositoryImpl() : _dataSource = NotificacionesDataSourceFactory.createSupabase(
  empresaId: 'ambutrack',
);
```

Asegurar que las notificaciones creadas desde el móvil también tengan `empresa_id = 'ambutrack'`.

### Solución 4: Suscribirse a Todos los Eventos Temporalmente

Para diagnosticar, cambiar el filtro Realtemporal temporalmente:

```dart
// SIN FILTRO - para ver todos los eventos
_channel!.onPostgresChanges(
  event: PostgresChangeEvent.all,
  schema: 'public',
  table: _tableName,
  // Quitar el filtro temporalmente
  callback: (payload) {
    debugPrint('🔔 Evento recibido (sin filtro): ${payload.eventType}');
    debugPrint('🔔 Payload: ${payload.newRecord}');
  },
).subscribe();
```

Si con esto se reciben eventos, el problema está en el filtro por `usuario_destino_id`.

---

## ✅ Checklist de Verificación

- [ ] La tabla `tnotificaciones` existe en Supabase
- [ ] La tabla tiene datos (creados desde el móvil)
- [ ] Realtime está habilitado para `tnotificaciones`
- [ ] El usuario en la web está autenticado
- [ ] El `usuario_destino_id` de las notificaciones coincide con el ID del usuario auth en la web
- [ ] Las políticas RLS permiten la lectura
- [ ] El BLoC está suscrito al stream
- [ ] El canal Realtime está conectado (status = 'subscribed')

---

## 🚀 Próximos Pasos

1. **Ejecutar las queries de diagnóstico** en Supabase SQL Editor
2. **Verificar los logs** en la consola del navegador (web) y en el móvil
3. **Comparar IDs de usuario** entre móvil y web
4. **Probar sin filtro Realtime** para confirmar conexión
5. **Revisar código de la app móvil** para verificar cómo crea notificaciones

---

**Documento creado para diagnóstico del problema de notificaciones entre móvil y web.**
