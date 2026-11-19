import 'package:supabase_flutter/supabase_flutter.dart';

import '../../comunidad_autonoma_contract.dart';
import '../../entities/comunidad_autonoma_entity.dart';
import '../../models/comunidad_autonoma_supabase_model.dart';

/// Implementación de [ComunidadAutonomaDataSource] usando Supabase
class SupabaseComunidadAutonomaDataSource
    implements ComunidadAutonomaDataSource {
  SupabaseComunidadAutonomaDataSource({
    SupabaseClient? supabase,
    this.tableName = 'tcomunidades',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  @override
  Future<List<ComunidadAutonomaEntity>> getAll({
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
          .map((dynamic json) =>
              ComunidadAutonomaSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener comunidades autónomas: $e');
    }
  }

  @override
  Future<ComunidadAutonomaEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ComunidadAutonomaSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener comunidad autónoma por ID: $e');
    }
  }

  @override
  Future<ComunidadAutonomaEntity> create(
    ComunidadAutonomaEntity entity,
  ) async {
    try {
      final ComunidadAutonomaSupabaseModel model =
          ComunidadAutonomaSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return ComunidadAutonomaSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear comunidad autónoma: $e');
    }
  }

  @override
  Future<ComunidadAutonomaEntity> update(
    ComunidadAutonomaEntity entity,
  ) async {
    try {
      final ComunidadAutonomaSupabaseModel model =
          ComunidadAutonomaSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', entity.id)
          .select()
          .single();

      return ComunidadAutonomaSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar comunidad autónoma: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar comunidad autónoma: $e');
    }
  }

  @override
  Future<List<ComunidadAutonomaEntity>> createBatch(
    List<ComunidadAutonomaEntity> entities,
  ) async {
    try {
      final List<Map<String, dynamic>> dataList = entities.map((entity) {
        final ComunidadAutonomaSupabaseModel model =
            ComunidadAutonomaSupabaseModel.fromEntity(entity);
        final Map<String, dynamic> data = model.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        return data;
      }).toList();

      final dynamic response =
          await _supabase.from(tableName).insert(dataList).select();

      return (response as List)
          .map((dynamic json) =>
              ComunidadAutonomaSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear comunidades en lote: $e');
    }
  }

  @override
  Future<List<ComunidadAutonomaEntity>> updateBatch(
    List<ComunidadAutonomaEntity> entities,
  ) async {
    try {
      final List<ComunidadAutonomaEntity> updated = <ComunidadAutonomaEntity>[];

      for (final ComunidadAutonomaEntity entity in entities) {
        final ComunidadAutonomaEntity result = await update(entity);
        updated.add(result);
      }

      return updated;
    } catch (e) {
      throw Exception('Error al actualizar comunidades en lote: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar comunidades en lote: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final response =
          await _supabase.from(tableName).select('id').count(CountOption.exact);

      return response.count;
    } catch (e) {
      throw Exception('Error al contar comunidades: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final response =
          await _supabase.from(tableName).select('id').eq('id', id).maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia de comunidad: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Error al limpiar comunidades: $e');
    }
  }

  @override
  Stream<List<ComunidadAutonomaEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre')
        .map((List<Map<String, dynamic>> rows) => rows
            .map((Map<String, dynamic> row) =>
                ComunidadAutonomaSupabaseModel.fromJson(row).toEntity())
            .toList());
  }

  @override
  Stream<ComunidadAutonomaEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> rows) {
          if (rows.isEmpty) return null;
          return ComunidadAutonomaSupabaseModel.fromJson(rows.first).toEntity();
        });
  }
}
