import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/crud_permissions.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Botón de acción CRUD que se oculta/muestra según permisos del usuario
///
/// Este widget verifica automáticamente los permisos CRUD y:
/// - Muestra el botón si el usuario tiene el permiso correspondiente
/// - Oculta el botón (SizedBox.shrink) si NO tiene permiso
///
/// Ejemplo de uso:
/// ```dart
/// CrudActionButton(
///   userRole: currentUserRole,
///   module: AppModule.personal,
///   action: CrudAction.create,
///   onPressed: () => _showCrearDialog(),
///   label: 'Crear Personal',
///   icon: Icons.person_add,
/// )
/// ```
class CrudActionButton extends StatelessWidget {
  const CrudActionButton({
    required this.userRole,
    required this.module,
    required this.action,
    required this.onPressed,
    super.key,
    this.icon,
    this.label,
    this.tooltip,
    this.style,
  });

  /// Rol del usuario actual
  final UserRole userRole;

  /// Módulo donde se ejecutará la acción
  final AppModule module;

  /// Tipo de acción CRUD (create, read, update, delete)
  final CrudAction action;

  /// Callback cuando se presiona el botón
  final VoidCallback onPressed;

  /// Icono del botón (opcional, usa icono por defecto según acción)
  final IconData? icon;

  /// Texto del botón (opcional, si no se especifica es solo icono)
  final String? label;

  /// Tooltip del botón (opcional, usa tooltip por defecto según acción)
  final String? tooltip;

  /// Estilo custom del botón (opcional, usa estilo por defecto según acción)
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

  /// Verifica si el usuario tiene el permiso para esta acción
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

  /// Obtiene el icono por defecto según el tipo de acción
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

  /// Obtiene el tooltip por defecto según el tipo de acción
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

  /// Obtiene el color por defecto según el tipo de acción
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

  /// Obtiene el estilo por defecto según el tipo de acción
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
enum CrudAction {
  /// Crear nuevo registro
  create,

  /// Leer/Ver registro
  read,

  /// Actualizar registro existente
  update,

  /// Eliminar registro
  delete,
}
