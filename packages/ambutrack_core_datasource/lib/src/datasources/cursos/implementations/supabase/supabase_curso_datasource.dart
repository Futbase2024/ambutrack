import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../cursos/entities/curso_entity.dart';
import '../../../cursos/curso_contract.dart';
import '../../../cursos/models/curso_supabase_model.dart';

/// Implementación de Supabase para cursos
class SupabaseCursoDataSource implements CursoDataSource {
  SupabaseCursoDataSource() : _supabase = Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableName = 'cursos';

  @override
  Future<List<CursoEntity>> getAll() async {
    debugPrint('📦 CursoDataSource: Obteniendo todos los registros...');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .order('nombre', ascending: true);

      debugPrint('📦 CursoDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((dynamic json) =>
              CursoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 CursoDataSource: ❌ Error al obtener registros: $e');
      rethrow;
    }
  }

  @override
  Future<CursoEntity> getById(String id) async {
    debugPrint('📦 CursoDataSource: Obteniendo por ID: $id');

    try {
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).select().eq('id', id).single();

      debugPrint('📦 CursoDataSource: ✅ Registro obtenido');

      return CursoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 CursoDataSource: ❌ Error al obtener por ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<CursoEntity>> getActivos() async {
    debugPrint('📦 CursoDataSource: Obteniendo cursos activos...');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('nombre', ascending: true);

      debugPrint('📦 CursoDataSource: ✅ ${data.length} registros activos');

      return data
          .map((dynamic json) =>
              CursoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 CursoDataSource: ❌ Error al obtener activos: $e');
      rethrow;
    }
  }

  @override
  Future<List<CursoEntity>> getByTipo(String tipo) async {
    debugPrint('📦 CursoDataSource: Obteniendo por tipo: $tipo');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo', tipo)
          .order('nombre', ascending: true);

      debugPrint('📦 CursoDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((dynamic json) =>
              CursoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 CursoDataSource: ❌ Error al obtener por tipo: $e');
      rethrow;
    }
  }

  @override
  Future<CursoEntity> create(CursoEntity entity) async {
    debugPrint('📦 CursoDataSource: Creando registro...');

    try {
      final CursoSupabaseModel model =
          CursoSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).insert(model.toJson()).select().single();

      debugPrint('📦 CursoDataSource: ✅ Registro creado');

      return CursoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 CursoDataSource: ❌ Error al crear: $e');
      rethrow;
    }
  }

  @override
  Future<CursoEntity> update(CursoEntity entity) async {
    debugPrint('📦 CursoDataSource: Actualizando registro: ${entity.id}');

    try {
      final CursoSupabaseModel model =
          CursoSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      debugPrint('📦 CursoDataSource: ✅ Registro actualizado');

      return CursoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 CursoDataSource: ❌ Error al actualizar: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 CursoDataSource: Eliminando registro: $id');

    try {
      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint('📦 CursoDataSource: ✅ Registro eliminado');
    } catch (e) {
      debugPrint('📦 CursoDataSource: ❌ Error al eliminar: $e');
      rethrow;
    }
  }

  @override
  Stream<List<CursoEntity>> watchAll() {
    debugPrint('📦 CursoDataSource: Iniciando stream de todos los registros');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('nombre', ascending: true)
        .map(
          (List<Map<String, dynamic>> data) => data
              .map(
                  (Map<String, dynamic> json) => CursoSupabaseModel.fromJson(json).toEntity())
              .toList(),
        );
  }

  @override
  Stream<List<CursoEntity>> watchActivos() {
    debugPrint('📦 CursoDataSource: Stream de cursos activos');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .eq('activo', true)
        .order('nombre', ascending: true)
        .map(
          (List<Map<String, dynamic>> data) => data
              .map(
                  (Map<String, dynamic> json) => CursoSupabaseModel.fromJson(json).toEntity())
              .toList(),
        );
  }
}
