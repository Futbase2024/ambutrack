import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/producto_entity.dart';
import '../../models/producto_supabase_model.dart';
import '../../producto_contract.dart';

/// Implementación de ProductoDataSource usando Supabase
class SupabaseProductoDataSource implements ProductoDataSource {
  SupabaseProductoDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'productos';

  @override
  Future<List<ProductoEntity>> getAll() async {
    try {
      debugPrint('=æ Producto DS: Obteniendo todos los productos...');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .order('nombre', ascending: true);

      final List<ProductoEntity> productos = data
          .map((json) => ProductoSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Producto DS:  ${productos.length} productos obtenidos');
      return productos;
    } catch (e) {
      debugPrint('=æ Producto DS: L Error al obtener productos: $e');
      rethrow;
    }
  }

  @override
  Future<ProductoEntity?> getById(String id) async {
    try {
      debugPrint('=æ Producto DS: Obteniendo producto con ID: $id');

      final Map<String, dynamic>? data =
          await _supabase.from(_tableName).select().eq('id', id).maybeSingle();

      if (data == null) {
        debugPrint('=æ Producto DS:   Producto no encontrado');
        return null;
      }

      final ProductoEntity producto =
          ProductoSupabaseModel.fromJson(data).toEntity();

      debugPrint('=æ Producto DS:  Producto obtenido: ${producto.nombre}');
      return producto;
    } catch (e) {
      debugPrint('=æ Producto DS: L Error al obtener producto: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductoEntity>> getByCategoria(CategoriaProducto categoria) async {
    try {
      debugPrint('=æ Producto DS: Obteniendo productos de categoría: ${categoria.label}');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('categoria', categoria.code)
          .eq('activo', true)
          .order('nombre', ascending: true);

      final List<ProductoEntity> productos = data
          .map((json) => ProductoSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Producto DS:  ${productos.length} productos de ${categoria.label}');
      return productos;
    } catch (e) {
      debugPrint('=æ Producto DS: L Error al obtener productos por categoría: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductoEntity>> search(String query) async {
    try {
      debugPrint('=æ Producto DS: Buscando productos con query: $query');

      final String searchPattern = '%$query%';

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .or('nombre.ilike.$searchPattern,codigo.ilike.$searchPattern,principio_activo.ilike.$searchPattern')
          .order('nombre', ascending: true);

      final List<ProductoEntity> productos = data
          .map((json) => ProductoSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Producto DS:  ${productos.length} productos encontrados');
      return productos;
    } catch (e) {
      debugPrint('=æ Producto DS: L Error al buscar productos: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductoEntity>> getMedicacion() async {
    return getByCategoria(CategoriaProducto.medicacion);
  }

  @override
  Future<List<ProductoEntity>> getElectromedicina() async {
    return getByCategoria(CategoriaProducto.electromedicina);
  }

  @override
  Future<List<ProductoEntity>> getMaterialAmbulancia() async {
    return getByCategoria(CategoriaProducto.materialAmbulancia);
  }

  @override
  Future<List<ProductoEntity>> getProductosConMantenimiento() async {
    try {
      debugPrint('=æ Producto DS: Obteniendo productos que requieren mantenimiento...');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('requiere_mantenimiento', true)
          .eq('activo', true)
          .order('nombre', ascending: true);

      final List<ProductoEntity> productos = data
          .map((json) => ProductoSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Producto DS:  ${productos.length} productos con mantenimiento');
      return productos;
    } catch (e) {
      debugPrint('=æ Producto DS: L Error al obtener productos con mantenimiento: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductoEntity>> getProductosConReceta() async {
    try {
      debugPrint('=æ Producto DS: Obteniendo productos que requieren receta...');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('requiere_receta', true)
          .eq('activo', true)
          .order('nombre', ascending: true);

      final List<ProductoEntity> productos = data
          .map((json) => ProductoSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Producto DS:  ${productos.length} productos con receta');
      return productos;
    } catch (e) {
      debugPrint('=æ Producto DS: L Error al obtener productos con receta: $e');
      rethrow;
    }
  }

  @override
  Future<ProductoEntity> create(ProductoEntity producto) async {
    try {
      debugPrint('=æ Producto DS: Creando producto: ${producto.nombre}');

      final ProductoSupabaseModel model =
          ProductoSupabaseModel.fromEntity(producto);
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).insert(model.toJson()).select().single();

      final ProductoEntity createdProducto =
          ProductoSupabaseModel.fromJson(data).toEntity();

      debugPrint('=æ Producto DS:  Producto creado: ${createdProducto.nombre}');
      return createdProducto;
    } catch (e) {
      debugPrint('=æ Producto DS: L Error al crear producto: $e');
      rethrow;
    }
  }

  @override
  Future<ProductoEntity> update(ProductoEntity producto) async {
    try {
      debugPrint('=æ Producto DS: Actualizando producto: ${producto.nombre}');

      final ProductoSupabaseModel model =
          ProductoSupabaseModel.fromEntity(producto);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', producto.id)
          .select()
          .single();

      final ProductoEntity updatedProducto =
          ProductoSupabaseModel.fromJson(data).toEntity();

      debugPrint('=æ Producto DS:  Producto actualizado: ${updatedProducto.nombre}');
      return updatedProducto;
    } catch (e) {
      debugPrint('=æ Producto DS: L Error al actualizar producto: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('=æ Producto DS: Eliminando producto (soft delete): $id');

      await _supabase
          .from(_tableName)
          .update({'activo': false}).eq('id', id);

      debugPrint('=æ Producto DS:  Producto eliminado');
    } catch (e) {
      debugPrint('=æ Producto DS: L Error al eliminar producto: $e');
      rethrow;
    }
  }

  @override
  Stream<List<ProductoEntity>> watchAll() {
    debugPrint('=æ Producto DS: Observando cambios en productos...');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('activo', true)
        .order('nombre', ascending: true)
        .map((data) =>
            data.map((json) => ProductoSupabaseModel.fromJson(json).toEntity()).toList());
  }

  @override
  Stream<List<ProductoEntity>> watchByCategoria(CategoriaProducto categoria) {
    debugPrint('=æ Producto DS: Observando cambios en categoría: ${categoria.label}');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) {
          // Filtrar en memoria ya que stream no soporta .eq()
          return data
              .where((json) =>
                  json['categoria'] == categoria.code &&
                  json['activo'] == true)
              .map((json) => ProductoSupabaseModel.fromJson(json).toEntity())
              .toList()
                ..sort((a, b) => a.nombre.compareTo(b.nombre));
        });
  }
}
