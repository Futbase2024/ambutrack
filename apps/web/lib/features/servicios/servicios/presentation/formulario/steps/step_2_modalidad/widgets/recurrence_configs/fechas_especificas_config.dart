import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Configuración para FECHAS ESPECÍFICAS (selección manual de fechas concretas)
class FechasEspecificasConfig extends StatelessWidget {
  const FechasEspecificasConfig({
    required this.fechasSeleccionadas,
    required this.onFechasChanged,
    super.key,
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
              'Fechas Seleccionadas (${fechasSeleccionadas.length})',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _selectFecha(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar Fecha'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.spacingSmall,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),

        // Lista de fechas seleccionadas
        if (fechasSeleccionadas.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Center(
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.event_note,
                    size: 48,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    'No hay fechas seleccionadas',
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontMedium,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Haz clic en "Agregar Fecha" para seleccionar',
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontSmall,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray300),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: fechasSeleccionadas.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final DateTime fecha = fechasSeleccionadas[index];
                return ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  title: Text(
                    DateFormat('EEEE, dd \'de\' MMMM \'de\' yyyy', 'es')
                        .format(fecha),
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontMedium,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () => _removeFecha(index),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _selectFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      selectableDayPredicate: (DateTime day) {
        // No permitir seleccionar fechas ya añadidas
        return !fechasSeleccionadas
            .any((DateTime f) => _isSameDay(f, day));
      },
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
      final List<DateTime> nuevasFechas = <DateTime>[
        ...fechasSeleccionadas,
        picked,
      ]..sort(); // Ordenar cronológicamente
      onFechasChanged(nuevasFechas);
    }
  }

  void _removeFecha(int index) {
    final List<DateTime> nuevasFechas = List<DateTime>.from(fechasSeleccionadas)
      ..removeAt(index);
    onFechasChanged(nuevasFechas);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
