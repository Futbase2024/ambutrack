import '../entities/evento_traslado_type_enum.dart';
import '../entities/traslado_evento_entity.dart';

/// Modelo DTO para serialización JSON desde/hacia Supabase para eventos de traslados
class TrasladoEventoSupabaseModel {
  const TrasladoEventoSupabaseModel({
    required this.id,
    required this.trasladoId,
    required this.eventType,
    required this.createdAt,
    this.oldConductorId,
    this.newConductorId,
    this.oldEstado,
    this.newEstado,
    this.actorUserId,
    this.metadata,
  });

  final String id;
  final String trasladoId;
  final String eventType;
  final String? oldConductorId;
  final String? newConductorId;
  final String? oldEstado;
  final String? newEstado;
  final String? actorUserId;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  /// Convierte desde JSON de Supabase
  factory TrasladoEventoSupabaseModel.fromJson(Map<String, dynamic> json) {
    return TrasladoEventoSupabaseModel(
      id: json['id'] as String,
      trasladoId: json['traslado_id'] as String,
      eventType: json['event_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      oldConductorId: json['old_conductor_id'] as String?,
      newConductorId: json['new_conductor_id'] as String?,
      oldEstado: json['old_estado'] as String?,
      newEstado: json['new_estado'] as String?,
      actorUserId: json['actor_user_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'traslado_id': trasladoId,
      'event_type': eventType,
      'created_at': createdAt.toIso8601String(),
      if (oldConductorId != null) 'old_conductor_id': oldConductorId,
      if (newConductorId != null) 'new_conductor_id': newConductorId,
      if (oldEstado != null) 'old_estado': oldEstado,
      if (newEstado != null) 'new_estado': newEstado,
      if (actorUserId != null) 'actor_user_id': actorUserId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Convierte a Entity de dominio
  TrasladoEventoEntity toEntity() {
    return TrasladoEventoEntity(
      id: id,
      trasladoId: trasladoId,
      eventType: EventoTrasladoType.fromString(eventType),
      createdAt: createdAt,
      oldConductorId: oldConductorId,
      newConductorId: newConductorId,
      oldEstado: oldEstado,
      newEstado: newEstado,
      actorUserId: actorUserId,
      metadata: metadata,
    );
  }

  /// Crea desde Entity de dominio
  factory TrasladoEventoSupabaseModel.fromEntity(TrasladoEventoEntity entity) {
    return TrasladoEventoSupabaseModel(
      id: entity.id,
      trasladoId: entity.trasladoId,
      eventType: entity.eventType.value,
      createdAt: entity.createdAt,
      oldConductorId: entity.oldConductorId,
      newConductorId: entity.newConductorId,
      oldEstado: entity.oldEstado,
      newEstado: entity.newEstado,
      actorUserId: entity.actorUserId,
      metadata: entity.metadata,
    );
  }
}
