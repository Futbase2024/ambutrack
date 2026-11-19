import 'entities/alerta_stock_entity.dart';
import 'entities/categoria_equipamiento_entity.dart';
import 'entities/item_revision_entity.dart';
import 'entities/movimiento_stock_entity.dart';
import 'entities/producto_entity.dart';
import 'entities/revision_mensual_entity.dart';
import 'entities/stock_minimo_entity.dart';
import 'entities/stock_vehiculo_entity.dart';

/// Contrato para datasource de Stock
///
/// Define los métodos para gestión de stock de equipamiento médico
abstract class StockDataSource {
  // ========================================================================
  // CATEGORÍAS DE EQUIPAMIENTO
  // ========================================================================

  /// Obtiene todas las categorías de equipamiento
  Future<List<CategoriaEquipamientoEntity>> getCategorias();

  /// Obtiene una categoría por ID
  Future<CategoriaEquipamientoEntity?> getCategoriaById(String id);

  // ========================================================================
  // PRODUCTOS
  // ========================================================================

  /// Obtiene todos los productos activos
  Future<List<ProductoEntity>> getProductos();

  /// Obtiene productos por categoría
  Future<List<ProductoEntity>> getProductosByCategoria(String categoriaId);

  /// Obtiene un producto por ID
  Future<ProductoEntity?> getProductoById(String id);

  /// Crea un nuevo producto
  Future<ProductoEntity> createProducto(ProductoEntity producto);

  /// Actualiza un producto
  Future<ProductoEntity> updateProducto(ProductoEntity producto);

  /// Elimina un producto
  Future<void> deleteProducto(String id);

  // ========================================================================
  // STOCK MÍNIMO POR TIPO
  // ========================================================================

  /// Obtiene el stock mínimo de un producto para un tipo de vehículo
  Future<StockMinimoEntity?> getStockMinimo(
    String productoId,
    String tipoVehiculo,
  );

  /// Obtiene todo el stock mínimo de un tipo de vehículo
  Future<List<StockMinimoEntity>> getStockMinimoByTipo(String tipoVehiculo);

  /// Crea o actualiza stock mínimo
  Future<StockMinimoEntity> upsertStockMinimo(StockMinimoEntity stockMinimo);

  // ========================================================================
  // STOCK DE VEHÍCULO
  // ========================================================================

  /// Obtiene el stock de un vehículo (usando vista con estados calculados)
  Future<List<StockVehiculoEntity>> getStockVehiculo(String vehiculoId);

  /// Obtiene un item de stock por ID
  Future<StockVehiculoEntity?> getStockById(String id);

  /// Actualiza un item de stock
  Future<StockVehiculoEntity> updateStock(StockVehiculoEntity stock);

  // ========================================================================
  // MOVIMIENTOS DE STOCK
  // ========================================================================

  /// Registra un movimiento de stock (entrada/salida/ajuste)
  /// Usa la función RPC de Supabase
  Future<Map<String, dynamic>> registrarMovimiento({
    required String vehiculoId,
    required String productoId,
    required String tipo,
    required int cantidad,
    String? lote,
    DateTime? fechaCaducidad,
    String? motivo,
    String? usuarioId,
  });

  /// Registra stock manual directamente en vehículo (sin pasar por almacén)
  ///
  /// Este método NO usa la función RPC, hace INSERT/UPDATE directo en stock_vehiculo.
  /// Útil para añadir stock que ya existe en la ambulancia o proviene de fuente externa
  /// (no del almacén de la empresa).
  ///
  /// Si el producto con ese lote ya existe en el vehículo, suma la cantidad.
  /// Si no existe, crea un nuevo registro.
  Future<Map<String, dynamic>> registrarStockManual({
    required String vehiculoId,
    required String productoId,
    required int cantidad,
    String? lote,
    DateTime? fechaCaducidad,
    String? motivo,
    String? usuarioId,
  });

  /// Obtiene el historial de movimientos
  Future<List<MovimientoStockEntity>> getHistorialMovimientos({
    String? vehiculoId,
    String? productoId,
    DateTime? desde,
    DateTime? hasta,
    int limit = 50,
  });

  // ========================================================================
  // ALERTAS
  // ========================================================================

  /// Obtiene alertas activas de un vehículo
  Future<List<AlertaStockEntity>> getAlertasVehiculo(String vehiculoId);

  /// Obtiene todas las alertas activas
  Future<List<AlertaStockEntity>> getAlertasActivas();

  /// Marca una alerta como resuelta
  Future<void> resolverAlerta(String alertaId, String usuarioId);

  /// Genera alertas automáticas (llama función RPC)
  Future<void> generarAlertas();

  // ========================================================================
  // REVISIONES MENSUALES
  // ========================================================================

  /// Obtiene revisiones de un vehículo
  Future<List<RevisionMensualEntity>> getRevisionesVehiculo(String vehiculoId);

  /// Obtiene una revisión por ID
  Future<RevisionMensualEntity?> getRevisionById(String id);

  /// Crea una nueva revisión
  Future<RevisionMensualEntity> createRevision(RevisionMensualEntity revision);

  /// Actualiza una revisión
  Future<RevisionMensualEntity> updateRevision(RevisionMensualEntity revision);

  /// Completa una revisión
  Future<RevisionMensualEntity> completarRevision(
    String revisionId,
    String? firmaBase64,
    String? observaciones,
  );

  // ========================================================================
  // ITEMS DE REVISIÓN
  // ========================================================================

  /// Obtiene items de una revisión
  Future<List<ItemRevisionEntity>> getItemsRevision(String revisionId);

  /// Actualiza un item de revisión
  Future<ItemRevisionEntity> updateItemRevision(ItemRevisionEntity item);

  /// Verifica un item de revisión
  Future<ItemRevisionEntity> verificarItem(
    String itemId,
    int cantidadEncontrada,
    bool caducidadOk,
    String estado,
    String? observacion,
  );
}
