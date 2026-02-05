import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Configuración: Fechas Específicas
class ConfigEspecificoWidget extends StatelessWidget {
  const ConfigEspecificoWidget({
    super.key,
    required this.fechasSeleccionadas,
    required this.onFechasChanged,
  });

  final List<DateTime> fechasSeleccionadas;
  final void Function(List<DateTime>) onFechasChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Fechas seleccionadas (${fechasSeleccionadas.length})',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
            AppButton(
              label: 'Agregar Fecha',
              icon: Icons.add,
              variant: AppButtonVariant.text,
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  final List<DateTime> newFechas = List<DateTime>.from(fechasSeleccionadas)..add(picked);
                  onFechasChanged(newFechas);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (fechasSeleccionadas.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.warning_amber, color: AppColors.warning, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Agrega al menos una fecha específica para el servicio',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimaryLight),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fechasSeleccionadas.map((DateTime fecha) {
              return Chip(
                label: Text(
                  DateFormat('dd/MM/yyyy').format(fecha),
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  final List<DateTime> newFechas = List<DateTime>.from(fechasSeleccionadas)..remove(fecha);
                  onFechasChanged(newFechas);
                },
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              );
            }).toList(),
          ),
      ],
    );
  }
}
