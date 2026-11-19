import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio abstracto de consumo de combustible
abstract class ConsumoCombustibleRepository {
  /// Obtener todos los registros de consumo
  Future<List<ConsumoCombustibleEntity>> getAll();

  /// Obtener un registro por ID
  Future<ConsumoCombustibleEntity?> getById(String id);

  /// Obtener registros de un vehículo específico
  Future<List<ConsumoCombustibleEntity>> getByVehiculo(String vehiculoId);

  /// Obtener registros por rango de fechas
  Future<List<ConsumoCombustibleEntity>> getByRangoFechas(
    DateTime fechaInicio,
    DateTime fechaFin, {
    String? empresaId,
  });

  /// Obtener el último registro de un vehículo
  Future<ConsumoCombustibleEntity?> getUltimoRegistro(String vehiculoId);

  /// Obtener el kilometraje del último registro
  Future<double> getUltimoKilometraje(String vehiculoId);

  /// Obtener estadísticas de un vehículo
  Future<Map<String, double>> getEstadisticas(
    String vehiculoId, {
    int dias = 30,
  });

  /// Obtener estadísticas de la flota
  Future<Map<String, double>> getEstadisticasFlota(
    String empresaId, {
    int dias = 30,
  });

  /// Crear un nuevo registro de consumo
  ///
  /// Valida que el kilometraje NO sea inferior al último registro del vehículo
  /// y actualiza el kilometraje del vehículo automáticamente.
  ///
  /// Lanza [ArgumentError] si el kilometraje es inferior al último registrado.
  Future<ConsumoCombustibleEntity> create(ConsumoCombustibleEntity consumo);

  /// Actualizar un registro existente
  Future<ConsumoCombustibleEntity> update(ConsumoCombustibleEntity consumo);

  /// Eliminar un registro
  Future<void> delete(String id);

  /// Stream en tiempo real de todos los registros
  Stream<List<ConsumoCombustibleEntity>> watchAll();

  /// Stream en tiempo real de registros de un vehículo
  Stream<List<ConsumoCombustibleEntity>> watchByVehiculo(String vehiculoId);
}
