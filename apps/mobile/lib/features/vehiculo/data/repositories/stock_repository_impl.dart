import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/stock_repository.dart';

/// Implementación del repositorio de stock de vehículos
class StockRepositoryImpl implements StockRepository {
  StockRepositoryImpl() : _dataSource = StockDataSourceFactory.createSupabase();

  final StockDataSource _dataSource;

  @override
  Future<List<StockVehiculoEntity>> getStockVehiculo(String vehiculoId) async {
    debugPrint('📦 Repository: Obteniendo stock del vehículo: $vehiculoId');
    return await _dataSource.getStockVehiculo(vehiculoId);
  }

  @override
  Future<StockVehiculoEntity?> getStockById(String id) async {
    debugPrint('📦 Repository: Obteniendo stock con ID: $id');
    return await _dataSource.getStockById(id);
  }

  @override
  Future<StockVehiculoEntity> updateStock(StockVehiculoEntity stock) async {
    debugPrint('📦 Repository: Actualizando stock con ID: ${stock.id}');
    return await _dataSource.updateStock(stock);
  }
}
