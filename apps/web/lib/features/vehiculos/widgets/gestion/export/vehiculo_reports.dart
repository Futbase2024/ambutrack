import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/export/gestion_report.dart';
import 'package:ambutrack_web/core/widgets/gestion/export/gestion_report_grid.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_grid_column.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/export/vehiculo_ficha_data.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/export/vehiculo_report_tablas.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';

/// Construye los informes exportables de vehículos (PDF y Excel)
class VehiculoReports {
  const VehiculoReports._();

  /// Columnas de la rejilla que se pueden exportar (las que elige el usuario)
  static List<GestionColumn<VehiculoEntity>> get columnasExportables =>
      vehiculoGestionColumns.where((GestionColumn<VehiculoEntity> c) => c.exportValue != null).toList();

  /// Listado idéntico a la rejilla: filtros, orden y estilos, con las [columnas]
  /// elegidas (todas si es null). Con [todosLosDatos] (Excel) añade una hoja con todos los campos.
  static GestionReport listado(
    List<VehiculoEntity> vs, {
    required String filtros,
    required bool todosLosDatos,
    List<GestionColumn<VehiculoEntity>>? columnas,
  }) {
    return GestionReport(
      title: 'Listado de vehículos',
      subtitle: filtros,
      landscape: true,
      summary: resumen(vs),
      sections: <GestionReportSection>[
        gestionReportTableFromGrid<VehiculoEntity>(
          title: 'Listado de vehículos',
          sheetName: 'Listado',
          columns: columnas ?? vehiculoGestionColumns,
          rows: vs,
          emptyMessage: 'Ningún vehículo coincide con los filtros',
        ),
        if (todosLosDatos) VehiculoReportTablas.vehiculos(vs, sheetName: 'Todos los datos'),
      ],
    );
  }

  /// Indicadores de la flota
  static List<GestionReportField> resumen(List<VehiculoEntity> vs) {
    int estado(VehiculoEstado e) => vs.where((VehiculoEntity v) => v.estado == e).length;
    return <GestionReportField>[
      GestionReportField('Vehículos', vs.length),
      GestionReportField('Disponibles', estado(VehiculoEstado.activo)),
      GestionReportField('Mantenimiento', estado(VehiculoEstado.mantenimiento)),
      GestionReportField('Reparación', estado(VehiculoEstado.reparacion)),
      GestionReportField('Baja', estado(VehiculoEstado.baja)),
      GestionReportField('Requieren CAP', vs.where((VehiculoEntity v) => v.requiereCap).length),
      GestionReportField('Con silla eléc.', vs.where((VehiculoEntity v) => v.tieneSillaElectrica).length),
    ];
  }

  /// Ficha individual completa de un vehículo
  static GestionReport ficha(VehiculoFichaData d) {
    final VehiculoEntity v = d.vehiculo;
    final List<VehiculoFichaData> uno = <VehiculoFichaData>[d];
    return GestionReport(
      title: 'Ficha de vehículo · ${v.matricula}',
      subtitle: '${v.marca} ${v.modelo} · ${v.tipoVehiculo}',
      summary: <GestionReportField>[
        GestionReportField('Estado', vehiculoEstadoLabel(v.estado)),
        GestionReportField('Km actual', v.kmActual?.round()),
        GestionReportField('Próxima ITV', v.proximaItv),
        GestionReportField('Reparaciones abiertas', d.ordenes.where((OrdenReparacionEntity o) => o.estado.isActiva).length),
      ],
      sections: <GestionReportSection>[
        ..._datosGenerales(v),
        VehiculoReportTablas.itv(uno),
        VehiculoReportTablas.documentos(uno),
        VehiculoReportTablas.reparaciones(uno),
        VehiculoReportTablas.equipamiento(uno),
      ],
    );
  }

  /// Informe completo para Excel: un libro con hojas consolidadas de todos los vehículos
  static GestionReport completoExcel(List<VehiculoFichaData> datos, {required String filtros}) {
    return GestionReport(
      title: 'Informe completo de vehículos',
      subtitle: filtros,
      summary: resumen(datos.map((VehiculoFichaData d) => d.vehiculo).toList()),
      sections: <GestionReportSection>[
        VehiculoReportTablas.vehiculos(datos.map((VehiculoFichaData d) => d.vehiculo).toList(), sheetName: 'Vehículos'),
        VehiculoReportTablas.itv(datos, conMatricula: true),
        VehiculoReportTablas.documentos(datos, conMatricula: true),
        VehiculoReportTablas.reparaciones(datos, conMatricula: true),
        VehiculoReportTablas.equipamiento(datos, conMatricula: true),
      ],
    );
  }

  static List<GestionReportFields> _datosGenerales(VehiculoEntity v) {
    final DateTime hoy = DateTime.now();
    bool vencida(DateTime? f) => f != null && f.isBefore(hoy);
    return <GestionReportFields>[
      GestionReportFields(
        title: 'Identificación y características',
        fields: <GestionReportField>[
          GestionReportField('Matrícula', v.matricula),
          GestionReportField('Nº interno', v.numeroInterno),
          GestionReportField('Alias', v.alias),
          GestionReportField('Nº bastidor', v.numeroBastidor),
          GestionReportField('Marca', v.marca),
          GestionReportField('Modelo', v.modelo),
          GestionReportField('Año', v.anioFabricacion),
          GestionReportField('Tipo', v.tipoVehiculo),
          GestionReportField('Categoría', v.categoria),
          GestionReportField('Clasificación', v.clasificacion),
          GestionReportField('Requiere CAP', v.requiereCap),
          GestionReportField('Silla eléctrica', v.tieneSillaElectrica),
          GestionReportField('Soporte silla eléc.', v.tieneSoporteSillaElectrica),
          GestionReportField('Carros', v.numeroCarros),
          GestionReportField('Pasajeros', v.capacidadPasajeros),
          GestionReportField('Camillas', v.capacidadCamilla),
        ],
      ),
      GestionReportFields(
        title: 'Uso y vencimientos',
        fields: <GestionReportField>[
          GestionReportField('Estado', vehiculoEstadoLabel(v.estado)),
          GestionReportField('Km actual', v.kmActual?.round()),
          GestionReportField('Ubicación', v.ubicacionActual),
          GestionReportField('Adquisición', v.fechaAdquisicion),
          GestionReportField('Próxima ITV', v.proximaItv, highlight: vencida(v.proximaItv)),
          GestionReportField('Venc. seguro', v.fechaVencimientoSeguro, highlight: vencida(v.fechaVencimientoSeguro)),
          GestionReportField('Homologación', v.homologacionSanitaria),
          GestionReportField(
            'Venc. homolog.',
            v.fechaVencimientoHomologacion,
            highlight: vencida(v.fechaVencimientoHomologacion),
          ),
          GestionReportField('Últ. manten.', v.ultimoMantenimiento),
          GestionReportField('Próx. manten.', v.proximoMantenimiento, highlight: vencida(v.proximoMantenimiento)),
          GestionReportField('Km próx. manten.', v.kmProximoMantenimiento),
        ],
      ),
      GestionReportFields(
        title: 'Observaciones',
        fields: <GestionReportField>[GestionReportField('Notas', v.observaciones)],
      ),
    ];
  }
}
