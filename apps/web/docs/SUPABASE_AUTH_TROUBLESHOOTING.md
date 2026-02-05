# Supabase Auth - Solución de Problemas

## 🚨 Error: "Database error querying schema"

### Descripción del Error

```
AuthException - [500] {
  "code": "unexpected_failure",
  "message": "Database error querying schema"
}
```

Este error ocurre cuando Supabase Auth no puede acceder correctamente al schema `auth.users`.

---

## 🔍 Diagnóstico

### 1. Verificar que el proyecto Supabase esté activo

1. Ir a [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Seleccionar tu proyecto
3. Verificar que el estado sea **"Active"** (no "Paused")

### 2. Verificar las credenciales en SupabaseOptions

**Archivo**: `lib/core/supabase/supabase_options.dart`

```dart
class SupabaseOptions {
  static const SupabaseConfig dev = SupabaseConfig(
    url: 'https://TU_PROJECT_ID.supabase.co',  // ✅ Verificar
    anonKey: 'TU_ANON_KEY',  // ✅ Verificar
  );
}
```

**Cómo obtener las credenciales correctas**:
1. Dashboard de Supabase → Settings → API
2. Copiar:
   - **Project URL** → `url`
   - **anon/public key** → `anonKey`

### 3. Verificar el schema auth.users

**SQL Editor** en Supabase Dashboard:

```sql
-- Verificar que la tabla auth.users existe
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'auth' AND table_name = 'users';

-- Verificar que hay usuarios
SELECT id, email, created_at
FROM auth.users
LIMIT 5;
```

**Resultado esperado**:
- Primera query: Debe retornar 1 fila con `auth.users`
- Segunda query: Debe mostrar los usuarios registrados

---

## 🛠️ Soluciones

### Solución 1: Reiniciar el Proyecto Supabase

Si el proyecto está pausado:

1. Dashboard → Project Settings → General
2. Click en **"Restore project"**
3. Esperar 2-3 minutos
4. Volver a intentar el login

### Solución 2: Verificar/Regenerar las API Keys

1. Dashboard → Settings → API
2. Verificar que las keys mostradas coincidan con `SupabaseOptions`
3. Si no coinciden, actualizar `lib/core/supabase/supabase_options.dart`

### Solución 3: Crear Usuario Manualmente

Si el usuario `algonclagu@gmail.com` no existe:

**Opción A - Desde Dashboard**:
1. Dashboard → Authentication → Users
2. Click **"Invite user"** o **"Create new user"**
3. Email: `algonclagu@gmail.com`
4. Password: `123456`
5. Auto Confirm: **✅ Activado**

**Opción B - Desde SQL Editor**:

```sql
-- SOLO si el usuario NO existe
-- Verificar primero:
SELECT email FROM auth.users WHERE email = 'algonclagu@gmail.com';

-- Si no existe, crear (ejecutar EN EL DASHBOARD, NO en código):
-- La creación debe hacerse desde el dashboard de Supabase
```

**⚠️ IMPORTANTE**: La creación de usuarios debe hacerse desde el Dashboard de Supabase o usando el método `signUp()`, NO directamente en SQL.

### Solución 4: Verificar Row Level Security (RLS)

Las tablas `auth.users` y `auth.sessions` NO deben tener RLS activado (son gestionadas internamente por Supabase).

```sql
-- Verificar que auth.users NO tiene RLS
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'auth' AND tablename = 'users';

-- Resultado esperado: rowsecurity = false
```

### Solución 5: Verificar la Red/Firewall

Si estás en una red corporativa o con VPN:

1. Intentar desde otra red (ej: hotspot móvil)
2. Verificar que `https://TU_PROJECT_ID.supabase.co` sea accesible desde el navegador
3. Revisar si hay restricciones de firewall

---

## 🧪 Testing Rápido

### Método 1: Probar desde el navegador

```javascript
// Abrir Developer Tools (F12) en https://supabase.com/dashboard
// Ejecutar en Console:

const supabase = require('@supabase/supabase-js').createClient(
  'https://TU_PROJECT_ID.supabase.co',
  'TU_ANON_KEY'
);

const { data, error } = await supabase.auth.signInWithPassword({
  email: 'algonclagu@gmail.com',
  password: '123456'
});

console.log('Result:', data, error);
```

### Método 2: Usar Postman/Insomnia

```http
POST https://TU_PROJECT_ID.supabase.co/auth/v1/token?grant_type=password
Content-Type: application/json
apikey: TU_ANON_KEY

{
  "email": "algonclagu@gmail.com",
  "password": "123456"
}
```

**Respuesta esperada**: `200 OK` con `access_token` y `refresh_token`

---

## 📝 Checklist de Verificación

Antes de continuar, verificar:

- [ ] Proyecto Supabase está **activo** (no pausado)
- [ ] Las credenciales en `SupabaseOptions` son correctas
- [ ] La URL tiene el formato `https://xxx.supabase.co` (NO `supabase.com`)
- [ ] La anon key empieza con `eyJ...`
- [ ] El usuario `algonclagu@gmail.com` existe en auth.users
- [ ] El usuario tiene `email_confirmed_at` no nulo
- [ ] La contraseña es correcta
- [ ] No hay restricciones de red/firewall

---

## 🔄 Siguiente Paso

Una vez verificado todo lo anterior:

1. **Hot Restart** de la app Flutter:
   ```bash
   # Detener la app (Ctrl+C)
   flutter run --flavor dev -t lib/main_dev.dart
   ```

2. Verificar los logs en consola:
   ```
   🔑 AuthService: Intentando signIn con Supabase para algonclagu@gmail.com
   ✅ AuthService: SignIn exitoso - User: algonclagu@gmail.com  ← Esperado
   ```

---

## 💡 Solución Temporal (Solo para desarrollo)

Si necesitas continuar desarrollando mientras se resuelve el problema de Supabase, puedes volver a activar el bypass temporal:

```dart
// lib/core/services/auth_service.dart (SOLO TEMPORALMENTE)

Future<AuthResult<AuthResponse>> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  // 🚨 BYPASS TEMPORAL - ELIMINAR CUANDO SUPABASE FUNCIONE
  if (F.appFlavor == Flavor.dev && email == 'algonclagu@gmail.com') {
    debugPrint('⚠️ [BYPASS TEMPORAL] Mock login para desarrollo');
    // ... código de bypass anterior ...
  }

  // Código normal de Supabase
  // ...
}
```

**⚠️ RECORDAR**: Eliminar este bypass cuando Supabase esté funcionando correctamente.

---

## 📞 Soporte

Si el problema persiste después de seguir todos los pasos:

1. Revisar logs de Supabase: Dashboard → Logs → Auth Logs
2. Contactar soporte de Supabase con el error completo
3. Verificar el status de Supabase: [https://status.supabase.com](https://status.supabase.com)
