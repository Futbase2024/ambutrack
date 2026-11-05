import 'package:supabase_flutter/supabase_flutter.dart';

import '../../agenda_pendiente_contract.dart';
import '../../entities/agenda_pendiente_entity.dart';
import '../../models/agenda_pendiente_supabase_model.dart';

/// Implementación de [AgendaPendienteDataSource] usando Supabase
///
/// Proporciona operaciones CRUD para agenda de pendientes
/// en PostgreSQL vía Supabase con filtrado por empresa.
class SupabaseAgendaPendienteDataSource
    implements AgendaPendienteDataSource {
  SupabaseAgendaPendienteDataSource({
    SupabaseClient? supabase,
    this.tableName = 'tagenda_pendientes',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  // ========== CRUD BÁSICO ==========

  @override
  Future<List<AgendaPendienteEntity>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = _supabase.from(tableName).select();

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response =
          await query.order('fecha', ascending: false);

      return (response as List)
          .map((dynamic json) => AgendaPendienteSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener agenda de pendientes: $e');
    }
  }

  @override
  Future<AgendaPendienteEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return AgendaPendienteSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener pendiente por ID: $e');
    }
  }

  @override
  Future<AgendaPendienteEntity> create(
    AgendaPendienteEntity entity,
  ) async {
    try {
      final AgendaPendienteSupabaseModel model =
          AgendaPendienteSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return AgendaPendienteSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear pendiente: $e');
    }
  }

  @override
  Future<AgendaPendienteEntity> update(
    AgendaPendienteEntity entity,
  ) async {
    try {
      final AgendaPendienteSupabaseModel model =
          AgendaPendienteSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson();
      data.remove('id');
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', entity.id)
          .select()
          .single();

      return AgendaPendienteSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar pendiente: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar pendiente: $e');
    }
  }

  // ========== OPERACIONES BATCH ==========

  @override
  Future<List<AgendaPendienteEntity>> createBatch(
    List<AgendaPendienteEntity> entities,
  ) async {
    try {
      final List<Map<String, dynamic>> models = entities
          .map((AgendaPendienteEntity e) =>
              AgendaPendienteSupabaseModel.fromEntity(e).toJson())
          .toList();

      final List<dynamic> response = await _supabase
          .from(tableName)
          .insert(models)
          .select();

      return response
          .map((dynamic json) => AgendaPendienteSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear pendientes en lote: $e');
    }
  }

  @override
  Future<List<AgendaPendienteEntity>> updateBatch(
    List<AgendaPendienteEntity> entities,
  ) async {
    try {
      final List<AgendaPendienteEntity> updated =
          <AgendaPendienteEntity>[];
      for (final AgendaPendienteEntity entity in entities) {
        final AgendaPendienteEntity result = await update(entity);
        updated.add(result);
      }
      return updated;
    } catch (e) {
      throw Exception('Error al actualizar pendientes en lote: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar pendientes en lote: $e');
    }
  }

  // ========== CONTEO Y EXISTENCIA ==========

  @override
  Future<int> count() async {
    try {
      final dynamic response =
          await _supabase.from(tableName).select().count();

      return response.count as int;
    } catch (e) {
      throw Exception('Error al contar pendientes: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia del pendiente: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase
          .from(tableName)
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (e) {
      throw Exception('Error al limpiar pendientes: $e');
    }
  }

  // ========== STREAMING / REAL-TIME ==========

  @override
  Stream<List<AgendaPendienteEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('fecha')
        .map((List<Map<String, dynamic>> data) {
          return data
              .map((Map<String, dynamic> json) =>
                  AgendaPendienteSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<AgendaPendienteEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return AgendaPendienteSupabaseModel.fromJson(data.first)
              .toEntity();
        });
  }

  // ========== MÉTODOS ESPECÍFICOS ==========

  @override
  Future<List<AgendaPendienteEntity>> getByEmpresa(
    String empresaId,
  ) async {
    try {
      final dynamic response = await _supabase
          .from(tableName)
          .select()
          .eq('empresa_id', empresaId)
          .order('fecha', ascending: false);

      return (response as List)
          .map((dynamic json) => AgendaPendienteSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      throw Exception(
        'Error al obtener pendientes por empresa: $e',
      );
    }
  }

  @override
  Future<List<AgendaPendienteEntity>> getPendientesHoy(
    String empresaId,
  ) async {
    try {
      final String today =
          DateTime.now().toIso8601String().split('T')[0];

      final dynamic response = await _supabase
          .from(tableName)
          .select()
          .eq('empresa_id', empresaId)
          .eq('fecha', today)
          .eq('completado', false)
          .order('fecha', ascending: false);

      return (response as List)
          .map((dynamic json) => AgendaPendienteSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      throw Exception(
        'Error al obtener pendientes de hoy: $e',
      );
    }
  }

  @override
  Future<void> marcarCompletado(String id, bool completado) async {
    try {
      await _supabase
          .from(tableName)
          .update(<String, dynamic>{
            'completado': completado,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception(
        'Error al marcar pendiente como completado: $e',
      );
    }
  }
}
