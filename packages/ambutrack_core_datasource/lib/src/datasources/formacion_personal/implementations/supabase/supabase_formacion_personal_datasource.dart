import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../formacion_personal/entities/formacion_personal_entity.dart';
import '../../../formacion_personal/formacion_personal_contract.dart';
import '../../../formacion_personal/models/formacion_personal_supabase_model.dart';

/// Implementación de Supabase para formación personal
class SupabaseFormacionPersonalDataSource implements FormacionPersonalDataSource {
  SupabaseFormacionPersonalDataSource() : _supabase = Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableName = 'formacion_personal';

  @override
  Future<List<FormacionPersonalEntity>> getAll() async {
    debugPrint('📦 FormacionPersonalDataSource: Obteniendo todos los registros...');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .order('fecha_expiracion', ascending: true);

      debugPrint('📦 FormacionPersonalDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((dynamic json) =>
              FormacionPersonalSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 FormacionPersonalDataSource: ❌ Error al obtener registros: $e');
      rethrow;
    }
  }

  @override
  Future<FormacionPersonalEntity> getById(String id) async {
    debugPrint('📦 FormacionPersonalDataSource: Obteniendo por ID: $id');

    try {
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).select().eq('id', id).single();

      debugPrint('📦 FormacionPersonalDataSource: ✅ Registro obtenido');

      return FormacionPersonalSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 FormacionPersonalDataSource: ❌ Error al obtener por ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<FormacionPersonalEntity>> getByPersonalId(String personalId) async {
    debugPrint('📦 FormacionPersonalDataSource: Obteniendo por personalId: $personalId');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('personal_id', personalId)
          .order('fecha_expiracion', ascending: false);

      debugPrint('📦 FormacionPersonalDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((dynamic json) =>
              FormacionPersonalSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 FormacionPersonalDataSource: ❌ Error al obtener por personal: $e');
      rethrow;
    }
  }

  @override
  Future<List<FormacionPersonalEntity>> getVigentes() async {
    debugPrint('📦 FormacionPersonalDataSource: Obteniendo formación vigente...');

    try {
      final DateTime now = DateTime.now();
      final DateTime thirtyDaysLater = now.add(const Duration(days: 30));

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', 'vigente')
          .order('fecha_expiracion', ascending: true);

      debugPrint('📦 FormacionPersonalDataSource: ✅ ${data.length} registros vigentes');

      return data
          .map((dynamic json) =>
              FormacionPersonalSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 FormacionPersonalDataSource: ❌ Error al obtener vigentes: $e');
      rethrow;
    }
  }

  @override
  Future<List<FormacionPersonalEntity>> getProximasVencer() async {
    debugPrint('📦 FormacionPersonalDataSource: Obteniendo formación próxima a vencer...');

    try {
      final DateTime now = DateTime.now();
      final DateTime thirtyDaysLater = now.add(const Duration(days: 30));

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', 'proxima_vencer')
          .gte('fecha_expiracion', now.toIso8601String())
          .lte('fecha_expiracion', thirtyDaysLater.toIso8601String())
          .order('fecha_expiracion', ascending: true);

      debugPrint('📦 FormacionPersonalDataSource: ✅ ${data.length} registros próximos a vencer');

      return data
          .map((dynamic json) =>
              FormacionPersonalSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 FormacionPersonalDataSource: ❌ Error al obtener próximas a vencer: $e');
      rethrow;
    }
  }

  @override
  Future<List<FormacionPersonalEntity>> getVencidas() async {
    debugPrint('📦 FormacionPersonalDataSource: Obteniendo formación vencida...');

    try {
      final DateTime now = DateTime.now();

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', 'vencida')
          .lte('fecha_expiracion', now.toIso8601String())
          .order('fecha_expiracion', ascending: false);

      debugPrint('📦 FormacionPersonalDataSource: ✅ ${data.length} registros vencidos');

      return data
          .map((dynamic json) =>
              FormacionPersonalSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 FormacionPersonalDataSource: ❌ Error al obtener vencidas: $e');
      rethrow;
    }
  }

  @override
  Future<List<FormacionPersonalEntity>> getByEstado(String estado) async {
    debugPrint('📦 FormacionPersonalDataSource: Obteniendo por estado: $estado');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', estado)
          .order('fecha_expiracion', ascending: true);

      debugPrint('📦 FormacionPersonalDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((dynamic json) =>
              FormacionPersonalSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 FormacionPersonalDataSource: ❌ Error al obtener por estado: $e');
      rethrow;
    }
  }

  @override
  Future<FormacionPersonalEntity> create(FormacionPersonalEntity entity) async {
    debugPrint('📦 FormacionPersonalDataSource: Creando registro...');

    try {
      final FormacionPersonalSupabaseModel model =
          FormacionPersonalSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).insert(model.toJson()).select().single();

      debugPrint('📦 FormacionPersonalDataSource: ✅ Registro creado');

      return FormacionPersonalSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 FormacionPersonalDataSource: ❌ Error al crear: $e');
      rethrow;
    }
  }

  @override
  Future<FormacionPersonalEntity> update(FormacionPersonalEntity entity) async {
    debugPrint('📦 FormacionPersonalDataSource: Actualizando registro: ${entity.id}');

    try {
      final FormacionPersonalSupabaseModel model =
          FormacionPersonalSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      debugPrint('📦 FormacionPersonalDataSource: ✅ Registro actualizado');

      return FormacionPersonalSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 FormacionPersonalDataSource: ❌ Error al actualizar: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 FormacionPersonalDataSource: Eliminando registro: $id');

    try {
      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint('📦 FormacionPersonalDataSource: ✅ Registro eliminado');
    } catch (e) {
      debugPrint('📦 FormacionPersonalDataSource: ❌ Error al eliminar: $e');
      rethrow;
    }
  }

  @override
  Stream<List<FormacionPersonalEntity>> watchAll() {
    debugPrint('📦 FormacionPersonalDataSource: Iniciando stream de todos los registros');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('fecha_expiracion', ascending: true)
        .map(
          (List<Map<String, dynamic>> data) => data
              .map(
                  (Map<String, dynamic> json) => FormacionPersonalSupabaseModel.fromJson(json).toEntity())
              .toList(),
        );
  }

  @override
  Stream<List<FormacionPersonalEntity>> watchByPersonalId(String personalId) {
    debugPrint('📦 FormacionPersonalDataSource: Stream por personalId: $personalId');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .eq('personal_id', personalId)
        .order('fecha_expiracion', ascending: false)
        .map(
          (List<Map<String, dynamic>> data) => data
              .map(
                  (Map<String, dynamic> json) => FormacionPersonalSupabaseModel.fromJson(json).toEntity())
              .toList(),
        );
  }
}
