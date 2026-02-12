import 'package:equatable/equatable.dart';
import 'evento_traslado_type.dart';
import 'ubicacion_entity.dart';

/// Entidad de dominio para Eventos de Traslado
///
/// Representa un evento que ocurre durante el ciclo de vida de un traslado
/// (asignación, cambio de estado, inicio, finalización, etc.)
class TrasladoEventoEntity extends Equatable {
  const TrasladoEventoEntity({
    required this.id,
    required this.trasladoId,
    required this.eventType,
    required this.timestamp,
    this.conductorId,
    this.conductorNombre,
    this.vehiculoId,
    this.vehiculoMatricula,
    this.estadoAnterior,
    this.estadoNuevo,
    this.ubicacion,
    this.observaciones,
    this.metadata,
    this.createdAt,
  });

  /// ID único del evento
  final String id;

  /// ID del traslado asociado
  final String trasladoId;

  /// Tipo de evento
  final EventoTrasladoType eventType;

  /// Fecha y hora del evento
  final DateTime timestamp;

  /// ID del conductor (si aplica)
  final String? conductorId;

  /// Nombre del conductor (si aplica)
  final String? conductorNombre;

  /// ID del vehículo (si aplica)
  final String? vehiculoId;

  /// Matrícula del vehículo (si aplica)
  final String? vehiculoMatricula;

  /// Estado anterior (para eventos de cambio de estado)
  final String? estadoAnterior;

  /// Estado nuevo (para eventos de cambio de estado)
  final String? estadoNuevo;

  /// Ubicación GPS donde ocurrió el evento
  final UbicacionEntity? ubicacion;

  /// Observaciones adicionales
  final String? observaciones;

  /// Metadata adicional en formato JSON
  final Map<String, dynamic>? metadata;

  /// Fecha de creación del registro
  final DateTime? createdAt;

  /// Convierte el evento a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'traslado_id': trasladoId,
      'event_type': eventType.value,
      'timestamp': timestamp.toIso8601String(),
      if (conductorId != null) 'conductor_id': conductorId,
      if (conductorNombre != null) 'conductor_nombre': conductorNombre,
      if (vehiculoId != null) 'vehiculo_id': vehiculoId,
      if (vehiculoMatricula != null) 'vehiculo_matricula': vehiculoMatricula,
      if (estadoAnterior != null) 'estado_anterior': estadoAnterior,
      if (estadoNuevo != null) 'estado_nuevo': estadoNuevo,
      if (ubicacion != null) 'ubicacion': ubicacion!.toJson(),
      if (observaciones != null) 'observaciones': observaciones,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// Crea un TrasladoEventoEntity desde Map<String, dynamic>
  factory TrasladoEventoEntity.fromJson(Map<String, dynamic> json) {
    return TrasladoEventoEntity(
      id: json['id'] as String,
      trasladoId: json['traslado_id'] as String,
      eventType: EventoTrasladoType.fromValue(json['event_type'] as String?) ??
          EventoTrasladoType.statusChanged,
      timestamp: DateTime.parse(json['timestamp'] as String),
      conductorId: json['conductor_id'] as String?,
      conductorNombre: json['conductor_nombre'] as String?,
      vehiculoId: json['vehiculo_id'] as String?,
      vehiculoMatricula: json['vehiculo_matricula'] as String?,
      estadoAnterior: json['estado_anterior'] as String?,
      estadoNuevo: json['estado_nuevo'] as String?,
      ubicacion: json['ubicacion'] != null
          ? UbicacionEntity.fromJson(json['ubicacion'] as Map<String, dynamic>)
          : null,
      observaciones: json['observaciones'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Crea una copia con campos modificados
  TrasladoEventoEntity copyWith({
    String? id,
    String? trasladoId,
    EventoTrasladoType? eventType,
    DateTime? timestamp,
    String? conductorId,
    String? conductorNombre,
    String? vehiculoId,
    String? vehiculoMatricula,
    String? estadoAnterior,
    String? estadoNuevo,
    UbicacionEntity? ubicacion,
    String? observaciones,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return TrasladoEventoEntity(
      id: id ?? this.id,
      trasladoId: trasladoId ?? this.trasladoId,
      eventType: eventType ?? this.eventType,
      timestamp: timestamp ?? this.timestamp,
      conductorId: conductorId ?? this.conductorId,
      conductorNombre: conductorNombre ?? this.conductorNombre,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      vehiculoMatricula: vehiculoMatricula ?? this.vehiculoMatricula,
      estadoAnterior: estadoAnterior ?? this.estadoAnterior,
      estadoNuevo: estadoNuevo ?? this.estadoNuevo,
      ubicacion: ubicacion ?? this.ubicacion,
      observaciones: observaciones ?? this.observaciones,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        trasladoId,
        eventType,
        timestamp,
        conductorId,
        conductorNombre,
        vehiculoId,
        vehiculoMatricula,
        estadoAnterior,
        estadoNuevo,
        ubicacion,
        observaciones,
        metadata,
        createdAt,
      ];

  @override
  String toString() {
    return 'TrasladoEventoEntity('
        'id: $id, '
        'trasladoId: $trasladoId, '
        'eventType: ${eventType.label}, '
        'timestamp: $timestamp'
        ')';
  }
}
