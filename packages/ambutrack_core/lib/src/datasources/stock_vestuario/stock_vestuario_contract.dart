import 'package:ambutrack_core/src/datasources/stock_vestuario/entities/stock_vestuario_entity.dart';

/// Contrato para el DataSource de Stock de Vestuario
abstract class StockVestuarioDataSource {
  /// Obtiene todos los artículos de stock
  Future<List<StockVestuarioEntity>> getAll();

  /// Obtiene un artículo de stock por ID
  Future<StockVestuarioEntity> getById(String id);

  /// Crea un nuevo artículo de stock
  Future<StockVestuarioEntity> create(StockVestuarioEntity item);

  /// Actualiza un artículo de stock existente
  Future<StockVestuarioEntity> update(StockVestuarioEntity item);

  /// Elimina un artículo de stock
  Future<void> delete(String id);

  /// Observa cambios en tiempo real en todos los artículos
  Stream<List<StockVestuarioEntity>> watchAll();

  /// Obtiene artículos con stock bajo (disponible <= mínimo)
  Future<List<StockVestuarioEntity>> getStockBajo();

  /// Obtiene artículos disponibles (con stock > 0)
  Future<List<StockVestuarioEntity>> getDisponibles();

  /// Incrementa cantidad asignada (cuando se asigna vestuario)
  Future<void> incrementarAsignada(String id, int cantidad);

  /// Decrementa cantidad asignada (cuando se devuelve vestuario)
  Future<void> decrementarAsignada(String id, int cantidad);
}
