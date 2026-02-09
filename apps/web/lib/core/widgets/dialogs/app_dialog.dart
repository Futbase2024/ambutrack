import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Tipo de diálogo que determina el color del header
enum AppDialogType {
  /// Diálogo para ver detalles (azul)
  view,

  /// Diálogo para editar/modificar (verde)
  edit,

  /// Diálogo para crear nuevo (azul primario)
  create,

  /// Diálogo informativo (azul info)
  info,

  /// Diálogo de advertencia (amarillo)
  warning,
}

/// Diálogo estándar de la aplicación con header colorido y footer personalizado
///
/// Características:
/// - Header con color según el tipo de acción
/// - Botón X de cerrar con estilo IconButton
/// - Contenido scrollable con padding
/// - Footer opcional con botones personalizados
/// - Ancho máximo configurable (por defecto 600px)
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon = Icons.article,
    this.actions,
    this.maxWidth = 600,
    this.showCloseButton = true,
    this.type = AppDialogType.view,
  });

  /// Título del diálogo
  final String title;

  /// Contenido del diálogo
  final Widget content;

  /// Icono a mostrar en el header (por defecto: Icons.article)
  final IconData icon;

  /// Botones del footer (opcional)
  /// Si es null, no se muestra footer
  final List<Widget>? actions;

  /// Ancho máximo del diálogo (por defecto: 600px)
  final double maxWidth;

  /// Mostrar botón X de cerrar en el header (por defecto: true)
  final bool showCloseButton;

  /// Tipo de diálogo que determina el color del header
  final AppDialogType type;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header azul con icono y título
            _buildHeader(context),

            // Contenido scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingXl),
                child: content,
              ),
            ),

            // Footer con botones (si existen)
            if (actions != null && actions!.isNotEmpty) _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// Construye el header con icono, título y botón cerrar
  Widget _buildHeader(BuildContext context) {
    final Color headerColor = _getHeaderColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingXl,
        vertical: AppSizes.paddingLarge,
      ),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLarge),
          topRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Icono blanco
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: AppSizes.spacingMedium),

          // Título blanco
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Botón X de cerrar
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
              iconSize: 28,
              tooltip: 'Cerrar',
            ),
        ],
      ),
    );
  }

  /// Obtiene el color del header según el tipo de diálogo
  Color _getHeaderColor() {
    switch (type) {
      case AppDialogType.view:
        return AppColors.primaryLight; // Azul para ver
      case AppDialogType.edit:
        return AppColors.secondaryLight; // Verde para editar (#059669)
      case AppDialogType.create:
        return AppColors.primary; // Azul primario para crear (#1E40AF)
      case AppDialogType.info:
        return AppColors.info; // Azul info
      case AppDialogType.warning:
        return AppColors.warning; // Amarillo advertencia
    }
  }

  /// Construye el footer con botones
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: const Border(
          top: BorderSide(
            color: AppColors.gray200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // Distribuir botones con spacing
          for (int i = 0; i < actions!.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppSizes.spacingMedium),
            actions![i],
          ],
        ],
      ),
    );
  }
}

/// Función helper para mostrar un AppDialog
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  IconData icon = Icons.article,
  List<Widget>? actions,
  double maxWidth = 600,
  bool showCloseButton = true,
  bool barrierDismissible = true,
  AppDialogType type = AppDialogType.view,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return AppDialog(
        title: title,
        content: content,
        icon: icon,
        actions: actions,
        maxWidth: maxWidth,
        showCloseButton: showCloseButton,
        type: type,
      );
    },
  );
}
