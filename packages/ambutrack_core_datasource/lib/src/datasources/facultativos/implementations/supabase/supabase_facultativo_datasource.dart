import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/facultativo_entity.dart';
import '../../facultativo_contract.dart';
import '../../models/facultativo_supabase_model.dart';

/// Implementación de Supabase para el datasource de facultativos
///
/// Gestiona operaciones CRUD en la tabla tfacultativos con JOIN
/// a tespecialidades para obtener el nombre de la especialidad.
class SupabaseFacultativoDataSource implements FacultativoDataSource {
  SupabaseFacultativoDataSource({
    SupabaseClient? supabase,
    this.tableName = 'tfacultativos',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  /// Query base con JOIN a especialidades
  ///
  /// IMPORTANTE: Usar sintaxis correcta para JOIN en Supabase:
  /// tespecialidades!especialidad_id(nombre)
  String get _baseQuery => '''
    id,
    created_at,
    updated_at,
    nombre,
    apellidos,
    num_colegiado,
    especialidad_id,
    telefono,
    email,
    activo,
    tespecialidades!especialidad_id(nombre)
  ''';

  @override
  Future<List<FacultativoEntity>> getAll({int? limit, int? offset}) async {
    dynamic query = _supabase.from(tableName).select(_baseQuery);

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 100) - 1);
    } else if (limit != null) {
      query = query.limit(limit);
    }

    final dynamic response = await query.order('nombre', ascending: true);

    return (response as List)
        .map((json) => FacultativoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<FacultativoEntity?> getById(String id) async {
    final response = await _supabase
        .from(tableName)
        .select(_baseQuery)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return FacultativoSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<FacultativoEntity> create(FacultativoEntity entity) async {
    final model = FacultativoSupabaseModel.fromEntity(entity);
    final json = model.toJson();

    // Supabase genera automáticamente id, created_at, updated_at
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');

    final response =
        await _supabase.from(tableName).insert(json).select(_baseQuery).single();

    return FacultativoSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<FacultativoEntity> update(FacultativoEntity entity) async {
    final model = FacultativoSupabaseModel.fromEntity(entity);
    final json = model.toJson();

    // No actualizar created_at
    json.remove('created_at');
    // Actualizar updated_at al momento actual
    json['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from(tableName)
        .update(json)
        .eq('id', entity.id)
        .select(_baseQuery)
        .single();

    return FacultativoSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<void> delete(String id) async {
    await _supabase.from(tableName).delete().eq('id', id);
  }

  @override
  Future<List<FacultativoEntity>> createBatch(
    List<FacultativoEntity> entities,
  ) async {
    final jsonList = entities.map((entity) {
      final model = FacultativoSupabaseModel.fromEntity(entity);
      final json = model.toJson();
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');
      return json;
    }).toList();

    final response =
        await _supabase.from(tableName).insert(jsonList).select(_baseQuery);

    return (response as List)
        .map((json) => FacultativoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<FacultativoEntity>> updateBatch(
    List<FacultativoEntity> entities,
  ) async {
    final results = <FacultativoEntity>[];

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
  Stream<List<FacultativoEntity>> watchAll() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: ['id'])
        .map((rows) {
          return rows
              .map((json) => FacultativoSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<FacultativoEntity?> watchById(String id) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((rows) {
          if (rows.isEmpty) return null;
          return FacultativoSupabaseModel.fromJson(rows.first).toEntity();
        });
  }

  // ========== MÉTODOS ESPECÍFICOS ==========

  @override
  Future<List<FacultativoEntity>> getActivos() async {
    final response = await _supabase
        .from(tableName)
        .select(_baseQuery)
        .eq('activo', true)
        .order('nombre');

    return (response as List)
        .map((json) => FacultativoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<FacultativoEntity>> filterByEspecialidad(
    String especialidadId,
  ) async {
    final response = await _supabase
        .from(tableName)
        .select(_baseQuery)
        .eq('especialidad_id', especialidadId)
        .order('nombre');

    return (response as List)
        .map((json) => FacultativoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }
}
