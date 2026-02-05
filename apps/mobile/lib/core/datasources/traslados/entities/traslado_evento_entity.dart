import 'package:equatable/equatable.dart';
import 'evento_traslado_type_enum.dart';

/// Entidad de dominio que representa un evento de traslado en el event ledger
class TrasladoEventoEntity extends Equatable {
  const TrasladoEventoEntity({
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
  final EventoTrasladoType eventType;
  final String? oldConductorId;
  final String? newConductorId;
  final String? oldEstado;
  final String? newEstado;
  final String? actorUserId;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [
        id,
        trasladoId,
        eventType,
        oldConductorId,
        newConductorId,
        oldEstado,
        newEstado,
        createdAt,
      ];

  /// Indica si este evento representa que me asignaron el traslado
  bool meAsignaronA(String conductorId) {
    return newConductorId == conductorId &&
        (eventType == EventoTrasladoType.assigned ||
            eventType == EventoTrasladoType.reassigned);
  }

  /// Indica si este evento representa que me quitaron el traslado
  bool meQuitaronA(String conductorId) {
    return oldConductorId == conductorId &&
        (eventType == EventoTrasladoType.unassigned ||
            (eventType == EventoTrasladoType.reassigned &&
                newConductorId != conductorId));
  }

  /// Indica si este evento es un cambio de estado solamente
  bool get esCambioEstado => eventType == EventoTrasladoType.statusChanged;

  /// Indica si este evento involucra cambio de conductor
  bool get esCambioConductor =>
      eventType == EventoTrasladoType.assigned ||
      eventType == EventoTrasladoType.unassigned ||
      eventType == EventoTrasladoType.reassigned;

  TrasladoEventoEntity copyWith({
    String? id,
    String? trasladoId,
    EventoTrasladoType? eventType,
    String? oldConductorId,
    String? newConductorId,
    String? oldEstado,
    String? newEstado,
    String? actorUserId,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return TrasladoEventoEntity(
      id: id ?? this.id,
      trasladoId: trasladoId ?? this.trasladoId,
      eventType: eventType ?? this.eventType,
      oldConductorId: oldConductorId ?? this.oldConductorId,
      newConductorId: newConductorId ?? this.newConductorId,
      oldEstado: oldEstado ?? this.oldEstado,
      newEstado: newEstado ?? this.newEstado,
      actorUserId: actorUserId ?? this.actorUserId,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
