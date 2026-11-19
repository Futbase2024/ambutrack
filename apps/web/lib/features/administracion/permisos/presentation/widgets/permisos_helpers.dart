import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/role_permissions.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Filtro de acceso respecto al rol seleccionado
enum PermisoAccesoFiltro { todos, conAcceso, sinAcceso }

/// Grupos de módulos (según el primer segmento de la ruta)
const Map<String, String> _gruposPorSegmento = <String, String>{
  '': 'General',
  'perfil': 'General',
  'personal': 'Personal',
  'cuadrante': 'Cuadrantes',
  'vehiculos': 'Flota',
  'flota': 'Flota',
  'servicios': 'Servicios',
  'operaciones': 'Operaciones',
  'informes': 'Informes',
  'trafico': 'Tráfico',
  'taller': 'Taller',
  'almacen': 'Almacén',
  'tablas': 'Tablas maestras',
  'administracion': 'Administración',
  'configuracion': 'Administración',
  'mis-turnos': 'Datos propios',
  'mis-servicios': 'Datos propios',
  'mis-ausencias': 'Datos propios',
  'calendario': 'Calendario',
};

/// Grupo funcional al que pertenece un módulo
String moduloGrupo(AppModule module) {
  final List<String> segments = module.route.split('/').where((String s) => s.isNotEmpty).toList();
  final String first = segments.isEmpty ? '' : segments.first;
  return _gruposPorSegmento[first] ?? 'Otros';
}

/// Grupos existentes, en el orden en que aparecen en [AppModule]
List<String> gruposModulos() {
  final List<String> grupos = <String>[];
  for (final AppModule m in AppModule.values) {
    final String g = moduloGrupo(m);
    if (!grupos.contains(g)) {
      grupos.add(g);
    }
  }
  return grupos;
}

/// Etiqueta corta del rol para las cabeceras de la matriz
String rolEtiquetaCorta(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'Admin';
    case UserRole.jefePersonal:
      return 'J. Personal';
    case UserRole.jefeTrafic:
      return 'J. Tráfico';
    case UserRole.coordinador:
      return 'Coordin.';
    case UserRole.administrativo:
      return 'Admvo.';
    case UserRole.conductor:
      return 'Conductor';
    case UserRole.sanitario:
      return 'Sanitario';
    case UserRole.tecnico:
      return 'Técnico';
    case UserRole.jefeMantenimiento:
      return 'J. Mant.';
    case UserRole.operador:
      return 'Operador';
  }
}

/// Color identificativo del rol
Color rolColor(UserRole role) {
  if (role.isAdmin) {
    return AppColors.error;
  }
  if (role.isManager) {
    return AppColors.warning;
  }
  if (role.isOperative) {
    return AppColors.success;
  }
  if (role.isReadOnly) {
    return AppColors.gray500;
  }
  return AppColors.primary;
}

/// Tipo de perfil del rol
String rolTipo(UserRole role) {
  if (role.isAdmin) {
    return 'Administración total';
  }
  if (role.isManager) {
    return 'Gestión';
  }
  if (role.isOperative) {
    return 'Operativo (datos propios)';
  }
  if (role.isReadOnly) {
    return 'Solo lectura';
  }
  return 'Supervisión / gestión parcial';
}

/// Módulos accesibles por el rol (admin: todos)
List<AppModule> modulosDeRol(UserRole role) =>
    AppModule.values.where((AppModule m) => RolePermissions.hasAccessToModule(role, m)).toList();

/// Roles con acceso al módulo
List<UserRole> rolesConAcceso(AppModule module) =>
    UserRole.values.where((UserRole r) => RolePermissions.hasAccessToModule(r, module)).toList();

/// Aplica búsqueda, grupo y filtro de acceso a la lista de módulos
List<AppModule> filtrarModulos({
  required String query,
  required String? grupo,
  required UserRole? rol,
  required PermisoAccesoFiltro acceso,
}) {
  final String q = query.trim().toLowerCase();
  return AppModule.values.where((AppModule m) {
    if (grupo != null && moduloGrupo(m) != grupo) {
      return false;
    }
    if (rol != null && acceso != PermisoAccesoFiltro.todos) {
      final bool tiene = RolePermissions.hasAccessToModule(rol, m);
      if (acceso == PermisoAccesoFiltro.conAcceso ? !tiene : tiene) {
        return false;
      }
    }
    if (q.isEmpty) {
      return true;
    }
    return m.label.toLowerCase().contains(q) ||
        m.value.contains(q) ||
        m.route.toLowerCase().contains(q);
  }).toList();
}
