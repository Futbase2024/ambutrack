import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/crud_permissions.dart';
import 'package:ambutrack_web/core/auth/permissions/role_permissions.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/widgets/permisos_helpers.dart';
import 'package:ambutrack_web/features/administracion/shared/admin_shared_widgets.dart';
import 'package:flutter/material.dart';

/// Marca de acceso en una celda de la matriz: ✓ (verde) o — (gris)
class PermisoAccessMark extends StatelessWidget {
  const PermisoAccessMark({required this.granted, super.key});

  final bool granted;

  @override
  Widget build(BuildContext context) {
    return granted
        ? const Icon(Icons.check_circle, size: 16, color: AppColors.success)
        : const Icon(Icons.remove, size: 14, color: AppColors.gray300);
  }
}

/// Columnas fijas: grupo, módulo y ruta
List<GestionColumn<AppModule>> _baseColumns() => <GestionColumn<AppModule>>[
      GestionColumn<AppModule>(
        label: 'Grupo',
        width: 130,
        sortValue: (AppModule m) => moduloGrupo(m).toLowerCase(),
        cell: (AppModule m) => AdminCellText(moduloGrupo(m), muted: true),
      ),
      GestionColumn<AppModule>(
        label: 'Módulo',
        flex: 2,
        sortValue: (AppModule m) => m.label.toLowerCase(),
        cell: (AppModule m) => AdminCellText(m.label, bold: true),
      ),
      GestionColumn<AppModule>(
        label: 'Ruta',
        flex: 2,
        sortValue: (AppModule m) => m.route,
        cell: (AppModule m) => AdminCellText(m.route, muted: true),
      ),
    ];

GestionColumn<AppModule> _rolColumn(UserRole role) => GestionColumn<AppModule>(
      label: rolEtiquetaCorta(role),
      width: 84,
      alignment: Alignment.center,
      sortValue: (AppModule m) => RolePermissions.hasAccessToModule(role, m) ? 0 : 1,
      cell: (AppModule m) => PermisoAccessMark(granted: RolePermissions.hasAccessToModule(role, m)),
    );

GestionColumn<AppModule> _crudColumn(
  String label,
  bool Function(UserRole role, AppModule module) check,
  UserRole role,
) =>
    GestionColumn<AppModule>(
      label: label,
      width: 74,
      alignment: Alignment.center,
      sortValue: (AppModule m) => check(role, m) ? 0 : 1,
      cell: (AppModule m) => PermisoAccessMark(granted: check(role, m)),
    );

/// Columnas de la matriz.
///
/// - Sin rol seleccionado: una columna por rol (matriz completa Rol × Módulo).
/// - Con rol seleccionado: columna de acceso del rol + permisos CRUD granulares.
List<GestionColumn<AppModule>> permisosMatrixColumns(UserRole? rol) {
  final UserRole? r = rol;
  if (r == null) {
    return <GestionColumn<AppModule>>[
      ..._baseColumns(),
      for (final UserRole role in UserRole.values) _rolColumn(role),
    ];
  }
  return <GestionColumn<AppModule>>[
    ..._baseColumns(),
    _rolColumn(r),
    _crudColumn('Crear', CrudPermissions.canCreate, r),
    _crudColumn('Leer', CrudPermissions.canRead, r),
    _crudColumn('Editar', CrudPermissions.canUpdate, r),
    _crudColumn('Borrar', CrudPermissions.canDelete, r),
  ];
}
