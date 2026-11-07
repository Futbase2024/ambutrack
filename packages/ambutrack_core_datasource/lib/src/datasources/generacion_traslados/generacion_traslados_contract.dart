import 'entities/resultado_generacion_traslados_entity.dart';

/// Contrato del DataSource de generación de traslados diarios
abstract class GeneracionTrasladosDataSource {
  /// Genera los traslados del periodo [desde]–[hasta] (ambos inclusive)
  /// a partir de los servicios recurrentes activos.
  ///
  /// Los traslados ya existentes no se duplican (ON CONFLICT DO NOTHING
  /// en la función `generar_traslados_periodo`).
  Future<ResultadoGeneracionTrasladosEntity> generarPeriodo({
    required DateTime desde,
    required DateTime hasta,
  });
}
