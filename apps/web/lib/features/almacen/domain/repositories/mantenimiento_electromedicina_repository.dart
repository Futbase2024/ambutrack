// Imports del core datasource (sistema nuevo de almacén)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource;

/// Repositorio para operaciones de Mantenimiento de Electromedicina
///
/// Actúa como pass-through al datasource sin conversiones Entity ↔ Entity
/// Gestiona el mantenimiento preventivo y correctivo de equipos electromédicos
abstract class MantenimientoElectromedicinaRepository {
  /// Obtiene todos los registros de mantenimiento
  Future<List<MantenimientoElectromedicinaEntity>> getAll();

  /// Obtiene un registro de mantenimiento por su ID
  Future<MantenimientoElectromedicinaEntity?> getById(String id);

  /// Obtiene registros de mantenimiento de un producto específico
  Future<List<MantenimientoElectromedicinaEntity>> getByProducto(String productoId);

  /// Obtiene mantenimientos por tipo
  Future<List<MantenimientoElectromedicinaEntity>> getByTipo(TipoMantenimientoElectromedicina tipo);

  /// Obtiene mantenimientos próximos a vencer
  Future<List<MantenimientoElectromedicinaEntity>> getProximosAVencer({int dias = 30});

  /// Obtiene mantenimientos vencidos
  Future<List<MantenimientoElectromedicinaEntity>> getVencidos();

  /// Crea un nuevo registro de mantenimiento
  Future<MantenimientoElectromedicinaEntity> create(MantenimientoElectromedicinaEntity mantenimiento);

  /// Actualiza un registro de mantenimiento existente
  Future<MantenimientoElectromedicinaEntity> update(MantenimientoElectromedicinaEntity mantenimiento);

  /// Elimina un registro de mantenimiento
  Future<void> delete(String id);

  /// Stream para observar todos los mantenimientos
  Stream<List<MantenimientoElectromedicinaEntity>> watchAll();

  /// Stream para observar mantenimientos de un producto
  Stream<List<MantenimientoElectromedicinaEntity>> watchByProducto(String productoId);

  /// Stream para observar mantenimientos próximos a vencer
  Stream<List<MantenimientoElectromedicinaEntity>> watchProximosAVencer({int dias = 30});
}
