import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio para operaciones del Sistema de Almacén General
///
/// Actúa como pass-through al datasource sin conversiones
abstract class AlmacenRepository {
  // ============================================
  // PROVEEDORES
  // ============================================

  Future<List<ProveedorEntity>> getAllProveedores();
  Future<ProveedorEntity> getProveedorById(String id);
  Future<ProveedorEntity> createProveedor(ProveedorEntity proveedor);
  Future<ProveedorEntity> updateProveedor(ProveedorEntity proveedor);
  Future<void> deleteProveedor(String id);
  Future<List<ProveedorEntity>> searchProveedores(String query);
  Future<List<ProveedorEntity>> getProveedoresActivos();

  // ============================================
  // STOCK DE ALMACÉN
  // ============================================

  Future<List<StockAlmacenEntity>> getAllStock();
  Future<List<StockAlmacenEntity>> getStockByProducto(String productoId);
  Future<StockAlmacenEntity?> getStockByLote(String productoId, String lote);
  Future<List<StockAlmacenEntity>> getStockBajo();
  Future<List<StockAlmacenEntity>> getStockProximoACaducar({int dias = 30});
  Future<StockAlmacenEntity> updateStock(StockAlmacenEntity stock);
  Future<void> reservarStock(String productoId, int cantidad, {String? lote});
  Future<void> liberarStockReservado(String productoId, int cantidad, {String? lote});
}
