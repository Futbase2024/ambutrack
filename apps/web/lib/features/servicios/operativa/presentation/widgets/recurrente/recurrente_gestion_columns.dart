import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/recurrente/recurrente_gestion_helpers.dart';

int _dia(DateTime? d) => d == null ? 0 : d.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

/// Columnas de la rejilla de servicios recurrentes
List<GestionColumn<ServicioRecurrenteEntity>> recurrenteGestionColumns(
  Map<String, String> pacientes,
) {
  return <GestionColumn<ServicioRecurrenteEntity>>[
    GestionColumn<ServicioRecurrenteEntity>(
      label: 'Código',
      width: 130,
      sortValue: (ServicioRecurrenteEntity s) => s.codigo,
      cell: (ServicioRecurrenteEntity s) => TrasladoCellText(s.codigo),
    ),
    GestionColumn<ServicioRecurrenteEntity>(
      label: 'Paciente',
      flex: 3,
      sortValue: (ServicioRecurrenteEntity s) => RecurrenteGestion.paciente(s, pacientes),
      cell: (ServicioRecurrenteEntity s) =>
          TrasladoCellText(RecurrenteGestion.paciente(s, pacientes), bold: true),
    ),
    GestionColumn<ServicioRecurrenteEntity>(
      label: 'Patrón',
      flex: 3,
      sortValue: (ServicioRecurrenteEntity s) => s.tipoRecurrencia,
      cell: (ServicioRecurrenteEntity s) => TrasladoCellText(RecurrenteGestion.patron(s)),
    ),
    GestionColumn<ServicioRecurrenteEntity>(
      label: 'Ida / Vuelta',
      width: 110,
      sortValue: (ServicioRecurrenteEntity s) =>
          s.horaRecogida.hour * 60 + s.horaRecogida.minute,
      cell: (ServicioRecurrenteEntity s) => TrasladoCellText(RecurrenteGestion.horario(s)),
    ),
    GestionColumn<ServicioRecurrenteEntity>(
      label: 'Periodo',
      width: 190,
      sortValue: (ServicioRecurrenteEntity s) => _dia(s.fechaServicioInicio),
      cell: (ServicioRecurrenteEntity s) => TrasladoCellText(RecurrenteGestion.periodo(s)),
    ),
    GestionColumn<ServicioRecurrenteEntity>(
      label: 'Destino',
      flex: 3,
      sortValue: RecurrenteGestion.destino,
      cell: (ServicioRecurrenteEntity s) => TrasladoCellText(RecurrenteGestion.destino(s)),
    ),
    GestionColumn<ServicioRecurrenteEntity>(
      label: 'Generados hasta',
      width: 120,
      sortValue: (ServicioRecurrenteEntity s) => _dia(s.trasladosGeneradosHasta),
      cell: (ServicioRecurrenteEntity s) =>
          TrasladoCellText(GestionFormatters.fecha(s.trasladosGeneradosHasta)),
    ),
    GestionColumn<ServicioRecurrenteEntity>(
      label: 'Vigencia',
      width: 110,
      sortValue: (ServicioRecurrenteEntity s) => RecurrenteGestion.vigencia(s).index,
      cell: (ServicioRecurrenteEntity s) {
        final RecurrenteVigencia v = RecurrenteGestion.vigencia(s);
        return GestionDotLabel(label: v.label, color: v.color);
      },
    ),
  ];
}
