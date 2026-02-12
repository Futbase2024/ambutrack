import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/dotacion_entity.dart';
import '../../dotaciones_contract.dart';

/// Implementación de [DotacionesDataSource] usando Supabase
class SupabaseDotacionesDataSource implements DotacionesDataSource {
  SupabaseDotacionesDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'dotaciones';

  @override
  Future<DotacionEntity> create(DotacionEntity entity) async {
    try {
      final Map<String, dynamic> json = entity.toJson();
      // Remover campos gestionados por Supabase
      json.remove('id');
      json.remove('codigo');
      json.remove('created_at');
      json.remove('updated_at');

      final dynamic response = await _supabase
          .from(_tableName)
          .insert(json)
          .select()
          .single();

      return DotacionEntity.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al crear dotación: $e');
    }
  }

  @override
  Future<DotacionEntity> update(DotacionEntity entity) async {
    try {
      final Map<String, dynamic> json = entity.toJson();
      json['updated_at'] = DateTime.now().toIso8601String();
      // Remover codigo (no se debe actualizar, es generado por Supabase)
      json.remove('codigo');
      // Remover campos de timestamp que maneja Supabase
      json.remove('created_at');

      final dynamic response = await _supabase
          .from(_tableName)
          .update(json)
          .eq('id', entity.id)
          .select()
          .single();

      return DotacionEntity.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al actualizar dotación: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar dotación: $e');
    }
  }

  @override
  Future<DotacionEntity> getById(String id) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return DotacionEntity.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener dotación por ID: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getAll({int? limit, int? offset}) async {
    try {
      dynamic query = _supabase.from(_tableName).select();

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia de dotación: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .count(CountOption.exact);

      return response.count as int;
    } catch (e) {
      throw Exception('Error al contar dotaciones: $e');
    }
  }

  @override
  Stream<List<DotacionEntity>> watchAll() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('created_at', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          return data.map((Map<String, dynamic> json) => DotacionEntity.fromJson(json)).toList();
        });
  }

  @override
  Stream<DotacionEntity?> watchById(String id) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) return null;
          return DotacionEntity.fromJson(data.first);
        });
  }

  @override
  Future<List<DotacionEntity>> createBatch(List<DotacionEntity> entities) async {
    try {
      final List<Map<String, dynamic>> jsonList = entities.map((DotacionEntity e) {
        final Map<String, dynamic> json = e.toJson();
        // Remover campos gestionados por Supabase
        json.remove('id');
        json.remove('codigo');
        json.remove('created_at');
        json.remove('updated_at');
        return json;
      }).toList();

      final dynamic response = await _supabase
          .from(_tableName)
          .insert(jsonList)
          .select();

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al crear dotaciones en lote: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> updateBatch(List<DotacionEntity> entities) async {
    try {
      final List<DotacionEntity> updated = <DotacionEntity>[];
      for (final DotacionEntity entity in entities) {
        final DotacionEntity result = await update(entity);
        updated.add(result);
      }
      return updated;
    } catch (e) {
      throw Exception('Error al actualizar dotaciones en lote: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(_tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar dotaciones en lote: $e');
    }
  }

  // ==================== MÉTODOS ESPECÍFICOS ====================


  @override
  Future<List<DotacionEntity>> getActivas() async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('nombre', ascending: true);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones activas: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByHospital(String hospitalId) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('hospital_id', hospitalId)
          .order('prioridad', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones por hospital: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByBase(String baseId) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('base_id', baseId)
          .order('prioridad', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones por base: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByContrato(String contratoId) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('contrato_id', contratoId)
          .order('prioridad', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones por contrato: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByTipoVehiculo(String tipoVehiculoId) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo_vehiculo_id', tipoVehiculoId)
          .eq('activo', true)
          .order('prioridad', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones por tipo de vehículo: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getVigentesEn(DateTime fecha) async {
    try {
      final String fechaStr = fecha.toIso8601String().split('T')[0]; // Solo fecha, sin hora

      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .lte('fecha_inicio', fechaStr)
          .or('fecha_fin.is.null,fecha_fin.gte.$fechaStr')
          .eq('activo', true)
          .order('prioridad', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones vigentes: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByDiaSemana(String diaSemana) async {
    try {
      final String columna = 'aplica_${diaSemana.toLowerCase()}';

      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq(columna, true)
          .eq('activo', true)
          .order('prioridad', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones por día de semana: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByPrioridad(int prioridadMinima) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .gte('prioridad', prioridadMinima)
          .eq('activo', true)
          .order('prioridad', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones por prioridad: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByCantidadUnidades(int cantidadMinima) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .gte('cantidad_unidades', cantidadMinima)
          .eq('activo', true)
          .order('cantidad_unidades', ascending: false);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones por cantidad de unidades: $e');
    }
  }

  @override
  Future<DotacionEntity> deactivate(String dotacionId) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .update(<String, dynamic>{
            'activo': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', dotacionId)
          .select()
          .single();

      return DotacionEntity.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al desactivar dotación: $e');
    }
  }

  @override
  Future<DotacionEntity> reactivate(String dotacionId) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .update(<String, dynamic>{
            'activo': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', dotacionId)
          .select()
          .single();

      return DotacionEntity.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al reactivar dotación: $e');
    }
  }


  @override
  Future<List<DotacionEntity>> getPorVencer(int diasAnticipacion) async {
    try {
      final DateTime fechaLimite = DateTime.now().add(Duration(days: diasAnticipacion));
      final String fechaLimiteStr = fechaLimite.toIso8601String().split('T')[0];

      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .not('fecha_fin', 'is', null)
          .lte('fecha_fin', fechaLimiteStr)
          .eq('activo', true)
          .order('fecha_fin', ascending: true);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones por vencer: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByPlantillaTurno(String plantillaTurnoId) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('plantilla_turno_id', plantillaTurnoId)
          .eq('activo', true)
          .order('nombre', ascending: true);

      return (response as List<dynamic>)
          .map((dynamic json) => DotacionEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dotaciones por plantilla de turno: $e');
    }
  }

  @override
  Future<DotacionEntity> updateCantidadUnidades(String dotacionId, int nuevaCantidad) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .update(<String, dynamic>{
            'cantidad_unidades': nuevaCantidad,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', dotacionId)
          .select()
          .single();

      return DotacionEntity.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al actualizar cantidad de unidades: $e');
    }
  }

  @override
  Future<DotacionEntity> updatePrioridad(String dotacionId, int nuevaPrioridad) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .update(<String, dynamic>{
            'prioridad': nuevaPrioridad,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', dotacionId)
          .select()
          .single();

      return DotacionEntity.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al actualizar prioridad: $e');
    }
  }

  @override
  Future<DotacionEntity> updateDiasAplicacion(String dotacionId, Map<String, bool> dias) async {
    try {
      final Map<String, dynamic> updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Mapear días del español a columnas de BD
      if (dias.containsKey('lunes')) updateData['aplica_lunes'] = dias['lunes'];
      if (dias.containsKey('martes')) updateData['aplica_martes'] = dias['martes'];
      if (dias.containsKey('miercoles')) updateData['aplica_miercoles'] = dias['miercoles'];
      if (dias.containsKey('jueves')) updateData['aplica_jueves'] = dias['jueves'];
      if (dias.containsKey('viernes')) updateData['aplica_viernes'] = dias['viernes'];
      if (dias.containsKey('sabado')) updateData['aplica_sabado'] = dias['sabado'];
      if (dias.containsKey('domingo')) updateData['aplica_domingo'] = dias['domingo'];

      final dynamic response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', dotacionId)
          .select()
          .single();

      return DotacionEntity.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al actualizar días de aplicación: $e');
    }
  }

  @override
  Future<DotacionEntity> extenderVigencia(String dotacionId, DateTime nuevaFechaFin) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .update(<String, dynamic>{
            'fecha_fin': nuevaFechaFin.toIso8601String().split('T')[0],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', dotacionId)
          .select()
          .single();

      return DotacionEntity.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al extender vigencia: $e');
    }
  }

  @override
  Future<void> clear() async {
    // Método requerido por BaseDatasource
    // En Supabase no hay cache local que limpiar
    // Si en el futuro se implementa cache, aquí se limpiaría
    return;
  }
}
