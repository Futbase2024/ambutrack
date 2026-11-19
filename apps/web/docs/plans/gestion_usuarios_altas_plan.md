# Plan: Alta y gestión segura de usuarios

> Fecha: 2026-11-19 · Rama: `features/taller_vehiculos`

## Decisiones acordadas

| Rol | Crear / editar / restablecer clave / activar | Eliminar | Roles que puede asignar |
|---|---|---|---|
| Administrador | ✅ | ✅ | Todos |
| Jefe de Personal | ✅ (solo usuarios de su empresa) | ❌ | administrativo, conductor, operador, sanitario, técnico |
| Jefe de Tráfico / Coordinador | Solo consulta | ❌ | — |
| Resto | Sin acceso | ❌ | — |

- Alta con **contraseña provisional** (PIN de 6 dígitos para la app móvil o contraseña web).
- **Cambio obligatorio** de la clave en el primer acceso (web y móvil).
- El registro público de Supabase queda **desactivado**.

## Problemas detectados en el estado anterior

1. Alta con `signUp()` desde el navegador + cambio de sesión del admin + RPC `auto_confirm_user` → frágil y obliga a tener el registro público abierto.
2. `delete` llamaba a `auth.admin.deleteUser` desde el cliente (sin service_role, no funcionaba).
3. `resetear-clave` permitía a coordinador / jefe de tráfico cambiar la clave de **cualquiera**, incluido un admin (escalada de privilegios).
4. La política "Users can update their own data" dejaba a un usuario cambiarse `activo`, `empresa_id`, `personal_id`, `dni`.
5. RLS de `usuarios` solo dejaba ver la lista al admin.

## Implementación

### Base de datos (migración `gestion_usuarios_seguridad`)
- `usuarios.debe_cambiar_password boolean not null default false`.
- `fn_puede_ver_usuarios()` + política SELECT para gestión (misma empresa).
- Trigger `trg_usuarios_proteger_columnas`: un no-admin no puede cambiar rol, activo, empresa, personal, email, DNI ni el flag.
- `DROP FUNCTION auto_confirm_user`.

### Edge Functions
- `admin-users` (reescrita): `create`, `update`, `reset_password`, `set_active`, `delete`, `change_own_password`.
  Valida rol del llamante, jerarquía de roles y empresa en servidor. Registra cada acción en `audit_log`.
- `resetear-clave`: endurecida con las mismas reglas (compatibilidad con builds antiguas).

### Core (`ambutrack_core_datasource`)
- Nuevo datasource `cuentas_usuario/` (contract + factory + impl Supabase vía Edge Function).

### Web
- `UsuariosRepositoryImpl`: escrituras vía `CuentasUsuarioDataSource`.
- `GestionUsuariosPermissions`: reglas de rol en cliente (UI).
- Formulario: roles filtrados, tipo de clave (PIN / contraseña), empresa fija para jefe de personal.
- Toolbar / panel: acciones deshabilitadas en modo consulta.
- `CambioClaveObligatorioGate` sobre toda la app.

### Móvil
- `AuthRepository`: `debeCambiarClave()` / `cambiarMiClave()`.
- `CambioClaveObligatorioGate` (nuevo PIN de 6 dígitos) bajo el `AppLockGate`.

## Manual (Dashboard de Supabase)
- Authentication → Sign In / Providers → desactivar **Allow new users to sign up**.
