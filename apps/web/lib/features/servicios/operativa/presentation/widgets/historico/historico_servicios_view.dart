import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_event.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/gestion_date_range_navigator.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_gestion_config.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Histórico de servicios: traslados cerrados (finalizados, cancelados,
/// no realizados, suspendidos, anulados) en un rango de fechas
class HistoricoServiciosView extends StatefulWidget {
  const HistoricoServiciosView({super.key});

  @override
  State<HistoricoServiciosView> createState() => _HistoricoServiciosViewState();
}

class _HistoricoServiciosViewState extends State<HistoricoServiciosView> {
  late DateTimeRange _range;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final DateTime hoy = DateTime(now.year, now.month, now.day);
    _range = DateTimeRange(start: hoy.subtract(const Duration(days: 30)), end: hoy);
    _load();
  }

  void _load() {
    context.read<TrasladosConsultaBloc>().add(
          TrasladosConsultaRequested(
            consulta: TrasladosConsulta.rango(_range.start, _range.end),
          ),
        );
  }

  void _onRangeChanged(DateTimeRange range) {
    setState(() => _range = range);
    _load();
  }

  static List<TrasladoEntity> _cerrados(List<TrasladoEntity> traslados) => traslados
      .where((TrasladoEntity t) => TrasladoGestion.estadosFinales.contains(t.estado))
      .toList();

  static List<String> _resumen(List<TrasladoEntity> base) {
    final int finalizados = base.where((TrasladoEntity t) => t.estado == 'finalizado').length;
    final double km = base.fold<double>(
      0,
      (double sum, TrasladoEntity t) => sum + (t.kmTotales ?? 0),
    );
    return <String>[
      'Finalizados $finalizados',
      'No finalizados ${base.length - finalizados}',
      'Km totales ${km.toStringAsFixed(0)}',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final String periodo =
        'Periodo ${GestionFormatters.fecha(_range.start)} – ${GestionFormatters.fecha(_range.end)}';
    return TrasladosGestionView(
      onRefresh: _load,
      config: TrasladosGestionConfig(
        title: 'Histórico de Servicios',
        icon: Icons.history,
        estados: TrasladoGestion.estadosFinales.toList(),
        toolbarTrailing: GestionDateRangeNavigator(range: _range, onChanged: _onRangeChanged),
        preFilter: _cerrados,
        extraStatus: _resumen,
        emptyMessage: 'No hay servicios cerrados en el periodo seleccionado',
        printSubtitle: periodo,
        filtersSignature: _range,
      ),
    );
  }
}
