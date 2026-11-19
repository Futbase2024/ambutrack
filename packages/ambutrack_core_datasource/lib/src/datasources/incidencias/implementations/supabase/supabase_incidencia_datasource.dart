import 'package:supabase_flutter/supabase_flutter.dart';

import '../../incidencia_contract.dart';
import '../../entities/incidencia_entity.dart';
import '../../models/incidencia_supabase_model.dart';

/// Implementación Supabase del datasource de incidencias
class SupabaseIncidenciaDataSource implements IncidenciaDataSource {
  final SupabaseClient _client;
  final String _tableName;

  SupabaseIncidenciaDataSource({
    SupabaseClient? supabaseClient,
    String tableName = 'incidencias',
  })  : _client = supabaseClient ?? Supabase.instance.client,
        _tableName = tableName;

  @override
  Future<List<IncidenciaEntity>> getAll({int? limit, int? offset}) async {
    try {
      var query = _client.from(_tableName).select().order(
            'fecha_incidencia',
            ascending: false,
          );

      if (limit != null && offset != null) {
        query = query.range(offset, offset + limit - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return (response as List)
          .map((json) =>
              IncidenciaSupabaseModel.fromJson(json as Map<String, dynamic>))
          .toList()
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener incidencias: $e');
    }
  }

  @override
  Future<IncidenciaEntity?> getById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return IncidenciaSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener incidencia $id: $e');
    }
  }

  @override
  Future<IncidenciaEntity> create(IncidenciaEntity entity) async {
    try {
      final model = IncidenciaSupabaseModel.fromEntity(entity);
      final json = model.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');

      final response =
          await _client.from(_tableName).insert(json).select().single();

      return IncidenciaSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear incidencia: $e');
    }
  }

  @override
  Future<IncidenciaEntity> update(IncidenciaEntity entity) async {
    try {
      final model = IncidenciaSupabaseModel.fromEntity(entity);
      final json = model.toJson()
        ..remove('id')
        ..remove('created_at')
        ..['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from(_tableName)
          .update(json)
          .eq('id', entity.id)
          .select()
          .single();

      return IncidenciaSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar incidencia: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar incidencia $id: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();
      return response != null;
    } catch (e) {
      throw Exception('Error al verificar incidencia $id: $e');
    }
  }

  @override
  Stream<List<IncidenciaEntity>> watchAll() {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha_incidencia', ascending: false)
        .map((data) => data
            .map((json) =>
                IncidenciaSupabaseModel.fromJson(json).toEntity())
            .toList());
  }

  @override
  Stream<IncidenciaEntity?> watchById(String id) {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) {
      if (data.isEmpty) return null;
      return IncidenciaSupabaseModel.fromJson(data.first).toEntity();
    });
  }

  @override
  Future<List<IncidenciaEntity>> createBatch(
      List<IncidenciaEntity> entities) async {
    try {
      final jsonList = entities.map((entity) {
        final model = IncidenciaSupabaseModel.fromEntity(entity);
        return model.toJson()
          ..remove('id')
          ..remove('created_at')
          ..remove('updated_at');
      }).toList();

      final response = await _client
          .from(_tableName)
          .insert(jsonList)
          .select();

      return (response as List)
          .map((json) =>
              IncidenciaSupabaseModel.fromJson(json as Map<String, dynamic>))
          .toList()
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear lote de incidencias: $e');
    }
  }

  @override
  Future<List<IncidenciaEntity>> updateBatch(
      List<IncidenciaEntity> entities) async {
    try {
      final results = <IncidenciaEntity>[];
      for (final entity in entities) {
        final updated = await update(entity);
        results.add(updated);
      }
      return results;
    } catch (e) {
      throw Exception('Error al actualizar lote de incidencias: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _client.from(_tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar lote de incidencias: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      throw Exception('Error al contar incidencias: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _client.from(_tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Error al limpiar incidencias: $e');
    }
  }
}
