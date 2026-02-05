import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/stock_vestuario/domain/repositories/stock_vestuario_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: StockVestuarioRepository)
class StockVestuarioRepositoryImpl implements StockVestuarioRepository {
  StockVestuarioRepositoryImpl() : _dataSource = StockVestuarioDataSourceFactory.createSupabase();
  final StockVestuarioDataSource _dataSource;

  @override
  Future<List<StockVestuarioEntity>> getAll() async {
    debugPrint('📦 Repository: Solicitando todos los artículos de stock...');
    return _dataSource.getAll();
  }

  @override
  Future<StockVestuarioEntity> getById(String id) async {
    return _dataSource.getById(id);
  }

  @override
  Future<StockVestuarioEntity> create(StockVestuarioEntity item) async {
    debugPrint('📦 Repository: Creando artículo: ${item.prenda}');
    return _dataSource.create(item);
  }

  @override
  Future<StockVestuarioEntity> update(StockVestuarioEntity item) async {
    debugPrint('📦 Repository: Actualizando artículo: ${item.id}');
    return _dataSource.update(item);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 Repository: Eliminando artículo: $id');
    await _dataSource.delete(id);
  }

  @override
  Stream<List<StockVestuarioEntity>> watchAll() {
    return _dataSource.watchAll();
  }

  @override
  Future<List<StockVestuarioEntity>> getStockBajo() async {
    return _dataSource.getStockBajo();
  }

  @override
  Future<List<StockVestuarioEntity>> getDisponibles() async {
    return _dataSource.getDisponibles();
  }

  @override
  Future<void> incrementarAsignada(String id, int cantidad) async {
    await _dataSource.incrementarAsignada(id, cantidad);
  }

  @override
  Future<void> decrementarAsignada(String id, int cantidad) async {
    await _dataSource.decrementarAsignada(id, cantidad);
  }
}
