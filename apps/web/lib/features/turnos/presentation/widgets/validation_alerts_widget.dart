import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/validation_result_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget para mostrar alertas de validación
class ValidationAlertsWidget extends StatelessWidget {
  const ValidationAlertsWidget({
    required this.validationResult,
    super.key,
  });

  final ValidationResult validationResult;

  @override
  Widget build(BuildContext context) {
    if (validationResult.issues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Header
          Row(
            children: <Widget>[
              Icon(
                _getIcon(),
                color: _getIconColor(),
                size: 20,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                _getTitle(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getIconColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),

          // Issues
          ...validationResult.issues.map(_buildIssueRow),
        ],
      ),
    );
  }

  Widget _buildIssueRow(ValidationIssue issue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            issue.severity.icon,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  issue.message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                if (issue.details != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    issue.details!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
                if (issue.suggestedAction != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      '💡 ${issue.suggestedAction}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (validationResult.hasErrors) {
      return AppColors.error.withValues(alpha: 0.1);
    } else if (validationResult.hasWarnings) {
      return AppColors.warning.withValues(alpha: 0.1);
    } else {
      return AppColors.info.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor() {
    if (validationResult.hasErrors) {
      return AppColors.error;
    } else if (validationResult.hasWarnings) {
      return AppColors.warning;
    } else {
      return AppColors.info;
    }
  }

  Color _getIconColor() {
    if (validationResult.hasErrors) {
      return AppColors.error;
    } else if (validationResult.hasWarnings) {
      return AppColors.warning;
    } else {
      return AppColors.info;
    }
  }

  IconData _getIcon() {
    if (validationResult.hasErrors) {
      return Icons.error_outline;
    } else if (validationResult.hasWarnings) {
      return Icons.warning_amber_outlined;
    } else {
      return Icons.info_outline;
    }
  }

  String _getTitle() {
    if (validationResult.hasErrors) {
      return 'Errores de Validación (${validationResult.errors.length})';
    } else if (validationResult.hasWarnings) {
      return 'Advertencias (${validationResult.warnings.length})';
    } else {
      return 'Información (${validationResult.infos.length})';
    }
  }
}

/// Diálogo para mostrar resultado de validación completo
class ValidationResultDialog extends StatelessWidget {
  const ValidationResultDialog({
    required this.validationResult,
    super.key,
  });

  final ValidationResult validationResult;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          Icon(
            validationResult.hasErrors
                ? Icons.error_outline
                : Icons.warning_amber_outlined,
            color: validationResult.hasErrors
                ? AppColors.error
                : AppColors.warning,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Text(
            'Resultado de Validación',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: ValidationAlertsWidget(validationResult: validationResult),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  /// Muestra el diálogo
  static Future<void> show(
    BuildContext context,
    ValidationResult validationResult,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ValidationResultDialog(validationResult: validationResult);
      },
    );
  }
}
