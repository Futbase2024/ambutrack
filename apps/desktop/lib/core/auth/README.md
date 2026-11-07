# 🔐 Sistema de Roles y Permisos - AmbuTrack

**Estado**: ✅ Implementado
**Versión**: 1.0
**Fecha**: 2025-12-26

---

## 📁 Estructura de Archivos

```
lib/core/auth/
├── enums/
│   ├── user_role.dart          # 10 roles del sistema
│   └── app_module.dart         # 50+ módulos de la aplicación
├── permissions/
│   └── role_permissions.dart   # Mapa de rol → módulos permitidos
├── services/
│   └── role_service.dart       # Servicio de verificación de permisos
└── README.md                    # Este archivo
```

---

## 🚀 Inicio Rápido

### 1. Inyectar RoleService en tu código

```dart
import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:get_it/get_it.dart';

final RoleService roleService = getIt<RoleService>();
```

### 2. Verificar Acceso a un Módulo

```dart
import 'package:ambutrack_web/core/auth/enums/app_module.dart';

final bool hasAccess = await roleService.hasAccessToModule(AppModule.personal);

if (hasAccess) {
  // Permitir acceso
} else {
  // Denegar acceso
}
```

### 3. Obtener Rol del Usuario Actual

```dart
import 'package:ambutrack_web/core/auth/enums/user_role.dart';

final UserRole role = await roleService.getCurrentUserRole();

if (role.isAdmin) {
  // Mostrar opciones de administrador
}
```

---

## 📋 Roles Disponibles

| Rol | Valor | Descripción | Módulos |
|-----|-------|-------------|---------|
| **Admin** | `admin` | Acceso total | Todos (50+) |
| **Jefe Personal** | `jefe_personal` | RRHH y turnos | 16 módulos |
| **Jefe Tráfico** | `jefe_trafico` | Operaciones y servicios | 21 módulos |
| **Coordinador** | `coordinador` | Supervisión operativa | 7 módulos |
| **Administrativo** | `administrativo` | Gestión documental | 6 módulos |
| **Conductor** | `conductor` | Acceso a datos propios | 3 módulos |
| **Sanitario** | `sanitario` | Acceso a datos propios | 3 módulos |
| **Gestor** | `gestor` | Gestión de flota | 8 módulos |
| **Técnico** | `tecnico` | Mantenimiento | 4 módulos |
| **Operador** | `operador` | Solo lectura | 3 módulos |

---

## 🛠️ Casos de Uso

### Caso 1: Ocultar Botón según Permisos

```dart
// En un widget
final RoleService roleService = getIt<RoleService>();
final bool isAdmin = await roleService.isAdmin();

if (isAdmin) {
  IconButton(
    icon: Icon(Icons.delete),
    onPressed: () => _deleteItem(),
  ),
}
```

### Caso 2: Proteger Ruta en GoRouter

```dart
// En app_router.dart
GoRoute(
  path: '/administracion/usuarios',
  name: 'usuarios',
  builder: (context, state) => UsuariosPage(),
  redirect: (context, state) async {
    final roleService = getIt<RoleService>();
    final hasAccess = await roleService.hasAccessToRoute('/administracion/usuarios');

    if (!hasAccess) {
      return '/'; // Redirigir a dashboard
    }

    return null;
  },
),
```

### Caso 3: Filtrar Menú según Rol

```dart
// En MenuWidget
final roleService = getIt<RoleService>();
final allowedModules = await roleService.getAllowedModules();

final visibleItems = allMenuItems.where((item) {
  final module = AppModule.fromString(item.moduleKey);
  return module != null && allowedModules.contains(module);
}).toList();
```

---

## 🔗 Integración con Supabase

### Tabla `tpersonal`

El rol se almacena en el campo `categoria`:

```sql
CREATE TABLE tpersonal (
  id UUID PRIMARY KEY,
  nombre VARCHAR NOT NULL,
  apellidos VARCHAR NOT NULL,
  usuario_id UUID REFERENCES auth.users(id),
  categoria VARCHAR,  -- Rol: 'admin', 'jefe_personal', etc.
  activo BOOLEAN DEFAULT true,
  -- ... otros campos
);
```

### Actualizar Rol de un Usuario

```sql
-- Asignar rol de administrador
UPDATE tpersonal
SET categoria = 'admin'
WHERE usuario_id = '<UUID_DEL_USUARIO>';

-- Asignar rol de jefe de personal
UPDATE tpersonal
SET categoria = 'jefe_personal'
WHERE email = 'jefe@ejemplo.com';
```

---

## ✅ Checklist de Integración

### Backend (Supabase)

- [ ] Verificar que tabla `tpersonal` tiene campo `categoria`
- [ ] Actualizar roles de usuarios existentes en BD
- [ ] Configurar Row Level Security (RLS) según roles

### Frontend (Flutter)

- [ ] Configurar DI en `lib/core/di/locator.dart`:
  ```dart
  @module
  abstract class AppModule {
    @lazySingleton
    RoleService get roleService => RoleService(get(), get());
  }
  ```
- [ ] Ejecutar `flutter pub run build_runner build`
- [ ] Integrar con GoRouter para protección de rutas
- [ ] Actualizar menú para filtrar opciones según rol
- [ ] Actualizar formularios con validaciones por rol
- [ ] Ejecutar `flutter analyze` (debe dar 0 warnings)

### Testing

- [ ] Crear tests unitarios para `RoleService`
- [ ] Crear tests de integración para rutas protegidas
- [ ] Verificar flujo completo con diferentes roles

---

## 📚 Documentación Completa

Ver documentación detallada en:
- [docs/arquitectura/sistema_roles.md](../../../docs/arquitectura/sistema_roles.md)

---

## 🐛 Troubleshooting

### Error: "No se encontró Personal para usuario X"

**Causa**: El usuario autenticado no tiene un registro en `tpersonal` con su `usuario_id`.

**Solución**:
```sql
UPDATE tpersonal
SET usuario_id = '<UUID_SUPABASE_AUTH>'
WHERE id = '<ID_PERSONAL>';
```

### Error: "Rol por defecto: operador"

**Causa**: El campo `categoria` está vacío o tiene un valor no válido.

**Solución**:
```sql
UPDATE tpersonal
SET categoria = 'admin'  -- o el rol correspondiente
WHERE usuario_id = '<UUID_SUPABASE_AUTH>';
```

### Cache no se actualiza

**Solución**:
```dart
final roleService = getIt<RoleService>();
await roleService.refreshCurrentPersonal();
```

---

## 📞 Soporte

Para dudas o problemas, consultar:
- Documentación completa en `docs/arquitectura/sistema_roles.md`
- Código fuente en `lib/core/auth/`

---

**Última actualización**: 2025-12-26
**Autor**: Sistema AmbuTrack
