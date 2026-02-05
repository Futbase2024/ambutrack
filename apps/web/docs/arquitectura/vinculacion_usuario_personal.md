# Vinculación Usuario Supabase Auth ↔ Personal

## 📋 Problema

Cuando un usuario se autentica en Supabase Auth pero **NO tiene un registro vinculado en la tabla `tpersonal`**, el sistema no puede:
- Obtener su rol/categoría
- Aprobar/rechazar vacaciones u otras acciones
- Verificar permisos en el sistema de roles

### Error Común

```
❌ Error: No se encontró un registro de Personal asociado al usuario autenticado.
Por favor, contacte al administrador para vincular su usuario con su ficha de personal.
```

## 🔍 Causa Raíz

El sistema de roles depende de dos tablas vinculadas:

1. **`auth.users`** (Supabase Auth)
   - Gestiona autenticación (email/password)
   - Genera UUID único por usuario

2. **`public.tpersonal`** (Datos de personal)
   - Almacena información del empleado
   - Campo `usuario_id` → FK a `auth.users.id`
   - Campo `categoria` → Almacena el rol del usuario

**El vínculo se hace mediante**: `tpersonal.usuario_id = auth.users.id`

## ✅ Solución

### Paso 1: Identificar el Usuario Autenticado

```sql
-- Ver usuario actual autenticado
SELECT
  id,
  email,
  created_at,
  last_sign_in_at
FROM auth.users
WHERE email = 'tu_email@ejemplo.com';
```

**Resultado esperado**:
```
id: ed0632de-8721-483d-b90b-ad8165f9cf17
email: test@ambutrack.com
```

### Paso 2: Verificar si Existe Registro en tpersonal

```sql
-- Verificar vinculación existente
SELECT
  id,
  nombre,
  apellidos,
  email,
  usuario_id,
  categoria,
  activo
FROM public.tpersonal
WHERE email = 'test@ambutrack.com'
   OR usuario_id = 'ed0632de-8721-483d-b90b-ad8165f9cf17';
```

**Si devuelve vacío** → El usuario NO tiene registro de Personal

### Paso 3: Crear Registro de Personal (si no existe)

```sql
-- Crear registro de Personal vinculado al usuario de Auth
INSERT INTO public.tpersonal (
  nombre,
  apellidos,
  email,
  usuario_id,
  categoria,
  activo,
  fecha_alta,
  created_at
)
VALUES (
  'Nombre',                              -- Nombre del empleado
  'Apellidos',                           -- Apellidos del empleado
  'test@ambutrack.com',                  -- Email (mismo que auth.users)
  'ed0632de-8721-483d-b90b-ad8165f9cf17', -- UUID de auth.users
  'admin',                                -- Rol (admin, jefe_personal, etc.)
  true,                                   -- Activo
  CURRENT_DATE,
  NOW()
)
RETURNING id, nombre, apellidos, email, usuario_id, categoria;
```

**Resultado esperado**:
```json
{
  "id": "b682a0b6-dd93-432c-8ab4-4e5dab18716f",
  "nombre": "Nombre",
  "apellidos": "Apellidos",
  "email": "test@ambutrack.com",
  "usuario_id": "ed0632de-8721-483d-b90b-ad8165f9cf17",
  "categoria": "admin"
}
```

### Paso 4: Actualizar Registro Existente (alternativa)

Si ya existe un registro de Personal pero sin `usuario_id`:

```sql
-- Vincular usuario existente de Personal con Auth
UPDATE public.tpersonal
SET
  usuario_id = 'ed0632de-8721-483d-b90b-ad8165f9cf17',
  categoria = 'admin',
  email = 'test@ambutrack.com',
  updated_at = NOW()
WHERE nombre = 'Nombre' AND apellidos = 'Apellidos'
RETURNING id, nombre, apellidos, email, usuario_id, categoria;
```

## 🔧 Verificación Post-Solución

### 1. Verificar Vinculación

```sql
-- Verificar que el usuario tiene registro de Personal
SELECT
  p.id,
  p.nombre,
  p.apellidos,
  p.email AS personal_email,
  p.usuario_id,
  p.categoria,
  u.email AS auth_email,
  u.last_sign_in_at
FROM public.tpersonal p
INNER JOIN auth.users u ON p.usuario_id = u.id
WHERE u.email = 'test@ambutrack.com';
```

**Resultado esperado**:
```
✅ 1 registro encontrado con todos los campos vinculados
```

### 2. Probar RoleService en Flutter

```dart
import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:ambutrack_web/core/di/locator.dart';

final RoleService roleService = getIt<RoleService>();

// Obtener PersonalEntity del usuario actual
final PersonalEntity? personal = await roleService.getCurrentPersonal();
debugPrint('Personal: ${personal?.nombre} ${personal?.apellidos}');
debugPrint('Usuario ID: ${personal?.usuarioId}');

// Obtener rol
final UserRole role = await roleService.getCurrentUserRole();
debugPrint('Rol: ${role.label} (${role.value})');

// Verificar si es admin
final bool isAdmin = await roleService.isAdmin();
debugPrint('¿Es admin?: $isAdmin');
```

**Salida esperada**:
```
Personal: Usuario Administrador Test
Usuario ID: ed0632de-8721-483d-b90b-ad8165f9cf17
Rol: Administrador (admin)
¿Es admin?: true
```

## 🚨 Errores Comunes y Soluciones

### Error 1: UUID Incorrecto

**Síntoma**:
```
❌ Error: No se encontró un registro de Personal asociado al usuario
```

**Causa**: El `usuario_id` en `tpersonal` no coincide con el `id` de `auth.users`

**Solución**:
```sql
-- Obtener UUID correcto de auth.users
SELECT id FROM auth.users WHERE email = 'tu_email@ejemplo.com';

-- Actualizar tpersonal con el UUID correcto
UPDATE public.tpersonal
SET usuario_id = 'UUID_CORRECTO_AQUI'
WHERE email = 'tu_email@ejemplo.com';
```

### Error 2: Email No Coincide

**Síntoma**: El usuario puede autenticarse pero no ve sus datos de Personal

**Causa**: Email en `auth.users` ≠ Email en `tpersonal`

**Solución**:
```sql
-- Sincronizar emails
UPDATE public.tpersonal
SET email = (SELECT email FROM auth.users WHERE id = tpersonal.usuario_id)
WHERE usuario_id IS NOT NULL;
```

### Error 3: Múltiples Usuarios con Mismo Email

**Síntoma**: Conflicto al vincular

**Causa**: Varios registros de Personal con el mismo email

**Solución**:
```sql
-- Identificar duplicados
SELECT email, COUNT(*)
FROM public.tpersonal
GROUP BY email
HAVING COUNT(*) > 1;

-- Marcar como inactivos los duplicados (excepto uno)
UPDATE public.tpersonal
SET activo = false
WHERE id IN (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY email ORDER BY created_at DESC) as rn
    FROM public.tpersonal
    WHERE email = 'email_duplicado@ejemplo.com'
  ) sub
  WHERE rn > 1
);
```

## 📊 Flujo Completo del Sistema

```
1. Usuario hace login
   ↓
2. Supabase Auth verifica credenciales
   ↓
3. AuthService.currentUser → UUID del usuario
   ↓
4. RoleService.getCurrentPersonal()
   ↓
5. PersonalRepository.getAll() busca en tpersonal
   ↓
6. Filtra por usuario_id = auth.users.id
   ↓
7. ¿Encontró registro?
   ├─ Sí → Extrae categoria (rol)
   │   ↓
   │   UserRole.fromString(categoria)
   │   ↓
   │   Sistema de permisos funciona ✅
   │
   └─ No → Error: Usuario no vinculado ❌
       ↓
       Solución: Crear/actualizar registro de Personal
```

## 🔐 Seguridad y Buenas Prácticas

### 1. Row Level Security (RLS)

**Recomendación**: Configurar políticas RLS en Supabase para reforzar seguridad:

```sql
-- Política: Usuarios solo pueden ver su propio registro de Personal
CREATE POLICY "Ver propio personal"
ON public.tpersonal
FOR SELECT
USING (auth.uid() = usuario_id);

-- Política: Admins pueden ver todo
CREATE POLICY "Admins ven todo"
ON public.tpersonal
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM tpersonal
    WHERE usuario_id = auth.uid()
    AND categoria = 'admin'
  )
);
```

### 2. Validación de Email

**Siempre** sincronizar emails entre `auth.users` y `tpersonal`:

```sql
-- Trigger para sincronizar email automáticamente
CREATE OR REPLACE FUNCTION sync_email_on_auth_change()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.tpersonal
  SET email = NEW.email, updated_at = NOW()
  WHERE usuario_id = NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_auth_email_change
AFTER UPDATE OF email ON auth.users
FOR EACH ROW
EXECUTE FUNCTION sync_email_on_auth_change();
```

### 3. Auditoría de Cambios

**Registrar** quién crea/modifica registros de Personal:

```sql
-- Siempre usar created_by y updated_by
INSERT INTO public.tpersonal (
  nombre, apellidos, email, usuario_id, categoria,
  created_by  -- UUID del admin que creó el registro
)
VALUES (
  'Nombre', 'Apellidos', 'email@ejemplo.com',
  'UUID_DEL_USUARIO', 'conductor',
  auth.uid()  -- UUID del admin actual
);
```

## 📝 Checklist de Vinculación

Al crear un nuevo usuario en AmbuTrack:

- [ ] Crear usuario en Supabase Auth (email + password)
- [ ] Obtener UUID generado (`auth.users.id`)
- [ ] Crear registro en `tpersonal` con:
  - [ ] `nombre` y `apellidos`
  - [ ] `email` (mismo que auth.users)
  - [ ] `usuario_id` (UUID de auth.users)
  - [ ] `categoria` (rol: admin, jefe_personal, etc.)
  - [ ] `activo = true`
- [ ] Verificar vinculación con query JOIN
- [ ] Probar login y acceso al sistema
- [ ] Verificar que `RoleService` funciona correctamente

## 🛠️ Scripts Útiles

### Script de Creación Masiva

```sql
-- Crear usuario en Auth + Personal en una transacción
DO $$
DECLARE
  nuevo_usuario_id UUID;
BEGIN
  -- 1. Crear usuario en Auth (requiere extensión supabase_auth_admin)
  INSERT INTO auth.users (email, encrypted_password, email_confirmed_at)
  VALUES (
    'nuevo@ejemplo.com',
    crypt('password123', gen_salt('bf')),
    NOW()
  )
  RETURNING id INTO nuevo_usuario_id;

  -- 2. Crear registro de Personal vinculado
  INSERT INTO public.tpersonal (
    nombre, apellidos, email, usuario_id, categoria, activo
  )
  VALUES (
    'Nuevo', 'Usuario', 'nuevo@ejemplo.com',
    nuevo_usuario_id, 'conductor', true
  );

  RAISE NOTICE 'Usuario creado: %', nuevo_usuario_id;
END $$;
```

### Script de Verificación

```sql
-- Verificar todos los usuarios vinculados correctamente
SELECT
  CASE
    WHEN p.usuario_id IS NULL THEN '❌ Sin vincular'
    WHEN u.id IS NULL THEN '❌ Usuario Auth no existe'
    WHEN p.email != u.email THEN '⚠️ Emails diferentes'
    ELSE '✅ OK'
  END as estado,
  p.nombre,
  p.apellidos,
  p.email as personal_email,
  u.email as auth_email,
  p.usuario_id,
  p.categoria
FROM public.tpersonal p
LEFT JOIN auth.users u ON p.usuario_id = u.id
WHERE p.activo = true
ORDER BY estado, p.nombre;
```

## 📚 Referencias

- [Sistema de Roles - Documentación](./sistema_roles.md)
- [Integración GoRouter](./integracion_gorouter_roles.md)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

---

**Actualizado**: 26 de Diciembre, 2025
**Estado**: ✅ Documentación completa
