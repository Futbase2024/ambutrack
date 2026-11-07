# 🔐 Credenciales de Usuarios de Prueba

**Fecha**: 2026-02-12
**Proyecto**: AmbuTrack Web
**Supabase Project ID**: `ycmopmnrhrpnnzkvnihr`

---

## 👥 USUARIOS DISPONIBLES

### 1. Usuario Administrador

| Campo | Valor |
|-------|-------|
| 🆔 **DNI** | `31687068Z` |
| 📧 **Email** | `tes@gmail.com` |
| 🔒 **Password** | (Password original del usuario) |
| 👤 **Nombre** | Tecnico Ambulancias |
| 🎭 **Rol** | `admin` (Administrador) |
| 🏢 **Empresa** | Ambulancias Barbate S.C.A. |
| ✅ **Estado** | Activo |
| 🔑 **UUID** | `d2651e52-04f7-4a88-85dc-f3fdfb7efd2e` |

**Login:**
- Con DNI: `31687068Z` + password
- Con Email: `tes@gmail.com` + password

---

### 2. Usuario Jefe de Personal ⏳ PENDIENTE DE CREACIÓN

| Campo | Valor |
|-------|-------|
| 🆔 **DNI** | `44045224V` |
| 📧 **Email** | `personal@ambulanciasbarbate.es` |
| 🔒 **Password** | `123456` ⚠️ SOLO DESARROLLO |
| 👤 **Nombre** | Jorge Tomas Ruiz Gallardo |
| 🎭 **Rol** | `jefe_personal` (Jefe de Personal) |
| 🏢 **Empresa** | Ambulancias Barbate S.C.A. |
| ✅ **Estado** | Pendiente de creación |
| 🔑 **UUID** | (Se generará al crear en dashboard) |

**Estado**: ⏳ Este usuario aún NO ha sido creado

**Instrucciones**: Ver [CREAR_USUARIO_JEFE_PERSONAL.md](CREAR_USUARIO_JEFE_PERSONAL.md) para el proceso completo de creación.

**Login** (una vez creado):
- Con DNI: `44045224V` + `123456`
- Con Email: `personal@ambulanciasbarbate.es` + `123456`

---

### 3. Usuario Regular

| Campo | Valor |
|-------|-------|
| 🆔 **DNI** | `31000000Z` |
| 📧 **Email** | `appfutbase@gmail.com` |
| 🔒 **Password** | (Password original del usuario) |
| 👤 **Nombre** | Pedro Sainz |
| 🎭 **Rol** | `usuario` (Usuario) |
| 🏢 **Empresa** | Ambulancias Barbate S.C.A. |
| ✅ **Estado** | Activo |
| 🔑 **UUID** | `cc477a19-f820-493c-9db4-a8ce346c9414` |

**Login:**
- Con DNI: `31000000Z` + password
- Con Email: `appfutbase@gmail.com` + password

---

## 🧪 CÓMO PROBAR

### Paso 1: Iniciar la Aplicación
```bash
cd apps/web
flutter run
```

### Paso 2: Login con DNI
1. En el campo "DNI o Correo electrónico" ingresar uno de los DNIs disponibles:
   - `31687068Z` (Admin) ✅ DISPONIBLE
   - `31000000Z` (Usuario) ✅ DISPONIBLE
   - `44045224V` (Jefe Personal - password: `123456`) ⏳ PENDIENTE DE CREACIÓN

2. Ingresar la contraseña correspondiente

3. Click "Iniciar Sesión"

**Nota**: El usuario con DNI `44045224V` debe crearse primero siguiendo [CREAR_USUARIO_JEFE_PERSONAL.md](CREAR_USUARIO_JEFE_PERSONAL.md)

### Paso 3: Verificar Perfil
Una vez logueado, navegar a "Perfil" y verificar que se muestran:
- ✅ DNI
- ✅ Nombre completo
- ✅ Rol con badge coloreado
- ✅ Estado (Activo)
- ✅ Empresa

---

## 📊 VERIFICACIÓN EN BASE DE DATOS

### Consulta SQL para ver todos los usuarios

```sql
SELECT
  u.id,
  u.email,
  u.dni,
  u.nombre,
  u.apellidos,
  u.rol,
  u.activo,
  e.nombre as empresa_nombre
FROM public.usuarios u
LEFT JOIN public.empresas e ON u.empresa_id = e.id
WHERE u.activo = true
ORDER BY u.created_at DESC;
```

### Verificar función de login con DNI

```sql
-- Probar conversión DNI → Email
SELECT public.get_email_by_dni('44045224V') as email;
-- Resultado esperado: personal@ambulanciasbarbate.es

SELECT public.get_email_by_dni('31687068Z') as email;
-- Resultado esperado: tes@gmail.com
```

---

## 🎨 ROLES Y PERMISOS

### Roles Configurados

| Rol | Color Badge | Descripción |
|-----|-------------|-------------|
| `admin` | 🔴 Rojo | Administrador del sistema |
| `coordinador` | 🔵 Azul Primary | Coordinador de servicios |
| `jefe_personal` | ⚪ Gris | Jefe de Personal (rol custom) |
| `conductor` | 🔵 Azul Info | Conductor de ambulancia |
| `sanitario` | 🟢 Verde | Personal sanitario |
| `usuario` | ⚪ Gris | Usuario básico |

**Nota**: El rol `jefe_personal` no tiene color específico en el código actual. Usa el color por defecto (gris).

---

## 🔒 SEGURIDAD

### Contraseñas
- ✅ Contraseñas cifradas con `bcrypt` en `auth.users`
- ✅ Función `crypt()` con salt `bf` (Blowfish)
- ⚠️ Password `123456` solo para usuario de prueba `44045224V`

### Recomendaciones
- 🔴 **NUNCA** usar `123456` en producción
- 🔴 Cambiar contraseñas de prueba antes de deploy
- ✅ Implementar política de contraseñas fuertes
- ✅ Habilitar autenticación de dos factores (2FA)

---

## 📝 NOTAS IMPORTANTES

1. **Sincronización Automática**:
   - El trigger `handle_new_auth_user` sincroniza automáticamente usuarios de `auth.users` a `public.usuarios`
   - Al crear un usuario en `auth.users`, se crea automáticamente en `usuarios`

2. **Login con DNI**:
   - La función `get_email_by_dni()` convierte DNI → Email
   - Luego se usa el email para autenticar en Supabase Auth
   - El DNI debe estar en la tabla `usuarios` con el campo `activo = true`

3. **Datos Completos**:
   - `auth.users` contiene datos básicos de autenticación
   - `public.usuarios` contiene datos extendidos (DNI, rol, empresa, etc.)
   - El perfil combina datos de ambas tablas

---

## 🚀 PRÓXIMOS PASOS

1. ✅ Login con DNI implementado
2. ✅ Perfil mostrando todos los campos
3. ✅ Usuarios de prueba Admin y Usuario Regular creados
4. ⏳ **ACCIÓN REQUERIDA**: Crear usuario Jefe Personal desde Dashboard de Supabase
   - Ver instrucciones en [CREAR_USUARIO_JEFE_PERSONAL.md](CREAR_USUARIO_JEFE_PERSONAL.md)
5. ⏳ **Pendiente**: CRUD de usuarios con asignación de DNI/empresa/rol
6. ⏳ **Pendiente**: RLS y permisos por rol en Supabase
7. ⏳ **Pendiente**: Filtrado por empresa (multi-tenancy)

---

**⚠️ IMPORTANTE**: El usuario Jefe Personal (DNI `44045224V`) debe crearse manualmente desde el Dashboard de Supabase siguiendo las instrucciones en [CREAR_USUARIO_JEFE_PERSONAL.md](CREAR_USUARIO_JEFE_PERSONAL.md).

**Razón**: Los usuarios NO pueden crearse directamente con SQL en `auth.users` porque Supabase Auth requiere validaciones internas y metadatos que solo se generan correctamente desde el dashboard o mediante la API de administración.
