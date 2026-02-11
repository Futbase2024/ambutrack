# 🔧 Sistema de Notificaciones - RLS y Manejo de Errores

## ✅ Estado Actual

Las políticas RLS (Row Level Security) están **correctamente configuradas** en Supabase.

### Políticas Activas:
- ✅ `select_own_notifications` (SELECT) - Ver notificaciones propias
- ✅ `update_own_notifications` (UPDATE) - Actualizar notificaciones propias
- ✅ `delete_own_notifications` (DELETE) - Eliminar notificaciones propias

### Validación de Autenticación

El sistema ahora verifica automáticamente:
- **Autenticación del usuario** antes de cada operación
- **Permisos RLS** en tiempo real
- **Mensajes de error claros** cuando hay problemas de permisos

## ✅ Verificación de Políticas RLS

Para verificar que las políticas están activas en Supabase:

### Opción 1: Supabase Dashboard

1. **Abrir Supabase Dashboard**
   - URL: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr
   - Ir a: `Authentication` → `Policies`

2. **Buscar tabla**: `tnotificaciones`

3. **Verificar políticas activas**:
   - ✅ `select_own_notifications` (SELECT)
   - ✅ `update_own_notifications` (UPDATE)
   - ✅ `delete_own_notifications` (DELETE)

### Opción 2: SQL Editor

```sql
-- Ver todas las políticas de la tabla
SELECT
    policyname,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'tnotificaciones'
ORDER BY cmd, policyname;

-- Verificar que RLS está habilitado
SELECT
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename = 'tnotificaciones';
```

## 📋 Políticas RLS Configuradas

Las siguientes políticas están activas y funcionando correctamente:

### 1. SELECT - Ver notificaciones propias
```sql
CREATE POLICY "select_own_notifications"
ON tnotificaciones FOR SELECT
TO public
USING (auth.uid() = usuario_destino_id);
```
✅ Permite ver solo las notificaciones donde el usuario es el destinatario

### 2. UPDATE - Actualizar notificaciones propias
```sql
CREATE POLICY "update_own_notifications"
ON tnotificaciones FOR UPDATE
TO public
USING (auth.uid() = usuario_destino_id)
WITH CHECK (auth.uid() = usuario_destino_id);
```
✅ Permite marcar como leídas solo las notificaciones propias

### 3. DELETE - Eliminar notificaciones propias
```sql
CREATE POLICY "delete_own_notifications"
ON tnotificaciones FOR DELETE
TO public
USING (auth.uid() = usuario_destino_id);
```
✅ Permite eliminar solo las notificaciones propias

## 🧪 Funcionamiento del Sistema

### 1. **Validación de Autenticación**

Antes de cada operación, el sistema verifica:
```dart
final currentUser = _client.auth.currentUser;
if (currentUser == null) {
  throw DataSourceException(
    message: 'Usuario no autenticado',
    code: 'UNAUTHENTICATED',
  );
}
```

### 2. **Logging Detallado**

El datasource registra cada operación:
```
🗑️ delete - Eliminando notificación ID: xxx
🗑️ delete - Usuario autenticado: yyy
✅ delete - Eliminada correctamente
```

O en caso de error:
```
❌ delete - Usuario no autenticado
⚠️ delete - No se eliminó ninguna fila. Posible problema de permisos RLS.
```

### 3. **Diálogos Profesionales de Error**

Cuando ocurre un error RLS, el usuario ve un diálogo profesional con:
- Icono según tipo de error (🔒 sesión expirada, 🛡️ sin permisos, ⚠️ error genérico)
- Título descriptivo
- Mensaje claro del problema
- Botón "Entendido" para cerrar y recargar

### 4. **Recarga Automática**

Al cerrar un diálogo de error, el sistema automáticamente:
- Recarga las notificaciones
- Sincroniza el estado
- Permite reintentar la operación

## 🔍 Diagnóstico de Problemas Comunes

### Problema: "Usuario no autenticado"

**Causa**: La sesión de Supabase expiró o no existe.

**Solución**:
1. Verificar que el usuario inició sesión
2. Revisar token de autenticación: `Supabase.instance.client.auth.currentUser`
3. Forzar re-login si es necesario

### Problema: "No tienes permisos"

**Causa**: La notificación pertenece a otro usuario o las políticas RLS bloquearon la operación.

**Logs a verificar**:
```
🗑️ delete - Usuario autenticado: user_id_1
⚠️ delete - No se eliminó ninguna fila
```

**Verificación en Supabase**:
```sql
-- Verificar que usuario_destino_id coincide con auth.uid()
SELECT id, usuario_destino_id
FROM tnotificaciones
WHERE id = 'notification_id';

-- Verificar usuario actual
SELECT auth.uid();
```

### Problema: "0 filas afectadas"

**Causa**: Las políticas RLS están bloqueando la operación porque:
- El `usuario_destino_id` no coincide con `auth.uid()`
- La notificación no existe
- Falta el contexto de autenticación en la request

**Solución**:
1. Verificar logs del datasource
2. Confirmar que `currentUser` no es null
3. Verificar que la notificación existe y pertenece al usuario
4. Revisar políticas RLS en Supabase Dashboard

## 📚 Referencias

- **Tabla**: `tnotificaciones`
- **Proyecto Supabase**: `ycmopmnrhrpnnzkvnihr`
- **Documentación RLS**: https://supabase.com/docs/guides/auth/row-level-security
- **Código DataSource**: `packages/ambutrack_core/lib/src/datasources/notificaciones/implementations/supabase/`
- **Código BLoC**: `apps/web/lib/features/notificaciones/presentation/bloc/`

## 🛠️ Archivos Modificados

### DataSource (Core Package)
- ✅ Agregada validación de autenticación en todas las operaciones
- ✅ Mejorado logging con detalles del usuario autenticado
- ✅ Errores específicos con códigos (`UNAUTHENTICATED`, `RLS_BLOCKED`)
- ✅ Método `.select()` en delete/update para verificar filas afectadas

### BLoC (App)
- ✅ Manejo de errores específicos de RLS
- ✅ Mensajes de error traducidos y claros
- ✅ Logging mejorado con emojis para facilitar debugging

### UI (Notificaciones Panel)
- ✅ BlocConsumer para escuchar errores
- ✅ Diálogos profesionales Material 3
- ✅ Iconos contextuales según tipo de error
- ✅ Recarga automática después de error

---

**Última actualización**: 2026-02-11
**Estado**: ✅ Sistema funcional con validación RLS completa
