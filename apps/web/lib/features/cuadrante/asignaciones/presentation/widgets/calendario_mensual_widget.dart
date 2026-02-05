import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/dia_slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget del calendario mensual que muestra las asignaciones
class CalendarioMensualWidget extends StatelessWidget {
  const CalendarioMensualWidget({
    required this.selectedMonth,
    required this.asignaciones,
    required this.onMonthChanged,
    this.onDayTap,
    this.onAsignacionTap,
    super.key,
  });

  final DateTime selectedMonth;
  final List<CuadranteAsignacionEntity> asignaciones;
  final void Function(DateTime) onMonthChanged;

  /// Callback cuando se hace clic en un día (para crear nueva asignación)
  final void Function(DateTime)? onDayTap;

  /// Callback cuando se hace clic en una asignación (para editarla)
  final void Function(CuadranteAsignacionEntity)? onAsignacionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: <Widget>[
          _buildCalendarHeader(),
          const Divider(height: 1, color: AppColors.gray200),
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    const List<String> diasSemana = <String>[
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      decoration: const BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radius),
          topRight: Radius.circular(AppSizes.radius),
        ),
      ),
      child: Row(
        children: diasSemana.map((String dia) {
          return Expanded(
            child: Center(
              child: Text(
                dia,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final DateTime firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month);
    final DateTime lastDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    // Calcular el primer lunes de la vista (puede ser del mes anterior)
    final int weekdayOfFirst = firstDayOfMonth.weekday; // 1 = Lunes, 7 = Domingo
    final DateTime startDate = firstDayOfMonth.subtract(Duration(days: weekdayOfFirst - 1));

    // Calcular cuántas semanas necesitamos (siempre 6 para consistencia)
    const int totalWeeks = 6;
    final List<List<DateTime>> weeks = <List<DateTime>>[];

    DateTime currentDate = startDate;
    for (int week = 0; week < totalWeeks; week++) {
      final List<DateTime> weekDays = <DateTime>[];
      for (int day = 0; day < 7; day++) {
        weekDays.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
      weeks.add(weekDays);
    }

    return ListView.builder(
      itemCount: weeks.length,
      itemBuilder: (BuildContext context, int weekIndex) {
        return _buildWeekRow(weeks[weekIndex], firstDayOfMonth, lastDayOfMonth);
      },
    );
  }

  Widget _buildWeekRow(List<DateTime> weekDays, DateTime firstDay, DateTime lastDay) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: weekDays.map((DateTime day) {
          final bool isCurrentMonth = day.month == selectedMonth.month;
          final bool isToday = _isToday(day);
          final List<CuadranteAsignacionEntity> asignacionesDelDia = _getAsignacionesDelDia(day);

          return Expanded(
            child: DiaSlotWidget(
              fecha: day,
              asignaciones: asignacionesDelDia,
              isCurrentMonth: isCurrentMonth,
              isToday: isToday,
              onDayTap: onDayTap,
              onAsignacionTap: onAsignacionTap,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<CuadranteAsignacionEntity> _getAsignacionesDelDia(DateTime dia) {
    return asignaciones.where((CuadranteAsignacionEntity asignacion) {
      return asignacion.fecha.year == dia.year &&
          asignacion.fecha.month == dia.month &&
          asignacion.fecha.day == dia.day;
    }).toList();
  }

  bool _isToday(DateTime fecha) {
    final DateTime now = DateTime.now();
    return fecha.year == now.year && fecha.month == now.month && fecha.day == now.day;
  }
}
