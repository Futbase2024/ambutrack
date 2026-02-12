import 'package:supabase_flutter/supabase_flutter.dart';

import '../../motivo_traslado_contract.dart';
import '../../entities/motivo_traslado_entity.dart';
import '../../models/motivo_traslado_supabase_model.dart';

/// Implementación de [MotivoTrasladoDataSource] usando Supabase
///
/// Proporciona operaciones CRUD para motivos de traslado en PostgreSQL vía Supabase.
class SupabaseMotivoTrasladoDataSource implements MotivoTrasladoDataSource {
  SupabaseMotivoTrasladoDataSource({
    SupabaseClient? supabase,
    this.tableName = 'tmotivos_traslado',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  @override
  Future<List<MotivoTrasladoEntity>> getAll({
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
          .map((dynamic json) => MotivoTrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener motivos de traslado: $e');
    }
  }

  @override
  Future<MotivoTrasladoEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return MotivoTrasladoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener motivo de traslado por ID: $e');
    }
  }

  @override
  Future<MotivoTrasladoEntity> create(MotivoTrasladoEntity entity) async {
    try {
      final MotivoTrasladoSupabaseModel model =
          MotivoTrasladoSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return MotivoTrasladoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear motivo de traslado: $e');
    }
  }

  @override
  Future<MotivoTrasladoEntity> update(MotivoTrasladoEntity entity) async {
    try {
      final MotivoTrasladoSupabaseModel model =
          MotivoTrasladoSupabaseModel.fromEntity(entity);

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

      return MotivoTrasladoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar motivo de traslado: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar motivo de traslado: $e');
    }
  }

  @override
  Future<List<MotivoTrasladoEntity>> createBatch(
    List<MotivoTrasladoEntity> entities,
  ) async {
    try {
      final List<Map<String, dynamic>> dataList = entities.map((entity) {
        final MotivoTrasladoSupabaseModel model =
            MotivoTrasladoSupabaseModel.fromEntity(entity);
        final Map<String, dynamic> data = model.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        return data;
      }).toList();

      final List<dynamic> response = await _supabase
          .from(tableName)
          .insert(dataList)
          .select();

      return response
          .map((dynamic json) => MotivoTrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear motivos en lote: $e');
    }
  }

  @override
  Future<List<MotivoTrasladoEntity>> updateBatch(
    List<MotivoTrasladoEntity> entities,
  ) async {
    try {
      final List<MotivoTrasladoEntity> results = [];
      for (final entity in entities) {
        final updated = await update(entity);
        results.add(updated);
      }
      return results;
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

  @override
  Future<int> count() async {
    try {
      final dynamic response = await _supabase
          .from(tableName)
          .select()
          .count();

      return response.count as int;
    } catch (e) {
      throw Exception('Error al contar motivos de traslado: $e');
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
      throw Exception('Error al limpiar motivos de traslado: $e');
    }
  }

  @override
  Stream<List<MotivoTrasladoEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre')
        .map((List<Map<String, dynamic>> data) {
          return data
              .map((Map<String, dynamic> json) =>
                  MotivoTrasladoSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<MotivoTrasladoEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return MotivoTrasladoSupabaseModel.fromJson(data.first).toEntity();
        });
  }
}
