import 'entities/movimiento_stock_entity.dart';

/// Contrato para el DataSource de Movimientos de Stock
///
/// Define las operaciones para registrar y consultar movimientos de stock
/// entre almacenes (Base Central y Vehículos).
abstract class MovimientoStockDataSource {
  /// Obtiene todos los movimientos de stock
  Future<List<MovimientoStockEntity>> getAll();

  /// Obtiene un movimiento por ID
  Future<MovimientoStockEntity?> getById(String id);

  /// Obtiene movimientos de un producto específico
  Future<List<MovimientoStockEntity>> getByProducto(String idProducto);

  /// Obtiene movimientos de un almacén (como origen)
  Future<List<MovimientoStockEntity>> getByAlmacenOrigen(String idAlmacenOrigen);

  /// Obtiene movimientos de un almacén (como destino)
  Future<List<MovimientoStockEntity>> getByAlmacenDestino(String idAlmacenDestino);

  /// Obtiene movimientos por tipo
  Future<List<MovimientoStockEntity>> getByTipo(TipoMovimientoStock tipo);

  /// Obtiene movimientos de un servicio
  Future<List<MovimientoStockEntity>> getByServicio(String idServicio);

  /// Obtiene movimientos por rango de fechas
  Future<List<MovimientoStockEntity>> getByFechaRange({
    required DateTime desde,
    required DateTime hasta,
  });

  /// Registra una entrada de compra (Proveedor  Base Central)
  Future<MovimientoStockEntity> registrarEntradaCompra({
    required String idProducto,
    required String idAlmacenDestino,
    required double cantidad,
    String? lote,
    String? numeroSerie,
    String? referencia,
    String? motivo,
    String? observaciones,
  });

  /// Registra una transferencia a vehículo (Base  Vehículo)
  Future<MovimientoStockEntity> registrarTransferenciaAVehiculo({
    required String idProducto,
    required String idAlmacenOrigen,
    required String idAlmacenDestino,
    required double cantidad,
    String? lote,
    String? numeroSerie,
    String? motivo,
    String? observaciones,
  });

  /// Registra una devolución de vehículo (Vehículo  Base)
  Future<MovimientoStockEntity> registrarTransferenciaDeVehiculo({
    required String idProducto,
    required String idAlmacenOrigen,
    required String idAlmacenDestino,
    required double cantidad,
    String? lote,
    String? numeroSerie,
    String? motivo,
    String? observaciones,
  });

  /// Registra una transferencia entre vehículos
  Future<MovimientoStockEntity> registrarTransferenciaEntreVehiculos({
    required String idProducto,
    required String idAlmacenOrigen,
    required String idAlmacenDestino,
    required double cantidad,
    String? lote,
    String? numeroSerie,
    String? motivo,
    String? observaciones,
  });

  /// Registra consumo en servicio
  Future<MovimientoStockEntity> registrarConsumoServicio({
    required String idProducto,
    required String idAlmacenOrigen,
    required double cantidad,
    required String idServicio,
    String? lote,
    String? numeroSerie,
    String? observaciones,
  });

  /// Registra ajuste de inventario
  Future<MovimientoStockEntity> registrarAjusteInventario({
    required String idProducto,
    required String idAlmacen,
    required double cantidad,
    required String motivo,
    String? observaciones,
  });

  /// Registra baja por caducidad
  Future<MovimientoStockEntity> registrarBajaCaducidad({
    required String idProducto,
    required String idAlmacenOrigen,
    required double cantidad,
    String? lote,
    String? observaciones,
  });

  /// Registra baja por deterioro
  Future<MovimientoStockEntity> registrarBajaDeterioro({
    required String idProducto,
    required String idAlmacenOrigen,
    required double cantidad,
    String? numeroSerie,
    required String motivo,
    String? observaciones,
  });

  /// Registra devolución a proveedor
  Future<MovimientoStockEntity> registrarDevolucionProveedor({
    required String idProducto,
    required String idAlmacenOrigen,
    required double cantidad,
    String? lote,
    String? numeroSerie,
    String? referencia,
    String? motivo,
    String? observaciones,
  });

  /// Stream para observar cambios en todos los movimientos
  Stream<List<MovimientoStockEntity>> watchAll();

  /// Stream para observar movimientos de un producto
  Stream<List<MovimientoStockEntity>> watchByProducto(String idProducto);

  /// Stream para observar movimientos de un almacén
  Stream<List<MovimientoStockEntity>> watchByAlmacen(String idAlmacen);
}
