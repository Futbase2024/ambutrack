import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_formatters.dart';
import 'package:ambutrack_web/features/informes/domain/costes_informe_models.dart';
import 'package:ambutrack_web/features/informes/domain/informe_calculos.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:ambutrack_web/features/informes/domain/traslado_grupo.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/domain/repositories/itv_revision_repository.dart';
import 'package:ambutrack_web/features/mantenimiento/domain/repositories/mantenimiento_repository.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/orden_reparacion_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/consumo_combustible_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/incidencia_vehiculo_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

/// BLoC del informe "Costes operativos".
///
/// Fuentes: `consumo_combustible`, `ordenes_reparacion`, `mantenimientos`,
/// `itv_revisiones`, `incidencias_vehiculo` (solo las que no tienen orden de
/// reparación, para no duplicar) y `traslados` (coste por servicio / km).
@injectable
class CostesInformeBloc extends InformeBloc<CostesInformeRaw, CostesInformeData> {
  CostesInformeBloc(
    this._vehiculos,
    this._consumos,
    this._ordenes,
    this._mantenimientos,
    this._itv,
    this._incidencias,
    this._traslados,
  );

  static const String kVehiculo = 'vehiculo';

  final VehiculoRepository _vehiculos;
  final ConsumoCombustibleRepository _consumos;
  final OrdenReparacionRepository _ordenes;
  final MantenimientoRepository _mantenimientos;
  final ItvRevisionRepository _itv;
  final IncidenciaVehiculoRepository _incidencias;
  final TrasladoRepository _traslados;

  @override
  String get nombre => 'CostesInformeBloc';

  @override
  Future<CostesInformeRaw> cargar(InformeFiltro filtro) async {
    // Consultas en paralelo
    final (
      List<VehiculoEntity> vehiculos,
      List<ConsumoCombustibleEntity> consumos,
      List<OrdenReparacionEntity> ordenes,
      Either<Exception, List<MantenimientoEntity>> mantenimientos,
      List<ItvRevisionEntity> itv,
      List<IncidenciaVehiculoEntity> incidencias,
      List<TrasladoEntity> traslados,
    ) = await (
      _vehiculos.getAll(),
      _consumos.getByRangoFechas(filtro.desde, filtro.finExclusivo),
      _ordenes.getAll(),
      _mantenimientos.getAll(),
      _itv.getAll(),
      _incidencias.getAll(),
      _traslados.getByRangoFechas(desde: filtro.desde, hasta: filtro.hasta),
    ).wait;

    final List<OrdenReparacionEntity> ords =
        ordenes.where((OrdenReparacionEntity o) => o.estado != EstadoOrdenReparacion.anulada).toList();
    final List<MantenimientoEntity> mants = mantenimientos.fold(
      (Exception e) => throw e,
      (List<MantenimientoEntity> l) => l,
    );
    final Set<String> mantConOrden =
        ords.map((OrdenReparacionEntity o) => o.mantenimientoId).whereType<String>().toSet();
    final Set<String> incConOrden = ords.map((OrdenReparacionEntity o) => o.incidenciaId).whereType<String>().toSet();

    final List<CosteApunte> apuntes = <CosteApunte>[
      for (final ConsumoCombustibleEntity c in consumos)
        CosteApunte(
          vehiculoId: c.vehiculoId,
          concepto: CosteConcepto.combustible,
          fecha: c.fecha,
          importe: c.costoTotal,
        ),
      for (final OrdenReparacionEntity o in ords)
        CosteApunte(
          vehiculoId: o.vehiculoId,
          concepto: CosteConcepto.reparaciones,
          fecha: o.fechaFinalizacion ?? o.fechaEntrada,
          importe: o.costoTotal,
        ),
      for (final MantenimientoEntity m in mants)
        if (m.estado != EstadoMantenimiento.cancelado && !mantConOrden.contains(m.id))
          CosteApunte(
            vehiculoId: m.vehiculoId,
            concepto: CosteConcepto.mantenimiento,
            fecha: m.fechaFin ?? m.fecha,
            importe: m.costoTotal,
          ),
      for (final ItvRevisionEntity i in itv)
        if (i.estado != EstadoItvRevision.cancelada)
          CosteApunte(vehiculoId: i.vehiculoId, concepto: CosteConcepto.itv, fecha: i.fecha, importe: i.costoTotal),
      for (final IncidenciaVehiculoEntity i in incidencias)
        if ((i.costoReparacion ?? 0) > 0 && !incConOrden.contains(i.id))
          CosteApunte(
            vehiculoId: i.vehiculoId,
            concepto: CosteConcepto.averias,
            fecha: i.fechaResolucion ?? i.fechaReporte,
            importe: i.costoReparacion!,
          ),
    ];

    return CostesInformeRaw(
      vehiculos: vehiculos,
      apuntes: apuntes.where((CosteApunte a) => a.importe > 0 && filtro.contiene(a.fecha)).toList(),
      traslados: traslados
          .where((TrasladoEntity t) => TrasladoGrupo.de(t) == TrasladoGrupo.finalizado)
          .toList(),
    );
  }

  @override
  CostesInformeData calcular(CostesInformeRaw raw, InformeFiltro filtro) {
    final String? vehiculo = filtro.extra(kVehiculo);
    final Map<String, String> matriculas = <String, String>{
      for (final VehiculoEntity v in raw.vehiculos) v.id: v.matricula,
    };
    final List<CosteApunte> apuntes =
        raw.apuntes.where((CosteApunte a) => vehiculo == null || a.vehiculoId == vehiculo).toList();
    final List<TrasladoEntity> traslados =
        raw.traslados.where((TrasladoEntity t) => vehiculo == null || t.idVehiculo == vehiculo).toList();

    final Set<String> ids = <String>{
      ...apuntes.map((CosteApunte a) => a.vehiculoId),
      ...traslados.map((TrasladoEntity t) => t.idVehiculo).whereType<String>(),
    };
    final List<CostesInformeFila> filas = ids.map((String id) {
      final Map<CosteConcepto, double> importes = <CosteConcepto, double>{};
      for (final CosteApunte a in apuntes.where((CosteApunte a) => a.vehiculoId == id)) {
        importes[a.concepto] = (importes[a.concepto] ?? 0) + a.importe;
      }
      final Iterable<TrasladoEntity> servicios = traslados.where((TrasladoEntity t) => t.idVehiculo == id);
      return CostesInformeFila(
        vehiculoId: id,
        matricula: matriculas[id] ?? 'Vehículo eliminado',
        importes: importes,
        servicios: servicios.length,
        km: InformeCalculos.suma(servicios, (TrasladoEntity t) => t.kmTotales),
      );
    }).toList()
      ..sort((CostesInformeFila a, CostesInformeFila b) => b.total.compareTo(a.total));

    final Map<String, double> conceptos = <String, double>{
      for (final CosteConcepto c in CosteConcepto.values)
        c.label: InformeCalculos.suma(apuntes.where((CosteApunte a) => a.concepto == c), (CosteApunte a) => a.importe),
    };
    final double total = InformeCalculos.suma(apuntes, (CosteApunte a) => a.importe);

    return CostesInformeData(
      total: total,
      kpis: _kpis(apuntes, traslados, total),
      porConcepto: InformeCalculos.barras(conceptos, GestionFormatters.moneda),
      porMes: _porMes(apuntes, filtro),
      filas: filas,
      vehiculos: Map<String, String>.fromEntries(
        matriculas.entries.toList()
          ..sort((MapEntry<String, String> a, MapEntry<String, String> b) => a.value.compareTo(b.value)),
      ),
    );
  }

  List<InformeKpi> _kpis(List<CosteApunte> apuntes, List<TrasladoEntity> traslados, double total) {
    double de(CosteConcepto c) =>
        InformeCalculos.suma(apuntes.where((CosteApunte a) => a.concepto == c), (CosteApunte a) => a.importe);
    String pct(CosteConcepto c) => '${InformeCalculos.porcentaje(de(c), total)} del total';
    final double km = InformeCalculos.suma(traslados, (TrasladoEntity t) => t.kmTotales);
    return <InformeKpi>[
      InformeKpi(label: 'Coste total', valor: GestionFormatters.moneda(total), detalle: '${apuntes.length} apuntes'),
      InformeKpi(
        label: 'Combustible',
        valor: GestionFormatters.moneda(de(CosteConcepto.combustible)),
        detalle: pct(CosteConcepto.combustible),
      ),
      InformeKpi(
        label: 'Reparaciones',
        valor: GestionFormatters.moneda(de(CosteConcepto.reparaciones) + de(CosteConcepto.averias)),
        detalle: 'Taller + averías sin orden',
      ),
      InformeKpi(
        label: 'Mantenimiento',
        valor: GestionFormatters.moneda(de(CosteConcepto.mantenimiento)),
        detalle: pct(CosteConcepto.mantenimiento),
      ),
      InformeKpi(
        label: 'ITV y revisiones',
        valor: GestionFormatters.moneda(de(CosteConcepto.itv)),
        detalle: pct(CosteConcepto.itv),
      ),
      InformeKpi(
        label: 'Coste por servicio',
        valor: traslados.isEmpty ? '—' : GestionFormatters.moneda(total / traslados.length),
        detalle: km > 0 ? '${GestionFormatters.moneda(total / km)} / km' : '${traslados.length} servicios',
      ),
    ];
  }

  /// Coste por mes, en orden cronológico
  List<InformeBarItem> _porMes(List<CosteApunte> apuntes, InformeFiltro filtro) {
    final Map<String, double> meses = <String, double>{};
    DateTime mes = DateTime(filtro.desde.year, filtro.desde.month);
    while (!mes.isAfter(filtro.hasta)) {
      meses[InformeCalculos.mes(mes)] = 0;
      mes = DateTime(mes.year, mes.month + 1);
    }
    for (final CosteApunte a in apuntes) {
      final String clave = InformeCalculos.mes(a.fecha.toLocal());
      meses[clave] = (meses[clave] ?? 0) + a.importe;
    }
    return InformeCalculos.barras(meses, GestionFormatters.moneda, maximo: 36, ordenar: false);
  }
}
