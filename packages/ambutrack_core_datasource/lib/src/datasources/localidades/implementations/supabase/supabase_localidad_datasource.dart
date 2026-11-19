import 'package:supabase_flutter/supabase_flutter.dart';

import '../../localidad_contract.dart';
import '../../entities/localidad_entity.dart';
import '../../models/localidad_supabase_model.dart';

/// Implementación de Supabase para el datasource de localidades
class SupabaseLocalidadDataSource implements LocalidadDataSource {
  SupabaseLocalidadDataSource({
    SupabaseClient? supabase,
    this.tableName = 'tpoblaciones',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  /// Query base con JOIN a tprovincias para obtener el nombre de la provincia
  String get _selectWithJoin => '*, tprovincias!provincia_id(nombre)';

  @override
  Future<List<LocalidadEntity>> getAll({int? limit, int? offset}) async {
    try {
      dynamic query = _supabase.from(tableName).select(_selectWithJoin);

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('nombre', ascending: true);

      return (response as List)
          .map((json) => LocalidadSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener localidades: $e');
    }
  }

  @override
  Future<LocalidadEntity?> getById(String id) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select(_selectWithJoin)
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return LocalidadSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener localidad por ID: $e');
    }
  }

  @override
  Future<LocalidadEntity> create(LocalidadEntity entity) async {
    try {
      final model = LocalidadSupabaseModel.fromEntity(entity);
      final data = model.toJson();

      // Remover campos auto-generados
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _supabase
          .from(tableName)
          .insert(data)
          .select(_selectWithJoin)
          .single();

      return LocalidadSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear localidad: $e');
    }
  }

  @override
  Future<LocalidadEntity> update(LocalidadEntity entity) async {
    try {
      final model = LocalidadSupabaseModel.fromEntity(entity);
      final data = model.toJson();

      // Remover campos que no deben actualizarse
      data.remove('id');
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', entity.id)
          .select(_selectWithJoin)
          .single();

      return LocalidadSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar localidad: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar localidad: $e');
    }
  }

  @override
  Future<List<LocalidadEntity>> createBatch(List<LocalidadEntity> entities) async {
    try {
      final dataList = entities.map((entity) {
        final model = LocalidadSupabaseModel.fromEntity(entity);
        final data = model.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        return data;
      }).toList();

      final response = await _supabase
          .from(tableName)
          .insert(dataList)
          .select(_selectWithJoin);

      return (response as List)
          .map((json) => LocalidadSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear localidades en batch: $e');
    }
  }

  @override
  Future<List<LocalidadEntity>> updateBatch(List<LocalidadEntity> entities) async {
    try {
      final results = <LocalidadEntity>[];
      for (final entity in entities) {
        final updated = await update(entity);
        results.add(updated);
      }
      return results;
    } catch (e) {
      throw Exception('Error al actualizar localidades en batch: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar localidades en batch: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final response = await _supabase.from(tableName).select().count();
      return response.count;
    } catch (e) {
      throw Exception('Error al contar localidades: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();
      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia de localidad: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Error al limpiar localidades: $e');
    }
  }

  @override
  Stream<List<LocalidadEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre', ascending: true)
        .map(
          (List<Map<String, dynamic>> data) => data
              .map((json) => LocalidadSupabaseModel.fromJson(json).toEntity())
              .toList(),
        );
  }

  @override
  Stream<LocalidadEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return LocalidadSupabaseModel.fromJson(data.first).toEntity();
        });
  }

  @override
  Future<List<LocalidadEntity>> getByProvincia(String provinciaId) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select(_selectWithJoin)
          .eq('provincia_id', provinciaId)
          .order('nombre', ascending: true);

      return (response as List)
          .map((json) => LocalidadSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener localidades por provincia: $e');
    }
  }
}
