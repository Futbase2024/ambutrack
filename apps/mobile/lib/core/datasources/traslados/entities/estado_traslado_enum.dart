/// Estados posibles de un traslado en la app móvil
enum EstadoTraslado {
  /// Traslado creado pero no asignado
  pendiente('pendiente'),

  /// Traslado asignado a conductor/vehículo
  asignado('asignado'),

  /// Conductor ha recibido el traslado en su móvil
  recibido('recibido'),

  /// Conductor ha llegado al origen
  enOrigen('en_origen'),

  /// Conductor está saliendo del origen con el paciente
  saliendoOrigen('saliendo_origen'),

  /// Conductor ha llegado al destino
  enDestino('en_destino'),

  /// Traslado finalizado
  finalizado('finalizado'),

  /// Traslado cancelado
  cancelado('cancelado'),

  /// Traslado no realizado
  noRealizado('no_realizado'),

  /// Traslado suspendido
  suspendido('suspendido');

  const EstadoTraslado(this.value);

  final String value;

  /// Convierte string a enum
  static EstadoTraslado fromString(String value) {
    return EstadoTraslado.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EstadoTraslado.pendiente,
    );
  }

  /// Color para el estado en la UI
  String get colorHex {
    switch (this) {
      case EstadoTraslado.pendiente:
        return '#F59E0B'; // Naranja
      case EstadoTraslado.asignado:
        return '#3B82F6'; // Azul
      case EstadoTraslado.recibido:
        return '#8B5CF6'; // Púrpura
      case EstadoTraslado.enOrigen:
        return '#10B981'; // Verde claro
      case EstadoTraslado.saliendoOrigen:
        return '#06B6D4'; // Cyan
      case EstadoTraslado.enDestino:
        return '#14B8A6'; // Teal
      case EstadoTraslado.finalizado:
        return '#22C55E'; // Verde
      case EstadoTraslado.cancelado:
        return '#EF4444'; // Rojo
      case EstadoTraslado.noRealizado:
        return '#DC2626'; // Rojo oscuro
      case EstadoTraslado.suspendido:
        return '#9CA3AF'; // Gris
    }
  }

  /// Label legible para el usuario
  String get label {
    switch (this) {
      case EstadoTraslado.pendiente:
        return 'PENDIENTE';
      case EstadoTraslado.asignado:
        return 'ASIGNADO';
      case EstadoTraslado.recibido:
        return 'RECIBIDO';
      case EstadoTraslado.enOrigen:
        return 'EN ORIGEN';
      case EstadoTraslado.saliendoOrigen:
        return 'SALIENDO';
      case EstadoTraslado.enDestino:
        return 'EN DESTINO';
      case EstadoTraslado.finalizado:
        return 'FINALIZADO';
      case EstadoTraslado.cancelado:
        return 'CANCELADO';
      case EstadoTraslado.noRealizado:
        return 'NO REALIZADO';
      case EstadoTraslado.suspendido:
        return 'SUSPENDIDO';
    }
  }

  /// Indica si el traslado está activo (puede cambiar de estado)
  bool get isActivo {
    return this != EstadoTraslado.finalizado &&
        this != EstadoTraslado.cancelado &&
        this != EstadoTraslado.noRealizado &&
        this != EstadoTraslado.suspendido;
  }

  /// Indica si el conductor puede cambiar a este estado desde la app
  bool get esCambiableDesdeApp {
    return this == EstadoTraslado.recibido ||
        this == EstadoTraslado.enOrigen ||
        this == EstadoTraslado.saliendoOrigen ||
        this == EstadoTraslado.enDestino ||
        this == EstadoTraslado.finalizado;
  }
}
