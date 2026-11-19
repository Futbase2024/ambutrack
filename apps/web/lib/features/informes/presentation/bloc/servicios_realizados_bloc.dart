import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/informes/domain/informe_calculos.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:ambutrack_web/features/informes/domain/traslado_grupo.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:injectable/injectable.dart';

/// Datos agregados del informe de servicios realizados
class ServiciosRealizadosData {
  const ServiciosRealizadosData({
    required this.kpis,
    required this.porEstado,
    required this.porMotivo,
    required this.filas,
    required this.vehiculos,
    required this.total,
  });

  final List<InformeKpi> kpis;
  final List<InformeBarItem> porEstado;
  final List<InformeBarItem> porMotivo;

  /// Traslados tras aplicar todos los filtros
  final List<TrasladoEntity> filas;

  /// Matrículas disponibles para el filtro
  final List<String> vehiculos;

  /// Traslados del periodo (filtrados por vehículo)
  final int total;
}

/// BLoC del informe "Servicios realizados" (fuente: tabla `traslados`)
@injectable
class ServiciosRealizadosBloc extends InformeBloc<List<TrasladoEntity>, ServiciosRealizadosData> {
  ServiciosRealizadosBloc(this._repository);

  /// Claves de filtros extra
  static const String kVehiculo = 'vehiculo';
  static const String kGrupo = 'grupo';

  final TrasladoRepository _repository;

  @override
  String get nombre => 'ServiciosRealizadosBloc';

  @override
  Future<List<TrasladoEntity>> cargar(InformeFiltro filtro) =>
      _repository.getByRangoFechas(desde: filtro.desde, hasta: filtro.hasta);

  @override
  ServiciosRealizadosData calcular(List<TrasladoEntity> raw, InformeFiltro filtro) {
    final String? vehiculo = filtro.extra(kVehiculo);
    final String? grupo = filtro.extra(kGrupo);

    final List<TrasladoEntity> base = raw
        .where((TrasladoEntity t) => vehiculo == null || TrasladoTextos.vehiculo(t) == vehiculo)
        .toList();
    final List<TrasladoEntity> finalizados =
        base.where((TrasladoEntity t) => TrasladoGrupo.de(t) == TrasladoGrupo.finalizado).toList();
    final int cancelados = base.where((TrasladoEntity t) => TrasladoGrupo.de(t) == TrasladoGrupo.cancelado).length;
    final int noRealizados =
        base.where((TrasladoEntity t) => TrasladoGrupo.de(t) == TrasladoGrupo.noRealizado).length;
    final double km = InformeCalculos.suma(finalizados, (TrasladoEntity t) => t.kmTotales);
    final List<int> duraciones = finalizados
        .map((TrasladoEntity t) => t.duracionRealMinutos ?? 0)
        .where((int d) => d > 0)
        .toList();

    final Map<String, double> estados = <String, double>{
      for (final TrasladoGrupo g in TrasladoGrupo.values) g.label: 0,
    };
    for (final TrasladoEntity t in base) {
      final String label = TrasladoGrupo.de(t).label;
      estados[label] = estados[label]! + 1;
    }

    final List<TrasladoEntity> filas = base
        .where((TrasladoEntity t) => grupo == null || TrasladoGrupo.de(t).name == grupo)
        .toList();

    final Set<String> vehiculos = raw.map(TrasladoTextos.vehiculo).toSet();

    return ServiciosRealizadosData(
      total: base.length,
      kpis: <InformeKpi>[
        InformeKpi(label: 'Servicios del periodo', valor: InformeCalculos.entero(base.length)),
        InformeKpi(
          label: 'Finalizados',
          valor: InformeCalculos.entero(finalizados.length),
          detalle: InformeCalculos.porcentaje(finalizados.length, base.length),
        ),
        InformeKpi(
          label: 'Cancelados / anulados',
          valor: InformeCalculos.entero(cancelados),
          detalle: InformeCalculos.porcentaje(cancelados, base.length),
        ),
        InformeKpi(
          label: 'No realizados',
          valor: InformeCalculos.entero(noRealizados),
          detalle: InformeCalculos.porcentaje(noRealizados, base.length),
        ),
        InformeKpi(label: 'Km en servicio', valor: InformeCalculos.entero(km), detalle: 'Servicios finalizados'),
        InformeKpi(
          label: 'Duración media',
          valor: duraciones.isEmpty ? '—' : '${InformeCalculos.entero(InformeCalculos.media(duraciones))} min',
          detalle: '${duraciones.length} con duración registrada',
        ),
      ],
      porEstado: InformeCalculos.barras(estados, InformeCalculos.entero, ordenar: false),
      porMotivo: InformeCalculos.contar(base, TrasladoTextos.motivo),
      filas: filas,
      vehiculos: vehiculos.toList()..sort(),
    );
  }
}
