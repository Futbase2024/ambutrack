import 'package:ambutrack_web/features/home/presentation/config/dashboard_card_config.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/charts/dashboard_chart_cards.dart';
import 'package:flutter/material.dart';

/// Separación entre gráficas
const double _kSpacing = 14;

/// Altura de cada gráfica cuando se apilan (altura disponible no acotada)
const double _kAlturaApilada = 280;

/// Ancho mínimo de cada gráfica para colocarla en columnas
const double _kAnchoMinimoGrafica = 320;

/// Sección de gráficas del Dashboard
///
/// - Altura acotada (pantalla ancha): todas las gráficas en una fila.
/// - Altura libre (pantalla estrecha con scroll): se reparten en filas de
///   1, 2 o 3 columnas según el ancho, con altura fija por gráfica.
class DashboardCharts extends StatelessWidget {
  const DashboardCharts({
    super.key,
    required this.totalVehiculos,
    required this.vehiculosEnServicio,
    required this.vehiculosMantenimiento,
    required this.vehiculosDisponibles,
    required this.serviciosProgramadosActivos,
    required this.serviciosProgramadosCompletados,
    required this.serviciosUrgenciasActivos,
    required this.serviciosUrgenciasCompletados,
    required this.serviciosTotalesDia,
    required this.serviciosCompletadosDia,
    required this.serviciosEnProceso,
    this.visibleCharts,
  });

  final int totalVehiculos;
  final int vehiculosEnServicio;
  final int vehiculosMantenimiento;
  final int vehiculosDisponibles;
  final int serviciosProgramadosActivos;
  final int serviciosProgramadosCompletados;
  final int serviciosUrgenciasActivos;
  final int serviciosUrgenciasCompletados;
  final int serviciosTotalesDia;
  final int serviciosCompletadosDia;
  final int serviciosEnProceso;

  /// Charts a mostrar. Si es null, se muestran todos (backward compatible).
  final Set<DashboardChartType>? visibleCharts;

  bool _visible(DashboardChartType type) => visibleCharts == null || visibleCharts!.contains(type);

  List<Widget> _charts() {
    return <Widget>[
      if (_visible(DashboardChartType.flota))
        VehiculosChartCard(
          disponibles: vehiculosDisponibles,
          enServicio: vehiculosEnServicio,
          mantenimiento: vehiculosMantenimiento,
          inactivos: totalVehiculos - vehiculosDisponibles - vehiculosEnServicio - vehiculosMantenimiento,
        ),
      if (_visible(DashboardChartType.servicios))
        ServiciosDistributionCard(
          urgencias: serviciosUrgenciasActivos + serviciosUrgenciasCompletados,
          programados: serviciosProgramadosActivos + serviciosProgramadosCompletados,
          enProceso: serviciosEnProceso,
        ),
      if (_visible(DashboardChartType.resumenDia))
        ResumenDiaCard(
          totalDia: serviciosTotalesDia,
          completados: serviciosCompletadosDia,
          enProceso: serviciosEnProceso,
          pendientes: serviciosTotalesDia - serviciosCompletadosDia - serviciosEnProceso,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> charts = _charts();
    if (charts.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxHeight.isFinite) {
          return _ChartsRow(charts: charts);
        }
        final int columnas = (constraints.maxWidth / _kAnchoMinimoGrafica).floor().clamp(1, charts.length);
        return _ChartsGrid(charts: charts, columnas: columnas);
      },
    );
  }
}

/// Fila de gráficas que ocupa toda la altura disponible
class _ChartsRow extends StatelessWidget {
  const _ChartsRow({required this.charts});

  final List<Widget> charts;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < charts.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: _kSpacing),
          Expanded(child: charts[i]),
        ],
      ],
    );
  }
}

/// Rejilla de gráficas con altura fija por fila (para layouts con scroll)
class _ChartsGrid extends StatelessWidget {
  const _ChartsGrid({required this.charts, required this.columnas});

  final List<Widget> charts;
  final int columnas;

  @override
  Widget build(BuildContext context) {
    final List<Widget> filas = <Widget>[];
    for (int inicio = 0; inicio < charts.length; inicio += columnas) {
      final List<Widget> fila = charts.sublist(inicio, (inicio + columnas).clamp(0, charts.length));
      filas.add(
        SizedBox(
          height: _kAlturaApilada,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < columnas; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: _kSpacing),
                Expanded(child: i < fila.length ? fila[i] : const SizedBox.shrink()),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < filas.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: _kSpacing),
          filas[i],
        ],
      ],
    );
  }
}
