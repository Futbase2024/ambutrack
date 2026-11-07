import 'package:supabase_flutter/supabase_flutter.dart';
import '../../entities/mantenimiento_entity.dart';
import '../../mantenimiento_contract.dart';
import '../../models/mantenimiento_supabase_model.dart';

/// Implementación Supabase del datasource de Mantenimientos
class SupabaseMantenimientoDataSource implements MantenimientoDataSource {
  SupabaseMantenimientoDataSource({
    SupabaseClient? supabase,
    this.tableName = 'tmantenimientos',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  @override
  Future<List<MantenimientoEntity>> getAll({int? limit, int? offset}) async {
    try {
      dynamic query = _supabase.from(tableName).select();

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('fecha', ascending: false);
      final List<Map<String, dynamic>> data =
          (response as List).cast<Map<String, dynamic>>();

      return data
          .map(MantenimientoSupabaseModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos: $e');
    }
  }

  @override
  Future<MantenimientoEntity?> getById(String id) async {
    try {
      final dynamic response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final Map<String, dynamic> data = response as Map<String, dynamic>;
      return MantenimientoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      throw Exception('Error al obtener mantenimiento por ID: $e');
    }
  }

  @override
  Future<MantenimientoEntity> create(MantenimientoEntity entity) async {
    try {
      final model = MantenimientoSupabaseModel.fromEntity(entity);
      final dynamic response = await _supabase
          .from(tableName)
          .insert(model.toJson())
          .select()
          .single();

      final Map<String, dynamic> data = response as Map<String, dynamic>;
      return MantenimientoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      throw Exception('Error al crear mantenimiento: $e');
    }
  }

  @override
  Future<MantenimientoEntity> update(MantenimientoEntity entity) async {
    try {
      final model = MantenimientoSupabaseModel.fromEntity(entity);
      final dynamic response = await _supabase
          .from(tableName)
          .update(model.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      final Map<String, dynamic> data = response as Map<String, dynamic>;
      return MantenimientoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar mantenimiento: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar mantenimiento: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }

    try {
      await _supabase.from(tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar mantenimientos en batch: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final dynamic response =
          await _supabase.from(tableName).select().count();
      return response.count as int;
    } catch (e) {
      throw Exception('Error al contar mantenimientos: $e');
    }
  }

  @override
  Stream<List<MantenimientoEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('fecha', ascending: false)
        .map((List<Map<String, dynamic>> data) => data
            .map(MantenimientoSupabaseModel.fromJson)
            .map((model) => model.toEntity())
            .toList());
  }

  @override
  Stream<MantenimientoEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return MantenimientoSupabaseModel.fromJson(data.first).toEntity();
        });
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Error al limpiar mantenimientos: $e');
    }
  }

  @override
  Future<List<MantenimientoEntity>> createBatch(
    List<MantenimientoEntity> entities,
  ) async {
    if (entities.isEmpty) {
      return <MantenimientoEntity>[];
    }

    try {
      final List<Map<String, dynamic>> data = entities
          .map(MantenimientoSupabaseModel.fromEntity)
          .map((model) => model.toJson())
          .toList();

      final dynamic response =
          await _supabase.from(tableName).insert(data).select();

      final List<Map<String, dynamic>> result =
          (response as List).cast<Map<String, dynamic>>();

      return result
          .map(MantenimientoSupabaseModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear mantenimientos en batch: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final dynamic response = await _supabase
          .from(tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia de mantenimiento: $e');
    }
  }

  @override
  Future<List<MantenimientoEntity>> updateBatch(
    List<MantenimientoEntity> entities,
  ) async {
    if (entities.isEmpty) {
      return <MantenimientoEntity>[];
    }

    try {
      final List<MantenimientoEntity> updated = <MantenimientoEntity>[];

      for (final MantenimientoEntity entity in entities) {
        final MantenimientoEntity result = await update(entity);
        updated.add(result);
      }

      return updated;
    } catch (e) {
      throw Exception('Error al actualizar mantenimientos en batch: $e');
    }
  }

  // ===== MÉTODOS ESPECIALIZADOS =====

  @override
  Future<List<MantenimientoEntity>> getByVehiculo(String vehiculoId) async {
    try {
      final dynamic response = await _supabase
          .from(tableName)
          .select()
          .eq('vehiculo_id', vehiculoId)
          .order('fecha', ascending: false);

      final List<Map<String, dynamic>> data =
          (response as List).cast<Map<String, dynamic>>();

      return data
          .map(MantenimientoSupabaseModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos por vehículo: $e');
    }
  }

  @override
  Future<List<MantenimientoEntity>> getProximos(int dias) async {
    try {
      final DateTime hoy = DateTime.now();
      final DateTime futuro = hoy.add(Duration(days: dias));

      final dynamic response = await _supabase
          .from(tableName)
          .select()
          .eq('estado', 'programado')
          .gte('fecha_programada', hoy.toIso8601String())
          .lte('fecha_programada', futuro.toIso8601String())
          .order('fecha_programada', ascending: true);

      final List<Map<String, dynamic>> data =
          (response as List).cast<Map<String, dynamic>>();

      return data
          .map(MantenimientoSupabaseModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos próximos: $e');
    }
  }

  @override
  Future<List<MantenimientoEntity>> getVencidos() async {
    try {
      final DateTime hoy = DateTime.now();

      final dynamic response = await _supabase
          .from(tableName)
          .select()
          .eq('estado', 'programado')
          .lt('fecha_programada', hoy.toIso8601String())
          .order('fecha_programada', ascending: true);

      final List<Map<String, dynamic>> data =
          (response as List).cast<Map<String, dynamic>>();

      return data
          .map(MantenimientoSupabaseModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos vencidos: $e');
    }
  }
}
