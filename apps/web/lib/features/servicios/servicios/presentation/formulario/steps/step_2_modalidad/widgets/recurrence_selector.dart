import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/servicios/domain/entities/configuracion_modalidad.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Selector de tipo de recurrencia para servicios
/// Muestra 6 opciones en grid: Único, Diario, Semanal, Días Alternos, Fechas Específicas, Mensual
class RecurrenceSelector extends StatelessWidget {
  const RecurrenceSelector({
    required this.tipoSeleccionado,
    required this.onTipoChanged,
    super.key,
  });

  final TipoRecurrencia? tipoSeleccionado;
  final void Function(TipoRecurrencia) onTipoChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Tipo de Recurrencia *',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacing),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSizes.spacing,
          mainAxisSpacing: AppSizes.spacing,
          childAspectRatio: 2.5,
          children: <Widget>[
            _RecurrenceCard(
              tipo: TipoRecurrencia.unico,
              icon: Icons.calendar_today,
              isSelected: tipoSeleccionado == TipoRecurrencia.unico,
              onTap: () => onTipoChanged(TipoRecurrencia.unico),
            ),
            _RecurrenceCard(
              tipo: TipoRecurrencia.diario,
              icon: Icons.calendar_view_day,
              isSelected: tipoSeleccionado == TipoRecurrencia.diario,
              onTap: () => onTipoChanged(TipoRecurrencia.diario),
            ),
            _RecurrenceCard(
              tipo: TipoRecurrencia.semanal,
              icon: Icons.calendar_view_week,
              isSelected: tipoSeleccionado == TipoRecurrencia.semanal,
              onTap: () => onTipoChanged(TipoRecurrencia.semanal),
            ),
            _RecurrenceCard(
              tipo: TipoRecurrencia.diasAlternos,
              icon: Icons.repeat,
              isSelected: tipoSeleccionado == TipoRecurrencia.diasAlternos,
              onTap: () => onTipoChanged(TipoRecurrencia.diasAlternos),
            ),
            _RecurrenceCard(
              tipo: TipoRecurrencia.fechasEspecificas,
              icon: Icons.event_note,
              isSelected: tipoSeleccionado == TipoRecurrencia.fechasEspecificas,
              onTap: () => onTipoChanged(TipoRecurrencia.fechasEspecificas),
            ),
            _RecurrenceCard(
              tipo: TipoRecurrencia.mensual,
              icon: Icons.calendar_month,
              isSelected: tipoSeleccionado == TipoRecurrencia.mensual,
              onTap: () => onTipoChanged(TipoRecurrencia.mensual),
            ),
          ],
        ),
      ],
    );
  }
}

/// Card individual para un tipo de recurrencia
class _RecurrenceCard extends StatelessWidget {
  const _RecurrenceCard({
    required this.tipo,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final TipoRecurrencia tipo;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSmall,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 6),
            Text(
              tipo.displayName,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              tipo.description,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
