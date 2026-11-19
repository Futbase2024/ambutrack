/// Enum que representa los posibles estados de un traslado
///
/// Estados cronológicos del ciclo de vida de un traslado:
/// 1. pendiente - Traslado creado pero sin asignar
/// 2. asignado - Recursos asignados (personal + vehículo)
/// 3. enviado - Notificación enviada al conductor
/// 4. recibidoConductor - Conductor confirma recepción
/// 5. enOrigen - Conductor llega al punto de recogida
/// 6. saliendoOrigen - Inicia traslado con paciente
/// 7. enTransito - En camino al destino
/// 8. enDestino - Llega al destino
/// 9. finalizado - Traslado completado exitosamente
/// 10. cancelado - Traslado cancelado antes de completar
/// 11. suspendido - Traslado suspendido temporalmente
/// 12. noRealizado - Traslado no se pudo realizar
/// 13. anulado - Traslado anulado por error administrativo
enum EstadoTraslado {
  pendiente('pendiente', 'Pendiente'),
  asignado('asignado', 'Asignado'),
  enviado('enviado', 'Enviado'),
  recibidoConductor('recibido_conductor', 'Recibido por Conductor'),
  recibido('recibido_conductor', 'Recibido por Conductor'), // Alias de recibidoConductor
  enOrigen('en_origen', 'En Origen'),
  saliendoOrigen('saliendo_origen', 'Saliendo de Origen'),
  enTransito('en_transito', 'En Tránsito'),
  enDestino('en_destino', 'En Destino'),
  finalizado('finalizado', 'Finalizado'),
  cancelado('cancelado', 'Cancelado'),
  suspendido('suspendido', 'Suspendido'),
  noRealizado('no_realizado', 'No Realizado'),
  anulado('anulado', 'Anulado');

  const EstadoTraslado(this.value, this.label);

  /// Valor que se guarda en la base de datos
  final String value;

  /// Etiqueta para mostrar al usuario
  final String label;

  /// Convierte un string a EstadoTraslado
  static EstadoTraslado? fromValue(String? value) {
    if (value == null) return null;

    for (final EstadoTraslado estado in EstadoTraslado.values) {
      if (estado.value == value) {
        return estado;
      }
    }

    return null;
  }

  /// Verifica si el estado indica que el traslado está en curso
  bool get estaEnCurso {
    return this != EstadoTraslado.finalizado &&
           this != EstadoTraslado.cancelado &&
           this != EstadoTraslado.anulado &&
           this != EstadoTraslado.suspendido &&
           this != EstadoTraslado.noRealizado;
  }

  /// Verifica si el estado permite cancelación
  bool get permiteCancelacion {
    return this == EstadoTraslado.pendiente ||
           this == EstadoTraslado.asignado ||
           this == EstadoTraslado.enviado ||
           this == EstadoTraslado.recibidoConductor;
  }

  /// Verifica si el estado permite edición
  bool get permiteEdicion {
    return this == EstadoTraslado.pendiente ||
           this == EstadoTraslado.asignado;
  }

  /// Verifica si requiere asignación de recursos
  bool get requiereAsignacion {
    return this == EstadoTraslado.pendiente;
  }

  /// Retorna el color hexadecimal asociado al estado
  String get colorHex {
    switch (this) {
      case EstadoTraslado.pendiente:
        return '#FFA500'; // Naranja
      case EstadoTraslado.asignado:
        return '#4169E1'; // Azul
      case EstadoTraslado.enviado:
        return '#1E90FF'; // Azul claro
      case EstadoTraslado.recibidoConductor:
      case EstadoTraslado.recibido:
        return '#00CED1'; // Turquesa
      case EstadoTraslado.enOrigen:
        return '#9370DB'; // Morado claro
      case EstadoTraslado.saliendoOrigen:
        return '#8A2BE2'; // Morado
      case EstadoTraslado.enTransito:
        return '#FFD700'; // Dorado
      case EstadoTraslado.enDestino:
        return '#32CD32'; // Verde lima
      case EstadoTraslado.finalizado:
        return '#228B22'; // Verde oscuro
      case EstadoTraslado.cancelado:
        return '#DC143C'; // Rojo
      case EstadoTraslado.suspendido:
        return '#FF8C00'; // Naranja oscuro
      case EstadoTraslado.noRealizado:
        return '#8B0000'; // Rojo oscuro
      case EstadoTraslado.anulado:
        return '#696969'; // Gris oscuro
    }
  }

  @override
  String toString() => label;
}
