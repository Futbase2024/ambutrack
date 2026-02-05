import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/disponibilidad_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Panel que muestra los gaps de cobertura (franjas sin personal)
class GapsCoberturaPanel extends StatelessWidget {
  const GapsCoberturaPanel({
    required this.gaps,
    this.onGapSelected,
    super.key,
  });

  final List<DisponibilidadEntity> gaps;
  final void Function(DisponibilidadEntity)? onGapSelected;

  @override
  Widget build(BuildContext context) {
    if (gaps.isEmpty) {
      return _buildNoGaps();
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(),
          const SizedBox(height: AppSizes.spacing),
          Expanded(
            child: ListView.separated(
              itemCount: gaps.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (BuildContext context, int index) {
                final DisponibilidadEntity gap = gaps[index];
                return _buildGapItem(gap);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: const Icon(
            Icons.warning_amber,
            color: AppColors.error,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Gaps de Cobertura Detectados',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              Text(
                '${gaps.length} ${gaps.length == 1 ? 'franja sin cobertura' : 'franjas sin cobertura'}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGapItem(DisponibilidadEntity gap) {
    return InkWell(
      onTap: onGapSelected != null ? () => onGapSelected!(gap) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
        child: Row(
          children: <Widget>[
            // Icono de alerta
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.spacing),

            // Información del gap
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'es').format(gap.fecha),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('HH:mm').format(gap.horaInicio)} - ${DateFormat('HH:mm').format(gap.horaFin)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            // Badge de severidad
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Text(
                'SIN COBERTURA',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoGaps() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.success),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              'No hay gaps de cobertura',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Todas las franjas horarias tienen personal asignado',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
