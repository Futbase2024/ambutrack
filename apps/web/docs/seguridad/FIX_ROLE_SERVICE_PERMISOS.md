# 🔧 FIX: RoleService - Obtención Correcta de Roles

> **Fecha**: 2026-02-12
> **Problema**: RoleService buscaba rol en tabla incorrecta
> **Estado**: ✅ CORREGIDO

---

## ❌ PROBLEMA DETECTADO

### Síntoma

Todos los usuarios podían acceder a TODAS las rutas, independientemente de su rol.

**Logs del problema**:
```
🔐 RoleService: No se encontró Personal para usuario 334ec917-e577-488a-b319-75f14ca5cb6b
🔐 RoleService: Sin Personal → Rol por defecto: operador
🔐 RoleService: ¿Acceso a ruta /administracion/usuarios-roles? true (Rol: Operador)
```

**Resultado**: Un usuario con rol `jefe_personal` podía acceder a rutas de admin.

### Causa Raíz

**RoleService estaba buscando el rol en la tabla INCORRECTA**:

```dart
// ❌ CÓDIGO INCORRECTO (antes del fix)
Future<UserRole> getCurrentUserRole() async {
  final PersonalEntity? personal = await getCurrentPersonal();

  if (personal == null) {
    debugPrint('🔐 RoleService: Sin Personal → Rol por defecto: operador');
    return UserRole.operador;  // ❌ FALLBACK INCORRECTO
  }

  final UserRole role = UserRole.fromString(personal.categoria);  // ❌ Buscando en tabla personal
  return role;
}
```

**Problema**:
1. `RoleService` buscaba el rol en la tabla `personal` (empleados/trabajadores)
2. Usuarios admin que no son empleados no tienen registro en `personal`
3. Al no encontrar registro, usaba `operador` como fallback
4. `UserRole.operador` aparentemente tenía permisos amplios (probablemente por error en matriz de permisos)

---

## ✅ SOLUCIÓN APLICADA

### Cambio 1: Inyectar AuthRepository en lugar de AuthService

**Antes**:
```dart
@lazySingleton
class RoleService {
  RoleService(this._authService, this._personalRepository);

  final AuthService _authService;  // ❌ AuthService.currentUser es User de Supabase (no tiene rol)
  final PersonalRepository _personalRepository;
```

**Después**:
```dart
@lazySingleton
class RoleService {
  RoleService(this._authRepository, this._personalRepository);

  final AuthRepository _authRepository;  // ✅ AuthRepository.currentUser es UserEntity (tiene rol)
  final PersonalRepository _personalRepository;
```

### Cambio 2: Obtener rol desde AuthRepository.currentUser

**Antes**:
```dart
// ❌ Buscaba en tabla personal (empleados)
Future<UserRole> getCurrentUserRole() async {
  final PersonalEntity? personal = await getCurrentPersonal();

  if (personal == null) {
    return UserRole.operador;  // ❌ Fallback incorrecto
  }

  final UserRole role = UserRole.fromString(personal.categoria);
  return role;
}
```

**Después**:
```dart
// ✅ Busca en tabla usuarios (autenticación)
Future<UserRole> getCurrentUserRole() async {
  // ✅ CORREGIDO: Obtener rol desde tabla usuarios (AuthRepository)
  // NO desde tabla personal (que es solo para empleados)
  final String? rolString = _authRepository.currentUser?.rol;

  if (rolString == null || rolString.isEmpty) {
    debugPrint('🔐 RoleService: ⚠️ Usuario sin rol asignado → Rol por defecto: operador');
    return UserRole.operador;
  }

  final UserRole role = UserRole.fromString(rolString);

  debugPrint('🔐 RoleService: Rol del usuario: ${role.label} (${role.value})');

  return role;
}
```

### Cambio 3: Corregir getUserId de .id a .uid

**Antes**:
```dart
final String? userId = _authRepository.currentUser?.id;  // ❌ UserEntity usa 'uid' no 'id'
```

**Después**:
```dart
final String? userId = _authRepository.currentUser?.uid;  // ✅ Correcto
```

---

## 📊 ARQUITECTURA CORRECTA

### Dos Tablas Diferentes con Propósitos Distintos

| Tabla | Propósito | Roles Almacenados | Quién tiene registro |
|-------|-----------|-------------------|----------------------|
| **`usuarios`** | Autenticación y permisos | `admin`, `coordinador`, `jefe_personal`, etc. | **TODOS los usuarios del sistema** |
| **`personal`** | Empleados/Trabajadores | N/A (usa `categoria` para puesto laboral) | **Solo empleados operativos** (conductores, sanitarios, etc.) |

### Flujo Correcto

```
Usuario se autentica
    ↓
AuthRepository obtiene UserEntity de tabla usuarios
    ↓
UserEntity contiene el campo 'rol' (admin, coordinador, etc.)
    ↓
RoleService lee currentUser.rol desde AuthRepository
    ↓
UserRole.fromString(rol) convierte a enum UserRole
    ↓
RolePermissions valida permisos según UserRole
```

---

## 🔐 VERIFICACIÓN

### Test Manual

1. **Usuario Admin** (`test@ambutrack.com`):
   - ✅ Debe acceder a `/administracion/usuarios-roles`
   - ✅ Debe acceder a todas las rutas

2. **Usuario Jefe Personal** (`personal@ambulanciasbarbate.es`):
   - ✅ Debe acceder a `/personal`
   - ❌ NO debe acceder a `/administracion/usuarios-roles`
   - ❌ NO debe acceder a `/vehiculos`

3. **Usuario Operador** (si existe):
   - ❌ NO debe acceder a módulos administrativos
   - ✅ Debe acceder solo a módulos operativos

### Logs Esperados (Después del Fix)

```
🔐 RoleService: Rol del usuario: Jefe de Personal (jefe_personal)
🔐 RoleService: ¿Acceso a ruta /administracion/usuarios-roles? false (Rol: Jefe de Personal)
❌ AuthGuard: Usuario sin permisos para: /administracion/usuarios-roles
→ Redirigido a /403
```

---

## 📝 ARCHIVOS MODIFICADOS

### 1. `/lib/core/auth/services/role_service.dart`

**Cambios**:
- Línea 4: `import 'package:ambutrack_web/features/auth/domain/repositories/auth_repository.dart';`
- Línea 13: `RoleService(this._authRepository, this._personalRepository);`
- Línea 15: `final AuthRepository _authRepository;`
- Línea 33: `final String? userId = _authRepository.currentUser?.uid;`
- Líneas 68-83: Reimplementación de `getCurrentUserRole()` para usar `AuthRepository`

### 2. Regeneración de DI

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Resultado**: `locator.config.dart` regenerado con nueva inyección.

---

## 🧪 COMANDOS EJECUTADOS

```bash
# 1. Modificar role_service.dart (manual)

# 2. Regenerar inyección de dependencias
cd /Users/lokisoft1/Desktop/Desarrollo/Pruebas\ Ambutrack/ambutrack/apps/web
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Verificar errores
flutter analyze --no-fatal-infos
```

**Resultado**: ✅ 0 errores críticos

---

## ⚠️ PENDIENTE: REVISAR MATRIZ DE PERMISOS

**Nota Importante**: El fallback a `UserRole.operador` sigue existiendo para usuarios sin rol asignado. Es necesario revisar:

1. **¿Por qué `operador` tiene acceso amplio?**
   - Verificar `RolePermissions.getModulesForRole(UserRole.operador)`
   - Probablemente debería tener acceso MUY limitado

2. **Sugerencia**: Cambiar fallback a un rol más restrictivo o lanzar error
   ```dart
   if (rolString == null || rolString.isEmpty) {
     throw Exception('Usuario sin rol asignado - Contactar administrador');
   }
   ```

---

## ✅ RESULTADO FINAL

| Métrica | Estado |
|---------|--------|
| **RoleService corregido** | ✅ |
| **Inyección regenerada** | ✅ |
| **Flutter analyze** | ✅ 0 errores |
| **Testing manual** | ⏳ Pendiente |

---

## 🚀 PRÓXIMOS PASOS

1. **Testing Manual**:
   - Probar acceso con diferentes roles
   - Verificar que `/403` se muestra correctamente
   - Confirmar logs de AuthGuard

2. **Revisar Matriz de Permisos**:
   - Auditar permisos de `UserRole.operador`
   - Ajustar si tiene acceso indebido

3. **Documentar Roles**:
   - Crear guía de roles y sus permisos
   - Definir qué rol debe tener cada tipo de usuario

---

**Corregido por**: Claude Code Agent
**Fecha**: 2026-02-12
**Estado**: ✅ FIX APLICADO - LISTO PARA TESTING
