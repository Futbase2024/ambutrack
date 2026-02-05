/// Modos de visualización del cuadrante
enum CuadranteViewMode {
  /// Vista de tabla semanal
  tabla('Tabla', '📊'),

  /// Vista de calendario mensual
  calendario('Calendario', '📅'),

  /// Vista de disponibilidad/ocupación (heat map)
  disponibilidad('Disponibilidad', '🔥');

  const CuadranteViewMode(this.nombre, this.emoji);

  /// Nombre legible del modo
  final String nombre;

  /// Emoji representativo
  final String emoji;

  /// Obtiene el display text (emoji + nombre)
  String get displayText => '$emoji $nombre';
}
