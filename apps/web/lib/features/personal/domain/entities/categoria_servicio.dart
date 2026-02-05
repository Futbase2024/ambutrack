/// Categoría de servicio del personal
/// Indica si el personal trabaja en urgencias o servicios programados
enum CategoriaServicio {
  /// Servicios de urgencia/emergencia
  urgencias('Urgencias', '🚨'),

  /// Servicios programados
  programado('Programado', '📋');

  const CategoriaServicio(this.nombre, this.emoji);

  /// Nombre legible de la categoría
  final String nombre;

  /// Emoji representativo
  final String emoji;

  /// Convierte string a enum
  static CategoriaServicio fromString(String? value) {
    if (value == null) {
      return CategoriaServicio.programado;
    }

    return CategoriaServicio.values.firstWhere(
      (CategoriaServicio e) => e.name == value,
      orElse: () => CategoriaServicio.programado,
    );
  }

  /// Obtiene el display text (emoji + nombre)
  String get displayText => '$emoji $nombre';
}
