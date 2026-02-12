// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource;

/// Repositorio para operaciones de Stock del sistema simplificado de Almacén
///
/// Actúa como pass-through al datasource sin conversiones Entity ↔ Entity
/// Gestiona el stock actual de productos en diferentes almacenes y vehículos
abstract class StockRepository {
  /// Obtiene todo el stock
  Future<List<StockEntity>> getAll();

  /// Obtiene el stock de un producto específico
  Future<List<StockEntity>> getByProducto(String productoId);

  /// Obtiene el stock de un almacén específico
  Future<List<StockEntity>> getByAlmacen(String almacenId);

  /// Obtiene el stock de un vehículo específico
  Future<List<StockEntity>> getByVehiculo(String vehiculoId);

  /// Obtiene productos con stock bajo (cantidad_actual < cantidad_minima)
  Future<List<StockEntity>> getStockBajo(String almacenId);

  /// Obtiene productos próximos a caducar
  Future<List<StockEntity>> getProximoACaducar({int diasAntes = 30});

  /// Obtiene un registro de stock específico
  Future<StockEntity?> getById(String id);

  /// Obtiene el stock de un producto en un almacén/vehículo específico
  Future<StockEntity?> getStockEspecifico({
    required String productoId,
    String? almacenId,
    String? vehiculoId,
  });

  /// Crea un nuevo registro de stock
  Future<StockEntity> create(StockEntity stock);

  /// Actualiza un registro de stock existente
  Future<StockEntity> update(StockEntity stock);

  /// Elimina un registro de stock
  Future<void> delete(String id);

  /// Ajusta la cantidad de stock (crea movimiento automáticamente)
  Future<StockEntity> ajustarCantidad({
    required String stockId,
    required double nuevaCantidad,
    required String motivo,
  });

  /// Transfiere stock desde un almacén a un vehículo
  Future<StockEntity> transferirAVehiculo({
    required String idStock,
    required String vehiculoId,
    required double cantidad,
    required String motivo,
    String? lote,
    DateTime? fechaCaducidad,
  });

  /// Transfiere stock entre dos almacenes
  Future<StockEntity> transferirEntreAlmacenes({
    required String idStockOrigen,
    required String almacenDestinoId,
    required double cantidad,
    required String motivo,
  });

  /// Stream para observar todo el stock
  Stream<List<StockEntity>> watchAll();

  /// Stream para observar el stock de un almacén
  Stream<List<StockEntity>> watchByAlmacen(String almacenId);

  /// Stream para observar el stock de un vehículo
  Stream<List<StockEntity>> watchByVehiculo(String vehiculoId);
}
