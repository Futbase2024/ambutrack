import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Configuración para servicio ÚNICO (una sola fecha)
class UnicoConfig extends StatelessWidget {
  const UnicoConfig({
    required this.fechaSeleccionada,
    required this.onFechaChanged,
    super.key,
  });

  final DateTime? fechaSeleccionada;
  final void Function(DateTime) onFechaChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Fecha del Servicio *',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingSmall,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray300),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.textSecondaryLight,
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: Text(
                    fechaSeleccionada != null
                        ? DateFormat('dd/MM/yyyy', 'es').format(fechaSeleccionada!)
                        : 'Seleccionar fecha',
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontMedium,
                      color: fechaSeleccionada != null
                          ? AppColors.textPrimaryLight
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondaryLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (picked != null) {
      onFechaChanged(picked);
    }
  }
}
