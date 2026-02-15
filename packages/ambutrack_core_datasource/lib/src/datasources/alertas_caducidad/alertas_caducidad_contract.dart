import 'entities/alerta_caducidad_entity.dart';

/// Contract para el DataSource de Alertas de Caducidad
///
/// Define las operaciones que debe implementar cualquier datasource
/// para la gestión de alertas de caducidad
abstract class AlertasCaducidadDataSource {
  /// Obtiene todas las alertas activas con filtros opcionales
  ///
  /// [usuarioId] - ID del usuario para filtrar alertas personales
  /// [umbralSeguro] - Días umbral para alertas de seguros (por defecto 90)
  /// [umbralItv] - Días umbral para alertas de ITV (por defecto 90)
  /// [umbralHomologacion] - Días umbral para alertas de homologación (por defecto 90)
  /// [umbralMantenimiento] - Días umbral para alertas de mantenimiento (por defecto 90)
  /// [incluirVistas] - Si debe incluir documentos ya vistos (por defecto true)
  Future<List<AlertaCaducidadEntity>> getAlertasActivas({
    String? usuarioId,
    int? umbralSeguro,
    int? umbralItv,
    int? umbralHomologacion,
    int? umbralMantenimiento,
    bool incluirVistas = true,
  });

  /// Obtiene solo las alertas críticas (< 7 días)
  ///
  /// [usuarioId] - ID del usuario para filtrar alertas personales
  Future<List<AlertaCaducidadEntity>> getAlertasCriticas({
    String? usuarioId,
  });

  /// Obtiene un resumen de alertas agrupadas por severidad
  Future<AlertasResumenEntity> getResumen();

  /// Obtiene alertas por tipo específico
  ///
  /// [tipo] - Tipo de alerta a filtrar
  Future<List<AlertaCaducidadEntity>> getAlertasPorTipo(AlertaTipo tipo);

  /// Obtiene alertas por severidad
  ///
  /// [severidad] - Severidad de alerta a filtrar
  Future<List<AlertaCaducidadEntity>> getAlertasPorSeveridad(
      AlertaSeveridad severidad);

  /// Obtiene alertas de un vehículo específico
  ///
  /// [vehiculoId] - ID del vehículo
  Future<List<AlertaCaducidadEntity>> getAlertasPorVehiculo(
      String vehiculoId);
}
