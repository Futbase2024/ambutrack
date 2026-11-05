import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/informes/domain/flota_informe_models.dart';
import 'package:ambutrack_web/features/informes/domain/informe_calculos.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:ambutrack_web/features/informes/domain/traslado_grupo.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/orden_reparacion_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/consumo_combustible_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/incidencia_vehiculo_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:injectable/injectable.dart';

/// Etiqueta legible del estado de un vehículo
String vehiculoEstadoLabel(VehiculoEstado e) {
  switch (e) {
    case VehiculoEstado.activo:
      return 'Activo';
    case VehiculoEstado.mantenimiento:
      return 'Mantenimiento';
    case VehiculoEstado.reparacion:
      return 'Reparación';
    case VehiculoEstado.baja:
      return 'Baja';
  }
}

/// Días que una orden de reparación mantiene el vehículo en taller dentro
/// del periodo (las órdenes activas cuentan hasta hoy)
int diasEnTaller(InformeFiltro filtro, OrdenReparacionEntity o) {
  if (o.estado == EstadoOrdenReparacion.anulada) {
    return 0;
  }
  final DateTime fin = o.fechaCierre ?? o.fechaFinalizacion ?? (o.estado.isActiva ? DateTime.now() : o.fechaEntrada);
  return InformeCalculos.diasSolapados(filtro, o.fechaEntrada, fin);
}

/// BLoC del informe "Estadísticas de flota".
///
/// Fuentes: `tvehiculos`, `traslados`, `consumo_combustible`,
/// `incidencias_vehiculo` y `ordenes_reparacion`.
@injectable
class FlotaInformeBloc extends InformeBloc<FlotaInformeRaw, FlotaInformeData> {
  FlotaInformeBloc(this._vehiculos, this._traslados, this._consumos, this._incidencias, this._ordenes);

  static const String kCategoria = 'categoria';
  static const String kEstado = 'estado';

  final VehiculoRepository _vehiculos;
  final TrasladoRepository _traslados;
  final ConsumoCombustibleRepository _consumos;
  final IncidenciaVehiculoRepository _incidencias;
  final OrdenReparacionRepository _ordenes;

  @override
  String get nombre => 'FlotaInformeBloc';

  @override
  Future<FlotaInformeRaw> cargar(InformeFiltro filtro) async {
    // Consultas en paralelo
    final (
      List<VehiculoEntity> vehiculos,
      List<TrasladoEntity> traslados,
      List<ConsumoCombustibleEntity> consumos,
      List<IncidenciaVehiculoEntity> incidencias,
      List<OrdenReparacionEntity> ordenes,
    ) = await (
      _vehiculos.getAll(),
      _traslados.getByRangoFechas(desde: filtro.desde, hasta: filtro.hasta),
      _consumos.getByRangoFechas(filtro.desde, filtro.finExclusivo),
      _incidencias.getAll(),
      _ordenes.getAll(),
    ).wait;
    return FlotaInformeRaw(
      vehiculos: vehiculos,
      traslados: traslados,
      consumos: consumos.where((ConsumoCombustibleEntity c) => filtro.contiene(c.fecha)).toList(),
      incidencias: incidencias.where((IncidenciaVehiculoEntity i) => filtro.contiene(i.fechaReporte)).toList(),
      ordenes: ordenes,
    );
  }

  @override
  FlotaInformeData calcular(FlotaInformeRaw raw, InformeFiltro filtro) {
    final String? categoria = filtro.extra(kCategoria);
    final String? estado = filtro.extra(kEstado);
    final List<VehiculoEntity> vehiculos = raw.vehiculos
        .where((VehiculoEntity v) => categoria == null || v.categoria == categoria)
        .where((VehiculoEntity v) => estado == null || v.estado.name == estado)
        .toList();

    final List<FlotaInformeFila> filas = vehiculos.map((VehiculoEntity v) {
      final Iterable<TrasladoEntity> servicios = raw.traslados.where(
        (TrasladoEntity t) => t.idVehiculo == v.id && TrasladoGrupo.de(t) == TrasladoGrupo.finalizado,
      );
      final Iterable<ConsumoCombustibleEntity> consumos =
          raw.consumos.where((ConsumoCombustibleEntity c) => c.vehiculoId == v.id);
      return FlotaInformeFila(
        vehiculo: v,
        servicios: servicios.length,
        kmServicio: InformeCalculos.suma(servicios, (TrasladoEntity t) => t.kmTotales),
        litros: InformeCalculos.suma(consumos, (ConsumoCombustibleEntity c) => c.litros),
        kmRepostaje: InformeCalculos.suma(consumos, (ConsumoCombustibleEntity c) => c.kmRecorridosDesdeUltimo),
        averias: raw.incidencias.where((IncidenciaVehiculoEntity i) => i.vehiculoId == v.id).length,
        diasTaller: raw.ordenes
            .where((OrdenReparacionEntity o) => o.vehiculoId == v.id)
            .fold<int>(0, (int s, OrdenReparacionEntity o) => s + diasEnTaller(filtro, o)),
      );
    }).toList()
      ..sort((FlotaInformeFila a, FlotaInformeFila b) => b.servicios.compareTo(a.servicios));

    final Map<String, double> estados = <String, double>{};
    for (final VehiculoEntity v in vehiculos) {
      final String label = vehiculoEstadoLabel(v.estado);
      estados[label] = (estados[label] ?? 0) + 1;
    }

    return FlotaInformeData(
      kpis: _kpis(filas, filtro),
      serviciosPorVehiculo: InformeCalculos.barras(
        <String, double>{
          for (final FlotaInformeFila f in filas)
            if (f.servicios > 0) f.vehiculo.matricula: f.servicios.toDouble(),
        },
        InformeCalculos.entero,
        maximo: 10,
      ),
      estadoFlota: InformeCalculos.barras(estados, InformeCalculos.entero),
      filas: filas,
      categorias: raw.vehiculos
          .map((VehiculoEntity v) => v.categoria)
          .where((String c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort(),
    );
  }

  List<InformeKpi> _kpis(List<FlotaInformeFila> filas, InformeFiltro filtro) {
    final List<FlotaInformeFila> operativos =
        filas.where((FlotaInformeFila f) => f.vehiculo.estado != VehiculoEstado.baja).toList();
    final int activos = filas.where((FlotaInformeFila f) => f.vehiculo.estado == VehiculoEstado.activo).length;
    final double litros = InformeCalculos.suma(filas, (FlotaInformeFila f) => f.litros);
    final double kmRepostaje = InformeCalculos.suma(filas, (FlotaInformeFila f) => f.kmRepostaje);
    final int diasTaller = filas.fold<int>(0, (int s, FlotaInformeFila f) => s + f.diasTaller);
    final int diasPosibles = operativos.length * filtro.dias;
    return <InformeKpi>[
      InformeKpi(
        label: 'Vehículos activos',
        valor: '$activos / ${filas.length}',
        detalle: '${filas.length - operativos.length} de baja',
      ),
      InformeKpi(
        label: 'Servicios finalizados',
        valor: InformeCalculos.entero(filas.fold<int>(0, (int s, FlotaInformeFila f) => s + f.servicios)),
      ),
      InformeKpi(
        label: 'Km en servicio',
        valor: InformeCalculos.entero(InformeCalculos.suma(filas, (FlotaInformeFila f) => f.kmServicio)),
      ),
      InformeKpi(
        label: 'Combustible',
        valor: '${InformeCalculos.entero(litros)} L',
        detalle: kmRepostaje > 0 ? '${InformeCalculos.decimal(litros * 100 / kmRepostaje)} L/100 km' : null,
      ),
      InformeKpi(
        label: 'Averías reportadas',
        valor: InformeCalculos.entero(filas.fold<int>(0, (int s, FlotaInformeFila f) => s + f.averias)),
      ),
      InformeKpi(
        label: 'Disponibilidad',
        valor: diasPosibles == 0 ? '—' : InformeCalculos.porcentaje(diasPosibles - diasTaller, diasPosibles),
        detalle: '$diasTaller días en taller',
      ),
    ];
  }
}
