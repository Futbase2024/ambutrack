import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/tipo_paciente_entity.dart';
import '../../models/tipo_paciente_supabase_model.dart';
import '../../tipo_paciente_contract.dart';

/// Implementación de Supabase para el datasource de tipos de paciente
///
/// Gestiona operaciones CRUD en la tabla ttipos_paciente
class SupabaseTipoPacienteDataSource implements TipoPacienteDataSource {
  SupabaseTipoPacienteDataSource({
    SupabaseClient? supabase,
    this.tableName = 'ttipos_paciente',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  @override
  Future<List<TipoPacienteEntity>> getAll({int? limit, int? offset}) async {
    dynamic query = _supabase.from(tableName).select();

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 100) - 1);
    } else if (limit != null) {
      query = query.limit(limit);
    }

    final dynamic response = await query.order('nombre', ascending: true);

    return (response as List)
        .map((json) => TipoPacienteSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<TipoPacienteEntity?> getById(String id) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return TipoPacienteSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<TipoPacienteEntity> create(TipoPacienteEntity entity) async {
    final model = TipoPacienteSupabaseModel.fromEntity(entity);
    final json = model.toJson();

    // Supabase genera automáticamente id, created_at, updated_at
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');

    final response =
        await _supabase.from(tableName).insert(json).select().single();

    return TipoPacienteSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<TipoPacienteEntity> update(TipoPacienteEntity entity) async {
    final model = TipoPacienteSupabaseModel.fromEntity(entity);
    final json = model.toJson();

    // No actualizar created_at
    json.remove('created_at');
    // Actualizar updated_at al momento actual
    json['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from(tableName)
        .update(json)
        .eq('id', entity.id)
        .select()
        .single();

    return TipoPacienteSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<void> delete(String id) async {
    await _supabase.from(tableName).delete().eq('id', id);
  }

  @override
  Future<List<TipoPacienteEntity>> createBatch(
    List<TipoPacienteEntity> entities,
  ) async {
    final jsonList = entities.map((entity) {
      final model = TipoPacienteSupabaseModel.fromEntity(entity);
      final json = model.toJson();
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');
      return json;
    }).toList();

    final response =
        await _supabase.from(tableName).insert(jsonList).select();

    return (response as List)
        .map((json) => TipoPacienteSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<TipoPacienteEntity>> updateBatch(
    List<TipoPacienteEntity> entities,
  ) async {
    final results = <TipoPacienteEntity>[];

    for (final entity in entities) {
      final updated = await update(entity);
      results.add(updated);
    }

    return results;
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    await _supabase.from(tableName).delete().inFilter('id', ids);
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
  Future<bool> exists(String id) async {
    final response =
        await _supabase.from(tableName).select('id').eq('id', id).maybeSingle();

    return response != null;
  }

  @override
  Future<void> clear() async {
    // ⚠️ PELIGROSO: Elimina TODOS los registros
    await _supabase.from(tableName).delete().neq('id', '');
  }

  @override
  Stream<List<TipoPacienteEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: ['id'])
        .map((rows) {
          return rows
              .map((json) => TipoPacienteSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<TipoPacienteEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((rows) {
          if (rows.isEmpty) return null;
          return TipoPacienteSupabaseModel.fromJson(rows.first).toEntity();
        });
  }

  // ========== MÉTODOS ESPECÍFICOS ==========

  @override
  Future<List<TipoPacienteEntity>> getActivos() async {
    final response = await _supabase
        .from(tableName)
        .select()
        .eq('activo', true)
        .order('nombre');

    return (response as List)
        .map((json) => TipoPacienteSupabaseModel.fromJson(json).toEntity())
        .toList();
  }
}
