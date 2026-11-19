/// Origen de una orden de reparación
enum OrigenOrdenReparacion {
  averia('averia', 'Avería'),
  mantenimiento('mantenimiento', 'Mantenimiento'),
  itv('itv', 'ITV'),
  voluntaria('voluntaria', 'Voluntaria');

  const OrigenOrdenReparacion(this.value, this.displayName);

  final String value;
  final String displayName;

  static OrigenOrdenReparacion fromString(String? value) {
    return OrigenOrdenReparacion.values.firstWhere(
      (OrigenOrdenReparacion e) => e.value == value,
      orElse: () => OrigenOrdenReparacion.averia,
    );
  }
}

/// Estado del proceso de una orden de reparación
enum EstadoOrdenReparacion {
  abierta('abierta', 'Abierta'),
  enProceso('en_proceso', 'En proceso'),
  esperandoRepuestos('esperando_repuestos', 'Esperando repuestos'),
  finalizada('finalizada', 'Finalizada'),
  cerrada('cerrada', 'Cerrada'),
  anulada('anulada', 'Anulada');

  const EstadoOrdenReparacion(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Indica si la orden sigue activa (vehículo en taller)
  bool get isActiva =>
      this == EstadoOrdenReparacion.abierta ||
      this == EstadoOrdenReparacion.enProceso ||
      this == EstadoOrdenReparacion.esperandoRepuestos;

  /// Columna de fecha que se rellena al pasar a este estado (si aplica)
  String? get fechaColumn {
    switch (this) {
      case EstadoOrdenReparacion.enProceso:
        return 'fecha_inicio_trabajo';
      case EstadoOrdenReparacion.esperandoRepuestos:
        return 'fecha_espera_repuestos';
      case EstadoOrdenReparacion.finalizada:
        return 'fecha_finalizacion';
      case EstadoOrdenReparacion.cerrada:
        return 'fecha_cierre';
      case EstadoOrdenReparacion.abierta:
      case EstadoOrdenReparacion.anulada:
        return null;
    }
  }

  static EstadoOrdenReparacion fromString(String? value) {
    return EstadoOrdenReparacion.values.firstWhere(
      (EstadoOrdenReparacion e) => e.value == value,
      orElse: () => EstadoOrdenReparacion.abierta,
    );
  }
}

/// Prioridad de una orden de reparación
enum PrioridadOrdenReparacion {
  baja('baja', 'Baja'),
  normal('normal', 'Normal'),
  alta('alta', 'Alta'),
  urgente('urgente', 'Urgente');

  const PrioridadOrdenReparacion(this.value, this.displayName);

  final String value;
  final String displayName;

  static PrioridadOrdenReparacion fromString(String? value) {
    return PrioridadOrdenReparacion.values.firstWhere(
      (PrioridadOrdenReparacion e) => e.value == value,
      orElse: () => PrioridadOrdenReparacion.normal,
    );
  }
}

/// Estado de un repuesto dentro de una orden
enum EstadoRepuesto {
  solicitado('solicitado', 'Solicitado'),
  pedido('pedido', 'Pedido'),
  recibido('recibido', 'Recibido'),
  instalado('instalado', 'Instalado');

  const EstadoRepuesto(this.value, this.displayName);

  final String value;
  final String displayName;

  static EstadoRepuesto fromString(String? value) {
    return EstadoRepuesto.values.firstWhere(
      (EstadoRepuesto e) => e.value == value,
      orElse: () => EstadoRepuesto.solicitado,
    );
  }
}
