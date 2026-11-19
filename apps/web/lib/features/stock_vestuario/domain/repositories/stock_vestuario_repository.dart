import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio para Stock de Vestuario
abstract class StockVestuarioRepository {
  Future<List<StockVestuarioEntity>> getAll();
  Future<StockVestuarioEntity> getById(String id);
  Future<StockVestuarioEntity> create(StockVestuarioEntity item);
  Future<StockVestuarioEntity> update(StockVestuarioEntity item);
  Future<void> delete(String id);
  Stream<List<StockVestuarioEntity>> watchAll();
  Future<List<StockVestuarioEntity>> getStockBajo();
  Future<List<StockVestuarioEntity>> getDisponibles();
  Future<void> incrementarAsignada(String id, int cantidad);
  Future<void> decrementarAsignada(String id, int cantidad);
}
