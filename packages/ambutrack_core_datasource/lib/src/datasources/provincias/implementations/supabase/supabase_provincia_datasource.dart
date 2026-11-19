import 'package:supabase_flutter/supabase_flutter.dart';

import '../../provincia_contract.dart';
import '../../entities/provincia_entity.dart';
import '../../models/provincia_supabase_model.dart';

/// Implementación de [ProvinciaDataSource] usando Supabase
///
/// Proporciona operaciones CRUD para provincias en PostgreSQL vía Supabase.
/// Incluye JOIN con tabla tcomunidades para obtener el nombre de la comunidad autónoma.
class SupabaseProvinciaDataSource implements ProvinciaDataSource {
  SupabaseProvinciaDataSource({
    SupabaseClient? supabase,
    this.tableName = 'tprovincias',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  // ========== CRUD BÁSICO ==========

  @override
  Future<List<ProvinciaEntity>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = _supabase
          .from(tableName)
          .select('*, tcomunidades!comunidad_id(nombre)');

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('nombre', ascending: true);

      return (response as List)
          .map((dynamic json) =>
              ProvinciaSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener provincias: $e');
    }
  }

  @override
  Future<ProvinciaEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select('*, tcomunidades!comunidad_id(nombre)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ProvinciaSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener provincia por ID: $e');
    }
  }

  @override
  Future<ProvinciaEntity> create(ProvinciaEntity entity) async {
    try {
      final ProvinciaSupabaseModel model =
          ProvinciaSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson();
      data.remove('id'); // Supabase genera el ID
      data.remove('created_at'); // Supabase genera created_at
      data.remove('updated_at'); // Supabase genera updated_at
      data.remove('comunidad_autonoma'); // Campo calculado (JOIN)

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .insert(data)
          .select('*, tcomunidades!comunidad_id(nombre)')
          .single();

      return ProvinciaSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear provincia: $e');
    }
  }

  @override
  Future<ProvinciaEntity> update(ProvinciaEntity entity) async {
    try {
      final ProvinciaSupabaseModel model =
          ProvinciaSupabaseModel.fromEntity(entity);

      final Map<String, dynamic> data = model.toJson();
      data.remove('id'); // No se actualiza el ID
      data.remove('created_at'); // No se actualiza created_at
      data.remove('updated_at'); // Supabase actualiza automáticamente
      data.remove('comunidad_autonoma'); // Campo calculado (JOIN)

      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', entity.id)
          .select('*, tcomunidades!comunidad_id(nombre)')
          .single();

      return ProvinciaSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar provincia: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar provincia: $e');
    }
  }

  @override
  Future<List<ProvinciaEntity>> createBatch(
    List<ProvinciaEntity> entities,
  ) async {
    try {
      final List<Map<String, dynamic>> dataList = entities.map((entity) {
        final ProvinciaSupabaseModel model =
            ProvinciaSupabaseModel.fromEntity(entity);
        final Map<String, dynamic> data = model.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        data.remove('comunidad_autonoma');
        return data;
      }).toList();

      final dynamic response = await _supabase
          .from(tableName)
          .insert(dataList)
          .select('*, tcomunidades!comunidad_id(nombre)');

      return (response as List)
          .map((dynamic json) =>
              ProvinciaSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear provincias en lote: $e');
    }
  }

  @override
  Future<List<ProvinciaEntity>> updateBatch(
    List<ProvinciaEntity> entities,
  ) async {
    try {
      final List<ProvinciaEntity> updated = <ProvinciaEntity>[];

      for (final ProvinciaEntity entity in entities) {
        final ProvinciaEntity result = await update(entity);
        updated.add(result);
      }

      return updated;
    } catch (e) {
      throw Exception('Error al actualizar provincias en lote: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar provincias en lote: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final response =
          await _supabase.from(tableName).select('id').count(CountOption.exact);

      return response.count;
    } catch (e) {
      throw Exception('Error al contar provincias: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final response =
          await _supabase.from(tableName).select('id').eq('id', id).maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia de provincia: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Error al limpiar provincias: $e');
    }
  }

  // ========== STREAMS ==========

  @override
  Stream<List<ProvinciaEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre')
        .map((List<Map<String, dynamic>> rows) => rows
            .map((Map<String, dynamic> row) =>
                ProvinciaSupabaseModel.fromJson(row).toEntity())
            .toList());
  }

  @override
  Stream<ProvinciaEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> rows) {
          if (rows.isEmpty) return null;
          return ProvinciaSupabaseModel.fromJson(rows.first).toEntity();
        });
  }

  // ========== MÉTODOS ESPECÍFICOS ==========

  /// Obtiene todas las provincias de una comunidad autónoma
  Future<List<ProvinciaEntity>> getByComunidad(String comunidadId) async {
    try {
      final dynamic response = await _supabase
          .from(tableName)
          .select('*, tcomunidades!comunidad_id(nombre)')
          .eq('comunidad_id', comunidadId)
          .order('nombre', ascending: true);

      return (response as List)
          .map((dynamic json) =>
              ProvinciaSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener provincias por comunidad: $e');
    }
  }
}
