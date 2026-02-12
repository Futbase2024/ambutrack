import 'package:supabase_flutter/supabase_flutter.dart';

import '../../bases_contract.dart';
import '../../entities/base_entity.dart';

/// Implementación de Supabase para el datasource de bases
///
/// Proporciona operaciones CRUD y consultas específicas usando Supabase como backend
class SupabaseBasesDataSource implements BasesDataSource {
  /// Cliente de Supabase
  final SupabaseClient _supabase;

  /// Nombre de la tabla en Supabase
  final String _tableName;

  /// Constructor
  SupabaseBasesDataSource({
    SupabaseClient? supabase,
    String tableName = 'bases',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  // ==================== CRUD BÁSICO ====================

  @override
  Future<List<BaseCentroEntity>> getAll({int? limit, int? offset}) async {
    try {
      var query = _supabase
          .from(_tableName)
          .select()
          .order('nombre', ascending: true);

      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => BaseCentroEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener bases: $e');
    }
  }

  @override
  Future<BaseCentroEntity?> getById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return BaseCentroEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener base por ID: $e');
    }
  }

  @override
  Future<BaseCentroEntity> create(BaseCentroEntity entity) async {
    try {
      final data = entity.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      data.remove('tipo');
      data.remove('codigo'); // Campo no existe en Supabase

      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return BaseCentroEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear base: $e');
    }
  }

  @override
  Future<BaseCentroEntity> update(BaseCentroEntity entity) async {
    try {
      final data = entity.toJson();
      data.remove('created_at');
      data.remove('tipo');
      data.remove('codigo'); // Campo no existe en Supabase
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', entity.id)
          .select()
          .single();

      return BaseCentroEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar base: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar base: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia: $e');
    }
  }

  // ==================== STREAMING ====================

  @override
  Stream<List<BaseCentroEntity>> watchAll() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('nombre', ascending: true)
        .map((data) => data
            .map((json) => BaseCentroEntity.fromJson(json))
            .toList());
  }

  @override
  Stream<BaseCentroEntity?> watchById(String id) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) {
          if (data.isEmpty) return null;
          return BaseCentroEntity.fromJson(data.first);
        });
  }

  // ==================== OPERACIONES BATCH ====================

  @override
  Future<List<BaseCentroEntity>> createBatch(List<BaseCentroEntity> entities) async {
    try {
      final dataList = entities.map((entity) {
        final data = entity.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        data.remove('tipo');
        data.remove('codigo'); // Campo no existe en Supabase
        return data;
      }).toList();

      final response = await _supabase
          .from(_tableName)
          .insert(dataList)
          .select();

      return (response as List<dynamic>)
          .map((json) => BaseCentroEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error en createBatch: $e');
    }
  }

  @override
  Future<List<BaseCentroEntity>> updateBatch(List<BaseCentroEntity> entities) async {
    try {
      final results = <BaseCentroEntity>[];
      for (final entity in entities) {
        final updated = await update(entity);
        results.add(updated);
      }
      return results;
    } catch (e) {
      throw Exception('Error en updateBatch: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .inFilter('id', ids);
    } catch (e) {
      throw Exception('Error en deleteBatch: $e');
    }
  }

  // ==================== UTILIDADES ====================

  @override
  Future<int> count() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .count();

      return response.count;
    } catch (e) {
      throw Exception('Error al contar bases: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000'); // Elimina todos
    } catch (e) {
      throw Exception('Error al limpiar bases: $e');
    }
  }

  // ==================== MÉTODOS ESPECÍFICOS ====================

  @override
  Future<List<BaseCentroEntity>> getActivas() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('nombre', ascending: true);

      return (response as List<dynamic>)
          .map((json) => BaseCentroEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener bases activas: $e');
    }
  }

  @override
  Future<List<BaseCentroEntity>> getByPoblacion(String poblacionId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('poblacion_id', poblacionId)
          .order('nombre', ascending: true);

      return (response as List<dynamic>)
          .map((json) => BaseCentroEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener bases por población: $e');
    }
  }

  @override
  Future<BaseCentroEntity> deactivateBase(String baseId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({
            'activo': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', baseId)
          .select()
          .single();

      return BaseCentroEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error al desactivar base: $e');
    }
  }

  @override
  Future<BaseCentroEntity> reactivateBase(String baseId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({
            'activo': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', baseId)
          .select()
          .single();

      return BaseCentroEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error al reactivar base: $e');
    }
  }
}
