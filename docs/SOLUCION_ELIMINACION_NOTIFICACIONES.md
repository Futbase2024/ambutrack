# Solución: Eliminación de Notificaciones

## 🔴 Problema Identificado

Las notificaciones **NO se eliminan** porque faltan las **políticas RLS (Row Level Security)** en Supabase para la tabla `tnotificaciones`.

### ¿Por qué sucede esto?

Supabase tiene RLS activado en la tabla, lo que significa que **TODAS las operaciones (SELECT, INSERT, UPDATE, DELETE) requieren políticas explícitas**. Sin estas políticas, aunque el código funcione correctamente, Supabase bloquea las operaciones por seguridad.

---

## ✅ Solución: Aplicar Políticas RLS

### Paso 1: Abrir Supabase Dashboard

1. Ve a [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Selecciona tu proyecto de AmbuTrack
3. En el menú lateral, ve a **SQL Editor**

### Paso 2: Ejecutar Script SQL

Copia y pega el siguiente script SQL en el editor:

```sql
-- ========================================
-- POLÍTICAS RLS PARA TABLA tnotificaciones
-- ========================================

-- 1. Eliminar políticas antiguas
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propias notificaciones" ON tnotificaciones;
DROP POLICY IF EXISTS "delete_own_notifications" ON tnotificaciones;
DROP POLICY IF EXISTS "select_own_notifications" ON tnotificaciones;
DROP POLICY IF EXISTS "update_own_notifications" ON tnotificaciones;
DROP POLICY IF EXISTS "insert_notifications" ON tnotificaciones;

-- 2. Crear política para SELECT (leer notificaciones)
CREATE POLICY "select_own_notifications"
ON tnotificaciones
FOR SELECT
USING (
  auth.uid() = usuario_destino_id
);

-- 3. Crear política para UPDATE (marcar como leída)
CREATE POLICY "update_own_notifications"
ON tnotificaciones
FOR UPDATE
USING (
  auth.uid() = usuario_destino_id
)
WITH CHECK (
  auth.uid() = usuario_destino_id
);

-- 4. Crear política para DELETE (eliminar notificaciones) ⭐ CRÍTICO
CREATE POLICY "delete_own_notifications"
ON tnotificaciones
FOR DELETE
USING (
  auth.uid() = usuario_destino_id
);

-- 5. Crear política para INSERT (crear notificaciones)
CREATE POLICY "insert_notifications"
ON tnotificaciones
FOR INSERT
WITH CHECK (
  true -- Permitir a todos insertar (ajustar según necesidades)
);

-- 6. Habilitar RLS en la tabla
ALTER TABLE tnotificaciones ENABLE ROW LEVEL SECURITY;
```

### Paso 3: Ejecutar el Script

1. Haz clic en el botón **"Run"** (▶️) en la esquina inferior derecha
2. Deberías ver el mensaje: **"Success. No rows returned"**
3. ✅ ¡Listo! Las políticas están aplicadas

---

## 🔍 Verificación

### Opción 1: Verificar en Supabase Dashboard

1. Ve a **Table Editor** → `tnotificaciones`
2. Haz clic en el ícono de **candado** 🔒 junto al nombre de la tabla
3. Deberías ver las 4 políticas creadas:
   - ✅ `select_own_notifications`
   - ✅ `update_own_notifications`
   - ✅ `delete_own_notifications`
   - ✅ `insert_notifications`

### Opción 2: Verificar con SQL

Ejecuta esta query en el SQL Editor:

```sql
SELECT
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'tnotificaciones';
```

Deberías ver las 4 políticas listadas.

---

## 🧪 Prueba de Funcionalidad

### Desde la App Móvil

1. **Abre la app AmbuTrack móvil**
2. **Ve a Notificaciones**
3. **Prueba eliminar una notificación** (swipe o menú)
4. **Verifica en los logs**:
   ```
   🔔 [NotificacionesDataSource] 🗑️ delete - Eliminando notificación ID: xxx
   🔔 [NotificacionesDataSource] 🗑️ delete - Respuesta: 1 filas afectadas
   🔔 [NotificacionesDataSource] ✅ delete - Eliminada correctamente
   ```

### Desde SQL Editor (Manual)

```sql
-- Ver tus notificaciones
SELECT * FROM tnotificaciones WHERE usuario_destino_id = auth.uid();

-- Eliminar una notificación específica
DELETE FROM tnotificaciones
WHERE id = 'ID_DE_NOTIFICACION'
AND usuario_destino_id = auth.uid();

-- Si funciona, verás: "DELETE 1"
```

---

## 📱 Nuevo Menú de Opciones (Mejorado)

El menú de 3 puntos (⋮) ahora es un **Bottom Sheet profesional** con:

### Características:
- ✅ **Diseño moderno**: Bottom sheet con esquinas redondeadas
- ✅ **Iconos con fondos de color**: Cada opción tiene su color distintivo
- ✅ **Handle bar**: Barra superior para arrastrar y cerrar
- ✅ **Subtítulos**: Descripciones claras de cada acción
- ✅ **Responsive**: Se adapta al contenido

### Opciones disponibles:

1. **Marcar todas como leídas** (Verde)
   - Ícono: ✓✓
   - Solo visible si hay notificaciones sin leer
   - Muestra el conteo de no leídas

2. **Seleccionar** (Azul)
   - Ícono: ☑
   - Activa el modo de selección múltiple
   - Permite eliminar varias notificaciones a la vez

3. **Eliminar todas** (Rojo)
   - Ícono: 🗑️
   - Elimina todas las notificaciones
   - Requiere confirmación

---

## 🎯 Funcionalidades Completas

### 1. Eliminar Una Notificación
- **Método**: Swipe hacia la izquierda
- **Confirmación**: Diálogo de confirmación
- **Feedback**: SnackBar "Notificación eliminada"

### 2. Modo Selección Múltiple
- **Activar**: Menú → "Seleccionar"
- **UI**: Checkboxes al lado de cada notificación
- **AppBar**: Muestra "X seleccionadas"
- **Acciones**:
  - Botón "Seleccionar todo" / "Deseleccionar todo"
  - FAB rojo para eliminar seleccionadas
  - Botón X para salir del modo selección

### 3. Eliminar Todas
- **Método**: Menú → "Eliminar todas"
- **Confirmación**: Diálogo con advertencia
- **Efecto**: Elimina TODAS las notificaciones del usuario

---

## 🐛 Debugging

### Si sigue sin funcionar:

1. **Verifica que las políticas existen**:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'tnotificaciones';
   ```

2. **Verifica que RLS está habilitado**:
   ```sql
   SELECT tablename, rowsecurity
   FROM pg_tables
   WHERE tablename = 'tnotificaciones';
   ```
   Debe mostrar `rowsecurity = true`

3. **Revisa los logs de la app**:
   - Busca líneas con `🔔 [NotificacionesDataSource]`
   - Si dice "0 filas afectadas" → Problema de RLS
   - Si dice "1 filas afectadas" → ✅ Funciona

4. **Verifica el usuario autenticado**:
   ```sql
   SELECT auth.uid(); -- No debe ser NULL
   ```

---

## 📊 Estructura de Archivos Modificados

```
packages/ambutrack_core/
└── lib/src/datasources/notificaciones/
    ├── notificaciones_contract.dart          ✅ Métodos deleteAll, deleteMultiple
    └── implementations/supabase/
        ├── supabase_notificaciones_datasource.dart        ✅ Logs de debug
        └── supabase_notificaciones_datasource_debug.dart  ✅ Métodos nuevos

apps/mobile/
└── lib/features/notificaciones/
    ├── domain/repositories/
    │   └── notificaciones_repository.dart         ✅ Métodos eliminarTodas, eliminarSeleccionadas
    ├── data/repositories/
    │   └── notificaciones_repository_impl.dart    ✅ Implementaciones
    ├── presentation/
    │   ├── bloc/
    │   │   ├── notificaciones_bloc.dart           ✅ Handlers de eliminación
    │   │   └── notificaciones_event.dart          ✅ Eventos nuevos
    │   ├── pages/
    │   │   └── notificaciones_page.dart           ✅ Menú bottom sheet + modo selección
    │   └── widgets/
    │       └── notificacion_card.dart             ✅ Soporte modo selección

docs/
└── database/
    └── notificaciones_rls_policies.sql            ✅ Script SQL completo
```

---

## 🎉 Resultado Final

Después de aplicar las políticas RLS:

✅ **Eliminar una notificación** → Swipe funciona perfectamente
✅ **Eliminar múltiples** → Modo selección con checkboxes
✅ **Eliminar todas** → Opción en menú con confirmación
✅ **Menú profesional** → Bottom sheet moderno y claro
✅ **Logs detallados** → Debugging fácil con logs de cada operación
✅ **Sin errores** → `flutter analyze` sin issues

---

## 📞 Soporte

Si después de aplicar las políticas RLS sigues teniendo problemas:

1. **Verifica los logs** en la consola de la app
2. **Revisa Supabase Dashboard** → Logs → Busca errores de RLS
3. **Contacta al equipo** con los logs completos

---

**Fecha**: 2026-02-10
**Versión**: 1.0
**Estado**: ✅ Listo para producción
