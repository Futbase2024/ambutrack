import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Selector de días del mes en formato grid
/// Muestra botones del 1-31 + "Último día del mes"
class SelectorDiasMes extends StatelessWidget {
  const SelectorDiasMes({
    required this.diasSeleccionados,
    required this.onDiasChanged,
    super.key,
  });

  /// Lista de días seleccionados (1-31, 0=último día)
  final List<int> diasSeleccionados;

  /// Callback cuando cambia la selección
  final void Function(List<int>) onDiasChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Días del Mes *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Mensaje informativo
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.info,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Text(
                  'Selecciona los días del mes en los que se realizará el servicio. '
                  '"Último" representa el último día de cada mes.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacing),

        // Grid de días 1-31
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: 31,
          itemBuilder: (BuildContext context, int index) {
            final int dia = index + 1;
            final bool isSelected = diasSeleccionados.contains(dia);

            return _DayChip(
              label: dia.toString(),
              isSelected: isSelected,
              onTap: () => _toggleDia(dia),
            );
          },
        ),
        const SizedBox(height: AppSizes.spacing),

        // Botón especial para "Último día"
        SizedBox(
          width: double.infinity,
          child: _DayChip(
            label: 'Último',
            subtitle: 'Último día del mes',
            isSelected: diasSeleccionados.contains(0),
            onTap: () => _toggleDia(0),
            isWide: true,
          ),
        ),
      ],
    );
  }

  void _toggleDia(int dia) {
    debugPrint('🗓️ SelectorDiasMes: Toggle día $dia');
    final List<int> nuevaSeleccion = List<int>.from(diasSeleccionados);
    if (nuevaSeleccion.contains(dia)) {
      debugPrint('🗓️ SelectorDiasMes: Removiendo día $dia');
      nuevaSeleccion.remove(dia);
    } else {
      debugPrint('🗓️ SelectorDiasMes: Agregando día $dia');
      nuevaSeleccion.add(dia);
    }

    // Ordenar (0 al final)
    nuevaSeleccion.sort((int a, int b) {
      if (a == 0) {
        return 1;
      }
      if (b == 0) {
        return -1;
      }
      return a.compareTo(b);
    });

    debugPrint('🗓️ SelectorDiasMes: Nueva selección: $nuevaSeleccion');
    debugPrint('🗓️ SelectorDiasMes: Llamando onDiasChanged...');
    onDiasChanged(nuevaSeleccion);
  }
}

/// Chip individual para un día del mes
class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.isWide = false,
  });

  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? AppSizes.paddingMedium : AppSizes.paddingSmall,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              )
            : Center(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
      ),
    );
  }
}
