import 'entities/producto_entity.dart';

/// Contrato para el DataSource de Productos
///
/// Define las operaciones CRUD para gestionar productos
/// de las 3 categorías: Medicación, Electromedicina y Material de Ambulancia.
abstract class ProductoDataSource {
  /// Obtiene todos los productos activos
  Future<List<ProductoEntity>> getAll();

  /// Obtiene un producto por ID
  Future<ProductoEntity?> getById(String id);

  /// Obtiene productos por categoría
  Future<List<ProductoEntity>> getByCategoria(CategoriaProducto categoria);

  /// Busca productos por nombre, código o principio activo
  Future<List<ProductoEntity>> search(String query);

  /// Obtiene solo productos de MEDICACION
  Future<List<ProductoEntity>> getMedicacion();

  /// Obtiene solo productos de ELECTROMEDICINA
  Future<List<ProductoEntity>> getElectromedicina();

  /// Obtiene solo productos de MATERIAL_AMBULANCIA
  Future<List<ProductoEntity>> getMaterialAmbulancia();

  /// Obtiene productos que requieren mantenimiento
  Future<List<ProductoEntity>> getProductosConMantenimiento();

  /// Obtiene productos que requieren receta
  Future<List<ProductoEntity>> getProductosConReceta();

  /// Crea un nuevo producto
  Future<ProductoEntity> create(ProductoEntity producto);

  /// Actualiza un producto existente
  Future<ProductoEntity> update(ProductoEntity producto);

  /// Elimina un producto (soft delete: activo = false)
  Future<void> delete(String id);

  /// Stream para observar cambios en todos los productos
  Stream<List<ProductoEntity>> watchAll();

  /// Stream para observar cambios en productos de una categoría
  Stream<List<ProductoEntity>> watchByCategoria(CategoriaProducto categoria);
}
