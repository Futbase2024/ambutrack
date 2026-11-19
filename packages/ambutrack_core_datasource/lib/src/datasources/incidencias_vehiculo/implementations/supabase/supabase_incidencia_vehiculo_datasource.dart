import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../incidencia_vehiculo_contract.dart';
import '../../entities/incidencia_vehiculo_entity.dart';
import '../../models/incidencia_vehiculo_supabase_model.dart';

/// Implementación de IncidenciaVehiculoDataSource usando Supabase
class SupabaseIncidenciaVehiculoDataSource
    implements IncidenciaVehiculoDataSource {
  SupabaseIncidenciaVehiculoDataSource({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableName = 'incidencias_vehiculos';

  @override
  Future<List<IncidenciaVehiculoEntity>> getAll() async {
    try {
      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: Obteniendo todas las incidencias...');

      final response = await _supabase
          .from(_tableName)
          .select()
          .order('fecha_reporte', ascending: false);

      final List<IncidenciaVehiculoEntity> incidencias = (response as List)
          .map((json) => IncidenciaVehiculoSupabaseModel.fromJson(
                  json as Map<String, dynamic>)
              .toEntity())
          .toList();

      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: ✅ ${incidencias.length} incidencias obtenidas');
      return incidencias;
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: ❌ Error al obtener incidencias: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<IncidenciaVehiculoEntity> getById(String id) async {
    try {
      debugPrint('📦 SupabaseIncidenciaVehiculoDS: Obteniendo incidencia ID: $id');

      final response =
          await _supabase.from(_tableName).select().eq('id', id).single();

      final incidencia =
          IncidenciaVehiculoSupabaseModel.fromJson(response).toEntity();

      debugPrint('📦 SupabaseIncidenciaVehiculoDS: ✅ Incidencia obtenida');
      return incidencia;
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: ❌ Error al obtener incidencia: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<List<IncidenciaVehiculoEntity>> getByVehiculoId(
      String vehiculoId) async {
    try {
      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: Obteniendo incidencias de vehículo: $vehiculoId');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('vehiculo_id', vehiculoId)
          .order('fecha_reporte', ascending: false);

      final List<IncidenciaVehiculoEntity> incidencias = (response as List)
          .map((json) => IncidenciaVehiculoSupabaseModel.fromJson(
                  json as Map<String, dynamic>)
              .toEntity())
          .toList();

      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: ✅ ${incidencias.length} incidencias del vehículo');
      return incidencias;
    } catch (e, stack) {
      debugPrint('📦 SupabaseIncidenciaVehiculoDS: ❌ Error: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<List<IncidenciaVehiculoEntity>> getByEstado(
      EstadoIncidencia estado) async {
    try {
      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: Obteniendo incidencias en estado: ${estado.toJson()}');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', estado.toJson())
          .order('fecha_reporte', ascending: false);

      final List<IncidenciaVehiculoEntity> incidencias = (response as List)
          .map((json) => IncidenciaVehiculoSupabaseModel.fromJson(
                  json as Map<String, dynamic>)
              .toEntity())
          .toList();

      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: ✅ ${incidencias.length} incidencias en estado ${estado.toJson()}');
      return incidencias;
    } catch (e, stack) {
      debugPrint('📦 SupabaseIncidenciaVehiculoDS: ❌ Error: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<IncidenciaVehiculoEntity> create(
      IncidenciaVehiculoEntity incidencia) async {
    try {
      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: Creando incidencia para vehículo: ${incidencia.vehiculoId}');

      final model = IncidenciaVehiculoSupabaseModel.fromEntity(incidencia);
      final json = model.toJson();
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');

      final response =
          await _supabase.from(_tableName).insert(json).select().single();

      final created =
          IncidenciaVehiculoSupabaseModel.fromJson(response).toEntity();

      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: ✅ Incidencia creada con ID: ${created.id}');
      return created;
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: ❌ Error al crear incidencia: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<IncidenciaVehiculoEntity> update(
      IncidenciaVehiculoEntity incidencia) async {
    try {
      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: Actualizando incidencia ID: ${incidencia.id}');

      final model = IncidenciaVehiculoSupabaseModel.fromEntity(incidencia);
      final json = model.toJson();
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');

      final response = await _supabase
          .from(_tableName)
          .update(json)
          .eq('id', incidencia.id)
          .select()
          .single();

      final updated =
          IncidenciaVehiculoSupabaseModel.fromJson(response).toEntity();

      debugPrint('📦 SupabaseIncidenciaVehiculoDS: ✅ Incidencia actualizada');
      return updated;
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: ❌ Error al actualizar incidencia: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: Eliminando incidencia ID: $id');

      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint('📦 SupabaseIncidenciaVehiculoDS: ✅ Incidencia eliminada');
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseIncidenciaVehiculoDS: ❌ Error al eliminar incidencia: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<int> reenviarAviso(String id) async {
    try {
      debugPrint('📦 SupabaseIncidenciaVehiculoDS: 🔁 Reenviando aviso de avería ID: $id');
      final dynamic avisados = await _supabase.rpc<dynamic>(
        'reenviar_aviso_averia',
        params: <String, dynamic>{'p_incidencia_id': id},
      );
      final int total = (avisados as num?)?.toInt() ?? 0;
      debugPrint('📦 SupabaseIncidenciaVehiculoDS: ✅ Aviso reenviado a $total gestores');
      return total;
    } catch (e, stack) {
      debugPrint('📦 SupabaseIncidenciaVehiculoDS: ❌ Error al reenviar aviso: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Stream<List<IncidenciaVehiculoEntity>> watchByVehiculoId(
      String vehiculoId) {
    debugPrint(
        '📦 SupabaseIncidenciaVehiculoDS: 🔄 Stream de incidencias para vehículo: $vehiculoId');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha_reporte', ascending: false)
        .map((data) {
          debugPrint(
              '📦 SupabaseIncidenciaVehiculoDS: 🔄 Stream actualizado: ${data.length} incidencias totales');
          // Filtrar manualmente por vehículo
          final filtered = data
              .where((json) => json['vehiculo_id'] == vehiculoId)
              .map((json) =>
                  IncidenciaVehiculoSupabaseModel.fromJson(json).toEntity())
              .toList();
          debugPrint(
              '📦 SupabaseIncidenciaVehiculoDS: 🔄 ${filtered.length} incidencias del vehículo $vehiculoId');
          return filtered;
        });
  }
}
