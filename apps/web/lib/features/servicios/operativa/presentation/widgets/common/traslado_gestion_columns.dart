import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';

/// Días desde epoch (clave de orden segura en web)
int _dia(DateTime? d) => d == null ? 0 : d.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

int _minutos(DateTime? d) => d == null ? 99999 : d.toLocal().hour * 60 + d.toLocal().minute;

/// Columnas de la rejilla de traslados.
///
/// [nombres]: nombre del personal por ID.
/// [conFecha]: incluye la columna de fecha (pantallas de varios días).
List<GestionColumn<TrasladoEntity>> trasladoGestionColumns({
  required Map<String, String> nombres,
  bool conFecha = true,
}) {
  return <GestionColumn<TrasladoEntity>>[
    if (conFecha)
      GestionColumn<TrasladoEntity>(
        label: 'Fecha',
        width: 96,
        sortValue: (TrasladoEntity t) =>
            _dia(t.fecha) * 100000 + _minutos(t.horaProgramada),
        cell: (TrasladoEntity t) => TrasladoCellText(GestionFormatters.fecha(t.fecha)),
      ),
    GestionColumn<TrasladoEntity>(
      label: 'Hora',
      width: 64,
      sortValue: (TrasladoEntity t) => _minutos(t.horaProgramada),
      cell: (TrasladoEntity t) =>
          TrasladoCellText(TrasladoGestion.hora(t.horaProgramada), bold: true),
    ),
    GestionColumn<TrasladoEntity>(
      label: 'Código',
      width: 120,
      sortValue: (TrasladoEntity t) => t.codigo ?? '',
      cell: (TrasladoEntity t) => TrasladoCellText(GestionFormatters.texto(t.codigo)),
    ),
    GestionColumn<TrasladoEntity>(
      label: 'Paciente',
      flex: 3,
      sortValue: TrasladoGestion.paciente,
      cell: (TrasladoEntity t) => TrasladoCellText(TrasladoGestion.paciente(t), bold: true),
    ),
    GestionColumn<TrasladoEntity>(
      label: 'Tipo',
      width: 70,
      sortValue: TrasladoGestion.tipo,
      cell: (TrasladoEntity t) => TrasladoCellText(TrasladoGestion.tipo(t)),
    ),
    GestionColumn<TrasladoEntity>(
      label: 'Origen',
      flex: 3,
      sortValue: TrasladoGestion.origen,
      cell: (TrasladoEntity t) => TrasladoCellText(TrasladoGestion.origen(t)),
    ),
    GestionColumn<TrasladoEntity>(
      label: 'Destino',
      flex: 3,
      sortValue: TrasladoGestion.destino,
      cell: (TrasladoEntity t) => TrasladoCellText(TrasladoGestion.destino(t)),
    ),
    GestionColumn<TrasladoEntity>(
      label: 'Prioridad',
      width: 104,
      sortValue: (TrasladoEntity t) => t.prioridad,
      cell: (TrasladoEntity t) => TrasladoPrioridadDot(prioridad: t.prioridad),
    ),
    GestionColumn<TrasladoEntity>(
      label: 'Conductor',
      flex: 2,
      sortValue: (TrasladoEntity t) => TrasladoGestion.conductor(t, nombres),
      cell: (TrasladoEntity t) => TrasladoCellText(TrasladoGestion.conductor(t, nombres)),
    ),
    GestionColumn<TrasladoEntity>(
      label: 'Vehículo',
      width: 90,
      sortValue: (TrasladoEntity t) => t.matriculaVehiculo ?? '',
      cell: (TrasladoEntity t) => TrasladoCellText(TrasladoGestion.vehiculo(t)),
    ),
    GestionColumn<TrasladoEntity>(
      label: 'Estado',
      width: 150,
      sortValue: (TrasladoEntity t) =>
          TrasladoGestion.todosLosEstados.indexOf(t.estado ?? ''),
      cell: (TrasladoEntity t) => TrasladoEstadoDot(estado: t.estado),
    ),
  ];
}
