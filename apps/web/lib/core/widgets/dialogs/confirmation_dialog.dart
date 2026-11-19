import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo de confirmación profesional para acciones destructivas
///
/// Uso típico:
/// ```dart
/// final bool? confirmed = await showConfirmationDialog(
///   context: context,
///   title: 'Eliminar vehículo',
///   message: '¿Estás seguro de que deseas eliminar este vehículo?',
///   confirmText: 'Eliminar',
///   itemDetails: {
///     'Matrícula': 'AMB-001-XY',
///     'Marca': 'Mercedes-Benz',
///     'Modelo': 'Sprinter',
///   },
/// );
/// ```
///
/// Para una confirmación simple sin doble validación, usar [showSimpleConfirmationDialog]
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Eliminar',
  String cancelText = 'Cancelar',
  Map<String, String>? itemDetails,
  String? warningMessage,
  IconData icon = Icons.warning_rounded,
  Color iconColor = AppColors.error,
Color confirmButtonColor = AppColors.error, 
}) async {
  debugPrint('🚨 showConfirmationDialog: Mostrando PRIMER diálogo (detallado)...');
  debugPrint('   Title: $title');
  debugPrint('   confirmText recibido: $confirmText');

  // Esperar un frame para asegurar que el contexto está listo
  await Future<void>.delayed(const Duration(milliseconds: 50));

  if (!context.mounted) {
    return false;
  }

  // PRIMER DIÁLOGO: Mostrar detalles del item
  final bool? firstConfirmation = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: false,
    builder: (BuildContext dialogContext) {
      debugPrint('🏗️ Builder del PRIMER diálogo ejecutándose...');
      return _ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,  // Cambiar a "Continuar" para el primer paso
        cancelText: cancelText,
        itemDetails: itemDetails,
        warningMessage: warningMessage,
        icon: icon,
        iconColor: iconColor,
        confirmButtonColor: confirmButtonColor,
      );
    },
  );

  debugPrint('🔚 PRIMER diálogo cerrado con resultado: $firstConfirmation');

  // Si el usuario canceló en el primer diálogo, retornar false
  if (firstConfirmation != true) {
    debugPrint('❌ Usuario canceló en el PRIMER diálogo');
    return false;
  }

  // SEGUNDO DIÁLOGO: Confirmación final simple
  debugPrint('🚨 Mostrando SEGUNDO diálogo (confirmación final)...');

  await Future<void>.delayed(const Duration(milliseconds: 100));

  if (!context.mounted) {
    return false;
  }

  final bool? finalConfirmation = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: false,
    builder: (BuildContext dialogContext) {
      debugPrint('🏗️ Builder del SEGUNDO diálogo ejecutándose...');
      return _FinalConfirmationDialog(
        itemType: title.replaceAll('Confirmar Eliminación', '').trim(),
        confirmText: confirmText,
        actionDescription: confirmText.toLowerCase(),
      );
    },
  );

  debugPrint('🔚 SEGUNDO diálogo cerrado con resultado: $finalConfirmation');
  return finalConfirmation;
}

/// Diálogo de confirmación simple (sin doble validación)
///
/// Ideal para acciones menos críticas como eliminar notificaciones, marcar como leída, etc.
///
/// Uso típico:
/// ```dart
/// final bool? confirmed = await showSimpleConfirmationDialog(
///   context: context,
///   title: 'Eliminar notificación',
///   message: '¿Estás seguro de que deseas eliminar esta notificación?',
///   confirmText: 'Eliminar',
///   icon: Icons.delete_outline,
///   iconColor: AppColors.error,
/// );
/// ```
Future<bool?> showSimpleConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
  IconData icon = Icons.warning_rounded,
  Color iconColor = AppColors.error,
  Color confirmButtonColor = AppColors.error,
}) async {
  debugPrint('🚨 showSimpleConfirmationDialog: Mostrando diálogo simple...');
  debugPrint('   Title: $title');

  if (!context.mounted) {
    return false;
  }

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: false,
    builder: (BuildContext dialogContext) => _SimpleConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
      iconColor: iconColor,
      confirmButtonColor: confirmButtonColor,
    ),
  );
}

/// Widget de diálogo simple para confirmación
class _SimpleConfirmationDialog extends StatelessWidget {
  const _SimpleConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.icon,
    required this.iconColor,
    required this.confirmButtonColor,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color iconColor;
  final Color confirmButtonColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      elevation: 24,
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Icono
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Título
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Mensaje
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                color: AppColors.textSecondaryLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Botones
            Row(
              children: <Widget>[
                // Botón Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.gray300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontMedium,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),

                // Botón Confirmar
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmButtonColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmationDialog extends StatefulWidget {
  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.icon,
    required this.iconColor,
    required this.confirmButtonColor,
    this.itemDetails,
    this.warningMessage,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Map<String, String>? itemDetails;
  final String? warningMessage;
  final IconData icon;
  final Color iconColor;
  final Color confirmButtonColor;

  @override
  State<_ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<_ConfirmationDialog> {
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🎨 _ConfirmationDialog.initState() ejecutándose...');
    debugPrint('   confirmText en widget: ${widget.confirmText}');
    // Permitir cerrar el diálogo después de 500ms para evitar propagación de eventos
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _canClose = true;
          debugPrint('✅ Diálogo ahora puede cerrarse');
        });
      }
    });
  }

  void _handleCancel() {
    debugPrint('❌ Usuario presionó CANCELAR (canClose: $_canClose)');
    if (_canClose) {
      Navigator.of(context).pop(false);
    }
  }

  void _handleConfirm() {
    debugPrint('✅ Usuario presionó CONFIRMAR (canClose: $_canClose)');
    if (_canClose) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 _ConfirmationDialog.build() ejecutándose... (canClose: $_canClose)');
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        elevation: 24,
        child: Container(
        width: 500,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildHeader(),
            _buildContent(),
            _buildActions(context),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: widget.iconColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLarge),
          topRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSizes.padding),
          Expanded(
            child: Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Mensaje principal
          Text(
            widget.message,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMedium,
              color: AppColors.textPrimaryLight,
              height: 1.5,
            ),
          ),

          // Detalles del item (si existen)
          if (widget.itemDetails != null && widget.itemDetails!.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            Container(
              padding: const EdgeInsets.all(AppSizes.padding),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.itemDetails!.entries
                    .map(
                      (MapEntry<String, String> entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 100,
                              child: Text(
                                '${entry.key}:',
                                style: GoogleFonts.inter(
                                  fontSize: AppSizes.fontSmall,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: GoogleFonts.inter(
                                  fontSize: AppSizes.fontSmall,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],

          // Mensaje de advertencia (si existe)
          if (widget.warningMessage != null && widget.warningMessage!.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            Container(
              padding: const EdgeInsets.all(AppSizes.padding),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Text(
                      widget.warningMessage!,
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontSmall,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusLarge),
          bottomRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // Botón Cancelar
          TextButton(
            onPressed: _handleCancel,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondaryLight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXl,
                vertical: AppSizes.padding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
            ),
            child: Text(
              widget.cancelText,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),

          // Botón Confirmar
          ElevatedButton(
            onPressed: _handleConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.confirmButtonColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXl,
                vertical: AppSizes.padding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
            ),
            child: Text(
              widget.confirmText,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Diálogo de confirmación final pequeño y simple
/// Se muestra DESPUÉS del diálogo de detalles para doble confirmación
class _FinalConfirmationDialog extends StatefulWidget {
  const _FinalConfirmationDialog({
    required this.itemType,
    required this.confirmText,
    required this.actionDescription,
  });

  final String itemType;
  final String confirmText;
  final String actionDescription;

  @override
  State<_FinalConfirmationDialog> createState() => _FinalConfirmationDialogState();
}

class _FinalConfirmationDialogState extends State<_FinalConfirmationDialog> {
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🎨 _FinalConfirmationDialog.initState() ejecutándose...');
    // Permitir cerrar después de 300ms
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _canClose = true;
          debugPrint('✅ Diálogo final ahora puede cerrarse');
        });
      }
    });
  }

  void _handleCancel() {
    debugPrint('❌ Usuario presionó CANCELAR en diálogo final (canClose: $_canClose)');
    if (_canClose) {
      Navigator.of(context).pop(false);
    }
  }

  void _handleConfirm() {
    debugPrint('✅ Usuario presionó CONFIRMAR en diálogo final (canClose: $_canClose)');
    if (_canClose) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 _FinalConfirmationDialog.build() ejecutándose... (canClose: $_canClose)');
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      contentPadding: const EdgeInsets.all(AppSizes.paddingXl),
      content: Container(
        width: 400,
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Icono de advertencia grande
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Título
            Text(
              '¿Está seguro?',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Mensaje
            Text(
              'Esta acción es irreversible.\n¿Confirma la ${widget.actionDescription} definitiva?',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                color: AppColors.textSecondaryLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Botones
            Row(
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    label: 'Cancelar',
                    variant: AppButtonVariant.outline,
                    onPressed: _handleCancel,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: AppButton(
                    label: widget.confirmText,
                    variant: AppButtonVariant.danger,
                    onPressed: _handleConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
