import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de stock de vehículos
abstract class StockRepository {
  /// Obtiene el stock de un vehículo con información de caducidades
  Future<List<StockVehiculoEntity>> getStockVehiculo(String vehiculoId);

  /// Obtiene un item de stock por ID
  Future<StockVehiculoEntity?> getStockById(String id);

  /// Actualiza un item de stock
  Future<StockVehiculoEntity> updateStock(StockVehiculoEntity stock);
}
