import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/historial_medico_entity.dart';
import '../../historial_medico_contract.dart';
import '../../models/historial_medico_supabase_model.dart';

/// Implementación Supabase del DataSource de Historial Médico
class SupabaseHistorialMedicoDataSource implements HistorialMedicoDataSource {
  SupabaseHistorialMedicoDataSource() : _supabase = Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableName = 'historial_medico';

  @override
  Future<List<HistorialMedicoEntity>> getAll() async {
    debugPrint('📦 SupabaseHistorialMedicoDataSource: Obteniendo todos los registros...');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .order('fecha_reconocimiento', ascending: false);

      debugPrint('📦 SupabaseHistorialMedicoDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((json) => HistorialMedicoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 SupabaseHistorialMedicoDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<HistorialMedicoEntity> getById(String id) async {
    debugPrint('📦 SupabaseHistorialMedicoDataSource: Obteniendo registro con ID: $id');

    try {
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      debugPrint('📦 SupabaseHistorialMedicoDataSource: ✅ Registro obtenido');

      return HistorialMedicoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 SupabaseHistorialMedicoDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<HistorialMedicoEntity>> getByPersonalId(String personalId) async {
    debugPrint('📦 SupabaseHistorialMedicoDataSource: Obteniendo historial del personal: $personalId');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('personal_id', personalId)
          .order('fecha_reconocimiento', ascending: false);

      debugPrint('📦 SupabaseHistorialMedicoDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((json) => HistorialMedicoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 SupabaseHistorialMedicoDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<HistorialMedicoEntity>> getProximosACaducar() async {
    debugPrint('📦 SupabaseHistorialMedicoDataSource: Obteniendo reconocimientos próximos a caducar...');

    try {
      final DateTime ahora = DateTime.now();
      final DateTime limiteAlerta = ahora.add(const Duration(days: 30));

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .gte('fecha_caducidad', ahora.toIso8601String())
          .lte('fecha_caducidad', limiteAlerta.toIso8601String())
          .order('fecha_caducidad', ascending: true);

      debugPrint('📦 SupabaseHistorialMedicoDataSource: ✅ ${data.length} reconocimientos próximos a caducar');

      return data
          .map((json) => HistorialMedicoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 SupabaseHistorialMedicoDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<HistorialMedicoEntity>> getCaducados() async {
    debugPrint('📦 SupabaseHistorialMedicoDataSource: Obteniendo reconocimientos caducados...');

    try {
      final DateTime ahora = DateTime.now();

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .lt('fecha_caducidad', ahora.toIso8601String())
          .order('fecha_caducidad', ascending: false);

      debugPrint('📦 SupabaseHistorialMedicoDataSource: ✅ ${data.length} reconocimientos caducados');

      return data
          .map((json) => HistorialMedicoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 SupabaseHistorialMedicoDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<HistorialMedicoEntity> create(HistorialMedicoEntity entity) async {
    debugPrint('📦 SupabaseHistorialMedicoDataSource: Creando registro...');

    try {
      final HistorialMedicoSupabaseModel model = HistorialMedicoSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .insert(model.toJson())
          .select()
          .single();

      debugPrint('📦 SupabaseHistorialMedicoDataSource: ✅ Registro creado');

      return HistorialMedicoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 SupabaseHistorialMedicoDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<HistorialMedicoEntity> update(HistorialMedicoEntity entity) async {
    debugPrint('📦 SupabaseHistorialMedicoDataSource: Actualizando registro: ${entity.id}');

    try {
      final HistorialMedicoSupabaseModel model = HistorialMedicoSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      debugPrint('📦 SupabaseHistorialMedicoDataSource: ✅ Registro actualizado');

      return HistorialMedicoSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 SupabaseHistorialMedicoDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 SupabaseHistorialMedicoDataSource: Eliminando registro: $id');

    try {
      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint('📦 SupabaseHistorialMedicoDataSource: ✅ Registro eliminado');
    } catch (e) {
      debugPrint('📦 SupabaseHistorialMedicoDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<HistorialMedicoEntity>> watchAll() {
    debugPrint('📦 SupabaseHistorialMedicoDataSource: Iniciando stream de todos los registros');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha_reconocimiento', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          return data
              .map((json) => HistorialMedicoSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<List<HistorialMedicoEntity>> watchByPersonalId(String personalId) {
    debugPrint('📦 SupabaseHistorialMedicoDataSource: Iniciando stream del personal: $personalId');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('personal_id', personalId)
        .order('fecha_reconocimiento', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          return data
              .map((json) => HistorialMedicoSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }
}
