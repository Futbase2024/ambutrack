import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de alertas de caducidad.
///
/// La implementacion se encuentra en `data/repositories/alerta_caducidad_repository_impl.dart`.
///
/// Este repositorio es un pass-through directo al datasource, sin conversiones
/// Entity <-> Entity, segun el patron de arquitectura de AmbuTrack.
abstract class AlertaCaducidadRepository {
  /// Obtiene todas las alertas activas con filtros opcionales.
  ///
  /// Parametros opcionales:
  /// - [usuarioId]: ID del usuario para filtrar alertas personales
  /// - [umbralSeguro]: Dias de antelacion para seguros (defecto: 90)
  /// - [umbralItv]: Dias de antelacion para ITV (defecto: 90)
  /// - [umbralHomologacion]: Dias de antelacion para homologacion (defecto: 90)
  /// - [umbralMantenimiento]: Dias de antelacion para mantenimiento (defecto: 90)
  /// - [incluirVistas]: Si es false, excluye alertas ya vistas hoy (defecto: true)
  Future<List<AlertaCaducidadEntity>> getAlertasActivas({
    String? usuarioId,
    int? umbralSeguro,
    int? umbralItv,
    int? umbralHomologacion,
    int? umbralMantenimiento,
    bool incluirVistas = true,
  });

  /// Obtiene solo las alertas criticas (menos de 7 dias).
  ///
  /// Si se proporciona [usuarioId], filtra las alertas ya vistas hoy.
  Future<List<AlertaCaducidadEntity>> getAlertasCriticas({
    String? usuarioId,
  });

  /// Obtiene el resumen de alertas agrupadas por severidad.
  Future<AlertasResumenEntity> getResumen();

  /// Obtiene alertas filtradas por tipo.
  Future<List<AlertaCaducidadEntity>> getAlertasPorTipo(AlertaTipo tipo);

  /// Obtiene alertas filtradas por severidad.
  Future<List<AlertaCaducidadEntity>> getAlertasPorSeveridad(
    AlertaSeveridad severidad,
  );

  /// Obtiene todas las alertas asociadas a un vehiculo especifico.
  Future<List<AlertaCaducidadEntity>> getAlertasPorVehiculo(
    String vehiculoId,
  );
}
