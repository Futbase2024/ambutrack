import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource;

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
}
