import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio para Excepciones/Festivos
abstract class ExcepcionFestivoRepository {
  /// Obtiene todas las excepciones/festivos
  Future<List<ExcepcionFestivoEntity>> getAll();

  /// Obtiene solo las excepciones/festivos activas
  Future<List<ExcepcionFestivoEntity>> getActivas();

  /// Obtiene excepciones/festivos por año
  Future<List<ExcepcionFestivoEntity>> getByAnio(int anio);

  /// Obtiene excepciones/festivos por rango de fechas
  Future<List<ExcepcionFestivoEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });

  /// Obtiene excepciones/festivos por tipo
  Future<List<ExcepcionFestivoEntity>> getByTipo(String tipo);

  /// Obtiene una excepción/festivo por ID
  Future<ExcepcionFestivoEntity?> getById(String id);

  /// Crea una nueva excepción/festivo
  Future<ExcepcionFestivoEntity> create(ExcepcionFestivoEntity item);

  /// Actualiza una excepción/festivo existente
  Future<ExcepcionFestivoEntity> update(ExcepcionFestivoEntity item);

  /// Elimina una excepción/festivo
  Future<void> delete(String id);

  /// Activa/desactiva una excepción/festivo
  Future<void> toggleActivo(String id, {required bool activo});

  /// Stream de cambios en excepciones/festivos
  Stream<List<ExcepcionFestivoEntity>> watchAll();
}
