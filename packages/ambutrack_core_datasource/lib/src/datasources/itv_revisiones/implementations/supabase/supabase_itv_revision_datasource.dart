import 'package:supabase_flutter/supabase_flutter.dart';

import '../../itv_revision_contract.dart';
import '../../entities/itv_revision_entity.dart';
import '../../models/itv_revision_supabase_model.dart';

/// Implementación de Supabase para ItvRevisionDataSource
class SupabaseItvRevisionDataSource implements ItvRevisionDataSource {
  SupabaseItvRevisionDataSource({
    SupabaseClient? supabase,
    String tableName = 'titv_revisiones',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  final SupabaseClient _supabase;
  final String _tableName;

  @override
  Future<List<ItvRevisionEntity>> getAll({
    int? limit,
    int? offset,
  }) async {
    var query = _supabase.from(_tableName).select().order('fecha', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 100) - 1);
    }

    final List<dynamic> response = await query;

    return response
        .map((dynamic json) =>
            ItvRevisionSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<ItvRevisionEntity> getById(String id) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('id', id)
        .single();

    return ItvRevisionSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<ItvRevisionEntity> create(ItvRevisionEntity entity) async {
    final model = ItvRevisionSupabaseModel.fromEntity(entity);
    final response = await _supabase
        .from(_tableName)
        .insert(model.toJson())
        .select()
        .single();

    return ItvRevisionSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<ItvRevisionEntity> update(ItvRevisionEntity entity) async {
    final model = ItvRevisionSupabaseModel.fromEntity(entity);
    final response = await _supabase
        .from(_tableName)
        .update(model.toJson())
        .eq('id', entity.id)
        .select()
        .single();

    return ItvRevisionSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<void> delete(String id) async {
    await _supabase.from(_tableName).delete().eq('id', id);
  }

  @override
  Stream<List<ItvRevisionEntity>> watchAll() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('fecha', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          return data
              .map((Map<String, dynamic> json) =>
                  ItvRevisionSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<ItvRevisionEntity> watchById(String id) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            throw Exception('ItvRevision con ID $id no encontrada');
          }
          return ItvRevisionSupabaseModel.fromJson(data.first).toEntity();
        });
  }

  @override
  Future<int> count() async {
    final response = await _supabase
        .from(_tableName)
        .select('id')
        .count();

    return response.count;
  }

  @override
  Future<void> clear() async {
    await _supabase.from(_tableName).delete().neq('id', '');
  }

  @override
  Future<List<ItvRevisionEntity>> createBatch(List<ItvRevisionEntity> entities) async {
    final models = entities.map((e) => ItvRevisionSupabaseModel.fromEntity(e).toJson()).toList();
    final response = await _supabase.from(_tableName).insert(models).select();

    return (response as List)
        .map((dynamic json) =>
            ItvRevisionSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<ItvRevisionEntity>> updateBatch(List<ItvRevisionEntity> entities) async {
    final List<ItvRevisionEntity> results = <ItvRevisionEntity>[];

    for (final entity in entities) {
      final updated = await update(entity);
      results.add(updated);
    }

    return results;
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    await _supabase.from(_tableName).delete().inFilter('id', ids);
  }

  @override
  Future<bool> exists(String id) async {
    final response = await _supabase
        .from(_tableName)
        .select('id')
        .eq('id', id)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<List<ItvRevisionEntity>> getByVehiculo(String vehiculoId) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('vehiculo_id', vehiculoId)
        .order('fecha', ascending: false);

    return (response as List)
        .map((dynamic json) =>
            ItvRevisionSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<ItvRevisionEntity>> getProximasVencer(int dias) async {
    final now = DateTime.now();
    final fechaLimite = now.add(Duration(days: dias));

    final response = await _supabase
        .from(_tableName)
        .select()
        .gte('fecha_vencimiento', now.toIso8601String())
        .lte('fecha_vencimiento', fechaLimite.toIso8601String())
        .order('fecha_vencimiento', ascending: true);

    return (response as List)
        .map((dynamic json) =>
            ItvRevisionSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }
}
