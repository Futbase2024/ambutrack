import 'package:equatable/equatable.dart';

/// Tipo de notificación
enum NotificacionTipo {
  // Vacaciones y Ausencias
  vacacionSolicitada('vacacion_solicitada', 'Solicitud de Vacaciones'),
  vacacionAprobada('vacacion_aprobada', 'Vacaciones Aprobadas'),
  vacacionRechazada('vacacion_rechazada', 'Vacaciones Rechazadas'),
  ausenciaSolicitada('ausencia_solicitada', 'Solicitud de Ausencia'),
  ausenciaAprobada('ausencia_aprobada', 'Ausencia Aprobada'),
  ausenciaRechazada('ausencia_rechazada', 'Ausencia Rechazada'),

  // Turnos
  cambioTurno('cambio_turno', 'Cambio de Turno'),

  // Traslados (Mobile)
  trasladoAsignado('traslado_asignado', 'Nuevo Traslado Asignado'),
  trasladoDesadjudicado('traslado_desadjudicado', 'Traslado Desadjudicado'),
  trasladoIniciado('traslado_iniciado', 'Traslado Iniciado'),
  trasladoFinalizado('traslado_finalizado', 'Traslado Finalizado'),
  trasladoCancelado('traslado_cancelado', 'Traslado Cancelado'),

  // Checklist
  checklistPendiente('checklist_pendiente', 'Checklist Pendiente'),

  // Incidencias de vehículos
  incidenciaVehiculoReportada('incidencia_vehiculo_reportada', 'Incidencia de Vehículo Reportada'),
  incidenciaVehiculoActualizada('incidencia_vehiculo_actualizada', 'Incidencia de Vehículo Actualizada'),

  // Caducidades
  alertaCaducidad('alerta_caducidad', 'Alerta de Caducidad'),

  // Agenda
  agendaPendiente('agenda_pendiente', 'Pendiente Programado'),

  // Inicio de turno fuera de base (validación por coordinación)
  inicioTurnoPendiente('inicio_turno_pendiente', 'Inicio de Turno Pendiente'),
  inicioTurnoAprobado('inicio_turno_aprobado', 'Inicio de Turno Validado'),
  inicioTurnoRechazado('inicio_turno_rechazado', 'Inicio de Turno Rechazado'),

  // Vestuario
  vestuarioSolicitado('vestuario_solicitado', 'Solicitud de Vestuario'),
  vestuarioAprobado('vestuario_aprobado', 'Vestuario Aprobado'),
  vestuarioRechazado('vestuario_rechazado', 'Vestuario Rechazado'),
  vestuarioEntregado('vestuario_entregado', 'Vestuario Entregado'),

  // Generales
  alerta('alerta', 'Alerta'),
  info('info', 'Información');

  final String value;
  final String label;

  const NotificacionTipo(this.value, this.label);

  static NotificacionTipo fromString(String value) {
    return NotificacionTipo.values.firstWhere(
      (tipo) => tipo.value == value,
      orElse: () => NotificacionTipo.info,
    );
  }
}

/// Entidad de dominio para Notificaciones
class NotificacionEntity extends Equatable {
  const NotificacionEntity({
    required this.id,
    required this.empresaId,
    required this.usuarioDestinoId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    this.entidadTipo,
    this.entidadId,
    required this.leida,
    this.fechaLectura,
    this.metadata = const {},
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String empresaId;
  final String usuarioDestinoId;
  final NotificacionTipo tipo;
  final String titulo;
  final String mensaje;
  final String? entidadTipo;
  final String? entidadId;
  final bool leida;
  final DateTime? fechaLectura;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Copia la entidad con los campos especificados actualizados
  NotificacionEntity copyWith({
    String? id,
    String? empresaId,
    String? usuarioDestinoId,
    NotificacionTipo? tipo,
    String? titulo,
    String? mensaje,
    String? entidadTipo,
    String? entidadId,
    bool? leida,
    DateTime? fechaLectura,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificacionEntity(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      usuarioDestinoId: usuarioDestinoId ?? this.usuarioDestinoId,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      entidadTipo: entidadTipo ?? this.entidadTipo,
      entidadId: entidadId ?? this.entidadId,
      leida: leida ?? this.leida,
      fechaLectura: fechaLectura ?? this.fechaLectura,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        empresaId,
        usuarioDestinoId,
        tipo,
        titulo,
        mensaje,
        entidadTipo,
        entidadId,
        leida,
        fechaLectura,
        metadata,
        createdAt,
        updatedAt,
      ];
}
