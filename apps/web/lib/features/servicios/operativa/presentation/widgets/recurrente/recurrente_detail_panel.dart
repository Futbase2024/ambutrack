import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/historial/registro_historial_tab.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/recurrente/recurrente_gestion_helpers.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/recurrente/recurrente_traslados_tab.dart';
import 'package:flutter/material.dart';

/// Ficha lateral (solo lectura) del servicio recurrente seleccionado
class RecurrenteDetailPanel extends StatelessWidget {
  const RecurrenteDetailPanel({
    required this.servicio,
    required this.pacientes,
    required this.motivos,
    super.key,
  });

  final ServicioRecurrenteEntity? servicio;
  final Map<String, String> pacientes;
  final Map<String, String> motivos;

  @override
  Widget build(BuildContext context) {
    final ServicioRecurrenteEntity? s = servicio;
    if (s == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona un servicio para ver su programación',
      );
    }
    final RecurrenteVigencia v = RecurrenteGestion.vigencia(s);
    return GestionDetailPanel(
      key: ValueKey<String>(s.id),
      title: '${s.codigo} · ${RecurrenteGestion.paciente(s, pacientes)}',
      badges: <Widget>[
        GestionDotLabel(label: v.label, color: v.color),
        TrasladoPrioridadDot(prioridad: s.prioridad),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'Programación',
          child: _RecurrenteProgramacionTab(servicio: s, motivos: motivos),
        ),
        GestionDetailTab(label: 'Recorrido', child: _RecurrenteRecorridoTab(servicio: s)),
        GestionDetailTab(label: 'Traslados', child: RecurrenteTrasladosTab(servicioId: s.id)),
        GestionDetailTab(
          label: 'Cambios',
          child: RegistroHistorialTab(tabla: 'servicios_recurrentes', registroId: s.id),
        ),
      ],
    );
  }
}

class _RecurrenteProgramacionTab extends StatelessWidget {
  const _RecurrenteProgramacionTab({required this.servicio, required this.motivos});

  final ServicioRecurrenteEntity servicio;
  final Map<String, String> motivos;

  @override
  Widget build(BuildContext context) {
    final ServicioRecurrenteEntity s = servicio;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Patrón'),
        GestionDetailField(label: 'Tipo', value: RecurrenteGestion.tipoLabel(s.tipoRecurrencia)),
        GestionDetailField(label: 'Patrón', value: RecurrenteGestion.patron(s)),
        if (s.tipoRecurrencia == 'especifico')
          GestionDetailField(
            label: 'Fechas',
            value: (s.fechasEspecificas ?? const <DateTime>[])
                .map(GestionFormatters.fecha)
                .join(', '),
          ),
        GestionDetailField(label: 'Periodo', value: RecurrenteGestion.periodo(s)),
        const GestionDetailSection(title: 'Horario'),
        GestionDetailField(label: 'Recogida', value: TrasladoGestion.hora(s.horaRecogida)),
        GestionDetailField(
          label: 'Vuelta',
          value: s.requiereVuelta ? TrasladoGestion.hora(s.horaVuelta) : 'Sin vuelta',
        ),
        const GestionDetailSection(title: 'Clasificación'),
        GestionDetailField(label: 'Motivo', value: motivos[s.idMotivoTraslado]),
        GestionDetailField(label: 'Ambulancia', value: s.tipoAmbulancia),
        GestionDetailField(label: 'Prioridad', value: TrasladoGestion.prioridadLabel(s.prioridad)),
        const GestionDetailSection(title: 'Generación'),
        GestionDetailField(
          label: 'Generados hasta',
          value: GestionFormatters.fecha(s.trasladosGeneradosHasta),
        ),
        GestionDetailField(
          label: 'Requiere generar',
          value: s.requiereGeneracion ? 'Sí (ventana < 14 días)' : 'No',
        ),
      ],
    );
  }
}

class _RecurrenteRecorridoTab extends StatelessWidget {
  const _RecurrenteRecorridoTab({required this.servicio});

  final ServicioRecurrenteEntity servicio;

  @override
  Widget build(BuildContext context) {
    final ServicioRecurrenteEntity s = servicio;
    final List<String> requisitos = <String>[
      if (s.requiereCamilla ?? false) 'Camilla',
      if (s.requiereSillaRuedas ?? false) 'Silla de ruedas',
      if (s.requiereAyuda ?? false) 'Ayuda',
      if (s.requiereAcompanante ?? false) 'Acompañante',
    ];
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Recorrido'),
        GestionDetailField(label: 'Origen', value: RecurrenteGestion.origen(s)),
        GestionDetailField(label: 'Destino', value: RecurrenteGestion.destino(s)),
        const GestionDetailSection(title: 'Requisitos'),
        GestionDetailField(
          label: 'Requisitos',
          value: requisitos.isEmpty ? null : requisitos.join(', '),
        ),
        const GestionDetailSection(title: 'Observaciones'),
        GestionDetailField(label: 'Generales', value: s.observaciones),
        GestionDetailField(label: 'Médicas', value: s.observacionesMedicas),
      ],
    );
  }
}
