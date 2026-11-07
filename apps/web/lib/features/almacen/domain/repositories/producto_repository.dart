// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource;

/// Repositorio para operaciones de Productos del sistema simplificado de Almacén
///
/// Actúa como pass-through al datasource sin conversiones Entity ↔ Entity
/// Los productos se categorizan en: Medicación, Electromedicina, Material de Ambulancias
abstract class ProductoRepository {
  /// Obtiene todos los productos activos
  Future<List<ProductoEntity>> getAll();

  /// Obtiene un producto por su ID
  Future<ProductoEntity?> getById(String id);

  /// Obtiene productos por categoría
  Future<List<ProductoEntity>> getByCategoria(CategoriaProducto categoria);

  /// Busca productos por nombre o código
  Future<List<ProductoEntity>> search(String query);

  /// Crea un nuevo producto
  Future<ProductoEntity> create(ProductoEntity producto);

  /// Actualiza un producto existente
  Future<ProductoEntity> update(ProductoEntity producto);

  /// Elimina un producto (soft delete - activo = false)
  Future<void> delete(String id);

  /// Stream para observar todos los productos
  Stream<List<ProductoEntity>> watchAll();

  /// Stream para observar productos por categoría
  Stream<List<ProductoEntity>> watchByCategoria(CategoriaProducto categoria);
}
