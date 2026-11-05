import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/informes/domain/calidad_metricas.dart';
import 'package:ambutrack_web/features/informes/domain/informe_calculos.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:ambutrack_web/features/informes/domain/traslado_grupo.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:injectable/injectable.dart';

/// Datos agregados del informe de indicadores de calidad
class IndicadoresCalidadData {
  const IndicadoresCalidadData({
    required this.kpis,
    required this.distribucionRetrasos,
    required this.motivosIncidencia,
    required this.porVehiculo,
    required this.vehiculos,
    required this.global,
  });

  final List<InformeKpi> kpis;
  final List<InformeBarItem> distribucionRetrasos;
  final List<InformeBarItem> motivosIncidencia;
  final List<CalidadMetricas> porVehiculo;
  final List<String> vehiculos;
  final CalidadMetricas global;
}

/// BLoC del informe "Indicadores de calidad".
///
/// Fuente: tabla `traslados` (hora programada, marcas de tiempo de cada
/// estado, duración real/estimada y motivos de cancelación).
@injectable
class IndicadoresCalidadBloc extends InformeBloc<List<TrasladoEntity>, IndicadoresCalidadData> {
  IndicadoresCalidadBloc(this._repository);

  static const String kVehiculo = 'vehiculo';

  final TrasladoRepository _repository;

  @override
  String get nombre => 'IndicadoresCalidadBloc';

  @override
  Future<List<TrasladoEntity>> cargar(InformeFiltro filtro) =>
      _repository.getByRangoFechas(desde: filtro.desde, hasta: filtro.hasta);

  @override
  IndicadoresCalidadData calcular(List<TrasladoEntity> raw, InformeFiltro filtro) {
    final String? vehiculo = filtro.extra(kVehiculo);
    final List<TrasladoEntity> base = raw
        .where((TrasladoEntity t) => vehiculo == null || TrasladoTextos.vehiculo(t) == vehiculo)
        .toList();

    final CalidadMetricas global = CalidadMetricas('Total');
    final Map<String, CalidadMetricas> porVehiculo = <String, CalidadMetricas>{};
    for (final TrasladoEntity t in base) {
      global.add(t);
      final String clave = TrasladoTextos.vehiculo(t);
      porVehiculo.putIfAbsent(clave, () => CalidadMetricas(clave)).add(t);
    }

    final List<CalidadMetricas> filas = porVehiculo.values.toList()
      ..sort((CalidadMetricas a, CalidadMetricas b) => b.servicios.compareTo(a.servicios));

    return IndicadoresCalidadData(
      global: global,
      kpis: _kpis(global),
      distribucionRetrasos: _distribucion(global.retrasos),
      motivosIncidencia: InformeCalculos.contar(
        base.where((TrasladoEntity t) {
          final TrasladoGrupo g = TrasladoGrupo.de(t);
          return g == TrasladoGrupo.cancelado || g == TrasladoGrupo.noRealizado;
        }),
        _motivoIncidencia,
      ),
      porVehiculo: filas,
      vehiculos: raw.map(TrasladoTextos.vehiculo).toSet().toList()..sort(),
    );
  }

  List<InformeKpi> _kpis(CalidadMetricas g) {
    String pct(double? v) => v == null ? '—' : '${InformeCalculos.decimal(v)} %';
    String min(List<int> l, double v) => l.isEmpty ? '—' : '${InformeCalculos.entero(v)} min';
    return <InformeKpi>[
      InformeKpi(
        label: 'Tasa de realización',
        valor: pct(g.tasaRealizacion),
        detalle: '${g.finalizados} de ${g.cerrados} cerrados',
      ),
      InformeKpi(
        label: 'Puntualidad en origen',
        valor: pct(g.tasaPuntualidad),
        detalle: '≤ $kToleranciaPuntualidad min · ${g.retrasos.length} medidos',
      ),
      InformeKpi(
        label: 'Retraso medio en origen',
        valor: min(g.retrasos, g.retrasoMedio),
        detalle: 'Sobre hora programada',
      ),
      InformeKpi(
        label: 'Aceptación conductor',
        valor: min(g.aceptaciones, g.aceptacionMedia),
        detalle: 'Media envío → recibido',
      ),
      InformeKpi(
        label: 'Tasa de cancelación',
        valor: InformeCalculos.porcentaje(g.cancelados + g.noRealizados, g.servicios),
        detalle: '${g.cancelados + g.noRealizados} de ${g.servicios} servicios',
      ),
      InformeKpi(
        label: 'Duración media real',
        valor: min(g.duraciones, g.duracionMedia),
        detalle: g.estimadas.isEmpty ? 'Sin estimación' : 'Estimada ${InformeCalculos.entero(g.estimadaMedia)} min',
      ),
    ];
  }

  List<InformeBarItem> _distribucion(List<int> retrasos) {
    final Map<String, double> tramos = <String, double>{
      'A tiempo o antes': 0,
      '1 – 15 min': 0,
      '16 – 30 min': 0,
      '31 – 60 min': 0,
      'Más de 60 min': 0,
    };
    for (final int r in retrasos) {
      final String clave = r <= 0
          ? 'A tiempo o antes'
          : r <= 15
              ? '1 – 15 min'
              : r <= 30
                  ? '16 – 30 min'
                  : r <= 60
                      ? '31 – 60 min'
                      : 'Más de 60 min';
      tramos[clave] = tramos[clave]! + 1;
    }
    if (retrasos.isEmpty) {
      return <InformeBarItem>[];
    }
    return InformeCalculos.barras(tramos, InformeCalculos.entero, ordenar: false);
  }

  static String _motivoIncidencia(TrasladoEntity t) {
    final String? m = t.motivoCancelacion ?? t.motivoNoRealizacion;
    return m == null || m.trim().isEmpty ? 'Sin motivo indicado' : m.trim();
  }
}
