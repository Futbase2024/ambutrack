import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/asignacion_vehiculo_turno_entity.dart';
import '../../asignaciones_vehiculos_turnos_contract.dart';

/// Implementación de [AsignacionVehiculoTurnoDataSource] usando Supabase
class SupabaseAsignacionVehiculoTurnoDataSource
    implements AsignacionVehiculoTurnoDataSource {
  SupabaseAsignacionVehiculoTurnoDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'asignaciones_vehiculos_turnos';

  @override
  Future<AsignacionVehiculoTurnoEntity> create(
      AsignacionVehiculoTurnoEntity entity) async {
    try {
      final Map<String, dynamic> json = entity.toJson();
      // Remover campos gestionados por Supabase
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');

      final dynamic response =
          await _supabase.from(_tableName).insert(json).select().single();

      return AsignacionVehiculoTurnoEntity.fromJson(
          response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al crear asignación: $e');
    }
  }

  @override
  Future<AsignacionVehiculoTurnoEntity> update(
      AsignacionVehiculoTurnoEntity entity) async {
    try {
      final Map<String, dynamic> json = entity.toJson();
      json['updated_at'] = DateTime.now().toIso8601String();
      // Remover campos de timestamp que maneja Supabase
      json.remove('created_at');

      final dynamic response = await _supabase
          .from(_tableName)
          .update(json)
          .eq('id', entity.id)
          .select()
          .single();

      return AsignacionVehiculoTurnoEntity.fromJson(
          response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al actualizar asignación: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar asignación: $e');
    }
  }

  @override
  Future<AsignacionVehiculoTurnoEntity> getById(String id) async {
    try {
      final dynamic response =
          await _supabase.from(_tableName).select().eq('id', id).single();

      return AsignacionVehiculoTurnoEntity.fromJson(
          response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener asignación por ID: $e');
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getAll(
      {int? limit, int? offset}) async {
    try {
      dynamic query = _supabase.from(_tableName).select();

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener asignaciones: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final dynamic response =
          await _supabase.from(_tableName).select('id').eq('id', id).maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia de asignación: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final dynamic response =
          await _supabase.from(_tableName).select().count(CountOption.exact);

      return response.count as int;
    } catch (e) {
      throw Exception('Error al contar asignaciones: $e');
    }
  }

  @override
  Stream<List<AsignacionVehiculoTurnoEntity>> watchAll() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('fecha', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          return data
              .map((Map<String, dynamic> json) =>
                  AsignacionVehiculoTurnoEntity.fromJson(json))
              .toList();
        });
  }

  @override
  Stream<AsignacionVehiculoTurnoEntity?> watchById(String id) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) return null;
          return AsignacionVehiculoTurnoEntity.fromJson(data.first);
        });
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> createBatch(
      List<AsignacionVehiculoTurnoEntity> entities) async {
    try {
      final List<Map<String, dynamic>> jsonList =
          entities.map((AsignacionVehiculoTurnoEntity e) {
        final Map<String, dynamic> json = e.toJson();
        // Remover campos gestionados por Supabase
        json.remove('id');
        json.remove('created_at');
        json.remove('updated_at');
        return json;
      }).toList();

      final dynamic response =
          await _supabase.from(_tableName).insert(jsonList).select();

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al crear asignaciones en lote: $e');
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> updateBatch(
      List<AsignacionVehiculoTurnoEntity> entities) async {
    try {
      final List<AsignacionVehiculoTurnoEntity> updated =
          <AsignacionVehiculoTurnoEntity>[];
      for (final AsignacionVehiculoTurnoEntity entity in entities) {
        final AsignacionVehiculoTurnoEntity result = await update(entity);
        updated.add(result);
      }
      return updated;
    } catch (e) {
      throw Exception('Error al actualizar asignaciones en lote: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(_tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar asignaciones en lote: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      // Nota: Esta operación elimina TODOS los registros. Usar con precaución.
      await _supabase.from(_tableName).delete().neq('id', 'dummy');
    } catch (e) {
      throw Exception('Error al limpiar asignaciones: $e');
    }
  }

  // ==================== MÉTODOS ESPECÍFICOS ====================

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByFecha(DateTime fecha) async {
    try {
      final String fechaStr =
          fecha.toIso8601String().split('T')[0]; // Solo fecha, sin hora

      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('fecha', fechaStr)
          .order('plantilla_turno_id', ascending: true);

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener asignaciones por fecha: $e');
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByRangoFechas(
      DateTime inicio, DateTime fin) async {
    try {
      final String inicioStr = inicio.toIso8601String().split('T')[0];
      final String finStr = fin.toIso8601String().split('T')[0];

      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .gte('fecha', inicioStr)
          .lte('fecha', finStr)
          .order('fecha', ascending: true);

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener asignaciones por rango de fechas: $e');
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByVehiculo(
      String vehiculoId, DateTime fecha) async {
    try {
      final String fechaStr = fecha.toIso8601String().split('T')[0];

      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('vehiculo_id', vehiculoId)
          .eq('fecha', fechaStr)
          .order('plantilla_turno_id', ascending: true);

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener asignaciones por vehículo: $e');
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByEstado(String estado) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', estado)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener asignaciones por estado: $e');
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByDotacion(
      String dotacionId) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('dotacion_id', dotacionId)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener asignaciones por dotación: $e');
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByTurno(String turnoId) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('plantilla_turno_id', turnoId)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener asignaciones por turno: $e');
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByHospital(
      String hospitalId) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('hospital_id', hospitalId)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener asignaciones por hospital: $e');
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByBase(String baseId) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('base_id', baseId)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener asignaciones por base: $e');
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getActivas() async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener asignaciones activas: $e');
    }
  }

  @override
  Future<AsignacionVehiculoTurnoEntity> deactivate(String asignacionId) async {
    try {
      final Map<String, dynamic> updates = <String, dynamic>{
        'activo': false,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final dynamic response = await _supabase
          .from(_tableName)
          .update(updates)
          .eq('id', asignacionId)
          .select()
          .single();

      return AsignacionVehiculoTurnoEntity.fromJson(
          response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al desactivar asignación: $e');
    }
  }

  @override
  Future<AsignacionVehiculoTurnoEntity> reactivate(String asignacionId) async {
    try {
      final Map<String, dynamic> updates = <String, dynamic>{
        'activo': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final dynamic response = await _supabase
          .from(_tableName)
          .update(updates)
          .eq('id', asignacionId)
          .select()
          .single();

      return AsignacionVehiculoTurnoEntity.fromJson(
          response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al reactivar asignación: $e');
    }
  }

  @override
  Future<AsignacionVehiculoTurnoEntity> updateEstado(
      String asignacionId, String nuevoEstado) async {
    try {
      final Map<String, dynamic> updates = <String, dynamic>{
        'estado': nuevoEstado,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final dynamic response = await _supabase
          .from(_tableName)
          .update(updates)
          .eq('id', asignacionId)
          .select()
          .single();

      return AsignacionVehiculoTurnoEntity.fromJson(
          response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al actualizar estado de asignación: $e');
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getConflictos(
      String vehiculoId, DateTime fecha) async {
    try {
      final String fechaStr = fecha.toIso8601String().split('T')[0];

      // Obtiene todas las asignaciones del vehículo en esa fecha
      // El análisis de conflictos reales se debe hacer en la capa de dominio
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('vehiculo_id', vehiculoId)
          .eq('fecha', fechaStr)
          .eq('activo', true)
          .order('plantilla_turno_id', ascending: true);

      return (response as List<dynamic>)
          .map((dynamic json) => AsignacionVehiculoTurnoEntity.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener conflictos de asignaciones: $e');
    }
  }

  @override
  Future<AsignacionVehiculoTurnoEntity> cancelar(
      String asignacionId, String motivo) async {
    try {
      final Map<String, dynamic> updates = <String, dynamic>{
        'estado': 'cancelada',
        'observaciones': motivo,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final dynamic response = await _supabase
          .from(_tableName)
          .update(updates)
          .eq('id', asignacionId)
          .select()
          .single();

      return AsignacionVehiculoTurnoEntity.fromJson(
          response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al cancelar asignación: $e');
    }
  }
}
