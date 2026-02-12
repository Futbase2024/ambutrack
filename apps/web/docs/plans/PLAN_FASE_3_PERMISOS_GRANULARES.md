# 🔐 PLAN DE IMPLEMENTACIÓN - FASE 3: PERMISOS GRANULARES

> **Proyecto**: AmbuTrack Web
> **Fase**: Fase 3 - Permisos Granulares (CRUD)
> **Fecha**: 2026-02-12
> **Prioridad**: MEDIA
> **Estimación**: 2 semanas
> **Estado**: 📋 PLANIFICACIÓN

---

## 📋 ÍNDICE

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Objetivos](#objetivos)
3. [Matriz de Permisos CRUD](#matriz-de-permisos-crud)
4. [Arquitectura de Solución](#arquitectura-de-solución)
5. [Implementación Detallada](#implementación-detallada)
6. [Testing](#testing)
7. [Checklist de Implementación](#checklist-de-implementación)

---

## 1. RESUMEN EJECUTIVO

### Contexto

**Fase 1 y 2 completadas** ✅:
- ✅ AuthGuard valida permisos a nivel de **módulo completo**
- ✅ RLS en Supabase protege datos a nivel de base de datos
- ✅ Gestión de usuarios funcional
- ✅ Página 403 para acceso denegado

**Limitación actual**:
- Los permisos son "todo o nada" a nivel de módulo
- Ejemplo: Si `jefe_personal` tiene acceso a `/personal`, puede hacer **CUALQUIER** operación (crear, editar, eliminar)
- No hay control granular sobre **qué puede hacer** dentro de un módulo

### Solución: Permisos CRUD Granulares

Implementar control a nivel de **operación específica** dentro de cada módulo:
- ✅ **Create**: ¿Puede crear nuevos registros?
- ✅ **Read**: ¿Puede ver registros?
- ✅ **Update**: ¿Puede editar registros existentes?
- ✅ **Delete**: ¿Puede eliminar registros?

### Ejemplo Práctico

**Antes (Fase 1-2)**:
```
jefe_personal → Acceso a /personal → Puede hacer TODO
```

**Después (Fase 3)**:
```
jefe_personal → Acceso a /personal
  ✅ Read: Puede ver todo el personal
  ✅ Update: Puede editar datos
  ❌ Create: NO puede crear nuevo personal (solo admin)
  ❌ Delete: NO puede eliminar personal (solo admin)
```

---

## 2. OBJETIVOS

### Objetivo Principal

Implementar **permisos CRUD granulares** por rol en los 4 módulos críticos:
1. **Personal** (RRHH)
2. **Vehículos** (Flota)
3. **Servicios** (Operaciones)
4. **Usuarios y Roles** (Administración)

### Objetivos Específicos

1. **Definir matriz de permisos CRUD**
   - Documentar qué puede hacer cada rol en cada módulo
   - Validar con stakeholders antes de implementar

2. **Implementar `CrudPermissions` class**
   - Similar a `RolePermissions`
   - Métodos: `canCreate()`, `canRead()`, `canUpdate()`, `canDelete()`

3. **Modificar UI según permisos**
   - Ocultar botones de "Crear" si usuario no tiene permiso
   - Deshabilitar botones de "Editar/Eliminar" si usuario no tiene permiso
   - Mostrar tooltips explicativos cuando un botón está deshabilitado

4. **Validar permisos en BLoCs**
   - Añadir checks antes de ejecutar operaciones CRUD
   - Emitir estados de error si usuario no tiene permiso
   - Mostrar diálogos profesionales con mensaje claro

5. **Testing completo**
   - Unit tests para `CrudPermissions`
   - Widget tests para UI con permisos
   - Integration tests para flujos completos

---

## 3. MATRIZ DE PERMISOS CRUD

### 3.1. Módulo: PERSONAL (RRHH)

| Rol | Read | Create | Update | Delete | Notas |
|-----|------|--------|--------|--------|-------|
| **Admin** | ✅ | ✅ | ✅ | ✅ | Acceso total |
| **Jefe Personal** | ✅ | ✅ | ✅ | ❌ | Puede gestionar, pero no eliminar |
| **Administrativo** | ✅ | ❌ | ❌ | ❌ | Solo lectura |
| **Jefe Tráfico** | ✅ | ❌ | ❌ | ❌ | Solo lectura (para planificación) |
| **Coordinador** | ✅ | ❌ | ❌ | ❌ | Solo lectura (para operaciones) |
| **Conductor** | ✅* | ❌ | ✅* | ❌ | Solo sus propios datos |
| **Sanitario** | ✅* | ❌ | ✅* | ❌ | Solo sus propios datos |
| **Gestor** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Técnico** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Operador** | ✅ | ❌ | ❌ | ❌ | Solo lectura |

**\*** Solo sus propios datos (filtrado por `usuario_id`)

---

### 3.2. Módulo: VEHÍCULOS (Flota)

| Rol | Read | Create | Update | Delete | Notas |
|-----|------|--------|--------|--------|-------|
| **Admin** | ✅ | ✅ | ✅ | ✅ | Acceso total |
| **Jefe Tráfico** | ✅ | ✅ | ✅ | ❌ | Gestión operativa |
| **Gestor** | ✅ | ❌ | ✅ | ❌ | Puede actualizar estado/mantenimiento |
| **Técnico** | ✅ | ❌ | ✅* | ❌ | Solo mantenimiento/averías |
| **Coordinador** | ✅ | ❌ | ❌ | ❌ | Solo lectura |
| **Administrativo** | ✅ | ❌ | ❌ | ❌ | Solo lectura |
| **Jefe Personal** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Conductor** | ✅ | ❌ | ❌ | ❌ | Solo lectura (vehículo asignado) |
| **Sanitario** | ✅ | ❌ | ❌ | ❌ | Solo lectura (vehículo asignado) |
| **Operador** | ✅ | ❌ | ❌ | ❌ | Solo lectura |

**\*** Técnico solo puede actualizar campos de mantenimiento

---

### 3.3. Módulo: SERVICIOS (Operaciones)

| Rol | Read | Create | Update | Delete | Notas |
|-----|------|--------|--------|--------|-------|
| **Admin** | ✅ | ✅ | ✅ | ✅ | Acceso total |
| **Jefe Tráfico** | ✅ | ✅ | ✅ | ✅ | Gestión operativa completa |
| **Coordinador** | ✅ | ❌ | ✅* | ❌ | Solo actualizar estado/incidencias |
| **Administrativo** | ✅ | ❌ | ❌ | ❌ | Solo lectura |
| **Conductor** | ✅* | ❌ | ✅* | ❌ | Solo sus servicios asignados |
| **Sanitario** | ✅* | ❌ | ✅* | ❌ | Solo sus servicios asignados |
| **Jefe Personal** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Gestor** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Técnico** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Operador** | ✅ | ❌ | ❌ | ❌ | Solo lectura |

**\*** Solo servicios asignados (filtrado por `conductor_id` o `sanitario_id`)

---

### 3.4. Módulo: USUARIOS Y ROLES (Administración)

| Rol | Read | Create | Update | Delete | Notas |
|-----|------|--------|--------|--------|-------|
| **Admin** | ✅ | ✅ | ✅ | ✅ | Acceso total |
| **Jefe Personal** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Jefe Tráfico** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Coordinador** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Administrativo** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Conductor** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Sanitario** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Gestor** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Técnico** | ❌ | ❌ | ❌ | ❌ | Sin acceso |
| **Operador** | ❌ | ❌ | ❌ | ❌ | Sin acceso |

**Nota**: Solo `admin` puede gestionar usuarios y roles por seguridad.

---

### 3.5. Módulo: TABLAS MAESTRAS (Configuración)

| Rol | Read | Create | Update | Delete | Notas |
|-----|------|--------|--------|--------|-------|
| **Admin** | ✅ | ✅ | ✅ | ✅ | Acceso total |
| **Jefe Personal** | ✅ | ✅ | ✅ | ❌ | Puede gestionar categorías, perfiles |
| **Jefe Tráfico** | ✅ | ✅ | ✅ | ❌ | Puede gestionar tipos de servicio, rutas |
| **Coordinador** | ✅ | ❌ | ❌ | ❌ | Solo lectura |
| **Administrativo** | ✅ | ❌ | ❌ | ❌ | Solo lectura |
| **Otros** | ❌ | ❌ | ❌ | ❌ | Sin acceso |

---

## 4. ARQUITECTURA DE SOLUCIÓN

### 4.1. Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                    USUARIO AUTENTICADO                       │
│                     (con UserRole)                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      RoleService                             │
│  - getCurrentUserRole() → UserRole                          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   CrudPermissions                            │
│  - canCreate(role, module) → bool                           │
│  - canRead(role, module) → bool                             │
│  - canUpdate(role, module) → bool                           │
│  - canDelete(role, module) → bool                           │
└────────────────┬───────────────┬────────────────────────────┘
                 │               │
        ┌────────▼─────┐  ┌─────▼───────┐
        │   UI Layer   │  │  BLoC Layer │
        │  (Widgets)   │  │  (Business) │
        └──────────────┘  └─────────────┘
             │                   │
             │  1. Ocultar       │  2. Validar
             │     botones       │     operación
             │                   │
             ▼                   ▼
    ┌────────────────┐   ┌──────────────┐
    │ Botón "Crear"  │   │ BLoC Event   │
    │  Visible/No    │   │  Permitido/  │
    │                │   │  Error       │
    └────────────────┘   └──────────────┘
```

### 4.2. Flujo de Validación

**Escenario**: Usuario intenta eliminar un registro de Personal

```
1. Usuario hace clic en botón "Eliminar" (si está visible)
                    ↓
2. Widget captura evento onPressed
                    ↓
3. Muestra diálogo de confirmación
                    ↓
4. Usuario confirma
                    ↓
5. Dispara evento: PersonalDeleteRequested(id)
                    ↓
6. BLoC recibe evento
                    ↓
7. BLoC valida: CrudPermissions.canDelete(role, AppModule.personal)
                    ↓
         ┌──────────┴──────────┐
         │                     │
     ✅ TRUE                ❌ FALSE
         │                     │
         ▼                     ▼
   Ejecutar delete       Emitir error
   await repository      emit(ErrorState(
     .delete(id)           'No tienes permisos'))
         │                     │
         ▼                     ▼
   emit(Success)         Cerrar loading
                         Mostrar diálogo error
```

---

## 5. IMPLEMENTACIÓN DETALLADA

### 5.1. Crear `CrudPermissions` Class

**Ubicación**: `/lib/core/auth/permissions/crud_permissions.dart`

```dart
import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';

/// Permisos CRUD granulares por rol y módulo
///
/// Define qué operaciones específicas (Create, Read, Update, Delete)
/// puede realizar cada rol en cada módulo del sistema.
class CrudPermissions {
  // ==========================================
  // MÉTODOS PÚBLICOS
  // ==========================================

  /// Verifica si el rol puede CREAR registros en el módulo
  static bool canCreate(UserRole role, AppModule module) {
    // Admin siempre puede crear
    if (role.isAdmin) return true;

    final Map<AppModule, bool>? permissions = _createPermissions[role];
    return permissions?[module] ?? false;
  }

  /// Verifica si el rol puede LEER registros en el módulo
  static bool canRead(UserRole role, AppModule module) {
    // Admin siempre puede leer
    if (role.isAdmin) return true;

    final Map<AppModule, bool>? permissions = _readPermissions[role];
    return permissions?[module] ?? false;
  }

  /// Verifica si el rol puede ACTUALIZAR registros en el módulo
  static bool canUpdate(UserRole role, AppModule module) {
    // Admin siempre puede actualizar
    if (role.isAdmin) return true;

    final Map<AppModule, bool>? permissions = _updatePermissions[role];
    return permissions?[module] ?? false;
  }

  /// Verifica si el rol puede ELIMINAR registros en el módulo
  static bool canDelete(UserRole role, AppModule module) {
    // Admin siempre puede eliminar
    if (role.isAdmin) return true;

    final Map<AppModule, bool>? permissions = _deletePermissions[role];
    return permissions?[module] ?? false;
  }

  /// Obtiene todos los permisos CRUD para un rol y módulo
  static CrudPermissionsModel getPermissions(UserRole role, AppModule module) {
    return CrudPermissionsModel(
      canCreate: canCreate(role, module),
      canRead: canRead(role, module),
      canUpdate: canUpdate(role, module),
      canDelete: canDelete(role, module),
    );
  }

  // ==========================================
  // PERMISOS: CREATE
  // ==========================================

  static final Map<UserRole, Map<AppModule, bool>> _createPermissions = {
    UserRole.admin: {
      // Admin puede crear en todos los módulos
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuarios: true,
      AppModule.tablas: true,
    },

    UserRole.jefePersonal: {
      AppModule.personal: true,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: true, // Puede crear categorías, perfiles
    },

    UserRole.jefeTrafic: {
      AppModule.personal: false,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuarios: false,
      AppModule.tablas: true, // Puede crear tipos de servicio, rutas
    },

    UserRole.coordinador: {
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false, // Solo actualiza estado
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.administrativo: {
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.conductor: {
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.sanitario: {
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.gestor: {
      AppModule.personal: false,
      AppModule.vehiculos: false, // Solo actualiza
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.tecnico: {
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.operador: {
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },
  };

  // ==========================================
  // PERMISOS: READ
  // ==========================================

  static final Map<UserRole, Map<AppModule, bool>> _readPermissions = {
    UserRole.admin: {
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuarios: true,
      AppModule.tablas: true,
    },

    UserRole.jefePersonal: {
      AppModule.personal: true,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: true,
    },

    UserRole.jefeTrafic: {
      AppModule.personal: true, // Para planificación
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuarios: false,
      AppModule.tablas: true,
    },

    UserRole.coordinador: {
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuarios: false,
      AppModule.tablas: true,
    },

    UserRole.administrativo: {
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: true,
    },

    UserRole.conductor: {
      AppModule.personal: true, // Solo sus datos
      AppModule.vehiculos: true, // Solo vehículo asignado
      AppModule.servicios: true, // Solo sus servicios
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.sanitario: {
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.gestor: {
      AppModule.personal: false,
      AppModule.vehiculos: true,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.tecnico: {
      AppModule.personal: false,
      AppModule.vehiculos: true,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.operador: {
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuarios: false,
      AppModule.tablas: true,
    },
  };

  // ==========================================
  // PERMISOS: UPDATE
  // ==========================================

  static final Map<UserRole, Map<AppModule, bool>> _updatePermissions = {
    UserRole.admin: {
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuarios: true,
      AppModule.tablas: true,
    },

    UserRole.jefePersonal: {
      AppModule.personal: true,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: true,
    },

    UserRole.jefeTrafic: {
      AppModule.personal: false,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuarios: false,
      AppModule.tablas: true,
    },

    UserRole.coordinador: {
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: true, // Solo estado/incidencias
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.administrativo: {
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.conductor: {
      AppModule.personal: true, // Solo sus datos
      AppModule.vehiculos: false,
      AppModule.servicios: true, // Solo sus servicios
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.sanitario: {
      AppModule.personal: true,
      AppModule.vehiculos: false,
      AppModule.servicios: true,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.gestor: {
      AppModule.personal: false,
      AppModule.vehiculos: true, // Estado/mantenimiento
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.tecnico: {
      AppModule.personal: false,
      AppModule.vehiculos: true, // Solo mantenimiento
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.operador: {
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },
  };

  // ==========================================
  // PERMISOS: DELETE
  // ==========================================

  static final Map<UserRole, Map<AppModule, bool>> _deletePermissions = {
    UserRole.admin: {
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuarios: true,
      AppModule.tablas: true,
    },

    UserRole.jefePersonal: {
      AppModule.personal: false, // No puede eliminar
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    UserRole.jefeTrafic: {
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: true, // Puede eliminar servicios
      AppModule.usuarios: false,
      AppModule.tablas: false,
    },

    // Todos los demás roles: NO pueden eliminar
    UserRole.coordinador: {},
    UserRole.administrativo: {},
    UserRole.conductor: {},
    UserRole.sanitario: {},
    UserRole.gestor: {},
    UserRole.tecnico: {},
    UserRole.operador: {},
  };
}

/// Modelo de permisos CRUD
class CrudPermissionsModel {
  final bool canCreate;
  final bool canRead;
  final bool canUpdate;
  final bool canDelete;

  const CrudPermissionsModel({
    required this.canCreate,
    required this.canRead,
    required this.canUpdate,
    required this.canDelete,
  });

  /// Verifica si no tiene ningún permiso
  bool get hasNoPermissions =>
      !canCreate && !canRead && !canUpdate && !canDelete;

  /// Verifica si tiene todos los permisos
  bool get hasAllPermissions =>
      canCreate && canRead && canUpdate && canDelete;

  /// Verifica si solo tiene permiso de lectura
  bool get isReadOnly => canRead && !canCreate && !canUpdate && !canDelete;
}
```

---

### 5.2. Integrar Permisos en UI

**Ejemplo**: Personal Page - Ocultar botón "Crear" según permisos

**Archivo**: `/lib/features/personal/presentation/pages/personal_page.dart`

**ANTES (Fase 2)**:
```dart
FloatingActionButton(
  onPressed: () => _showCrearPersonalDialog(context),
  child: const Icon(Icons.add),
);
```

**DESPUÉS (Fase 3)**:
```dart
// En el build method, obtener permisos
FutureBuilder<CrudPermissionsModel>(
  future: _getPersonalPermissions(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const SizedBox.shrink();
    }

    final permissions = snapshot.data!;

    // Solo mostrar FAB si tiene permiso de crear
    if (!permissions.canCreate) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () => _showCrearPersonalDialog(context),
      tooltip: 'Crear Personal',
      child: const Icon(Icons.add),
    );
  },
);

// Helper method
Future<CrudPermissionsModel> _getPersonalPermissions() async {
  final role = await getIt<RoleService>().getCurrentUserRole();
  return CrudPermissions.getPermissions(role, AppModule.personal);
}
```

---

### 5.3. Integrar Validación en BLoCs

**Ejemplo**: PersonalBloc - Validar antes de eliminar

**Archivo**: `/lib/features/personal/presentation/bloc/personal_bloc.dart`

**ANTES (Fase 2)**:
```dart
Future<void> _onDelete(
  PersonalDeleteRequested event,
  Emitter<PersonalState> emit,
) async {
  try {
    await _repository.delete(event.id);
    emit(const PersonalOperationSuccess('Personal eliminado'));
    add(const PersonalLoadRequested());
  } catch (e) {
    emit(PersonalOperationFailure('Error al eliminar: $e'));
  }
}
```

**DESPUÉS (Fase 3)**:
```dart
Future<void> _onDelete(
  PersonalDeleteRequested event,
  Emitter<PersonalState> emit,
) async {
  try {
    // 1. Obtener rol actual
    final UserRole role = await _roleService.getCurrentUserRole();

    // 2. Validar permisos
    if (!CrudPermissions.canDelete(role, AppModule.personal)) {
      debugPrint('🚫 Usuario sin permisos para eliminar personal');
      emit(const PersonalOperationFailure(
        'No tienes permisos para eliminar personal.\n'
        'Contacta con tu administrador si necesitas acceso.',
      ));
      return;
    }

    // 3. Ejecutar operación
    debugPrint('✅ Usuario tiene permisos, eliminando personal...');
    await _repository.delete(event.id);
    emit(const PersonalOperationSuccess('Personal eliminado correctamente'));
    add(const PersonalLoadRequested());
  } catch (e) {
    debugPrint('❌ Error al eliminar personal: $e');
    emit(PersonalOperationFailure('Error al eliminar: $e'));
  }
}
```

---

### 5.4. Crear Widget Helper para Acciones CRUD

**Ubicación**: `/lib/core/widgets/crud/crud_action_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:ambutrack_web/core/auth/permissions/crud_permissions.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';

/// Botón de acción CRUD que se oculta/deshabilita según permisos
class CrudActionButton extends StatelessWidget {
  const CrudActionButton({
    super.key,
    required this.userRole,
    required this.module,
    required this.action,
    required this.onPressed,
    this.icon,
    this.label,
    this.tooltip,
    this.style,
  });

  final UserRole userRole;
  final AppModule module;
  final CrudAction action;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? label;
  final String? tooltip;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final bool hasPermission = _hasPermission();

    // Si no tiene permiso, no mostrar el botón
    if (!hasPermission) {
      return const SizedBox.shrink();
    }

    // Si tiene permiso, mostrar botón
    if (label != null) {
      // Botón con texto
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? _getDefaultIcon()),
        label: Text(label!),
        style: style ?? _getDefaultStyle(),
      );
    } else {
      // Botón solo icono
      return IconButton(
        onPressed: onPressed,
        icon: Icon(icon ?? _getDefaultIcon()),
        tooltip: tooltip ?? _getDefaultTooltip(),
        color: _getDefaultColor(),
      );
    }
  }

  bool _hasPermission() {
    switch (action) {
      case CrudAction.create:
        return CrudPermissions.canCreate(userRole, module);
      case CrudAction.read:
        return CrudPermissions.canRead(userRole, module);
      case CrudAction.update:
        return CrudPermissions.canUpdate(userRole, module);
      case CrudAction.delete:
        return CrudPermissions.canDelete(userRole, module);
    }
  }

  IconData _getDefaultIcon() {
    switch (action) {
      case CrudAction.create:
        return Icons.add;
      case CrudAction.read:
        return Icons.visibility_outlined;
      case CrudAction.update:
        return Icons.edit_outlined;
      case CrudAction.delete:
        return Icons.delete_outline;
    }
  }

  String _getDefaultTooltip() {
    switch (action) {
      case CrudAction.create:
        return 'Crear';
      case CrudAction.read:
        return 'Ver';
      case CrudAction.update:
        return 'Editar';
      case CrudAction.delete:
        return 'Eliminar';
    }
  }

  Color _getDefaultColor() {
    switch (action) {
      case CrudAction.create:
        return AppColors.primary;
      case CrudAction.read:
        return AppColors.info;
      case CrudAction.update:
        return AppColors.secondaryLight;
      case CrudAction.delete:
        return AppColors.error;
    }
  }

  ButtonStyle _getDefaultStyle() {
    switch (action) {
      case CrudAction.create:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        );
      case CrudAction.update:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryLight,
          foregroundColor: Colors.white,
        );
      case CrudAction.delete:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
        );
      default:
        return ElevatedButton.styleFrom();
    }
  }
}

/// Tipo de acción CRUD
enum CrudAction { create, read, update, delete }
```

**Uso en Personal Page**:
```dart
CrudActionButton(
  userRole: currentUserRole,
  module: AppModule.personal,
  action: CrudAction.create,
  onPressed: () => _showCrearPersonalDialog(context),
  label: 'Crear Personal',
  icon: Icons.person_add,
);
```

---

## 6. TESTING

### 6.1. Unit Tests - CrudPermissions

**Archivo**: `/test/unit/core/auth/permissions/crud_permissions_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ambutrack_web/core/auth/permissions/crud_permissions.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/enums/app_module.dart';

void main() {
  group('CrudPermissions', () {
    group('Admin', () {
      const role = UserRole.admin;

      test('puede hacer TODO en Personal', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), true);
        expect(CrudPermissions.canRead(role, AppModule.personal), true);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), true);
        expect(CrudPermissions.canDelete(role, AppModule.personal), true);
      });

      test('puede hacer TODO en Vehículos', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), true);
      });
    });

    group('Jefe Personal', () {
      const role = UserRole.jefePersonal;

      test('puede crear y editar Personal, pero NO eliminar', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), true);
        expect(CrudPermissions.canRead(role, AppModule.personal), true);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), true);
        expect(CrudPermissions.canDelete(role, AppModule.personal), false);
      });

      test('NO tiene acceso a Vehículos', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), false);
      });
    });

    group('Coordinador', () {
      const role = UserRole.coordinador;

      test('solo puede leer Personal', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), false);
        expect(CrudPermissions.canRead(role, AppModule.personal), true);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), false);
        expect(CrudPermissions.canDelete(role, AppModule.personal), false);
      });

      test('puede leer y actualizar Servicios (estado/incidencias)', () {
        expect(CrudPermissions.canCreate(role, AppModule.servicios), false);
        expect(CrudPermissions.canRead(role, AppModule.servicios), true);
        expect(CrudPermissions.canUpdate(role, AppModule.servicios), true);
        expect(CrudPermissions.canDelete(role, AppModule.servicios), false);
      });
    });

    group('getPermissions', () {
      test('retorna modelo con todos los permisos', () {
        final permissions = CrudPermissions.getPermissions(
          UserRole.admin,
          AppModule.personal,
        );

        expect(permissions.hasAllPermissions, true);
        expect(permissions.hasNoPermissions, false);
        expect(permissions.isReadOnly, false);
      });

      test('retorna modelo de solo lectura para Operador', () {
        final permissions = CrudPermissions.getPermissions(
          UserRole.operador,
          AppModule.personal,
        );

        expect(permissions.isReadOnly, true);
        expect(permissions.hasAllPermissions, false);
        expect(permissions.canRead, true);
        expect(permissions.canCreate, false);
      });
    });
  });
}
```

---

### 6.2. Widget Tests - UI con Permisos

**Archivo**: `/test/widget/features/personal/widgets/personal_action_buttons_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ambutrack_web/core/widgets/crud/crud_action_button.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/enums/app_module.dart';

void main() {
  group('CrudActionButton - Personal', () {
    testWidgets('Admin ve todos los botones', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CrudActionButton(
                  userRole: UserRole.admin,
                  module: AppModule.personal,
                  action: CrudAction.create,
                  onPressed: () {},
                  label: 'Crear',
                ),
                CrudActionButton(
                  userRole: UserRole.admin,
                  module: AppModule.personal,
                  action: CrudAction.delete,
                  onPressed: () {},
                  label: 'Eliminar',
                ),
              ],
            ),
          ),
        ),
      );

      // Debe mostrar ambos botones
      expect(find.text('Crear'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
    });

    testWidgets('Jefe Personal ve Crear pero NO Eliminar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CrudActionButton(
                  userRole: UserRole.jefePersonal,
                  module: AppModule.personal,
                  action: CrudAction.create,
                  onPressed: () {},
                  label: 'Crear',
                ),
                CrudActionButton(
                  userRole: UserRole.jefePersonal,
                  module: AppModule.personal,
                  action: CrudAction.delete,
                  onPressed: () {},
                  label: 'Eliminar',
                ),
              ],
            ),
          ),
        ),
      );

      // Debe mostrar Crear, pero NO Eliminar
      expect(find.text('Crear'), findsOneWidget);
      expect(find.text('Eliminar'), findsNothing);
    });

    testWidgets('Operador NO ve botones de acción', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CrudActionButton(
                  userRole: UserRole.operador,
                  module: AppModule.personal,
                  action: CrudAction.create,
                  onPressed: () {},
                  label: 'Crear',
                ),
                CrudActionButton(
                  userRole: UserRole.operador,
                  module: AppModule.personal,
                  action: CrudAction.update,
                  onPressed: () {},
                  label: 'Editar',
                ),
              ],
            ),
          ),
        ),
      );

      // NO debe mostrar ningún botón
      expect(find.text('Crear'), findsNothing);
      expect(find.text('Editar'), findsNothing);
    });
  });
}
```

---

### 6.3. Integration Tests - Flujo Completo

**Escenario**: Jefe Personal intenta eliminar personal

```dart
testWidgets('Jefe Personal NO puede eliminar personal', (tester) async {
  // 1. Login como jefe_personal
  await loginAs(UserRole.jefePersonal);

  // 2. Navegar a Personal
  await tester.tap(find.text('Personal'));
  await tester.pumpAndSettle();

  // 3. Verificar que NO hay botón de eliminar
  expect(find.byIcon(Icons.delete_outline), findsNothing);

  // 4. Si intenta eliminar vía evento directo
  context.read<PersonalBloc>().add(PersonalDeleteRequested('id123'));
  await tester.pumpAndSettle();

  // 5. Debe mostrar error de permisos
  expect(find.text('No tienes permisos para eliminar personal'), findsOneWidget);
});
```

---

## 7. CHECKLIST DE IMPLEMENTACIÓN

### 7.1. Preparación (Día 1)

- [ ] Revisar y aprobar matriz de permisos CRUD con stakeholders
- [ ] Crear branch: `feature/fase-3-permisos-granulares`
- [ ] Crear issue en gestión de proyecto
- [ ] Definir criterios de aceptación

### 7.2. Desarrollo Core (Días 2-4)

- [ ] Crear `crud_permissions.dart` con matrices de permisos
- [ ] Implementar métodos: `canCreate()`, `canRead()`, `canUpdate()`, `canDelete()`
- [ ] Crear `CrudPermissionsModel`
- [ ] Crear widget helper `CrudActionButton`
- [ ] Ejecutar `flutter analyze` → 0 warnings
- [ ] Unit tests para `CrudPermissions` (cobertura 100%)

### 7.3. Integración en Personal (Días 5-6)

- [ ] Modificar `PersonalPage` para ocultar botones según permisos
- [ ] Modificar `PersonalBloc` para validar antes de CRUD
- [ ] Actualizar `PersonalTable` con botones condicionales
- [ ] Testing manual con diferentes roles
- [ ] Widget tests para UI
- [ ] Integration tests para flujos

### 7.4. Integración en Vehículos (Días 7-8)

- [ ] Modificar `VehiculosPage`
- [ ] Modificar `VehiculosBloc`
- [ ] Actualizar `VehiculoTable`
- [ ] Testing manual y automatizado

### 7.5. Integración en Servicios (Días 9-10)

- [ ] Modificar `ServiciosPage`
- [ ] Modificar `ServiciosBloc`
- [ ] Actualizar `ServicioTable`
- [ ] Testing manual y automatizado

### 7.6. Integración en Usuarios (Día 11)

- [ ] Modificar `UsuariosPage`
- [ ] Modificar `UsuariosBloc`
- [ ] Actualizar `UsuarioTable`
- [ ] Verificar que solo Admin tiene acceso
- [ ] Testing manual y automatizado

### 7.7. Testing y QA (Días 12-13)

- [ ] Testing completo con todos los roles
- [ ] Verificar logs de validación
- [ ] Testing de regresión (no romper funcionalidad existente)
- [ ] Ejecutar `flutter analyze` → 0 warnings
- [ ] Verificar cobertura de tests ≥ 85%

### 7.8. Documentación (Día 14)

- [ ] Actualizar documentación en `docs/seguridad/`
- [ ] Crear guía de uso de permisos granulares
- [ ] Documentar matriz de permisos final
- [ ] Actualizar README si es necesario

---

## 8. CRITERIOS DE ACEPTACIÓN

### ✅ Feature Completa Cuando:

1. **Permisos implementados** en 4 módulos críticos:
   - ✅ Personal
   - ✅ Vehículos
   - ✅ Servicios
   - ✅ Usuarios

2. **UI refleja permisos**:
   - ✅ Botones ocultos si usuario no tiene permiso
   - ✅ Tooltips explicativos cuando corresponda
   - ✅ Experiencia de usuario clara

3. **BLoCs validan permisos**:
   - ✅ Checks antes de CRUD
   - ✅ Mensajes de error claros
   - ✅ Logs de auditoría

4. **Testing completo**:
   - ✅ Unit tests ≥ 90%
   - ✅ Widget tests para UI críticos
   - ✅ Integration tests para flujos principales
   - ✅ Testing manual con todos los roles

5. **Calidad de código**:
   - ✅ `flutter analyze` → 0 warnings
   - ✅ Código documentado
   - ✅ Patrones consistentes

---

## 9. RIESGOS Y MITIGACIONES

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Matriz de permisos incorrecta | Media | Alto | Validar con stakeholders antes de implementar |
| UI demasiado restrictiva | Media | Medio | Testing con usuarios reales |
| Performance por múltiples checks | Baja | Bajo | Cachear permisos en RoleService |
| Bypass de validaciones | Baja | Alto | Validar en BLoC Y en RLS de Supabase |

---

## 10. SIGUIENTES PASOS (POST-FASE 3)

Una vez completada Fase 3, considerar:

1. **Fase 4: Mejoras y Optimización**
   - Dashboard personalizado por rol
   - Caché de permisos optimizado
   - Notificaciones según rol

2. **Auditoría de Permisos**
   - Registrar intentos de acceso denegado
   - Dashboard de auditoría para Admin

3. **Permisos Dinámicos**
   - Permitir personalizar permisos por usuario
   - Sistema de excepciones temporal

---

**Plan elaborado por**: Claude Code Agent
**Fecha**: 2026-02-12
**Versión**: 1.0
**Estado**: 📋 LISTO PARA REVISIÓN Y APROBACIÓN
