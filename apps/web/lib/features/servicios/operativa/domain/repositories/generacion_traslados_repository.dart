import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio de generación de traslados diarios
abstract class GeneracionTrasladosRepository {
  /// Genera los traslados del periodo indicado a partir de los servicios
  /// recurrentes activos (sin duplicar los existentes)
  Future<ResultadoGeneracionTrasladosEntity> generarPeriodo({
    required DateTime desde,
    required DateTime hasta,
  });
}
