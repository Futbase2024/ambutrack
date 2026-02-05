import 'package:supabase_flutter/supabase_flutter.dart';

import '../../motivo_cancelacion_contract.dart';
import '../../entities/motivo_cancelacion_entity.dart';
import '../../models/motivo_cancelacion_supabase_model.dart';

/// Implementación de [MotivoCancelacionDataSource] usando Supabase
///
/// Proporciona operaciones CRUD para motivos de cancelación en PostgreSQL vía Supabase.
class SupabaseMotivoCancelacionDataSource
    implements MotivoCancelacionDataSource {
  SupabaseMotivoCancelacionDataSource({
    SupabaseClient? supabase,
    this.tableName = 'tmotivos_cancelacion',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  // ========== CRUD BÁSICO ==========

  @override
  Future<List<MotivoCancelacionEntity>> getAll({
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

      final dynamic response = await query.order('nombre', ascending: true);

      return (response as List)
          .map((dynamic json) => MotivoCancelacionSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener motivos de cancelación: $e');
    }
  }

  @override
  Future<MotivoCancelacionEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return MotivoCancelacionSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener motivo de cancelación por ID: $e');
    }
  }

  @override
  Future<MotivoCancelacionEntity> create(
    MotivoCancelacionEntity entity,
  ) async {
    try {
      final MotivoCancelacionSupabaseModel model =
          MotivoCancelacionSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson();
      data.remove('id'); // Supabase genera el ID
      data.remove('created_at'); // Supabase genera created_at
      data.remove('updated_at'); // Supabase genera updated_at

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return MotivoCancelacionSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear motivo de cancelación: $e');
    }
  }

  @override
  Future<MotivoCancelacionEntity> update(
    MotivoCancelacionEntity entity,
  ) async {
    try {
      final MotivoCancelacionSupabaseModel model =
          MotivoCancelacionSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson();
      data.remove('id'); // No actualizar ID
      data.remove('created_at'); // No actualizar created_at
      data['updated_at'] = DateTime.now().toIso8601String();

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', entity.id)
          .select()
          .single();

      return MotivoCancelacionSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar motivo de cancelación: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar motivo de cancelación: $e');
    }
  }

  // ========== OPERACIONES BATCH ==========

  @override
  Future<List<MotivoCancelacionEntity>> createBatch(
    List<MotivoCancelacionEntity> entities,
  ) async {
    try {
      final List<Map<String, dynamic>> models = entities
          .map((MotivoCancelacionEntity e) =>
              MotivoCancelacionSupabaseModel.fromEntity(e).toJson())
          .toList();

      final List<dynamic> response = await _supabase
          .from(tableName)
          .insert(models)
          .select();

      return response
          .map((dynamic json) => MotivoCancelacionSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear motivos en lote: $e');
    }
  }

  @override
  Future<List<MotivoCancelacionEntity>> updateBatch(
    List<MotivoCancelacionEntity> entities,
  ) async {
    try {
      final List<MotivoCancelacionEntity> updated = <MotivoCancelacionEntity>[];
      for (final MotivoCancelacionEntity entity in entities) {
        final MotivoCancelacionEntity result = await update(entity);
        updated.add(result);
      }
      return updated;
    } catch (e) {
      throw Exception('Error al actualizar motivos en lote: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar motivos en lote: $e');
    }
  }

  // ========== CONTEO Y EXISTENCIA ==========

  @override
  Future<int> count() async {
    try {
      final dynamic response = await _supabase
          .from(tableName)
          .select()
          .count();

      return response.count as int;
    } catch (e) {
      throw Exception('Error al contar motivos de cancelación: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final Map<String, dynamic>? response =
          await _supabase.from(tableName).select('id').eq('id', id).maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia del motivo: $e');
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
      throw Exception('Error al limpiar motivos de cancelación: $e');
    }
  }

  // ========== STREAMING / REAL-TIME ==========

  @override
  Stream<List<MotivoCancelacionEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre')
        .map((List<Map<String, dynamic>> data) {
          return data
              .map((Map<String, dynamic> json) =>
                  MotivoCancelacionSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<MotivoCancelacionEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return MotivoCancelacionSupabaseModel.fromJson(data.first).toEntity();
        });
  }
}
