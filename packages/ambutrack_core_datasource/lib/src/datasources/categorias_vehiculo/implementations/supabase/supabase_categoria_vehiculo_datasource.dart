import 'package:supabase_flutter/supabase_flutter.dart';

import '../../categoria_vehiculo_contract.dart';
import '../../entities/categoria_vehiculo_entity.dart';
import '../../models/categoria_vehiculo_supabase_model.dart';

/// Implementación de Supabase para el datasource de categorías de vehículo
class SupabaseCategoriaVehiculoDataSource implements CategoriaVehiculoDataSource {
  SupabaseCategoriaVehiculoDataSource({
    SupabaseClient? supabase,
    this.tableName = 'tcategorias_vehiculo',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  @override
  Future<List<CategoriaVehiculoEntity>> getAll({int? limit, int? offset}) async {
    try {
      dynamic query = _supabase.from(tableName).select();

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('nombre', ascending: true);

      return (response as List)
          .map((dynamic json) => CategoriaVehiculoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener categorías de vehículo: $e');
    }
  }

  @override
  Future<CategoriaVehiculoEntity?> getById(String id) async {
    try {
      final dynamic response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return CategoriaVehiculoSupabaseModel.fromJson(response as Map<String, dynamic>).toEntity();
    } catch (e) {
      throw Exception('Error al obtener categoría por ID: $e');
    }
  }

  @override
  Future<CategoriaVehiculoEntity> create(CategoriaVehiculoEntity entity) async {
    try {
      final CategoriaVehiculoSupabaseModel model = CategoriaVehiculoSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data = model.toJson();

      // Remover campos auto-generados
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final dynamic response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return CategoriaVehiculoSupabaseModel.fromJson(response as Map<String, dynamic>).toEntity();
    } catch (e) {
      throw Exception('Error al crear categoría: $e');
    }
  }

  @override
  Future<CategoriaVehiculoEntity> update(CategoriaVehiculoEntity entity) async {
    try {
      final CategoriaVehiculoSupabaseModel model = CategoriaVehiculoSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data = model.toJson();

      // Remover campos que no deben actualizarse
      data.remove('id');
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();

      final dynamic response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', entity.id)
          .select()
          .single();

      return CategoriaVehiculoSupabaseModel.fromJson(response as Map<String, dynamic>).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar categoría: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar categoría: $e');
    }
  }

  @override
  Future<List<CategoriaVehiculoEntity>> createBatch(List<CategoriaVehiculoEntity> entities) async {
    try {
      final List<Map<String, dynamic>> dataList = entities.map((CategoriaVehiculoEntity entity) {
        final CategoriaVehiculoSupabaseModel model = CategoriaVehiculoSupabaseModel.fromEntity(entity);
        final Map<String, dynamic> data = model.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        return data;
      }).toList();

      final dynamic response = await _supabase
          .from(tableName)
          .insert(dataList)
          .select();

      return (response as List)
          .map((dynamic json) => CategoriaVehiculoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear categorías en batch: $e');
    }
  }

  @override
  Future<List<CategoriaVehiculoEntity>> updateBatch(List<CategoriaVehiculoEntity> entities) async {
    try {
      final List<CategoriaVehiculoEntity> results = <CategoriaVehiculoEntity>[];
      for (final CategoriaVehiculoEntity entity in entities) {
        final CategoriaVehiculoEntity updated = await update(entity);
        results.add(updated);
      }
      return results;
    } catch (e) {
      throw Exception('Error al actualizar categorías en batch: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar categorías en batch: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final dynamic response = await _supabase.from(tableName).select().count();
      return response.count as int;
    } catch (e) {
      throw Exception('Error al contar categorías: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final dynamic response = await _supabase
          .from(tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();
      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia de categoría: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Error al limpiar categorías: $e');
    }
  }

  @override
  Stream<List<CategoriaVehiculoEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre', ascending: true)
        .map(
          (List<Map<String, dynamic>> data) => data
              .map((Map<String, dynamic> json) => CategoriaVehiculoSupabaseModel.fromJson(json).toEntity())
              .toList(),
        );
  }

  @override
  Stream<CategoriaVehiculoEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return CategoriaVehiculoSupabaseModel.fromJson(data.first).toEntity();
        });
  }
}
