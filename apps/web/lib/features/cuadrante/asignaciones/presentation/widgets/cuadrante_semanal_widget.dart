import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget para vista semanal del cuadrante
/// Muestra una semana completa (lunes a domingo) con slots por hora
class CuadranteSemanalWidget extends StatelessWidget {
  const CuadranteSemanalWidget({
    required this.selectedWeek,
    required this.asignaciones,
    required this.onWeekChanged,
    super.key,
  });

  final DateTime selectedWeek;
  final List<CuadranteAsignacionEntity> asignaciones;
  final void Function(DateTime) onWeekChanged;

  @override
  Widget build(BuildContext context) {
    // Calcular inicio de semana (lunes)
    final int weekday = selectedWeek.weekday;
    final DateTime firstDay = selectedWeek.subtract(Duration(days: weekday - 1));

    return Container(
      margin: const EdgeInsets.all(AppSizes.spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader(firstDay),
          const Divider(height: 1, color: AppColors.gray200),
          Expanded(
            child: _buildWeekGrid(firstDay),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(DateTime firstDay) {
    final List<String> diasSemana = <String>['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      child: Row(
        children: <Widget>[
          // Columna de horas (vacía en header)
          const SizedBox(width: 60),
          // Columnas de días
          for (int i = 0; i < 7; i++)
            Expanded(
              child: _buildDayHeader(
                diasSemana[i],
                firstDay.add(Duration(days: i)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String diaSemana, DateTime fecha) {
    final bool isToday = _isToday(fecha);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        children: <Widget>[
          Text(
            diaSemana,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isToday ? AppColors.primary : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${fecha.day}',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isToday ? AppColors.primary : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekGrid(DateTime firstDay) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Columna de horas
          _buildHoursColumn(),
          // Columnas de días
          for (int i = 0; i < 7; i++)
            Expanded(
              child: _buildDayColumn(firstDay.add(Duration(days: i))),
            ),
        ],
      ),
    );
  }

  Widget _buildHoursColumn() {
    return SizedBox(
      width: 60,
      child: Column(
        children: <Widget>[
          for (int hour = 0; hour < 24; hour++)
            Container(
              height: 80,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(DateTime fecha) {
    final List<CuadranteAsignacionEntity> asignacionesDelDia = asignaciones.where((CuadranteAsignacionEntity a) {
      return a.fecha.year == fecha.year && a.fecha.month == fecha.month && a.fecha.day == fecha.day;
    }).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.gray200.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: <Widget>[
          for (int hour = 0; hour < 24; hour++)
            _buildHourSlot(fecha, hour, asignacionesDelDia),
        ],
      ),
    );
  }

  Widget _buildHourSlot(DateTime fecha, int hour, List<CuadranteAsignacionEntity> asignacionesDelDia) {
    // Filtrar asignaciones que cruzan esta hora
    final List<CuadranteAsignacionEntity> asignacionesEnHora = asignacionesDelDia.where((CuadranteAsignacionEntity a) {
      final List<String> horaInicioParts = a.horaInicio.split(':');
      final int horaInicioInt = int.parse(horaInicioParts[0]);
      final List<String> horaFinParts = a.horaFin.split(':');
      final int horaFinInt = int.parse(horaFinParts[0]);

      if (a.cruzaMedianoche) {
        // Si cruza medianoche, verificar si la hora está en el rango
        return horaInicioInt <= hour || hour < horaFinInt;
      } else {
        return horaInicioInt <= hour && hour < horaFinInt;
      }
    }).toList();

    return Container(
      height: 80,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: asignacionesEnHora.isEmpty
          ? null
          : ListView.builder(
              padding: const EdgeInsets.all(2),
              itemCount: asignacionesEnHora.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildMiniAsignacionCard(asignacionesEnHora[index]);
              },
            ),
    );
  }

  Widget _buildMiniAsignacionCard(CuadranteAsignacionEntity asignacion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getEstadoColor(asignacion.estado).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getEstadoColor(asignacion.estado),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            asignacion.nombrePersonal,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (asignacion.matriculaVehiculo != null && asignacion.matriculaVehiculo!.isNotEmpty)
            Text(
              asignacion.matriculaVehiculo!,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Row(
            children: <Widget>[
              Text(
                '${asignacion.horaInicio} - ${asignacion.horaFin}',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(EstadoAsignacion estado) {
    switch (estado) {
      case EstadoAsignacion.planificada:
        return AppColors.warning;
      case EstadoAsignacion.confirmada:
        return AppColors.info;
      case EstadoAsignacion.activa:
        return AppColors.primary;
      case EstadoAsignacion.completada:
        return AppColors.success;
      case EstadoAsignacion.cancelada:
        return AppColors.error;
    }
  }

  bool _isToday(DateTime fecha) {
    final DateTime now = DateTime.now();
    return fecha.year == now.year && fecha.month == now.month && fecha.day == now.day;
  }
}
