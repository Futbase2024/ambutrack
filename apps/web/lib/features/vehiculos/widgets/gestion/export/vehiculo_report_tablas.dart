import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/export/gestion_report.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/gestion/documentacion_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_estado.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/export/vehiculo_ficha_data.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';

/// Tablas de los informes de vehículos, compartidas por la ficha individual
/// y por el informe completo (en este último con la matrícula como 1ª columna).
class VehiculoReportTablas {
  const VehiculoReportTablas._();

  static const GestionReportColumn _matricula = GestionReportColumn('Matrícula', flex: 1.1);

  /// Todos los campos de cada vehículo (hoja de datos para Excel)
  static GestionReportTable vehiculos(List<VehiculoEntity> vs, {required String sheetName}) {
    return GestionReportTable(
      title: 'Todos los datos de los vehículos',
      sheetName: sheetName,
      columns: _colsVehiculoCompleto,
      rows: vs.map(_filaCompleta).toList(),
      emptyMessage: 'No hay vehículos que coincidan con los filtros',
    );
  }

  static const List<GestionReportColumn> _colsVehiculoCompleto = <GestionReportColumn>[
    GestionReportColumn('Matrícula'), GestionReportColumn('Nº interno'), GestionReportColumn('Alias'),
    GestionReportColumn('Marca'), GestionReportColumn('Modelo'), GestionReportColumn('Año'),
    GestionReportColumn('Tipo'), GestionReportColumn('Categoría'), GestionReportColumn('Clasificación'),
    GestionReportColumn('Nº bastidor'), GestionReportColumn('Estado'), GestionReportColumn('Requiere CAP'),
    GestionReportColumn('Silla eléctrica'), GestionReportColumn('Pasajeros'), GestionReportColumn('Camillas'),
    GestionReportColumn('Km actual'), GestionReportColumn('Ubicación'), GestionReportColumn('Adquisición'),
    GestionReportColumn('Próxima ITV'), GestionReportColumn('Venc. seguro'), GestionReportColumn('Homologación'),
    GestionReportColumn('Venc. homologación'), GestionReportColumn('Últ. mantenimiento'),
    GestionReportColumn('Próx. mantenimiento'), GestionReportColumn('Km próx. mantenimiento'),
    GestionReportColumn('Observaciones', excelWidth: 50), GestionReportColumn('Alta'),
    GestionReportColumn('Modificado'),
  ];

  static List<Object?> _filaCompleta(VehiculoEntity v) => <Object?>[
        v.matricula, v.numeroInterno, v.alias, v.marca, v.modelo, v.anioFabricacion, v.tipoVehiculo,
        v.categoria, v.clasificacion, v.numeroBastidor, vehiculoEstadoLabel(v.estado), v.requiereCap,
        v.tieneSillaElectrica, v.capacidadPasajeros, v.capacidadCamilla, v.kmActual?.round(),
        v.ubicacionActual, v.fechaAdquisicion, v.proximaItv, v.fechaVencimientoSeguro,
        v.homologacionSanitaria, v.fechaVencimientoHomologacion, v.ultimoMantenimiento,
        v.proximoMantenimiento, v.kmProximoMantenimiento, v.observaciones, v.createdAt, v.updatedAt,
      ];

  static GestionReportTable itv(List<VehiculoFichaData> datos, {bool conMatricula = false}) {
    return _tabla<ItvRevisionEntity>(
      title: 'ITV y revisiones',
      datos: datos,
      items: (VehiculoFichaData d) => d.itv,
      conMatricula: conMatricula,
      columns: const <GestionReportColumn>[
        GestionReportColumn('Fecha', flex: 0.8), GestionReportColumn('Tipo', flex: 1.1),
        GestionReportColumn('Resultado'), GestionReportColumn('Estado', flex: 0.9),
        GestionReportColumn('Km', flex: 0.7), GestionReportColumn('Vence', flex: 0.8),
        GestionReportColumn('Taller', flex: 1.2), GestionReportColumn('Coste', flex: 0.8),
      ],
      fila: (ItvRevisionEntity i) => <Object?>[
        i.fecha, i.tipo.displayName, i.resultado.displayName, i.estado.displayName,
        i.kmVehiculo.round(), i.fechaVencimiento, i.taller, GestionMoney(i.costoTotal),
      ],
      vacio: 'Sin ITV ni revisiones registradas',
    );
  }

  static GestionReportTable documentos(List<VehiculoFichaData> datos, {bool conMatricula = false}) {
    return _tabla<DocumentacionVehiculoEntity>(
      title: 'Documentación',
      datos: datos,
      items: (VehiculoFichaData d) => d.documentos,
      conMatricula: conMatricula,
      columns: const <GestionReportColumn>[
        GestionReportColumn('Documento', flex: 1.4), GestionReportColumn('Nº póliza / licencia', flex: 1.2),
        GestionReportColumn('Compañía / entidad', flex: 1.3), GestionReportColumn('Emisión', flex: 0.8),
        GestionReportColumn('Vencimiento', flex: 0.8), GestionReportColumn('Estado', flex: 0.9),
        GestionReportColumn('Coste anual', flex: 0.8),
      ],
      fila: (DocumentacionVehiculoEntity d) => <Object?>[
        docTipoLabel(d), d.numeroPoliza, d.compania, d.fechaEmision, d.fechaVencimiento,
        docEstadoLabel(d.estado), _dinero(d.costeAnual),
      ],
      vacio: 'Sin documentación registrada',
    );
  }

  static GestionReportTable reparaciones(List<VehiculoFichaData> datos, {bool conMatricula = false}) {
    final double total = datos
        .expand((VehiculoFichaData d) => d.ordenes)
        .where((OrdenReparacionEntity o) => o.estado != EstadoOrdenReparacion.anulada)
        .fold<double>(0, (double s, OrdenReparacionEntity o) => s + o.costoTotal);
    return _tabla<OrdenReparacionEntity>(
      title: 'Reparaciones de taller',
      sheetName: 'Reparaciones',
      datos: datos,
      items: (VehiculoFichaData d) => d.ordenes,
      conMatricula: conMatricula,
      columns: const <GestionReportColumn>[
        GestionReportColumn('Nº orden', flex: 0.9), GestionReportColumn('Entrada', flex: 0.8),
        GestionReportColumn('Estado', flex: 0.9), GestionReportColumn('Prioridad', flex: 0.7),
        GestionReportColumn('Origen', flex: 0.8), GestionReportColumn('Taller', flex: 1.1),
        GestionReportColumn('Diagnóstico', flex: 1.8, excelWidth: 50), GestionReportColumn('Finalizada', flex: 0.8),
        GestionReportColumn('Importe', flex: 0.8),
      ],
      fila: (OrdenReparacionEntity o) => <Object?>[
        o.numeroOrden, o.fechaEntrada, o.estado.displayName, o.prioridad.displayName, o.origen.displayName,
        o.tallerNombre, o.diagnostico, o.fechaFinalizacion, GestionMoney(o.costoTotal),
      ],
      vacio: 'Sin órdenes de reparación',
      footer: 'Importe total (sin anuladas): ${GestionReportFormat.text(GestionMoney(total))}',
    );
  }

  static GestionReportTable equipamiento(List<VehiculoFichaData> datos, {bool conMatricula = false}) {
    return _tabla<StockVehiculoEntity>(
      title: 'Equipamiento y dotación',
      sheetName: 'Equipamiento',
      datos: datos,
      items: (VehiculoFichaData d) => List<StockVehiculoEntity>.of(d.dotacion)
        ..sort((StockVehiculoEntity a, StockVehiculoEntity b) {
          final int s = (a.seccionOrden ?? 999).compareTo(b.seccionOrden ?? 999);
          return s != 0 ? s : (a.orden ?? 999).compareTo(b.orden ?? 999);
        }),
      conMatricula: conMatricula,
      columns: const <GestionReportColumn>[
        GestionReportColumn('Sección', flex: 1.1), GestionReportColumn('Producto', flex: 2.2),
        GestionReportColumn('Cantidad', flex: 0.6), GestionReportColumn('Mínima', flex: 0.6),
        GestionReportColumn('Caducidad', flex: 0.8), GestionReportColumn('Lote', flex: 0.8),
        GestionReportColumn('Estado', flex: 0.9),
      ],
      fila: (StockVehiculoEntity l) => <Object?>[
        l.seccion ?? l.categoriaNombre, l.productoNombre ?? l.nombreComercial, l.cantidadActual,
        l.cantidadMinima, l.fechaCaducidad, l.lote, EstadoDotacion.of(l).label,
      ],
      vacio: 'Sin plantilla de equipamiento para su tipo',
    );
  }

  static GestionMoney? _dinero(double? v) => v == null ? null : GestionMoney(v);

  static GestionReportTable _tabla<T>({
    required String title,
    required List<VehiculoFichaData> datos,
    required List<T> Function(VehiculoFichaData) items,
    required bool conMatricula,
    required List<GestionReportColumn> columns,
    required List<Object?> Function(T) fila,
    required String vacio,
    String? footer,
    String? sheetName,
  }) {
    return GestionReportTable(
      title: title,
      sheetName: sheetName,
      columns: <GestionReportColumn>[if (conMatricula) _matricula, ...columns],
      rows: <List<Object?>>[
        for (final VehiculoFichaData d in datos)
          for (final T item in items(d)) <Object?>[if (conMatricula) d.vehiculo.matricula, ...fila(item)],
      ],
      emptyMessage: vacio,
      footer: footer,
    );
  }
}
