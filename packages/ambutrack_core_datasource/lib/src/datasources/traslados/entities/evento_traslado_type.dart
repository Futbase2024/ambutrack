/// Tipos de eventos que pueden ocurrir en un traslado
///
/// Estos eventos representan acciones o cambios de estado en el ciclo de vida de un traslado
enum EventoTrasladoType {
  /// Traslado asignado por primera vez
  assigned('assigned', 'Asignado'),

  /// Traslado reasignado a otros recursos
  reassigned('reassigned', 'Reasignado'),

  /// Traslado desasignado (recursos liberados)
  unassigned('unassigned', 'Desasignado'),

  /// Cambio de estado del traslado
  statusChanged('status_changed', 'Estado Cambiado'),

  /// Traslado cancelado
  cancelled('cancelled', 'Cancelado'),

  /// Inicio del traslado
  started('started', 'Iniciado'),

  /// Traslado finalizado
  completed('completed', 'Completado'),

  /// Traslado en tránsito
  inTransit('in_transit', 'En Tránsito');

  const EventoTrasladoType(this.value, this.label);

  /// Valor que se guarda en la base de datos
  final String value;

  /// Etiqueta para mostrar al usuario
  final String label;

  /// Convierte un string a EventoTrasladoType
  static EventoTrasladoType? fromValue(String? value) {
    if (value == null) return null;

    for (final EventoTrasladoType tipo in EventoTrasladoType.values) {
      if (tipo.value == value) {
        return tipo;
      }
    }

    return null;
  }

  @override
  String toString() => label;
}
