import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/tipo_vehiculo_entity.dart';
import '../../models/tipo_vehiculo_supabase_model.dart';
import '../../tipo_vehiculo_contract.dart';

/// Implementación Supabase del datasource de tipos de vehículo
class SupabaseTipoVehiculoDataSource implements TipoVehiculoDataSource {
  SupabaseTipoVehiculoDataSource() : _client = Supabase.instance.client;

  final SupabaseClient _client;
  static const String _tableName = 'tipos_vehiculo';

  @override
  Future<List<TipoVehiculoEntity>> getAll({int? limit, int? offset}) async {
    try {
      var query = _client.from(_tableName).select().order('orden', ascending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final List<Map<String, dynamic>> data = await query;

      return data
          .map((Map<String, dynamic> json) => TipoVehiculoSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener tipos de vehículo: $e');
    }
  }

  @override
  Future<TipoVehiculoEntity?> getById(String id) async {
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return TipoVehiculoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      if (e.toString().contains('PGRST116')) {
        return null;
      }
      throw Exception('Error al obtener tipo de vehículo por ID: $e');
    }
  }

  @override
  Future<TipoVehiculoEntity> create(TipoVehiculoEntity entity) async {
    try {
      final model = TipoVehiculoSupabaseModel.fromEntity(entity);
      final json = model.toJson();

      json.remove('id');
      json.remove('created_at');

      final data = await _client
          .from(_tableName)
          .insert(json)
          .select()
          .single();

      return TipoVehiculoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      throw Exception('Error al crear tipo de vehículo: $e');
    }
  }

  @override
  Future<TipoVehiculoEntity> update(TipoVehiculoEntity entity) async {
    try {
      final model = TipoVehiculoSupabaseModel.fromEntity(entity);
      final json = model.toJson();

      json.remove('id');
      json.remove('created_at');

      final data = await _client
          .from(_tableName)
          .update(json)
          .eq('id', entity.id)
          .select()
          .single();

      return TipoVehiculoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar tipo de vehículo: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar tipo de vehículo: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _client.from(_tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar tipos de vehículo en lote: $e');
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
      throw Exception('Error al contar tipos de vehículo: $e');
    }
  }

  @override
  Stream<List<TipoVehiculoEntity>> watchAll() {
    return _client
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('orden', ascending: true)
        .map((List<Map<String, dynamic>> data) => data
            .map((Map<String, dynamic> json) => TipoVehiculoSupabaseModel.fromJson(json).toEntity())
            .toList());
  }

  @override
  Stream<TipoVehiculoEntity?> watchById(String id) {
    return _client
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) return null;
          return TipoVehiculoSupabaseModel.fromJson(data.first).toEntity();
        });
  }

  @override
  Future<List<TipoVehiculoEntity>> getActivos() async {
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('orden', ascending: true);

      return data
          .map((Map<String, dynamic> json) => TipoVehiculoSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener tipos de vehículo activos: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _client.from(_tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Error al limpiar tipos de vehículo: $e');
    }
  }

  @override
  Future<List<TipoVehiculoEntity>> createBatch(
    List<TipoVehiculoEntity> entities,
  ) async {
    try {
      final List<Map<String, dynamic>> dataList = entities.map((entity) {
        final model = TipoVehiculoSupabaseModel.fromEntity(entity);
        final json = model.toJson();
        json.remove('id');
        json.remove('created_at');
        return json;
      }).toList();

      final data = await _client
          .from(_tableName)
          .insert(dataList)
          .select();

      return data
          .map((json) => TipoVehiculoSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear tipos de vehículo en lote: $e');
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
      throw Exception('Error al verificar existencia de tipo de vehículo: $e');
    }
  }

  @override
  Future<List<TipoVehiculoEntity>> updateBatch(
    List<TipoVehiculoEntity> entities,
  ) async {
    try {
      final List<TipoVehiculoEntity> updated = [];

      for (final entity in entities) {
        final result = await update(entity);
        updated.add(result);
      }

      return updated;
    } catch (e) {
      throw Exception('Error al actualizar tipos de vehículo en lote: $e');
    }
  }
}
