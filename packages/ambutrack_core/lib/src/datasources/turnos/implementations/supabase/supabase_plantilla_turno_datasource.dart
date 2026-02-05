import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/plantilla_turno_entity.dart';
import '../../models/plantilla_turno_supabase_model.dart';
import '../../plantilla_turno_contract.dart';

/// Implementación de PlantillaTurnoDataSource usando Supabase
class SupabasePlantillaTurnoDataSource implements PlantillaTurnoDataSource {
  SupabasePlantillaTurnoDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String tableName = 'plantillas_turno';

  @override
  Future<List<PlantillaTurnoEntity>> getAll({int? limit, int? offset}) async {
    dynamic query = _supabase.from(tableName).select();

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 100) - 1);
    } else if (limit != null) {
      query = query.limit(limit);
    }

    final dynamic response = await query.order('nombre', ascending: true);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(PlantillaTurnoSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<PlantillaTurnoEntity?> getById(String id) async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final Map<String, dynamic> data = response as Map<String, dynamic>;
    return PlantillaTurnoSupabaseModel.fromJson(data).toEntity();
  }

  @override
  Future<PlantillaTurnoEntity> create(PlantillaTurnoEntity entity) async {
    final PlantillaTurnoSupabaseModel model =
        PlantillaTurnoSupabaseModel.fromEntity(entity);

    final Map<String, dynamic> data = model.toJsonForInsert();

    final dynamic response =
        await _supabase.from(tableName).insert(data).select().single();

    final Map<String, dynamic> result = response as Map<String, dynamic>;
    return PlantillaTurnoSupabaseModel.fromJson(result).toEntity();
  }

  @override
  Future<PlantillaTurnoEntity> update(PlantillaTurnoEntity entity) async {
    final PlantillaTurnoSupabaseModel model =
        PlantillaTurnoSupabaseModel.fromEntity(entity);

    final Map<String, dynamic> data = model.toJson()
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');

    final dynamic response = await _supabase
        .from(tableName)
        .update(data)
        .eq('id', entity.id)
        .select()
        .single();

    final Map<String, dynamic> result = response as Map<String, dynamic>;
    return PlantillaTurnoSupabaseModel.fromJson(result).toEntity();
  }

  @override
  Future<void> delete(String id) async {
    // Soft delete
    await _supabase.from(tableName).update(<String, dynamic>{
      'activo': false,
    }).eq('id', id);
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    // Soft delete batch
    await _supabase.from(tableName).update(<String, dynamic>{
      'activo': false,
    }).inFilter('id', ids);
  }

  @override
  Future<int> count() async {
    final response = await _supabase
        .from(tableName)
        .select('id')
        .count(CountOption.exact);
    return response.count;
  }

  @override
  Stream<List<PlantillaTurnoEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre', ascending: true)
        .map((List<Map<String, dynamic>> data) {
          return data
              .map(PlantillaTurnoSupabaseModel.fromJson)
              .map((model) => model.toEntity())
              .toList();
        });
  }

  @override
  Stream<PlantillaTurnoEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            return null;
          }
          return PlantillaTurnoSupabaseModel.fromJson(data.first).toEntity();
        });
  }

  @override
  Future<void> clear() async {
    await _supabase.from(tableName).delete().neq('id', '');
  }

  @override
  Future<List<PlantillaTurnoEntity>> createBatch(
    List<PlantillaTurnoEntity> entities,
  ) async {
    final List<Map<String, dynamic>> dataList = entities.map((entity) {
      final model = PlantillaTurnoSupabaseModel.fromEntity(entity);
      return model.toJsonForInsert();
    }).toList();

    final dynamic response =
        await _supabase.from(tableName).insert(dataList).select();

    final List<Map<String, dynamic>> results =
        (response as List).cast<Map<String, dynamic>>();

    return results
        .map(PlantillaTurnoSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<bool> exists(String id) async {
    final response = await _supabase
        .from(tableName)
        .select('id')
        .eq('id', id)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<List<PlantillaTurnoEntity>> updateBatch(
    List<PlantillaTurnoEntity> entities,
  ) async {
    final List<PlantillaTurnoEntity> updated = [];

    for (final entity in entities) {
      final result = await update(entity);
      updated.add(result);
    }

    return updated;
  }

  // ===== MÉTODOS ESPECIALIZADOS =====

  @override
  Future<List<PlantillaTurnoEntity>> getActivos() async {
    final dynamic response = await _supabase
        .from(tableName)
        .select()
        .eq('activo', true)
        .order('nombre', ascending: true);

    final List<Map<String, dynamic>> data =
        (response as List).cast<Map<String, dynamic>>();

    return data
        .map(PlantillaTurnoSupabaseModel.fromJson)
        .map((model) => model.toEntity())
        .toList();
  }
}
