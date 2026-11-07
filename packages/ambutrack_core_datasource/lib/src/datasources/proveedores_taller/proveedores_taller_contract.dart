import 'entities/proveedor_taller_entity.dart';

/// Contrato del datasource de Proveedores de Taller
abstract class ProveedoresTallerDataSource {
  Future<List<ProveedorTallerEntity>> getAll();
  Future<ProveedorTallerEntity?> getById(String id);
  Future<ProveedorTallerEntity> create(ProveedorTallerEntity entity);
  Future<ProveedorTallerEntity> update(ProveedorTallerEntity entity);
  Future<void> delete(String id);
  Future<List<ProveedorTallerEntity>> getByTipo(String tipo);
  Future<List<ProveedorTallerEntity>> getActivos();
  Future<int> count();
}
