import '../../core/base_datasource.dart';
import 'entities/stock_entity.dart';

/// Contrato para el DataSource de stock
abstract class StockDataSource implements BaseDatasource<StockEntity> {
  /// Obtiene el stock de un producto específico
  Future<List<StockEntity>> getByProducto(String productoId);

  /// Obtiene el stock de un almacén específico
  Future<List<StockEntity>> getByAlmacen(String almacenId);

  /// Obtiene el stock de un producto en un almacén específico
  Future<StockEntity?> getByProductoAndAlmacen(
    String idProducto,
    String idAlmacen,
  );

  /// Obtiene el stock por lote
  Future<StockEntity?> getByLote(
    String idProducto,
    String idAlmacen,
    String lote,
  );

  /// Obtiene el stock por número de serie
  Future<StockEntity?> getByNumeroSerie(
    String idProducto,
    String numeroSerie,
  );

  /// Obtiene productos con stock bajo en un almacén
  Future<List<StockEntity>> getStockBajo(String idAlmacen);

  /// Obtiene productos próximos a caducar
  Future<List<StockEntity>> getStockProximoACaducar({int dias = 30});

  /// Ajusta la cantidad de stock
  Future<StockEntity> ajustarCantidad({
    required String idStock,
    required double cantidadAjuste,
    String? motivo,
  });

  /// Reserva una cantidad de stock
  Future<StockEntity> reservarCantidad({
    required String idStock,
    required double cantidad,
  });

  /// Libera cantidad reservada
  Future<StockEntity> liberarReservada({
    required String idStock,
    required double cantidad,
  });

  /// Stream para observar el stock de un almacén
  Stream<List<StockEntity>> watchByAlmacen(String almacenId);

  /// Stream para observar el stock de un producto
  Stream<List<StockEntity>> watchByProducto(String idProducto);

  /// Transfiere stock desde un almacén a un vehículo
  ///
  /// - Reduce cantidad en el almacén origen
  /// - Registra el movimiento de salida
  ///
  /// Retorna el stock actualizado del almacén
  Future<StockEntity> transferirAVehiculo({
    required String idStock,
    required String vehiculoId,
    required double cantidad,
    required String motivo,
    String? lote,
    DateTime? fechaCaducidad,
  });

  /// Transfiere stock entre dos almacenes
  ///
  /// - Reduce cantidad en el almacén origen
  /// - Incrementa o crea stock en el almacén destino
  /// - Registra ambos movimientos
  ///
  /// Retorna el stock actualizado del almacén origen
  Future<StockEntity> transferirEntreAlmacenes({
    required String idStockOrigen,
    required String almacenDestinoId,
    required double cantidad,
    required String motivo,
  });
}
