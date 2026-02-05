import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Configuración: Servicio Semanal
class ConfigSemanalWidget extends StatelessWidget {
  const ConfigSemanalWidget({
    super.key,
    required this.diasSeleccionados,
    required this.onDiasChanged,
  });

  final Set<int> diasSeleccionados;
  final void Function(Set<int>) onDiasChanged;

  static const List<String> _diasSemana = <String>['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Selecciona los días de la semana',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacing),
        Wrap(
          spacing: AppSizes.spacingSmall,
          children: List<Widget>.generate(7, (int index) {
            final bool isSelected = diasSeleccionados.contains(index + 1);
            return DiaSemanaBadgeWidget(
              label: _diasSemana[index],
              isSelected: isSelected,
              onTap: () {
                final Set<int> newDias = Set<int>.from(diasSeleccionados);
                if (isSelected) {
                  newDias.remove(index + 1);
                } else {
                  newDias.add(index + 1);
                }
                onDiasChanged(newDias);
              },
            );
          }),
        ),
        if (diasSeleccionados.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.spacingSmall),
            child: Text(
              'Selecciona al menos un día',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

/// Badge de día de la semana
class DiaSemanaBadgeWidget extends StatelessWidget {
  const DiaSemanaBadgeWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}
