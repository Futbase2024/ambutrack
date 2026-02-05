import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Configuración: Mensual
class ConfigMensualWidget extends StatelessWidget {
  const ConfigMensualWidget({
    super.key,
    required this.diasSeleccionados,
    required this.onDiasChanged,
  });

  final Set<int> diasSeleccionados;
  final void Function(Set<int>) onDiasChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Selecciona los días del mes',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 31,
          itemBuilder: (BuildContext context, int index) {
            final int dia = index + 1;
            final bool isSelected = diasSeleccionados.contains(dia);
            return DiaMesBadgeWidget(
              dia: dia,
              isSelected: isSelected,
              onTap: () {
                final Set<int> newDias = Set<int>.from(diasSeleccionados);
                if (isSelected) {
                  newDias.remove(dia);
                } else {
                  newDias.add(dia);
                }
                onDiasChanged(newDias);
              },
            );
          },
        ),
      ],
    );
  }
}

/// Badge de día del mes
class DiaMesBadgeWidget extends StatelessWidget {
  const DiaMesBadgeWidget({
    super.key,
    required this.dia,
    required this.isSelected,
    required this.onTap,
  });

  final int dia;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            dia.toString(),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}
