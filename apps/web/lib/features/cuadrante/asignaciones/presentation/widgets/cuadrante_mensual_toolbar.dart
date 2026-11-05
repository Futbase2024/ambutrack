import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tipos de vista del cuadrante
enum TipoVistaCuadrante {
  mensual,
  semanal,
  diaria,
}

const List<String> _meses = <String>[
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', //
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

/// Texto del periodo visible según el tipo de vista
String cuadranteRangoTexto(TipoVistaCuadrante tipo, DateTime date) {
  switch (tipo) {
    case TipoVistaCuadrante.mensual:
      return '${_meses[date.month - 1]} ${date.year}';
    case TipoVistaCuadrante.semanal:
      final DateTime firstDay = date.subtract(Duration(days: date.weekday - 1));
      final DateTime lastDay = firstDay.add(const Duration(days: 6));
      if (firstDay.month == lastDay.month) {
        return '${firstDay.day}-${lastDay.day} ${_meses[firstDay.month - 1]} ${firstDay.year}';
      } else if (firstDay.year == lastDay.year) {
        return '${firstDay.day} ${_meses[firstDay.month - 1]} - '
            '${lastDay.day} ${_meses[lastDay.month - 1]} ${firstDay.year}';
      }
      return '${firstDay.day} ${_meses[firstDay.month - 1]} ${firstDay.year} - '
          '${lastDay.day} ${_meses[lastDay.month - 1]} ${lastDay.year}';
    case TipoVistaCuadrante.diaria:
      const List<String> diasSemana = <String>['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return '${diasSemana[date.weekday - 1]}, ${date.day} ${_meses[date.month - 1]} ${date.year}';
  }
}

/// Barra de herramientas del cuadrante unificado: selector de vista y periodo
class CuadranteMensualToolbar extends StatelessWidget {
  const CuadranteMensualToolbar({
    required this.tipoVista,
    required this.selectedDate,
    required this.onTipoVistaChanged,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final TipoVistaCuadrante tipoVista;
  final DateTime selectedDate;
  final ValueChanged<TipoVistaCuadrante> onTipoVistaChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  static const Map<TipoVistaCuadrante, String> _unidad = <TipoVistaCuadrante, String>{
    TipoVistaCuadrante.mensual: 'Mes',
    TipoVistaCuadrante.semanal: 'Semana',
    TipoVistaCuadrante.diaria: 'Día',
  };

  @override
  Widget build(BuildContext context) {
    final String unidad = _unidad[tipoVista]!;
    return GestionToolbar(
      title: 'Cuadrante Mensual Unificado',
      icon: Icons.calendar_month,
      groups: const <List<GestionToolbarAction>>[],
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestionSegmentedSelector<TipoVistaCuadrante>(
            selected: tipoVista,
            onChanged: onTipoVistaChanged,
            options: const <GestionSegmentOption<TipoVistaCuadrante>>[
              GestionSegmentOption<TipoVistaCuadrante>(
                value: TipoVistaCuadrante.diaria,
                label: 'Diaria',
                icon: Icons.calendar_today,
              ),
              GestionSegmentOption<TipoVistaCuadrante>(
                value: TipoVistaCuadrante.semanal,
                label: 'Semanal',
                icon: Icons.calendar_view_week,
              ),
              GestionSegmentOption<TipoVistaCuadrante>(
                value: TipoVistaCuadrante.mensual,
                label: 'Mensual',
                icon: Icons.calendar_month,
              ),
            ],
          ),
          const SizedBox(width: 10),
          GestionPeriodNavigator(
            label: cuadranteRangoTexto(tipoVista, selectedDate),
            previousTooltip: '$unidad anterior',
            nextTooltip: '$unidad siguiente',
            onPrevious: onPrevious,
            onNext: onNext,
          ),
        ],
      ),
    );
  }
}

/// Barra de estado con el resumen de asignaciones del periodo
class CuadranteMensualStatusBar extends StatelessWidget {
  const CuadranteMensualStatusBar({
    required this.tipoVista,
    required this.selectedDate,
    super.key,
  });

  final TipoVistaCuadrante tipoVista;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CuadranteAsignacionesBloc, CuadranteAsignacionesState>(
      builder: (BuildContext context, CuadranteAsignacionesState state) {
        final List<String> items = <String>['Periodo: ${cuadranteRangoTexto(tipoVista, selectedDate)}'];
        if (state is CuadranteAsignacionesLoaded) {
          final List<CuadranteAsignacionEntity> list = state.asignaciones;
          items.insertAll(0, <String>[
            'Asignaciones: ${list.length}',
            'Personal: ${list.map((CuadranteAsignacionEntity a) => a.idPersonal).toSet().length}',
            'Vehículos: ${list.map((CuadranteAsignacionEntity a) => a.idVehiculo).whereType<String>().toSet().length}',
          ]);
        }
        return GestionStatusBar(items: items);
      },
    );
  }
}
