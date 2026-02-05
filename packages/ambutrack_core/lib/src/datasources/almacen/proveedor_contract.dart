import 'package:ambutrack_core_datasource/src/core/base_datasource.dart';
import 'package:ambutrack_core_datasource/src/datasources/almacen/entities/proveedor_entity.dart';

/// Contrato para el datasource de Proveedores
abstract class ProveedorDataSource implements BaseDatasource<ProveedorEntity> {
  /// Buscar proveedores por texto (nombre comercial, razón social, CIF)
  Future<List<ProveedorEntity>> search(String query);

  /// Obtener proveedores activos
  Future<List<ProveedorEntity>> getActivos();

  /// Obtener proveedores por ciudad
  Future<List<ProveedorEntity>> getByCiudad(String ciudad);
}
