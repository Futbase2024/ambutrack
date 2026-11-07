import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Vista de 14 días para planificación de servicios
///
/// Muestra un calendario de 2 semanas con los traslados de cada día
class Traslados14DaysView extends StatefulWidget {
  const Traslados14DaysView({
    required this.traslados,
    required this.onDaySelected,
    this.selectedDay,
    super.key,
  });

  final List<TrasladoEntity> traslados;
  final ValueChanged<DateTime> onDaySelected;
  final DateTime? selectedDay;

  @override
  State<Traslados14DaysView> createState() => _Traslados14DaysViewState();
}

class _Traslados14DaysViewState extends State<Traslados14DaysView> {
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    // Iniciar desde el lunes de la semana actual
    _startDate = _getMonday(DateTime.now());
  }

  DateTime _getMonday(DateTime date) {
    final int weekday = date.weekday;
    final DateTime monday = date.subtract(Duration(days: weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  List<DateTime> _get14Days() {
    return List<DateTime>.generate(
      14,
      (int index) => _startDate.add(Duration(days: index)),
    );
  }

  List<TrasladoEntity> _getTrasladosForDay(DateTime day) {
    final DateTime dayKey = DateTime(day.year, day.month, day.day);
    return widget.traslados.where((TrasladoEntity traslado) {
      if (traslado.fecha == null) {
        return false;
      }
      final DateTime trasladoKey = DateTime(
        traslado.fecha!.year,
        traslado.fecha!.month,
        traslado.fecha!.day,
      );
      return trasladoKey == dayKey;
    }).toList();
  }

  bool _isToday(DateTime day) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime dayKey = DateTime(day.year, day.month, day.day);
    return dayKey == today;
  }

  bool _isSelected(DateTime day) {
    if (widget.selectedDay == null) {
      return false;
    }
    final DateTime selectedKey = DateTime(
      widget.selectedDay!.year,
      widget.selectedDay!.month,
      widget.selectedDay!.day,
    );
    final DateTime dayKey = DateTime(day.year, day.month, day.day);
    return dayKey == selectedKey;
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> days = _get14Days();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.calendar_view_week,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vista 14 Días',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                Text(
                  '${DateFormat('dd MMM', 'es_ES').format(days.first)} - ${DateFormat('dd MMM yyyy', 'es_ES').format(days.last)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Días de la semana (2 semanas x 7 días)
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              children: <Widget>[
                // Semana 1
                _buildWeekHeader(days.sublist(0, 7)),
                const SizedBox(height: 8),
                _buildWeekDays(days.sublist(0, 7)),
                const SizedBox(height: 16),

                // Semana 2
                _buildWeekHeader(days.sublist(7, 14)),
                const SizedBox(height: 8),
                _buildWeekDays(days.sublist(7, 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(List<DateTime> weekDays) {
    return Row(
      children: weekDays.map((DateTime day) {
        return Expanded(
          child: Center(
            child: Text(
              DateFormat('E', 'es_ES').format(day).replaceAll('.', ''),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeekDays(List<DateTime> weekDays) {
    return Row(
      children: weekDays.map((DateTime day) {
        final List<TrasladoEntity> dayTraslados = _getTrasladosForDay(day);
        final bool isToday = _isToday(day);
        final bool isSelected = _isSelected(day);

        return Expanded(
          child: GestureDetector(
            onTap: () => widget.onDaySelected(day),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isToday
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.gray200,
                ),
              ),
              child: Column(
                children: <Widget>[
                  // Día del mes
                  Text(
                    DateFormat('d').format(day),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? AppColors.primary
                            : AppColors.textPrimaryLight,
                  ),
                ),
                  const SizedBox(height: 4),

                  // Contador de traslados
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppColors.gray100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${dayTraslados.length}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
