import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';

/// Permisos CRUD granulares por rol y módulo
///
/// Define qué operaciones específicas (Create, Read, Update, Delete)
/// puede realizar cada rol en cada módulo del sistema.
///
/// Ejemplo de uso:
/// ```dart
/// final role = await roleService.getCurrentUserRole();
/// if (CrudPermissions.canDelete(role, AppModule.personal)) {
///   // Usuario tiene permiso para eliminar
/// }
/// ```
class CrudPermissions {
  // ==========================================
  // MÉTODOS PÚBLICOS
  // ==========================================

  /// Verifica si el rol puede CREAR registros en el módulo
  static bool canCreate(UserRole role, AppModule module) {
    // Admin siempre puede crear
    if (role.isAdmin) {
      return true;
    }

    final Map<AppModule, bool>? permissions = _createPermissions[role];
    return permissions?[module] ?? false;
  }

  /// Verifica si el rol puede LEER registros en el módulo
  static bool canRead(UserRole role, AppModule module) {
    // Admin siempre puede leer
    if (role.isAdmin) {
      return true;
    }

    final Map<AppModule, bool>? permissions = _readPermissions[role];
    return permissions?[module] ?? false;
  }

  /// Verifica si el rol puede ACTUALIZAR registros en el módulo
  static bool canUpdate(UserRole role, AppModule module) {
    // Admin siempre puede actualizar
    if (role.isAdmin) {
      return true;
    }

    final Map<AppModule, bool>? permissions = _updatePermissions[role];
    return permissions?[module] ?? false;
  }

  /// Verifica si el rol puede ELIMINAR registros en el módulo
  static bool canDelete(UserRole role, AppModule module) {
    // Admin siempre puede eliminar
    if (role.isAdmin) {
      return true;
    }

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

  static final Map<UserRole, Map<AppModule, bool>> _createPermissions =
      <UserRole, Map<AppModule, bool>>{
    UserRole.admin: <AppModule, bool>{
      // Admin puede crear en todos los módulos
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuariosRoles: true,
    },

    UserRole.jefePersonal: <AppModule, bool>{
      AppModule.personal: true,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
    },

    UserRole.jefeTrafic: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
    },

    UserRole.coordinador: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false, // Solo actualiza estado
    },

    UserRole.administrativo: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
    },

    UserRole.conductor: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
    },

    UserRole.sanitario: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
    },

    UserRole.gestor: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: false, // Solo actualiza
      AppModule.servicios: false,
    },

    UserRole.tecnico: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
    },

    UserRole.operador: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
    },
  };

  // ==========================================
  // PERMISOS: READ
  // ==========================================

  static final Map<UserRole, Map<AppModule, bool>> _readPermissions =
      <UserRole, Map<AppModule, bool>>{
    UserRole.admin: <AppModule, bool>{
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuariosRoles: true,
    },

    UserRole.jefePersonal: <AppModule, bool>{
      AppModule.personal: true,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuariosRoles: false,
    },

    UserRole.jefeTrafic: <AppModule, bool>{
      AppModule.personal: true, // Para planificación
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuariosRoles: false,
    },

    UserRole.coordinador: <AppModule, bool>{
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuariosRoles: false,
    },

    UserRole.administrativo: <AppModule, bool>{
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: false,
      AppModule.usuariosRoles: false,
    },

    UserRole.conductor: <AppModule, bool>{
      AppModule.personal: true, // Solo sus datos
      AppModule.vehiculos: true, // Solo vehículo asignado
      AppModule.servicios: true, // Solo sus servicios
      AppModule.usuariosRoles: false,
    },

    UserRole.sanitario: <AppModule, bool>{
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuariosRoles: false,
    },

    UserRole.gestor: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: true,
      AppModule.servicios: false,
      AppModule.usuariosRoles: false,
    },

    UserRole.tecnico: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: true,
      AppModule.servicios: false,
      AppModule.usuariosRoles: false,
    },

    UserRole.operador: <AppModule, bool>{
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuariosRoles: false,
    },
  };

  // ==========================================
  // PERMISOS: UPDATE
  // ==========================================

  static final Map<UserRole, Map<AppModule, bool>> _updatePermissions =
      <UserRole, Map<AppModule, bool>>{
    UserRole.admin: <AppModule, bool>{
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuariosRoles: true,
    },

    UserRole.jefePersonal: <AppModule, bool>{
      AppModule.personal: true,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuariosRoles: false,
    },

    UserRole.jefeTrafic: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuariosRoles: false,
    },

    UserRole.coordinador: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: true, // Solo estado/incidencias
      AppModule.usuariosRoles: false,
    },

    UserRole.administrativo: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuariosRoles: false,
    },

    UserRole.conductor: <AppModule, bool>{
      AppModule.personal: true, // Solo sus datos
      AppModule.vehiculos: false,
      AppModule.servicios: true, // Solo sus servicios
      AppModule.usuariosRoles: false,
    },

    UserRole.sanitario: <AppModule, bool>{
      AppModule.personal: true,
      AppModule.vehiculos: false,
      AppModule.servicios: true,
      AppModule.usuariosRoles: false,
    },

    UserRole.gestor: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: true, // Estado/mantenimiento
      AppModule.servicios: false,
      AppModule.usuariosRoles: false,
    },

    UserRole.tecnico: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: true, // Solo mantenimiento
      AppModule.servicios: false,
      AppModule.usuariosRoles: false,
    },

    UserRole.operador: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuariosRoles: false,
    },
  };

  // ==========================================
  // PERMISOS: DELETE
  // ==========================================

  static final Map<UserRole, Map<AppModule, bool>> _deletePermissions =
      <UserRole, Map<AppModule, bool>>{
    UserRole.admin: <AppModule, bool>{
      AppModule.personal: true,
      AppModule.vehiculos: true,
      AppModule.servicios: true,
      AppModule.usuariosRoles: true,
    },

    UserRole.jefePersonal: <AppModule, bool>{
      AppModule.personal: false, // No puede eliminar
      AppModule.vehiculos: false,
      AppModule.servicios: false,
      AppModule.usuariosRoles: false,
    },

    UserRole.jefeTrafic: <AppModule, bool>{
      AppModule.personal: false,
      AppModule.vehiculos: false,
      AppModule.servicios: true, // Puede eliminar servicios
      AppModule.usuariosRoles: false,
    },

    // Todos los demás roles: NO pueden eliminar
    UserRole.coordinador: <AppModule, bool>{},
    UserRole.administrativo: <AppModule, bool>{},
    UserRole.conductor: <AppModule, bool>{},
    UserRole.sanitario: <AppModule, bool>{},
    UserRole.gestor: <AppModule, bool>{},
    UserRole.tecnico: <AppModule, bool>{},
    UserRole.operador: <AppModule, bool>{},
  };
}

/// Modelo de permisos CRUD para un rol y módulo específico
class CrudPermissionsModel {
  const CrudPermissionsModel({
    required this.canCreate,
    required this.canRead,
    required this.canUpdate,
    required this.canDelete,
  });

  /// Puede crear nuevos registros
  final bool canCreate;

  /// Puede ver registros existentes
  final bool canRead;

  /// Puede actualizar registros existentes
  final bool canUpdate;

  /// Puede eliminar registros
  final bool canDelete;

  /// Verifica si no tiene ningún permiso
  bool get hasNoPermissions =>
      !canCreate && !canRead && !canUpdate && !canDelete;

  /// Verifica si tiene todos los permisos
  bool get hasAllPermissions => canCreate && canRead && canUpdate && canDelete;

  /// Verifica si solo tiene permiso de lectura
  bool get isReadOnly => canRead && !canCreate && !canUpdate && !canDelete;

  /// Convierte a String para debugging
  @override
  String toString() {
    return 'CrudPermissions('
        'C:${canCreate ? "✅" : "❌"}, '
        'R:${canRead ? "✅" : "❌"}, '
        'U:${canUpdate ? "✅" : "❌"}, '
        'D:${canDelete ? "✅" : "❌"}'
        ')';
  }
}
