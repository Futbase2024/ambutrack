# 🧪 PLAN DE TESTING - FASE 1: SEGURIDAD CRÍTICA

> **Fecha**: 2026-02-12
> **Objetivo**: Verificar que el sistema RBAC funciona correctamente
> **Estimación**: 2-3 horas

---

## 📋 ÍNDICE

1. [Preparación del Entorno](#preparación-del-entorno)
2. [Testing de Frontend (AuthGuard)](#testing-de-frontend-authguard)
3. [Testing de Backend (RLS)](#testing-de-backend-rls)
4. [Casos de Prueba Críticos](#casos-de-prueba-críticos)
5. [Checklist de Verificación](#checklist-de-verificación)
6. [Solución de Problemas](#solución-de-problemas)

---

## 1. PREPARACIÓN DEL ENTORNO

### 1.1. Verificar Usuarios de Prueba

Necesitas al menos **3 usuarios** con roles diferentes para testing:

```sql
-- Ejecutar en Supabase SQL Editor
SELECT
  id,
  email,
  rol,
  activo
FROM usuarios
ORDER BY rol;
```

**Usuarios necesarios**:
- ✅ 1 usuario con rol = `'admin'`
- ✅ 1 usuario con rol = `'jefe_personal'` o `'jefe_trafico'`
- ✅ 1 usuario con rol = `'conductor'` o `'sanitario'`

### 1.2. Crear Usuarios de Prueba (si no existen)

Si no tienes usuarios de prueba, créalos:

#### Opción A: Desde Supabase Dashboard

1. Ve a **Authentication** → **Users**
2. Haz clic en **"Add user"**
3. Completa:
   - Email: `admin@ambutrack.test`
   - Password: `Test1234!`
   - Auto Confirm User: ✅ SÍ
4. Una vez creado, actualiza el rol:

```sql
-- Asignar rol de admin
UPDATE usuarios
SET rol = 'admin', activo = true
WHERE email = 'admin@ambutrack.test';
```

#### Opción B: Script SQL Completo

```sql
-- IMPORTANTE: Ejecuta esto SOLO si no tienes usuarios de prueba

-- 1. Crear usuario Admin (necesitas hacerlo desde Dashboard)
-- Email: admin@ambutrack.test
-- Password: Test1234!

-- 2. Crear usuario Jefe Personal (necesitas hacerlo desde Dashboard)
-- Email: jefe@ambutrack.test
-- Password: Test1234!

-- 3. Crear usuario Conductor (necesitas hacerlo desde Dashboard)
-- Email: conductor@ambutrack.test
-- Password: Test1234!

-- 4. Actualizar roles en tabla usuarios
UPDATE usuarios SET rol = 'admin', activo = true WHERE email = 'admin@ambutrack.test';
UPDATE usuarios SET rol = 'jefe_personal', activo = true WHERE email = 'jefe@ambutrack.test';
UPDATE usuarios SET rol = 'conductor', activo = true WHERE email = 'conductor@ambutrack.test';

-- 5. Verificar
SELECT id, email, rol, activo FROM usuarios ORDER BY rol;
```

### 1.3. Verificar RLS Habilitado

```sql
-- Verificar que RLS esté habilitado
SELECT
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'servicios');
```

**Resultado esperado**:
```
usuarios  | true
servicios | true
```

### 1.4. Verificar Políticas Creadas

```sql
-- Ver todas las políticas activas
SELECT
  tablename,
  policyname,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'servicios')
ORDER BY tablename, cmd, policyname;
```

**Resultado esperado**: 10 políticas (6 para usuarios, 4 para servicios)

---

## 2. TESTING DE FRONTEND (AuthGuard)

### 2.1. Ejecutar la Aplicación

```bash
# Desde el directorio web/
flutter run -d chrome --dart-define=ENV=dev
```

### 2.2. Casos de Prueba - AuthGuard

#### Test 1: Usuario no autenticado redirige a login ✅

**Pasos**:
1. Abre la app en modo incógnito o sin login
2. Intenta acceder a `http://localhost:XXXX/`

**Resultado esperado**:
- ✅ Redirige automáticamente a `/login`
- ✅ En consola: `❌ AuthGuard - No autenticado, redirigiendo a /login`

#### Test 2: Admin puede acceder a todos los módulos ✅

**Pasos**:
1. Inicia sesión con usuario `admin@ambutrack.test`
2. Navega a:
   - `/` (Dashboard) ✅
   - `/personal` ✅
   - `/vehiculos` ✅
   - `/servicios` ✅
   - `/perfil` ✅

**Resultado esperado**:
- ✅ Acceso permitido a todas las rutas
- ✅ En consola: `✅ AuthGuard - Usuario tiene acceso a: /ruta`

#### Test 3: Jefe Personal ve solo módulos de RRHH ✅

**Pasos**:
1. Cierra sesión (si estás logueado como admin)
2. Inicia sesión con usuario `jefe@ambutrack.test`
3. Navega a:
   - `/personal` → ✅ Debe permitir
   - `/vehiculos` → ❌ Debe redirigir a /403
   - `/servicios` → ❌ Debe redirigir a /403

**Resultado esperado**:
- ✅ Acceso a `/personal`
- ❌ Redirige a `/403` en `/vehiculos` y `/servicios`
- ✅ En consola: `🚫 AuthGuard - Usuario sin permisos para: /vehiculos`
- ✅ Muestra página 403 con mensaje "Acceso Denegado"

#### Test 4: Conductor solo ve dashboard y perfil ✅

**Pasos**:
1. Cierra sesión
2. Inicia sesión con usuario `conductor@ambutrack.test`
3. Navega a:
   - `/` (Dashboard) → ✅ Debe permitir
   - `/perfil` → ✅ Debe permitir
   - `/personal` → ❌ Debe redirigir a /403
   - `/vehiculos` → ❌ Debe redirigir a /403
   - `/servicios` → ❌ Debe redirigir a /403

**Resultado esperado**:
- ✅ Solo puede acceder a `/` y `/perfil`
- ❌ Redirige a `/403` en todo lo demás

#### Test 5: Bypass de URL no funciona ✅

**Pasos**:
1. Logueado como `conductor@ambutrack.test`
2. Escribe manualmente en la barra de direcciones:
   - `http://localhost:XXXX/personal`
   - `http://localhost:XXXX/vehiculos`

**Resultado esperado**:
- ❌ AuthGuard intercepta y redirige a `/403` inmediatamente
- ✅ Muestra página 403

---

## 3. TESTING DE BACKEND (RLS)

### 3.1. Testing desde Supabase SQL Editor

⚠️ **IMPORTANTE**: El SQL Editor de Supabase ejecuta queries como **superusuario**, por lo que RLS **NO aplica** allí. Para testing real de RLS, necesitas:

1. **Usar el cliente de Supabase en la app** (recomendado)
2. **Usar Supabase Studio con auth context**
3. **Simular con funciones SQL**

### 3.2. Función para Simular Usuario Autenticado

```sql
-- Crear función para testing de RLS
CREATE OR REPLACE FUNCTION test_rls_as_user(user_email TEXT)
RETURNS TABLE (
  test_name TEXT,
  result TEXT,
  details TEXT
) AS $$
DECLARE
  test_user_id UUID;
  test_user_rol TEXT;
BEGIN
  -- Obtener ID y rol del usuario de prueba
  SELECT id, rol INTO test_user_id, test_user_rol
  FROM usuarios
  WHERE email = user_email;

  IF test_user_id IS NULL THEN
    RETURN QUERY SELECT
      'ERROR'::TEXT,
      'FAIL'::TEXT,
      'Usuario no encontrado: ' || user_email;
    RETURN;
  END IF;

  -- Test 1: Verificar que el usuario puede ver sus propios datos
  RETURN QUERY SELECT
    'User can view own data'::TEXT,
    CASE
      WHEN EXISTS (
        SELECT 1 FROM usuarios WHERE id = test_user_id
      ) THEN 'PASS'::TEXT
      ELSE 'FAIL'::TEXT
    END,
    'User: ' || user_email || ' (Rol: ' || test_user_rol || ')';

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ejecutar tests
SELECT * FROM test_rls_as_user('admin@ambutrack.test');
SELECT * FROM test_rls_as_user('conductor@ambutrack.test');
```

### 3.3. Testing Real de RLS (Desde la Aplicación)

El testing más confiable de RLS es **desde la aplicación Flutter**:

#### Test 1: Admin puede listar usuarios

```dart
// En la app, logueado como admin
final usuarios = await supabase.from('usuarios').select();
print('Admin ve ${usuarios.length} usuarios');
// Debe funcionar y mostrar todos los usuarios
```

#### Test 2: Conductor NO puede listar usuarios

```dart
// En la app, logueado como conductor
try {
  final usuarios = await supabase.from('usuarios').select();
  print('Conductor ve ${usuarios.length} usuarios');
  // Debe devolver lista vacía o error de RLS
} catch (e) {
  print('RLS bloqueó acceso: $e'); // ✅ Esperado
}
```

#### Test 3: Conductor solo ve sus propios datos

```dart
// En la app, logueado como conductor
final misDatos = await supabase
    .from('usuarios')
    .select()
    .eq('id', supabase.auth.currentUser!.id)
    .single();
print('Conductor ve sus datos: ${misDatos['email']}');
// Debe funcionar
```

---

## 4. CASOS DE PRUEBA CRÍTICOS

### Tabla de Testing

| # | Usuario | Acción | Método | Resultado Esperado | Prioridad |
|---|---------|--------|--------|-------------------|-----------|
| 1 | Sin autenticar | Acceder a `/` | Frontend | ❌ Redirect a `/login` | 🔴 CRÍTICO |
| 2 | Admin | Acceder a `/personal` | Frontend | ✅ Permitido | 🔴 CRÍTICO |
| 3 | Admin | `SELECT * FROM usuarios` | Backend | ✅ Ve todos los usuarios | 🔴 CRÍTICO |
| 4 | Jefe Personal | Acceder a `/personal` | Frontend | ✅ Permitido | 🔴 CRÍTICO |
| 5 | Jefe Personal | Acceder a `/vehiculos` | Frontend | ❌ Redirect a `/403` | 🔴 CRÍTICO |
| 6 | Conductor | Acceder a `/personal` | Frontend | ❌ Redirect a `/403` | 🔴 CRÍTICO |
| 7 | Conductor | Acceder a `/perfil` | Frontend | ✅ Permitido | 🟠 ALTA |
| 8 | Conductor | `SELECT * FROM usuarios` | Backend | ❌ Lista vacía o error | 🔴 CRÍTICO |
| 9 | Conductor | Ver sus propios datos | Backend | ✅ Solo sus datos | 🟠 ALTA |
| 10 | Admin | Crear usuario | Backend | ✅ Permitido | 🔴 CRÍTICO |
| 11 | Conductor | Crear usuario | Backend | ❌ RLS bloquea | 🔴 CRÍTICO |
| 12 | Conductor | Cambiar su propio rol | Backend | ❌ RLS bloquea | 🔴 CRÍTICO |
| 13 | Jefe Tráfico | Ver servicios | Frontend | ✅ Permitido | 🟠 ALTA |
| 14 | Coordinador | Ver servicios | Frontend | ✅ Permitido | 🟠 ALTA |
| 15 | Coordinador | Crear servicio | Backend | ❌ RLS bloquea | 🟠 ALTA |

---

## 5. CHECKLIST DE VERIFICACIÓN

### Pre-Testing

- [ ] RLS habilitado en tabla `usuarios`
- [ ] RLS habilitado en tabla `servicios`
- [ ] 10 políticas RLS creadas (6 usuarios + 4 servicios)
- [ ] Función `can_manage_servicios()` existe
- [ ] Al menos 3 usuarios de prueba creados (admin, jefe, conductor)
- [ ] Aplicación compilada sin errores (`flutter analyze` → 0 errores críticos)

### Testing Frontend

- [ ] Usuario no autenticado redirige a login
- [ ] Admin puede acceder a todos los módulos
- [ ] Jefe Personal puede acceder a `/personal`
- [ ] Jefe Personal NO puede acceder a `/vehiculos`
- [ ] Conductor puede acceder a `/` y `/perfil`
- [ ] Conductor NO puede acceder a `/personal`, `/vehiculos`, `/servicios`
- [ ] Página 403 se muestra correctamente con diseño profesional
- [ ] Botón "Volver al Dashboard" funciona en página 403

### Testing Backend (RLS)

- [ ] Admin puede leer todos los usuarios
- [ ] Admin puede crear usuarios
- [ ] Conductor NO puede leer todos los usuarios
- [ ] Conductor puede leer solo sus propios datos
- [ ] Conductor NO puede cambiar su propio rol
- [ ] Jefe Tráfico puede ver servicios
- [ ] Coordinador puede ver servicios pero NO crear
- [ ] Admin puede eliminar servicios

### Logs y Debugging

- [ ] Consola muestra logs de AuthGuard correctamente
- [ ] No hay errores en consola de Flutter
- [ ] No hay errores en logs de Supabase

---

## 6. SOLUCIÓN DE PROBLEMAS

### Problema 1: "Usuario no tiene permisos pero debería tenerlos"

**Causas posibles**:
- Rol del usuario incorrecto en tabla `usuarios`
- Caché de RoleService (expira cada 5 minutos)
- Error en mapeo de rutas

**Solución**:
```sql
-- Verificar rol del usuario
SELECT id, email, rol FROM usuarios WHERE email = 'usuario@test.com';

-- Verificar mapeo de módulos a rutas
SELECT * FROM unnest(enum_range(NULL::text)) as modulo;
```

### Problema 2: "RLS bloquea operaciones que deberían funcionar"

**Causas posibles**:
- Usuario con `activo = false`
- Rol escrito incorrectamente (mayúsculas/minúsculas)

**Solución**:
```sql
-- Activar usuario
UPDATE usuarios SET activo = true WHERE email = 'usuario@test.com';

-- Verificar políticas RLS
SELECT * FROM pg_policies WHERE tablename = 'usuarios';
```

### Problema 3: "AuthGuard no redirige a /403"

**Causas posibles**:
- RoleService no inicializado
- Error en hasAccessToRoute()

**Solución**:
```dart
// Agregar más logs en auth_guard.dart
debugPrint('🔍 Verificando rol del usuario...');
final role = await _roleService.getCurrentUserRole();
debugPrint('🔍 Rol obtenido: $role');
```

### Problema 4: "Página 403 no se muestra"

**Causas posibles**:
- Ruta `/403` no registrada
- Error en ForbiddenPage

**Solución**:
```bash
# Verificar que la ruta existe
grep -r "forbidden" lib/core/router/app_router.dart

# Recompilar
flutter run -d chrome
```

---

## 7. SCRIPT DE TESTING AUTOMATIZADO

### Script SQL para Validación Rápida

```sql
-- ==========================================
-- SCRIPT DE VALIDACIÓN RÁPIDA - FASE 1
-- ==========================================

-- 1. Verificar RLS habilitado
SELECT
  '1. RLS Enabled' as test,
  CASE
    WHEN COUNT(*) = 2 AND COUNT(*) FILTER (WHERE rowsecurity = true) = 2
    THEN 'PASS ✅'
    ELSE 'FAIL ❌'
  END as result
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'servicios');

-- 2. Verificar políticas creadas
SELECT
  '2. Policies Created' as test,
  CASE
    WHEN COUNT(*) = 10
    THEN 'PASS ✅'
    ELSE 'FAIL ❌ (' || COUNT(*)::text || ' policies found, expected 10)'
  END as result
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'servicios');

-- 3. Verificar función can_manage_servicios existe
SELECT
  '3. Function can_manage_servicios' as test,
  CASE
    WHEN COUNT(*) = 1
    THEN 'PASS ✅'
    ELSE 'FAIL ❌'
  END as result
FROM pg_proc
WHERE proname = 'can_manage_servicios';

-- 4. Verificar usuarios de prueba
SELECT
  '4. Test Users' as test,
  CASE
    WHEN COUNT(*) >= 3
    THEN 'PASS ✅ (' || COUNT(*)::text || ' users found)'
    ELSE 'FAIL ❌ (Need at least 3 users with different roles)'
  END as result
FROM usuarios
WHERE activo = true;

-- 5. Verificar que hay al menos 1 admin
SELECT
  '5. Admin User Exists' as test,
  CASE
    WHEN COUNT(*) >= 1
    THEN 'PASS ✅'
    ELSE 'FAIL ❌ (No admin user found!)'
  END as result
FROM usuarios
WHERE rol = 'admin' AND activo = true;

-- 6. Verificar políticas inseguras eliminadas
SELECT
  '6. Insecure Policies Removed' as test,
  CASE
    WHEN COUNT(*) = 0
    THEN 'PASS ✅'
    ELSE 'FAIL ❌ (' || COUNT(*)::text || ' insecure policies found)'
  END as result
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'usuarios'
  AND (
    policyname IN ('usuarios_read_all', 'usuarios_insert', 'usuarios_update')
    OR roles @> ARRAY['public']::name[]
  );
```

**Ejecutar en Supabase SQL Editor** y verificar que todos muestran "PASS ✅"

---

## 8. TEMPLATE DE REPORTE DE TESTING

```markdown
# REPORTE DE TESTING - FASE 1

**Fecha**: ___________
**Tester**: ___________
**Duración**: ___________

## Resumen

- Total de tests: 15
- Tests exitosos: ____ / 15
- Tests fallidos: ____ / 15
- Bugs encontrados: ____

## Tests Ejecutados

### Frontend (AuthGuard)

- [ ] Test 1: Redirect a login (sin autenticar)
- [ ] Test 2: Admin accede a todos los módulos
- [ ] Test 3: Jefe Personal bloqueado en vehículos
- [ ] Test 4: Conductor solo ve dashboard y perfil
- [ ] Test 5: Bypass de URL no funciona

### Backend (RLS)

- [ ] Test 6: Admin lista usuarios
- [ ] Test 7: Conductor no lista usuarios
- [ ] Test 8: Conductor ve solo sus datos
- [ ] Test 9: Admin crea usuario
- [ ] Test 10: Conductor no crea usuario

## Bugs Encontrados

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

## Notas

___________________________________________________
___________________________________________________
___________________________________________________

## Conclusión

[ ] ✅ APROBADO - Listo para Fase 2
[ ] ❌ RECHAZADO - Requiere correcciones
```

---

## 9. SIGUIENTES PASOS

Una vez completado el testing exitosamente:

1. ✅ **Documentar resultados** usando el template de reporte
2. ✅ **Corregir bugs encontrados** (si los hay)
3. ✅ **Re-testear** después de correcciones
4. ✅ **Aprobar Fase 1** como completada
5. ✅ **Proceder a Fase 2**: Gestión de Usuarios

---

**Elaborado por**: Claude Code Agent
**Fecha**: 2026-02-12
**Versión**: 1.0
