import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Header de la página de planificación de servicios
///
/// Incluye:
/// - Selector de fecha con navegación (día anterior/siguiente)
/// - Botón para ir a HOY
/// - DatePicker al hacer clic en la fecha
class ServiciosHeader extends StatelessWidget {
  const ServiciosHeader({
    required this.selectedDay,
    required this.onDayChanged,
    super.key,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDayChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.calendar_month,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Asignación de Servicios',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(width: 12),

          // Selector de fecha
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Botón día anterior
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 16),
                  onPressed: () {
                    onDayChanged(selectedDay.subtract(const Duration(days: 1)));
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.textSecondaryLight,
                  tooltip: 'Día anterior',
                ),
                const SizedBox(width: 6),

                // Fecha seleccionada (clickable para mostrar calendario)
                InkWell(
                  onTap: () => _mostrarSelectorFecha(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'es_ES').format(selectedDay),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
                    ],
                  ),
                ),

                const SizedBox(width: 6),
                // Botón día siguiente
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 16),
                  onPressed: () {
                    onDayChanged(selectedDay.add(const Duration(days: 1)));
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.textSecondaryLight,
                  tooltip: 'Día siguiente',
                ),
              ],
            ),
          ),

          const Spacer(),

          // Botón para ir a hoy
          ElevatedButton.icon(
            onPressed: () {
              onDayChanged(DateTime.now());
            },
            icon: const Icon(Icons.today, size: 16),
            label: const Text('HOY'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo DatePicker para seleccionar fecha
  Future<void> _mostrarSelectorFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      onDayChanged(fecha);
    }
  }
}
