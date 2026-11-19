import 'entities/mantenimiento_electromedicina_entity.dart';

/// Contrato para el DataSource de Mantenimiento de Electromedicina
///
/// Define las operaciones para gestionar mantenimientos de equipos médicos
/// (categoría ELECTROMEDICINA).
abstract class MantenimientoElectromedicinaDataSource {
  /// Obtiene todos los mantenimientos
  Future<List<MantenimientoElectromedicinaEntity>> getAll();

  /// Obtiene un mantenimiento por ID
  Future<MantenimientoElectromedicinaEntity?> getById(String id);

  /// Obtiene mantenimientos de un producto específico
  Future<List<MantenimientoElectromedicinaEntity>> getByProducto(String idProducto);

  /// Obtiene mantenimientos por número de serie
  Future<List<MantenimientoElectromedicinaEntity>> getByNumeroSerie(String numeroSerie);

  /// Obtiene mantenimientos de un vehículo
  Future<List<MantenimientoElectromedicinaEntity>> getByVehiculo(String idVehiculo);

  /// Obtiene mantenimientos por tipo
  Future<List<MantenimientoElectromedicinaEntity>> getByTipo(TipoMantenimientoElectromedicina tipo);

  /// Obtiene mantenimientos por resultado
  Future<List<MantenimientoElectromedicinaEntity>> getByResultado(
    ResultadoMantenimiento resultado,
  );

  /// Obtiene mantenimientos próximos a vencer (próximos N días)
  Future<List<MantenimientoElectromedicinaEntity>> getProximosAVencer({
    int dias = 30,
  });

  /// Obtiene mantenimientos vencidos
  Future<List<MantenimientoElectromedicinaEntity>> getVencidos();

  /// Obtiene equipos NO APTOS (última revisión con resultado NO_APTO)
  Future<List<MantenimientoElectromedicinaEntity>> getEquiposNoAptos();

  /// Obtiene mantenimientos por rango de fechas
  Future<List<MantenimientoElectromedicinaEntity>> getByFechaRange({
    required DateTime desde,
    required DateTime hasta,
  });

  /// Crea un nuevo registro de mantenimiento
  Future<MantenimientoElectromedicinaEntity> create(
    MantenimientoElectromedicinaEntity mantenimiento,
  );

  /// Actualiza un mantenimiento existente
  Future<MantenimientoElectromedicinaEntity> update(
    MantenimientoElectromedicinaEntity mantenimiento,
  );

  /// Elimina un mantenimiento
  Future<void> delete(String id);

  /// Stream para observar cambios en todos los mantenimientos
  Stream<List<MantenimientoElectromedicinaEntity>> watchAll();

  /// Stream para observar mantenimientos de un producto
  Stream<List<MantenimientoElectromedicinaEntity>> watchByProducto(String idProducto);

  /// Stream para observar mantenimientos próximos a vencer
  Stream<List<MantenimientoElectromedicinaEntity>> watchProximosAVencer({
    int dias = 30,
  });
}
