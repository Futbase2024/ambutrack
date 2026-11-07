import 'entities/mantenimiento_entity.dart';

/// Contrato para operaciones de datasource de Mantenimientos
///
/// Define métodos CRUD estándar + métodos especializados para:
/// - Filtrado por vehículo
/// - Búsqueda de mantenimientos próximos
/// - Búsqueda de mantenimientos vencidos
abstract class MantenimientoDataSource {
  // ===== MÉTODOS CRUD BASE =====

  /// Obtiene todos los mantenimientos
  Future<List<MantenimientoEntity>> getAll({int? limit, int? offset});

  /// Obtiene un mantenimiento por ID
  Future<MantenimientoEntity?> getById(String id);

  /// Crea un nuevo mantenimiento
  Future<MantenimientoEntity> create(MantenimientoEntity entity);

  /// Actualiza un mantenimiento existente
  Future<MantenimientoEntity> update(MantenimientoEntity entity);

  /// Elimina un mantenimiento por ID
  Future<void> delete(String id);

  /// Elimina múltiples mantenimientos
  Future<void> deleteBatch(List<String> ids);

  /// Obtiene el conteo total de mantenimientos
  Future<int> count();

  /// Stream de todos los mantenimientos (real-time)
  Stream<List<MantenimientoEntity>> watchAll();

  /// Stream de un mantenimiento específico por ID (real-time)
  Stream<MantenimientoEntity?> watchById(String id);

  /// Elimina todos los mantenimientos (usar con precaución)
  Future<void> clear();

  /// Crea múltiples mantenimientos en batch
  Future<List<MantenimientoEntity>> createBatch(List<MantenimientoEntity> entities);

  /// Verifica si existe un mantenimiento con el ID dado
  Future<bool> exists(String id);

  /// Actualiza múltiples mantenimientos en batch
  Future<List<MantenimientoEntity>> updateBatch(List<MantenimientoEntity> entities);

  // ===== MÉTODOS ESPECIALIZADOS =====

  /// Obtiene mantenimientos de un vehículo específico
  Future<List<MantenimientoEntity>> getByVehiculo(String vehiculoId);

  /// Obtiene mantenimientos programados en los próximos N días
  ///
  /// Filtra mantenimientos con:
  /// - Estado: programado
  /// - fecha_programada entre hoy y hoy + [dias] días
  Future<List<MantenimientoEntity>> getProximos(int dias);

  /// Obtiene mantenimientos vencidos
  ///
  /// Filtra mantenimientos con:
  /// - Estado: programado
  /// - fecha_programada < hoy
  Future<List<MantenimientoEntity>> getVencidos();
}
