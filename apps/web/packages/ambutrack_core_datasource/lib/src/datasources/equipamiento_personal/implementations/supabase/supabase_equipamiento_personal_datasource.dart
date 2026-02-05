import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/equipamiento_personal_entity.dart';
import '../../equipamiento_personal_contract.dart';
import '../../models/equipamiento_personal_supabase_model.dart';

/// Implementación de Supabase para equipamiento personal
class SupabaseEquipamientoPersonalDataSource implements EquipamientoPersonalDataSource {
  SupabaseEquipamientoPersonalDataSource() : _supabase = Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableName = 'equipamiento_personal';

  @override
  Future<List<EquipamientoPersonalEntity>> getAll() async {
    debugPrint('📦 EquipamientoPersonalDataSource: Obteniendo todos los registros...');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .order('fecha_asignacion', ascending: false);

      debugPrint('📦 EquipamientoPersonalDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((dynamic json) =>
              EquipamientoPersonalSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 EquipamientoPersonalDataSource: ❌ Error al obtener registros: $e');
      rethrow;
    }
  }

  @override
  Future<EquipamientoPersonalEntity> getById(String id) async {
    debugPrint('📦 EquipamientoPersonalDataSource: Obteniendo por ID: $id');

    try {
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).select().eq('id', id).single();

      debugPrint('📦 EquipamientoPersonalDataSource: ✅ Registro obtenido');

      return EquipamientoPersonalSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 EquipamientoPersonalDataSource: ❌ Error al obtener por ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<EquipamientoPersonalEntity>> getByPersonalId(String personalId) async {
    debugPrint('📦 EquipamientoPersonalDataSource: Obteniendo por personalId: $personalId');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('personal_id', personalId)
          .order('fecha_asignacion', ascending: false);

      debugPrint('📦 EquipamientoPersonalDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((dynamic json) =>
              EquipamientoPersonalSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 EquipamientoPersonalDataSource: ❌ Error al obtener por personal: $e');
      rethrow;
    }
  }

  @override
  Future<List<EquipamientoPersonalEntity>> getAsignado() async {
    debugPrint('📦 EquipamientoPersonalDataSource: Obteniendo equipamiento asignado...');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .isFilter('fecha_devolucion', null)
          .order('fecha_asignacion', ascending: false);

      debugPrint('📦 EquipamientoPersonalDataSource: ✅ ${data.length} registros asignados');

      return data
          .map((dynamic json) =>
              EquipamientoPersonalSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 EquipamientoPersonalDataSource: ❌ Error al obtener asignados: $e');
      rethrow;
    }
  }

  @override
  Future<List<EquipamientoPersonalEntity>> getByTipo(String tipo) async {
    debugPrint('📦 EquipamientoPersonalDataSource: Obteniendo por tipo: $tipo');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo_equipamiento', tipo)
          .order('fecha_asignacion', ascending: false);

      debugPrint('📦 EquipamientoPersonalDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((dynamic json) =>
              EquipamientoPersonalSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 EquipamientoPersonalDataSource: ❌ Error al obtener por tipo: $e');
      rethrow;
    }
  }

  @override
  Future<EquipamientoPersonalEntity> create(EquipamientoPersonalEntity entity) async {
    debugPrint('📦 EquipamientoPersonalDataSource: Creando registro...');

    try {
      final EquipamientoPersonalSupabaseModel model =
          EquipamientoPersonalSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).insert(model.toJson()).select().single();

      debugPrint('📦 EquipamientoPersonalDataSource: ✅ Registro creado');

      return EquipamientoPersonalSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 EquipamientoPersonalDataSource: ❌ Error al crear: $e');
      rethrow;
    }
  }

  @override
  Future<EquipamientoPersonalEntity> update(EquipamientoPersonalEntity entity) async {
    debugPrint('📦 EquipamientoPersonalDataSource: Actualizando registro: ${entity.id}');

    try {
      final EquipamientoPersonalSupabaseModel model =
          EquipamientoPersonalSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      debugPrint('📦 EquipamientoPersonalDataSource: ✅ Registro actualizado');

      return EquipamientoPersonalSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 EquipamientoPersonalDataSource: ❌ Error al actualizar: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 EquipamientoPersonalDataSource: Eliminando registro: $id');

    try {
      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint('📦 EquipamientoPersonalDataSource: ✅ Registro eliminado');
    } catch (e) {
      debugPrint('📦 EquipamientoPersonalDataSource: ❌ Error al eliminar: $e');
      rethrow;
    }
  }

  @override
  Stream<List<EquipamientoPersonalEntity>> watchAll() {
    debugPrint('📦 EquipamientoPersonalDataSource: Iniciando stream de todos los registros');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('fecha_asignacion', ascending: false)
        .map(
          (List<Map<String, dynamic>> data) => data
              .map(
                  (Map<String, dynamic> json) => EquipamientoPersonalSupabaseModel.fromJson(json).toEntity())
              .toList(),
        );
  }

  @override
  Stream<List<EquipamientoPersonalEntity>> watchByPersonalId(String personalId) {
    debugPrint('📦 EquipamientoPersonalDataSource: Stream por personalId: $personalId');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .eq('personal_id', personalId)
        .order('fecha_asignacion', ascending: false)
        .map(
          (List<Map<String, dynamic>> data) => data
              .map(
                  (Map<String, dynamic> json) => EquipamientoPersonalSupabaseModel.fromJson(json).toEntity())
              .toList(),
        );
  }
}
