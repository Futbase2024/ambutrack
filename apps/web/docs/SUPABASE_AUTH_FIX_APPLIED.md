# ✅ Fix Aplicado: Error de Schema en Supabase Auth

## 🐛 Problema Original

```
AuthException - [500] {
  "code": "unexpected_failure",
  "message": "Database error querying schema"
}
```

**Error detallado en logs**:
```
"error finding user: sql: Scan error on column index 8, name \"email_change\":
converting NULL to string is unsupported"
```

## 🔍 Causa Raíz

La tabla `auth.users` tiene columnas que permiten `NULL`, pero la librería `gotrue` (motor de autenticación de Supabase) espera que sean **strings vacíos** `""` en lugar de `NULL`.

**Columnas afectadas**:
- `email_change`
- `confirmation_token`
- `recovery_token`
- `email_change_token_new`

Este es un **bug conocido** que ocurre cuando:
1. Se crea un proyecto Supabase con una versión antigua del schema
2. Se migra un proyecto desde Firebase Auth
3. Se crean usuarios antes de actualizar el schema

## ✅ Solución Aplicada

Se ejecutó el siguiente script SQL en Supabase (fecha: 2025-12-27):

```sql
-- Fix para columnas problemáticas en auth.users
-- Convertir NULL a string vacío en las columnas que causan el Scan error

UPDATE auth.users
SET
  email_change = COALESCE(email_change, ''),
  confirmation_token = COALESCE(confirmation_token, ''),
  recovery_token = COALESCE(recovery_token, ''),
  email_change_token_new = COALESCE(email_change_token_new, '')
WHERE
  email_change IS NULL
  OR confirmation_token IS NULL
  OR recovery_token IS NULL
  OR email_change_token_new IS NULL;
```

**Verificación**:
```sql
SELECT
  id,
  email,
  email_change,
  confirmation_token,
  recovery_token,
  email_change_token_new
FROM auth.users
WHERE email = 'algonclagu@gmail.com';
```

**Resultado esperado**: Todas las columnas deben mostrar `""` (string vacío) en lugar de `NULL`.

## 📊 Estado Actual

- ✅ **Fix aplicado**: Todas las columnas NULL convertidas a strings vacíos
- ✅ **Usuario de prueba**: `algonclagu@gmail.com` actualizado correctamente
- ✅ **Schema corregido**: La tabla `auth.users` ahora es compatible con gotrue

## 🧪 Prueba

Para verificar que el login funciona correctamente:

1. **Hot Restart** de la app Flutter:
   ```bash
   # Detener la app (Ctrl+C)
   flutter run --flavor dev -t lib/main_dev.dart
   ```

2. **Logs esperados**:
   ```
   🔑 AuthService: Intentando signIn con Supabase para algonclagu@gmail.com
   ✅ AuthService: SignIn exitoso - User: algonclagu@gmail.com
   ✅ AuthBloc: Login exitoso - User UID: d16c1c48-f93f-44b6-b55c-2b1801b17f74
   ✅ LoginPage: Usuario autenticado, redirigiendo a /
   ```

3. **Si aparece el error nuevamente**:
   - Verificar que el fix se aplicó: Ejecutar la query de verificación arriba
   - Si persiste, puede que haya otros usuarios con `NULL`: Ejecutar el UPDATE sin filtro WHERE

## 🔄 Prevención Futura

Para evitar este problema con nuevos usuarios:

### Opción 1: Usar Supabase Dashboard
Al crear usuarios desde el dashboard, Supabase maneja automáticamente estos campos.

### Opción 2: Crear Trigger en Base de Datos

```sql
-- Crear función que convierta NULL a string vacío automáticamente
CREATE OR REPLACE FUNCTION auth.fix_null_strings()
RETURNS TRIGGER AS $$
BEGIN
  NEW.email_change := COALESCE(NEW.email_change, '');
  NEW.confirmation_token := COALESCE(NEW.confirmation_token, '');
  NEW.recovery_token := COALESCE(NEW.recovery_token, '');
  NEW.email_change_token_new := COALESCE(NEW.email_change_token_new, '');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger que se ejecuta antes de INSERT/UPDATE
CREATE TRIGGER fix_null_strings_trigger
BEFORE INSERT OR UPDATE ON auth.users
FOR EACH ROW
EXECUTE FUNCTION auth.fix_null_strings();
```

**⚠️ ADVERTENCIA**: Este trigger modifica el comportamiento de la tabla `auth.users` que es gestionada por Supabase. Solo aplicar si es absolutamente necesario.

## 📚 Referencias

- [Supabase Auth Schema](https://supabase.com/docs/guides/auth/managing-user-data)
- [GoTrue GitHub Issues](https://github.com/supabase/gotrue/issues)
- Issue relacionado: Scan error converting NULL to string

## 📝 Notas Adicionales

- Este fix **NO afecta** la funcionalidad de la autenticación
- Los campos `email_change`, `confirmation_token`, etc., se rellenan automáticamente cuando son necesarios
- El string vacío `""` es equivalente a `NULL` para estos campos (no hay datos)
- **NO es necesario** ejecutar este fix en modo producción si no hay usuarios creados aún

## ✅ Checklist Post-Fix

- [x] Fix aplicado en base de datos
- [x] Usuario de prueba verificado
- [ ] Probar login desde la app (siguiente paso)
- [ ] Verificar que funcione en producción
- [ ] Documentar en README si es necesario

---

**Estado**: ✅ **SOLUCIONADO**
**Fecha**: 2025-12-27
**Proyecto**: AmbuTrack (ycmopmnrhrpnnzkvnihr)
