import 'package:supabase_flutter/supabase_flutter.dart';

import '../../especialidad_contract.dart';
import '../../entities/especialidad_entity.dart';
import '../../models/especialidad_supabase_model.dart';

/// Implementación de Supabase para el datasource de especialidades médicas
class SupabaseEspecialidadDataSource implements EspecialidadDataSource {
  SupabaseEspecialidadDataSource({
    SupabaseClient? supabase,
    this.tableName = 'tespecialidades',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  @override
  Future<List<EspecialidadEntity>> getAll({int? limit, int? offset}) async {
    try {
      dynamic query = _supabase.from(tableName).select();

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('nombre', ascending: true);

      return (response as List)
          .map((json) => EspecialidadSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener especialidades médicas: $e');
    }
  }

  @override
  Future<EspecialidadEntity?> getById(String id) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return EspecialidadSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener especialidad médica por ID: $e');
    }
  }

  @override
  Future<EspecialidadEntity> create(EspecialidadEntity entity) async {
    try {
      final model = EspecialidadSupabaseModel.fromEntity(entity);
      final data = model.toJson();

      // Remover campos auto-generados
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return EspecialidadSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear especialidad médica: $e');
    }
  }

  @override
  Future<EspecialidadEntity> update(EspecialidadEntity entity) async {
    try {
      final model = EspecialidadSupabaseModel.fromEntity(entity);
      final data = model.toJson();

      // Remover campos que no deben actualizarse
      data.remove('id');
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', entity.id)
          .select()
          .single();

      return EspecialidadSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar especialidad médica: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar especialidad médica: $e');
    }
  }

  @override
  Future<List<EspecialidadEntity>> createBatch(List<EspecialidadEntity> entities) async {
    try {
      final dataList = entities.map((entity) {
        final model = EspecialidadSupabaseModel.fromEntity(entity);
        final data = model.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        return data;
      }).toList();

      final response = await _supabase
          .from(tableName)
          .insert(dataList)
          .select();

      return (response as List)
          .map((json) => EspecialidadSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear especialidades médicas en batch: $e');
    }
  }

  @override
  Future<List<EspecialidadEntity>> updateBatch(List<EspecialidadEntity> entities) async {
    try {
      final results = <EspecialidadEntity>[];
      for (final entity in entities) {
        final updated = await update(entity);
        results.add(updated);
      }
      return results;
    } catch (e) {
      throw Exception('Error al actualizar especialidades médicas en batch: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar especialidades médicas en batch: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final response = await _supabase.from(tableName).select().count();
      return response.count;
    } catch (e) {
      throw Exception('Error al contar especialidades médicas: $e');
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
      throw Exception('Error al verificar existencia de especialidad médica: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Error al limpiar especialidades médicas: $e');
    }
  }

  @override
  Stream<List<EspecialidadEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre', ascending: true)
        .map(
          (List<Map<String, dynamic>> data) => data
              .map((json) => EspecialidadSupabaseModel.fromJson(json).toEntity())
              .toList(),
        );
  }

  @override
  Stream<EspecialidadEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return EspecialidadSupabaseModel.fromJson(data.first).toEntity();
        });
  }

  @override
  Future<List<EspecialidadEntity>> getActivas() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('activo', true)
          .order('nombre', ascending: true);

      return (response as List)
          .map((json) => EspecialidadSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener especialidades médicas activas: $e');
    }
  }

  @override
  Future<List<EspecialidadEntity>> filterByTipo(String tipo) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('tipo_especialidad', tipo)
          .order('nombre', ascending: true);

      return (response as List)
          .map((json) => EspecialidadSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al filtrar especialidades médicas por tipo: $e');
    }
  }
}
