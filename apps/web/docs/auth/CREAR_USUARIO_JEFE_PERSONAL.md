# 📝 Proceso para Crear Usuario: Jefe de Personal

**Fecha**: 2026-02-12
**Usuario**: Jorge Tomas Ruiz Gallardo
**DNI**: `44045224V`
**Email**: `personal@ambulanciasbarbate.es`
**Rol**: `jefe_personal`

---

## ⚠️ IMPORTANTE: NO usar SQL directo

**❌ NO FUNCIONA**: Crear usuarios manualmente con `INSERT INTO auth.users`

**Razón**: Supabase Auth requiere validaciones internas, metadatos y registros en múltiples tablas (`auth.users`, `auth.identities`, `auth.sessions`, etc.) que NO se replican correctamente con SQL directo.

**Síntomas de usuario creado incorrectamente**:
- Error al login: `Database error querying schema` [500]
- No se puede autenticar aunque el email/password sean correctos
- Faltan registros en `auth.identities`

---

## ✅ PROCESO CORRECTO

Existen **DOS formas** de crear el usuario correctamente:

### Opción A: Script Dart (Recomendado - Automatizado)

He creado un script en [`scripts/create_jefe_personal_user.dart`](../../scripts/create_jefe_personal_user.dart) que automatiza todo el proceso usando la Admin API de Supabase.

**Ventajas**:
- ✅ Automatizado (crea usuario en `auth.users` Y `public.usuarios`)
- ✅ Usa la Admin API oficial de Supabase
- ✅ Garantiza que todas las tablas se actualicen correctamente
- ✅ Verifica automáticamente que todo funcione

**Pasos**:

1. **Obtener SERVICE_ROLE_KEY** de Supabase:
   - Ir a: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr
   - Navegar a: **Settings** → **API** → **Project API keys**
   - Copiar la clave **"service_role"** (⚠️ NUNCA compartir esta clave)

2. **Editar el script**:
   - Abrir: [`scripts/create_jefe_personal_user.dart`](../../scripts/create_jefe_personal_user.dart)
   - Línea 23: Reemplazar `'TU_SERVICE_ROLE_KEY_AQUI'` con la clave copiada

3. **Ejecutar el script**:
   ```bash
   cd apps/web
   dart run scripts/create_jefe_personal_user.dart
   ```

4. **Verificar salida**:
   ```
   🚀 Iniciando creación de usuario Jefe Personal...
   📦 Inicializando Supabase...
   👤 Creando usuario en Supabase Auth...
   ✅ Usuario creado en auth.users
      UUID: b46ed8b0-d256-4e4f-a7ec-f4dd2baadb34
      Email: personal@ambulanciasbarbate.es
   📝 Insertando datos en public.usuarios...
   ✅ Datos insertados en public.usuarios
   🔍 Verificando datos...
   ✅ Verificación exitosa:
      DNI: 44045224V
      Nombre: Jorge Tomas Ruiz Gallardo
      Rol: jefe_personal
      Activo: true
      Empresa: 00000000-0000-0000-0000-000000000001
   ✨ Usuario Jefe Personal creado exitosamente!
   ```

5. **Eliminar el SERVICE_ROLE_KEY del script** después de usarlo (por seguridad)

---

### Opción B: Dashboard de Supabase (Manual)

### Paso 1: Crear Usuario en Dashboard de Supabase

1. **Acceder al Dashboard**:
   - URL: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr
   - Navegar a: **Authentication** → **Users** → **Add User**

2. **Completar Formulario**:
   ```
   Email: personal@ambulanciasbarbate.es
   Password: 123456
   ✅ Auto Confirm User (marcar checkbox)
   ```

3. **Crear Usuario**:
   - Click en **"Create User"**
   - **COPIAR EL UUID** que se genera automáticamente
   - Ejemplo: `b46ed8b0-d256-4e4f-a7ec-f4dd2baadb34`

### Paso 2: Completar Datos en `public.usuarios`

Una vez creado el usuario en el dashboard y obtenido su UUID, ejecutar el siguiente SQL en la sección **SQL Editor** del dashboard de Supabase:

```sql
-- Reemplazar [UUID_COPIADO] con el UUID real del paso anterior
INSERT INTO public.usuarios (
  id,
  email,
  dni,
  nombre,
  apellidos,
  rol,
  activo,
  empresa_id,
  created_at,
  updated_at
) VALUES (
  '[UUID_COPIADO]',  -- ⚠️ Reemplazar con UUID del dashboard
  'personal@ambulanciasbarbate.es',
  '44045224V',
  'Jorge Tomas',
  'Ruiz Gallardo',
  'jefe_personal',
  true,
  '00000000-0000-0000-0000-000000000001',  -- Ambulancias Barbate S.C.A.
  NOW(),
  NOW()
);
```

### Paso 3: Verificar Usuario Creado

Ejecutar esta query para verificar que todo está correcto:

```sql
-- Verificar datos en auth.users
SELECT id, email, email_confirmed_at, created_at
FROM auth.users
WHERE email = 'personal@ambulanciasbarbate.es';

-- Verificar datos en public.usuarios
SELECT id, email, dni, nombre, apellidos, rol, activo, empresa_id
FROM public.usuarios
WHERE email = 'personal@ambulanciasbarbate.es';

-- Verificar identities (debe existir)
SELECT id, provider, provider_id, user_id
FROM auth.identities
WHERE provider_id IN (
  SELECT id::text FROM auth.users WHERE email = 'personal@ambulanciasbarbate.es'
);
```

**Resultado esperado**:
- ✅ 1 registro en `auth.users` con `email_confirmed_at` NOT NULL
- ✅ 1 registro en `public.usuarios` con DNI `44045224V`
- ✅ 1 registro en `auth.identities` con `provider = 'email'`

### Paso 4: Probar Login

1. **Abrir aplicación Flutter** (`flutter run`)

2. **Login con DNI**:
   ```
   Usuario: 44045224V
   Contraseña: 123456
   ```

3. **Login con Email** (alternativa):
   ```
   Usuario: personal@ambulanciasbarbate.es
   Contraseña: 123456
   ```

4. **Verificar Perfil**:
   - Navegar a **Perfil**
   - Verificar que se muestran:
     - ✅ DNI: `44045224V`
     - ✅ Nombre: Jorge Tomas Ruiz Gallardo
     - ✅ Rol: Badge "Jefe Personal" (color gris)
     - ✅ Estado: Badge verde "Activo"
     - ✅ Email: personal@ambulanciasbarbate.es

---

## 🔧 Flujo Completo de Autenticación

### Login con DNI
```
Usuario ingresa: 44045224V + 123456
    ↓
LoginPage detecta formato DNI (regex: ^\d{8}[A-Za-z]?$)
    ↓
AuthBloc.add(AuthDniLoginRequested(dni: '44045224V', password: '123456'))
    ↓
AuthService.signInWithDniAndPassword()
    ↓
1. Supabase RPC: get_email_by_dni('44045224V')
   → SELECT email FROM usuarios WHERE dni = '44045224V' AND activo = true
   → Retorna: 'personal@ambulanciasbarbate.es'
    ↓
2. Supabase Auth: signInWithPassword(email, password)
   → Valida credenciales en auth.users + auth.identities
   → Crea sesión en auth.sessions
    ↓
3. AuthRepository._fetchUsuarioData(user_id)
   → SELECT * FROM usuarios WHERE id = user_id
   → Retorna: {dni, nombre, apellidos, rol, activo, empresa_id}
    ↓
4. UserMapper.fromSupabaseUserAndUsuario(authUser, usuarioData)
   → Combina datos de auth.users + usuarios
    ↓
UserEntity completo:
{
  uid: 'b46ed8b0-d256-4e4f-a7ec-f4dd2baadb34',
  email: 'personal@ambulanciasbarbate.es',
  displayName: 'Jorge Tomas Ruiz Gallardo',
  dni: '44045224V',
  rol: 'jefe_personal',
  activo: true,
  empresaId: '00000000-0000-0000-0000-000000000001'
}
    ↓
✅ Usuario autenticado → Navega a dashboard
```

---

## 🗄️ Estructura de Tablas

### `auth.users` (Supabase Auth - Gestionada automáticamente)
```sql
- id (UUID PRIMARY KEY) → Se genera automáticamente
- email (TEXT UNIQUE)
- encrypted_password (TEXT) → Se cifra automáticamente
- email_confirmed_at (TIMESTAMPTZ) → Se establece con "Auto Confirm User"
- created_at, updated_at (TIMESTAMPTZ)
- raw_app_meta_data (JSONB)
- raw_user_meta_data (JSONB)
- aud (TEXT) → 'authenticated'
- role (TEXT) → 'authenticated'
```

### `auth.identities` (Supabase Auth - Gestionada automáticamente)
```sql
- id (UUID PRIMARY KEY) → Se genera automáticamente
- user_id (UUID FK → auth.users.id)
- provider (TEXT) → 'email'
- provider_id (TEXT) → UUID del usuario
- identity_data (JSONB) → {sub, email, email_verified}
- created_at, updated_at (TIMESTAMPTZ)
```

### `public.usuarios` (Custom - Gestionada manualmente)
```sql
- id (UUID PRIMARY KEY FK → auth.users.id)
- email (TEXT)
- dni (TEXT UNIQUE) ✅
- nombre (TEXT)
- apellidos (TEXT)
- telefono (TEXT)
- rol (TEXT) ✅ → 'admin', 'coordinador', 'jefe_personal', 'conductor', 'sanitario', 'usuario'
- activo (BOOLEAN) ✅
- foto_url (TEXT)
- empresa_id (UUID FK → empresas.id) ✅
- created_at, updated_at (TIMESTAMPTZ)
```

---

## 🔐 Seguridad y Validaciones

### Contraseña
- ✅ **NUNCA** usar `123456` en producción
- ⚠️ Este password es **SOLO para desarrollo/pruebas**
- 🔒 En producción implementar:
  - Longitud mínima 12 caracteres
  - Combinación de mayúsculas, minúsculas, números y símbolos
  - Autenticación de dos factores (2FA)
  - Políticas de expiración de contraseñas

### Función `get_email_by_dni`
```sql
CREATE OR REPLACE FUNCTION public.get_email_by_dni(dni_input TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT email
    FROM public.usuarios
    WHERE dni = dni_input
      AND activo = true
    LIMIT 1
  );
END;
$$;
```

---

## 📊 Datos del Usuario Creado

| Campo | Valor |
|-------|-------|
| **DNI** | `44045224V` |
| **Email** | `personal@ambulanciasbarbate.es` |
| **Password** | `123456` ⚠️ SOLO DESARROLLO |
| **Nombre** | Jorge Tomas |
| **Apellidos** | Ruiz Gallardo |
| **Rol** | `jefe_personal` |
| **Empresa** | Ambulancias Barbate S.C.A. |
| **Estado** | Activo ✅ |

---

## ✅ Checklist de Verificación

- [ ] Usuario creado en Dashboard de Supabase (Authentication → Users)
- [ ] UUID copiado correctamente
- [ ] Registro en `public.usuarios` con UUID correcto
- [ ] Query de verificación ejecutada y exitosa
- [ ] Login con DNI funciona correctamente
- [ ] Login con Email funciona correctamente
- [ ] Perfil muestra todos los campos (DNI, rol, nombre, empresa)
- [ ] Badge de rol muestra color correcto
- [ ] Badge de estado muestra "Activo" en verde

---

**Estado**: ⏳ Pendiente de creación en Dashboard de Supabase
**Próximo Paso**: Crear usuario manualmente en el dashboard siguiendo los pasos anteriores
