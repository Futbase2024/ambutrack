import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../ausencia_contract.dart';
import '../../entities/ausencia_entity.dart';
import '../../models/ausencia_supabase_model.dart';

/// Implementación de AusenciaDataSource usando Supabase
class SupabaseAusenciaDataSource implements AusenciaDataSource {
  SupabaseAusenciaDataSource({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableName = 'ausencias';

  @override
  Future<List<AusenciaEntity>> getAll() async {
    try {
      debugPrint('📦 SupabaseAusenciaDS: Obteniendo todas las ausencias...');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('fecha_inicio', ascending: false);

      final List<AusenciaEntity> ausencias = (response as List)
          .map((json) =>
              AusenciaSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();

      debugPrint('📦 SupabaseAusenciaDS: ✅ ${ausencias.length} ausencias obtenidas');
      return ausencias;
    } catch (e, stack) {
      debugPrint('📦 SupabaseAusenciaDS: ❌ Error al obtener ausencias: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<List<AusenciaEntity>> getByPersonal(String idPersonal) async {
    try {
      debugPrint('📦 SupabaseAusenciaDS: Obteniendo ausencias de personal: $idPersonal');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id_personal', idPersonal)
          .eq('activo', true)
          .order('fecha_inicio', ascending: false);

      final List<AusenciaEntity> ausencias = (response as List)
          .map((json) =>
              AusenciaSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();

      debugPrint('📦 SupabaseAusenciaDS: ✅ ${ausencias.length} ausencias del personal');
      return ausencias;
    } catch (e, stack) {
      debugPrint('📦 SupabaseAusenciaDS: ❌ Error: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<List<AusenciaEntity>> getByEstado(EstadoAusencia estado) async {
    try {
      debugPrint('📦 SupabaseAusenciaDS: Obteniendo ausencias en estado: ${estado.toJson()}');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', estado.toJson())
          .eq('activo', true)
          .order('fecha_inicio', ascending: false);

      final List<AusenciaEntity> ausencias = (response as List)
          .map((json) =>
              AusenciaSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();

      debugPrint('📦 SupabaseAusenciaDS: ✅ ${ausencias.length} ausencias en estado ${estado.toJson()}');
      return ausencias;
    } catch (e, stack) {
      debugPrint('📦 SupabaseAusenciaDS: ❌ Error: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<List<AusenciaEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      debugPrint('📦 SupabaseAusenciaDS: Obteniendo ausencias entre $fechaInicio y $fechaFin');

      final response = await _supabase
          .from(_tableName)
          .select()
          .gte('fecha_inicio', fechaInicio.toIso8601String())
          .lte('fecha_fin', fechaFin.toIso8601String())
          .eq('activo', true)
          .order('fecha_inicio', ascending: false);

      final List<AusenciaEntity> ausencias = (response as List)
          .map((json) =>
              AusenciaSupabaseModel.fromJson(json as Map<String, dynamic>)
                  .toEntity())
          .toList();

      debugPrint('📦 SupabaseAusenciaDS: ✅ ${ausencias.length} ausencias en rango');
      return ausencias;
    } catch (e, stack) {
      debugPrint('📦 SupabaseAusenciaDS: ❌ Error: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> getById(String id) async {
    try {
      debugPrint('📦 SupabaseAusenciaDS: Obteniendo ausencia ID: $id');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      final ausencia = AusenciaSupabaseModel.fromJson(
        response,
      ).toEntity();

      debugPrint('📦 SupabaseAusenciaDS: ✅ Ausencia obtenida');
      return ausencia;
    } catch (e, stack) {
      debugPrint('📦 SupabaseAusenciaDS: ❌ Error al obtener ausencia: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> create(AusenciaEntity ausencia) async {
    try {
      debugPrint('📦 SupabaseAusenciaDS: Creando ausencia para personal: ${ausencia.idPersonal}');

      final model = AusenciaSupabaseModel.fromEntity(ausencia);
      final json = model.toJson();
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');

      final response = await _supabase
          .from(_tableName)
          .insert(json)
          .select()
          .single();

      final created = AusenciaSupabaseModel.fromJson(
        response,
      ).toEntity();

      debugPrint('📦 SupabaseAusenciaDS: ✅ Ausencia creada con ID: ${created.id}');
      return created;
    } catch (e, stack) {
      debugPrint('📦 SupabaseAusenciaDS: ❌ Error al crear ausencia: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> update(AusenciaEntity ausencia) async {
    try {
      debugPrint('📦 SupabaseAusenciaDS: Actualizando ausencia ID: ${ausencia.id}');

      final model = AusenciaSupabaseModel.fromEntity(ausencia);
      final json = model.toJson();
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');

      final response = await _supabase
          .from(_tableName)
          .update(json)
          .eq('id', ausencia.id)
          .select()
          .single();

      final updated = AusenciaSupabaseModel.fromJson(
        response,
      ).toEntity();

      debugPrint('📦 SupabaseAusenciaDS: ✅ Ausencia actualizada');
      return updated;
    } catch (e, stack) {
      debugPrint('📦 SupabaseAusenciaDS: ❌ Error al actualizar ausencia: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> aprobar({
    required String idAusencia,
    required String aprobadoPor,
    String? observaciones,
  }) async {
    try {
      debugPrint('📦 SupabaseAusenciaDS: Aprobando ausencia ID: $idAusencia');

      final Map<String, dynamic> updates = {
        'estado': 'Aprobada',
        'aprobado_por': aprobadoPor,
        'fecha_aprobacion': DateTime.now().toIso8601String(),
      };

      if (observaciones != null && observaciones.isNotEmpty) {
        updates['observaciones'] = observaciones;
      }

      final response = await _supabase
          .from(_tableName)
          .update(updates)
          .eq('id', idAusencia)
          .select()
          .single();

      final aprobada = AusenciaSupabaseModel.fromJson(
        response,
      ).toEntity();

      debugPrint('📦 SupabaseAusenciaDS: ✅ Ausencia aprobada');
      return aprobada;
    } catch (e, stack) {
      debugPrint('📦 SupabaseAusenciaDS: ❌ Error al aprobar ausencia: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> rechazar({
    required String idAusencia,
    required String aprobadoPor,
    String? observaciones,
  }) async {
    try {
      debugPrint('📦 SupabaseAusenciaDS: Rechazando ausencia ID: $idAusencia');

      final Map<String, dynamic> updates = {
        'estado': 'Rechazada',
        'aprobado_por': aprobadoPor,
        'fecha_aprobacion': DateTime.now().toIso8601String(),
      };

      if (observaciones != null && observaciones.isNotEmpty) {
        updates['observaciones'] = observaciones;
      }

      final response = await _supabase
          .from(_tableName)
          .update(updates)
          .eq('id', idAusencia)
          .select()
          .single();

      final rechazada = AusenciaSupabaseModel.fromJson(
        response,
      ).toEntity();

      debugPrint('📦 SupabaseAusenciaDS: ✅ Ausencia rechazada');
      return rechazada;
    } catch (e, stack) {
      debugPrint('📦 SupabaseAusenciaDS: ❌ Error al rechazar ausencia: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('📦 SupabaseAusenciaDS: Eliminando (soft) ausencia ID: $id');

      await _supabase
          .from(_tableName)
          .update({'activo': false})
          .eq('id', id);

      debugPrint('📦 SupabaseAusenciaDS: ✅ Ausencia eliminada (soft)');
    } catch (e, stack) {
      debugPrint('📦 SupabaseAusenciaDS: ❌ Error al eliminar ausencia: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Stream<List<AusenciaEntity>> watchAll() {
    debugPrint('📦 SupabaseAusenciaDS: 🔄 Iniciando stream de ausencias...');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('activo', true)
        .order('fecha_inicio', ascending: false)
        .map((data) {
          debugPrint('📦 SupabaseAusenciaDS: 🔄 Stream actualizado: ${data.length} ausencias');
          return data
              .map((json) =>
                  AusenciaSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<List<AusenciaEntity>> watchByPersonal(String idPersonal) {
    debugPrint('📦 SupabaseAusenciaDS: 🔄 Stream de ausencias para personal: $idPersonal');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha_inicio', ascending: false)
        .map((data) {
          debugPrint('📦 SupabaseAusenciaDS: 🔄 Stream actualizado: ${data.length} ausencias totales');
          // Filtrar manualmente por personal y activo
          final filtered = data
              .where((json) =>
                  json['id_personal'] == idPersonal && json['activo'] == true)
              .map((json) => AusenciaSupabaseModel.fromJson(json).toEntity())
              .toList();
          debugPrint('📦 SupabaseAusenciaDS: 🔄 ${filtered.length} ausencias del personal $idPersonal');
          return filtered;
        });
  }
}
