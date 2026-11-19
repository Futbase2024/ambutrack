// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource;
import 'package:ambutrack_web/features/almacen/domain/repositories/producto_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de Productos usando pass-through al datasource
///
/// Siguiendo el patrón establecido en el proyecto: el repositorio es un simple
/// pass-through sin conversiones Entity ↔ Entity ya que usamos las mismas
/// entidades del core datasource
@LazySingleton(as: ProductoRepository)
class ProductoRepositoryImpl implements ProductoRepository {
  ProductoRepositoryImpl()
      : _dataSource = ProductoDataSourceFactory.createSupabase();

  final ProductoDataSource _dataSource;

  @override
  Future<List<ProductoEntity>> getAll() async {
    debugPrint('📦 ProductoRepository: Solicitando todos los productos...');
    try {
      final List<ProductoEntity> productos = await _dataSource.getAll();
      debugPrint(
          '📦 ProductoRepository: ✅ ${productos.length} productos obtenidos');
      return productos;
    } catch (e) {
      debugPrint('📦 ProductoRepository: ❌ Error al obtener productos: $e');
      rethrow;
    }
  }

  @override
  Future<ProductoEntity?> getById(String id) async {
    debugPrint('📦 ProductoRepository: Solicitando producto con ID: $id');
    try {
      final ProductoEntity? producto = await _dataSource.getById(id);
      if (producto != null) {
        debugPrint(
            '📦 ProductoRepository: ✅ Producto obtenido: ${producto.nombre}');
      } else {
        debugPrint('📦 ProductoRepository: ⚠️ Producto no encontrado');
      }
      return producto;
    } catch (e) {
      debugPrint('📦 ProductoRepository: ❌ Error al obtener producto: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductoEntity>> getByCategoria(
      CategoriaProducto categoria) async {
    debugPrint(
        '📦 ProductoRepository: Solicitando productos de categoría: ${categoria.label}');
    try {
      final List<ProductoEntity> productos = await _dataSource.getByCategoria(categoria);
      debugPrint(
          '📦 ProductoRepository: ✅ ${productos.length} productos obtenidos');
      return productos;
    } catch (e) {
      debugPrint(
          '📦 ProductoRepository: ❌ Error al obtener productos por categoría: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductoEntity>> search(String query) async {
    debugPrint('📦 ProductoRepository: Buscando productos: "$query"');
    try {
      final List<ProductoEntity> productos = await _dataSource.search(query);
      debugPrint(
          '📦 ProductoRepository: ✅ ${productos.length} productos encontrados');
      return productos;
    } catch (e) {
      debugPrint('📦 ProductoRepository: ❌ Error al buscar productos: $e');
      rethrow;
    }
  }

  @override
  Future<ProductoEntity> create(ProductoEntity producto) async {
    debugPrint('📦 ProductoRepository: Creando producto: ${producto.nombre}');
    try {
      final ProductoEntity created = await _dataSource.create(producto);
      debugPrint(
          '📦 ProductoRepository: ✅ Producto creado con ID: ${created.id}');
      return created;
    } catch (e) {
      debugPrint('📦 ProductoRepository: ❌ Error al crear producto: $e');
      rethrow;
    }
  }

  @override
  Future<ProductoEntity> update(ProductoEntity producto) async {
    debugPrint('📦 ProductoRepository: Actualizando producto: ${producto.id}');
    try {
      final ProductoEntity updated = await _dataSource.update(producto);
      debugPrint(
          '📦 ProductoRepository: ✅ Producto actualizado: ${updated.nombre}');
      return updated;
    } catch (e) {
      debugPrint('📦 ProductoRepository: ❌ Error al actualizar producto: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 ProductoRepository: Eliminando producto: $id');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 ProductoRepository: ✅ Producto desactivado (soft delete)');
    } catch (e) {
      debugPrint('📦 ProductoRepository: ❌ Error al eliminar producto: $e');
      rethrow;
    }
  }

  @override
  Stream<List<ProductoEntity>> watchAll() {
    debugPrint('📦 ProductoRepository: Iniciando stream de todos los productos');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<ProductoEntity>> watchByCategoria(
      CategoriaProducto categoria) {
    debugPrint(
        '📦 ProductoRepository: Iniciando stream de productos de categoría: ${categoria.label}');
    return _dataSource.watchByCategoria(categoria);
  }
}
