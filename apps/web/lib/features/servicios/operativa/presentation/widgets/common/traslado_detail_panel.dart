import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/historial/registro_historial_tab.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:flutter/material.dart';

/// Ficha lateral (solo lectura) del traslado seleccionado
class TrasladoDetailPanel extends StatelessWidget {
  const TrasladoDetailPanel({
    required this.traslado,
    required this.nombres,
    super.key,
  });

  final TrasladoEntity? traslado;

  /// Nombre del personal por ID
  final Map<String, String> nombres;

  @override
  Widget build(BuildContext context) {
    final TrasladoEntity? t = traslado;
    if (t == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona un traslado para ver su ficha',
      );
    }
    return GestionDetailPanel(
      key: ValueKey<String>(t.id),
      title: '${TrasladoGestion.paciente(t)} · ${TrasladoGestion.tipo(t)}',
      badges: <Widget>[
        TrasladoEstadoDot(estado: t.estado),
        TrasladoPrioridadDot(prioridad: t.prioridad),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _TrasladoGeneralTab(traslado: t)),
        GestionDetailTab(
          label: 'Recursos',
          child: _TrasladoRecursosTab(traslado: t, nombres: nombres),
        ),
        GestionDetailTab(label: 'Cronología', child: _TrasladoCronasTab(traslado: t)),
        GestionDetailTab(label: 'Cambios', child: RegistroHistorialTab(tabla: 'traslados', registroId: t.id)),
      ],
    );
  }
}

class _TrasladoGeneralTab extends StatelessWidget {
  const _TrasladoGeneralTab({required this.traslado});

  final TrasladoEntity traslado;

  @override
  Widget build(BuildContext context) {
    final TrasladoEntity t = traslado;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Servicio'),
        GestionDetailField(label: 'Código', value: t.codigo),
        GestionDetailField(label: 'Fecha', value: GestionFormatters.fecha(t.fecha)),
        GestionDetailField(label: 'Hora programada', value: TrasladoGestion.hora(t.horaProgramada)),
        GestionDetailField(label: 'Tipo', value: TrasladoGestion.tipo(t)),
        GestionDetailField(label: 'Motivo', value: t.motivoTraslado?.nombre),
        GestionDetailField(
          label: 'Origen recurrente',
          value: t.idServicioRecurrente == null ? 'Manual / único' : 'Servicio recurrente',
        ),
        const GestionDetailSection(title: 'Recorrido'),
        GestionDetailField(label: 'Origen', value: TrasladoGestion.origen(t)),
        GestionDetailField(label: 'Destino', value: TrasladoGestion.destino(t)),
        const GestionDetailSection(title: 'Requisitos'),
        GestionDetailField(label: 'Requisitos', value: _requisitos(t)),
        const GestionDetailSection(title: 'Observaciones'),
        GestionDetailField(label: 'Observaciones', value: t.observaciones),
        GestionDetailField(label: 'Internas', value: t.observacionesInternas),
        if (t.motivoCancelacion != null)
          GestionDetailField(label: 'Mot. cancelación', value: t.motivoCancelacion),
        if (t.motivoNoRealizacion != null)
          GestionDetailField(label: 'Mot. no realiz.', value: t.motivoNoRealizacion),
      ],
    );
  }

  static String? _requisitos(TrasladoEntity t) {
    final List<String> r = <String>[
      if (t.requiereCamilla ?? false) 'Camilla',
      if (t.requiereSillaRuedas ?? false) 'Silla de ruedas',
      if (t.requiereAyuda ?? false) 'Ayuda',
      if (t.requiereAcompanante ?? false) 'Acompañante',
    ];
    return r.isEmpty ? null : r.join(', ');
  }
}

class _TrasladoRecursosTab extends StatelessWidget {
  const _TrasladoRecursosTab({required this.traslado, required this.nombres});

  final TrasladoEntity traslado;
  final Map<String, String> nombres;

  @override
  Widget build(BuildContext context) {
    final TrasladoEntity t = traslado;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Dotación'),
        GestionDetailField(label: 'Conductor', value: TrasladoGestion.conductor(t, nombres)),
        GestionDetailField(
          label: 'Enfermero/a',
          value: TrasladoGestion.personal(t.idPersonalEnfermero, nombres),
        ),
        GestionDetailField(
          label: 'Médico/a',
          value: TrasladoGestion.personal(t.idPersonalMedico, nombres),
        ),
        GestionDetailField(label: 'Vehículo', value: TrasladoGestion.vehiculo(t)),
        GestionDetailField(label: 'Asignado el', value: TrasladoGestion.fechaHora(t.fechaAsignacion)),
        const GestionDetailSection(title: 'Kilometraje y duración'),
        GestionDetailField(label: 'Km inicio', value: t.kmInicio?.toStringAsFixed(0)),
        GestionDetailField(label: 'Km fin', value: t.kmFin?.toStringAsFixed(0)),
        GestionDetailField(label: 'Km totales', value: t.kmTotales?.toStringAsFixed(0)),
        GestionDetailField(
          label: 'Duración est.',
          value: t.duracionEstimadaMinutos == null ? null : '${t.duracionEstimadaMinutos} min',
        ),
        GestionDetailField(
          label: 'Duración real',
          value: t.duracionRealMinutos == null ? null : '${t.duracionRealMinutos} min',
        ),
      ],
    );
  }
}

class _TrasladoCronasTab extends StatelessWidget {
  const _TrasladoCronasTab({required this.traslado});

  final TrasladoEntity traslado;

  @override
  Widget build(BuildContext context) {
    final TrasladoEntity t = traslado;
    final List<MapEntry<String, DateTime?>> cronas = <MapEntry<String, DateTime?>>[
      MapEntry<String, DateTime?>('Creado', t.createdAt),
      MapEntry<String, DateTime?>('Asignado', t.fechaAsignacion),
      MapEntry<String, DateTime?>('Enviado', t.fechaEnviado),
      MapEntry<String, DateTime?>('Recibido', t.fechaRecibidoConductor),
      MapEntry<String, DateTime?>('En origen', t.fechaEnOrigen),
      MapEntry<String, DateTime?>('Saliendo origen', t.fechaSaliendoOrigen),
      MapEntry<String, DateTime?>('En tránsito', t.fechaEnTransito),
      MapEntry<String, DateTime?>('En destino', t.fechaEnDestino),
      MapEntry<String, DateTime?>('Finalizado', t.fechaFinalizado),
      MapEntry<String, DateTime?>('Cancelado', t.fechaCancelado),
      MapEntry<String, DateTime?>('Suspendido', t.fechaSuspendido),
      MapEntry<String, DateTime?>('No realizado', t.fechaNoRealizado),
    ];
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Cronas'),
        for (final MapEntry<String, DateTime?> c in cronas)
          GestionDetailField(label: c.key, value: TrasladoGestion.fechaHora(c.value)),
      ],
    );
  }
}
