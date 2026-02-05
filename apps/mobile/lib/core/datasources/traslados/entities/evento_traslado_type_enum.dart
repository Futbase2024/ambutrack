/// Tipos de eventos de traslados registrados en el event ledger
enum EventoTrasladoType {
  /// Traslado asignado a conductor (NULL -> conductor)
  assigned('assigned'),

  /// Traslado desasignado (conductor -> NULL)
  unassigned('unassigned'),

  /// Traslado reasignado (conductor A -> conductor B)
  reassigned('reassigned'),

  /// Cambio de estado del traslado
  statusChanged('status_changed');

  const EventoTrasladoType(this.value);

  final String value;

  /// Convierte string a enum
  static EventoTrasladoType fromString(String value) {
    return EventoTrasladoType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventoTrasladoType.assigned,
    );
  }

  /// Label legible para el usuario
  String get label {
    switch (this) {
      case EventoTrasladoType.assigned:
        return 'ASIGNADO';
      case EventoTrasladoType.unassigned:
        return 'DESASIGNADO';
      case EventoTrasladoType.reassigned:
        return 'REASIGNADO';
      case EventoTrasladoType.statusChanged:
        return 'CAMBIO DE ESTADO';
    }
  }

  /// Indica si el evento implica que el conductor ganó el traslado
  bool get meAsignaron {
    return this == EventoTrasladoType.assigned ||
        this == EventoTrasladoType.reassigned;
  }

  /// Indica si el evento implica que el conductor perdió el traslado
  bool get meQuitaron {
    return this == EventoTrasladoType.unassigned ||
        this == EventoTrasladoType.reassigned;
  }
}
