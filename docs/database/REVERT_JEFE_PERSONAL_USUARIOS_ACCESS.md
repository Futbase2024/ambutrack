# Revert: Acceso de Jefe de Personal a gestión de usuarios

**Fecha:** 2026-02-12
**Proyecto:** AmbuTrack Web
**Supabase Project ID:** ycmopmnrhrpnnzkvnihr
**Migración:** `revert_jefe_personal_usuarios_access` (aplicada vía MCP)

---

## 📋 Contexto

### ❌ Error cometido:
Se aplicó una migración que permitía al rol `jefe_personal` gestionar usuarios, bajo la suposición incorrecta de que este rol necesitaba ese acceso.

### ✅ Comportamiento correcto:
**Solo el rol `admin` debe gestionar usuarios** (crear, editar, eliminar cuentas y asignar roles).

El rol `jefe_personal` gestiona **personal** (empleados en la tabla `personal`), NO **usuarios** (cuentas del sistema en la tabla `usuarios`).

---

## 🔴 Problema

### Migración incorrecta aplicada:
```sql
-- ❌ INCORRECTO
CREATE FUNCTION is_manager()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN get_current_user_role() IN ('admin', 'jefe_personal');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE POLICY "Managers can view all users"
  ON usuarios FOR SELECT
  TO authenticated
  USING (is_manager());  -- ❌ Permitía a jefe_personal ver todos los usuarios
```

### Consecuencias del error:
- ✅ `jefe_personal` podía ver todos los usuarios del sistema
- ✅ `jefe_personal` podía crear/editar/eliminar usuarios
- ❌ Violaba el principio de mínimo privilegio
- ❌ Inconsistente con los permisos de la aplicación Flutter

---

## ✅ Solución: Reversión

### Estrategia:
Restaurar las políticas RLS originales que **solo permiten a `admin` gestionar usuarios**.

### Políticas restauradas:

```sql
-- ✅ CORRECTO: Solo admin puede gestionar usuarios
CREATE POLICY "Admin can view all users"
  ON usuarios FOR SELECT
  TO authenticated
  USING (is_admin());  -- ✅ Solo 'admin'

CREATE POLICY "Admin can insert users"
  ON usuarios FOR INSERT
  TO authenticated
  WITH CHECK (is_admin());

CREATE POLICY "Admin can update users"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (is_admin());

CREATE POLICY "Admin can delete users"
  ON usuarios FOR DELETE
  TO authenticated
  USING (is_admin());

-- Políticas de usuarios regulares (sin cambios)
CREATE POLICY "Users can view their own data"
  ON usuarios FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Users can update their own data"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (
    id = auth.uid() AND
    rol = get_current_user_role()
  );
```

---

## 📦 Archivos modificados

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| Migración vía MCP | `revert_jefe_personal_usuarios_access` | ✅ Aplicada |
| `FIX_RLS_JEFE_PERSONAL_USUARIOS.md` | Documento original (marcado como revertido) | ⚠️ Obsoleto |
| `REVERT_JEFE_PERSONAL_USUARIOS_ACCESS.md` | Este documento | ✅ Vigente |
| `007_revert_jefe_personal_usuarios_access.sql` | Migración local | ✅ Creado |

---

## 🧪 Testing

### 1. Como usuario admin:
```sql
SELECT * FROM usuarios;
-- ✅ PASS: Retorna todos los usuarios
```

### 2. Como usuario jefe_personal:
```sql
SELECT * FROM usuarios;
-- ✅ PASS: Retorna SOLO su propio registro (id = auth.uid())
```

### 3. Como usuario regular (conductor, sanitario, etc.):
```sql
SELECT * FROM usuarios;
-- ✅ PASS: Retorna solo su propio registro
```

### 4. Verificar políticas aplicadas:
```sql
SELECT
  policyname,
  cmd,
  qual AS using_clause
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'usuarios'
ORDER BY policyname;
```

**Output esperado:**
```
policyname                        | cmd    | using_clause
----------------------------------+--------+-------------
Admin can delete users            | DELETE | is_admin()
Admin can insert users            | INSERT |
Admin can update users            | UPDATE | is_admin()
Admin can view all users          | SELECT | is_admin()
Users can update their own data   | UPDATE | (id = auth.uid())
Users can view their own data     | SELECT | (id = auth.uid())
```

---

## 📊 Matriz de Permisos Correcta

| Rol | Ver todos usuarios | Crear usuarios | Editar usuarios | Eliminar usuarios |
|-----|-------------------|----------------|-----------------|-------------------|
| `admin` | ✅ Sí | ✅ Sí | ✅ Sí | ✅ Sí |
| `jefe_personal` | ❌ No (solo su registro) | ❌ No | ❌ No (solo su registro) | ❌ No |
| `jefe_trafic` | ❌ No (solo su registro) | ❌ No | ❌ No (solo su registro) | ❌ No |
| Otros roles | ❌ No (solo su registro) | ❌ No | ❌ No (solo su registro) | ❌ No |

---

## 🔒 Separación de responsabilidades

### Tabla `usuarios` (gestión de cuentas del sistema)
- **Quién:** Solo `admin`
- **Qué:** Crear cuentas, asignar roles, gestionar accesos
- **Por qué:** Control centralizado de seguridad

### Tabla `personal` (gestión de empleados)
- **Quién:** `admin` y `jefe_personal`
- **Qué:** Datos laborales, turnos, ausencias, formación
- **Por qué:** Gestión de recursos humanos

**Clave:** Un empleado (`personal`) puede o no tener cuenta de usuario (`usuarios`). Son conceptos separados.

---

## 🎯 Lecciones aprendidas

### ❌ NO hacer:
```sql
-- Asumir que todos los "managers" necesitan los mismos permisos
CREATE FUNCTION is_manager() RETURNS BOOLEAN
AS $$ ... rol IN ('admin', 'jefe_personal', 'jefe_trafic') ... $$;

-- Usar is_manager() para TODAS las políticas administrativas
CREATE POLICY "..." USING (is_manager()); -- ❌ Demasiado amplio
```

### ✅ SÍ hacer:
```sql
-- Crear funciones específicas por tipo de permiso
CREATE FUNCTION can_manage_users() RETURNS BOOLEAN
AS $$ ... rol = 'admin' ... $$;  -- Solo admin

CREATE FUNCTION can_manage_personal() RETURNS BOOLEAN
AS $$ ... rol IN ('admin', 'jefe_personal') ... $$;  -- Admin + Jefe Personal

-- Usar la función correcta según el contexto
CREATE POLICY "..." ON usuarios USING (can_manage_users());
CREATE POLICY "..." ON personal USING (can_manage_personal());
```

---

## 🔧 Funciones auxiliares correctas

```sql
-- Para tabla usuarios: Solo admin
CREATE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN get_current_user_role() = 'admin';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Para tabla personal: Admin + Jefe Personal
CREATE FUNCTION is_manager()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN get_current_user_role() IN ('admin', 'jefe_personal');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Uso correcto:**
- `usuarios` → usa `is_admin()` ✅
- `personal` → usa `is_manager()` ✅

---

## 📚 Consistencia con aplicación Flutter

### RolePermissions (Flutter)
```dart
UserRole.jefePersonal: <AppModule>[
  AppModule.dashboard,
  AppModule.personal,           // ✅ Gestión de personal
  AppModule.formacion,
  AppModule.ausencias,
  AppModule.turnos,
  // ❌ NO incluye: AppModule.usuariosRoles
],
```

### RLS (Supabase)
```sql
-- ✅ Consistente: jefe_personal NO puede gestionar usuarios
CREATE POLICY "Admin can view all users"
  ON usuarios FOR SELECT
  USING (is_admin());
```

**Conclusión:** RLS y permisos Flutter están alineados correctamente.

---

## 📊 Impacto de la reversión

### Antes de la reversión (estado incorrecto):
- ❌ `jefe_personal` podía ver todos los usuarios
- ❌ `jefe_personal` podía crear/editar/eliminar usuarios
- ❌ Violación del principio de mínimo privilegio
- ❌ Inconsistencia con permisos de Flutter

### Después de la reversión (estado correcto):
- ✅ Solo `admin` puede gestionar usuarios
- ✅ `jefe_personal` solo ve su propio registro de usuario
- ✅ Principio de mínimo privilegio respetado
- ✅ Consistencia total entre RLS y Flutter
- ✅ Separación clara: usuarios vs personal

---

## 🔗 Referencias

- **Migración revertida:** `fix_usuarios_rls_allow_jefe_personal`
- **Migración de reversión:** `revert_jefe_personal_usuarios_access`
- **Documento obsoleto:** `FIX_RLS_JEFE_PERSONAL_USUARIOS.md` (marcado como ❌ REVERTIDO)
- **RLS original:** `005_fix_usuarios_rls_infinite_recursion.sql`
- **Permisos Flutter:** `lib/core/auth/permissions/role_permissions.dart`

---

**Estado:** ✅ Revertido y documentado
**Aplicado vía:** Supabase MCP
**Verificado por:** Claude Sonnet 4.5
**Fecha de aplicación:** 2026-02-12

---

## ⚠️ Nota importante

Si en el futuro se requiere que `jefe_personal` gestione usuarios, esto debe:

1. **Discutirse y aprobarse** como cambio de requerimientos de negocio
2. **Actualizarse en Flutter** primero (`role_permissions.dart`)
3. **Documentarse** la justificación de negocio
4. **Aplicarse en RLS** solo después de aprobación explícita

**NO asumir que "manager" = acceso a usuarios**. Son dominios separados:
- **Personal** (empleados) → `jefe_personal` ✅
- **Usuarios** (cuentas sistema) → `admin` ✅
