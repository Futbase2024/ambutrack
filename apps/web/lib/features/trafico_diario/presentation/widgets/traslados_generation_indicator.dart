import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Indicador del estado de generación de traslados
///
/// Muestra información sobre hasta qué fecha están generados los traslados
/// y si es necesario regenerarlos
class TrasladosGenerationIndicator extends StatelessWidget {
  const TrasladosGenerationIndicator({
    required this.trasladosGeneradosHasta,
    this.isLoading = false,
    this.onRefresh,
    super.key,
  });

  final DateTime? trasladosGeneradosHasta;
  final bool isLoading;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    // Si no hay fecha de generación, mostrar indicador de sin datos
    if (trasladosGeneradosHasta == null) {
      return _buildCard(
        context,
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.warning,
        title: 'Sin traslados generados',
        description: 'No hay traslados generados. Genera los traslados para comenzar.',
        backgroundColor: AppColors.warning.withValues(alpha: 0.1),
        borderColor: AppColors.warning,
        showRefresh: true,
      );
    }

    // Calcular días restantes
    final int diasRestantes = trasladosGeneradosHasta!.difference(now).inDays;

    // Si hay menos de 3 días, mostrar advertencia
    if (diasRestantes < 3) {
      return _buildCard(
        context,
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.warning,
        title: 'Traslados desactualizados',
        description: 'Generados hasta el ${DateFormat('dd/MM/yyyy').format(trasladosGeneradosHasta!)}. '
            'Quedan ${diasRestantes < 0 ? 0 : diasRestantes} días. '
            'Se recomienda regenerar.',
        backgroundColor: AppColors.warning.withValues(alpha: 0.1),
        borderColor: AppColors.warning,
        showRefresh: true,
      );
    }

    // Si está bien, mostrar indicador verde
    return _buildCard(
      context,
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
      title: 'Traslados actualizados',
      description: 'Generados hasta el ${DateFormat('dd/MM/yyyy').format(trasladosGeneradosHasta!)} '
          '($diasRestantes días restantes)',
      backgroundColor: AppColors.success.withValues(alpha: 0.1),
      borderColor: AppColors.success,
      showRefresh: false,
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required Color backgroundColor,
    required Color borderColor,
    required bool showRefresh,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: <Widget>[
          // Icono
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Botón de refresh si es necesario
          if (showRefresh && onRefresh != null) ...<Widget>[
            const SizedBox(width: 12),
            IconButton(
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : const Icon(Icons.refresh, size: 18),
              onPressed: isLoading ? null : onRefresh,
              tooltip: 'Regenerar traslados',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }
}
