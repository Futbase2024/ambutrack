import 'package:supabase_flutter/supabase_flutter.dart';

import '../../consumo_combustible_contract.dart';
import '../../entities/consumo_combustible_entity.dart';
import '../../models/consumo_combustible_supabase_model.dart';

/// Implementación del datasource de consumo de combustible con Supabase
class SupabaseConsumoCombustibleDataSource implements ConsumoCombustibleDataSource {
  /// Constructor con cliente de Supabase y nombre de tabla configurables
  SupabaseConsumoCombustibleDataSource({
    SupabaseClient? supabase,
    String tableName = 'tconsumo_combustible',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  final SupabaseClient _supabase;
  final String _tableName;

  // ========== MÉTODOS DE BaseDatasource ==========

  @override
  Future<List<ConsumoCombustibleEntity>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      debugPrint('📦 SupabaseConsumoCombustibleDataSource: 🔄 Cargando registros...');

      dynamic query = _supabase.from(_tableName).select();

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('fecha', ascending: false);

      final List<ConsumoCombustibleEntity> registros = (response as List)
          .map((json) => ConsumoCombustibleSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      debugPrint('📦 SupabaseConsumoCombustibleDataSource: ✅ ${registros.length} registros cargados');
      return registros;
    } catch (e) {
      throw Exception('Error al obtener registros de consumo: $e');
    }
  }

  @override
  Future<ConsumoCombustibleEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ConsumoCombustibleSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener registro de consumo por ID: $e');
    }
  }

  @override
  Future<ConsumoCombustibleEntity> create(ConsumoCombustibleEntity entity) async {
    try {
      final model = ConsumoCombustibleSupabaseModel.fromEntity(entity);
      final json = model.toJson();

      // Eliminar campos UUID vacíos para evitar errores de PostgreSQL
      final List<String> uuidFields = ['id', 'created_by', 'updated_by', 'conductor_id'];
      for (final String field in uuidFields) {
        if (json[field] == null || json[field] == '') {
          json.remove(field);
        }
      }

      // Eliminar campos de fecha null opcionales
      if (json['updated_at'] == null) {
        json.remove('updated_at');
      }

      final Map<String, dynamic> response = await _supabase
          .from(_tableName)
          .insert(json)
          .select()
          .single();

      debugPrint('📦 SupabaseConsumoCombustibleDataSource: ✅ Registro creado');
      return ConsumoCombustibleSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear registro de consumo: $e');
    }
  }

  @override
  Future<ConsumoCombustibleEntity> update(ConsumoCombustibleEntity entity) async {
    try {
      final model = ConsumoCombustibleSupabaseModel.fromEntity(entity);
      final json = model.toJson();

      // Eliminar campos inmutables/autogenerados que no deben actualizarse
      json.remove('id');
      json.remove('created_at');
      json.remove('empresa_id');
      json.remove('vehiculo_id'); // No permitir cambiar vehículo después de crear

      // Eliminar campos UUID vacíos para evitar errores
      final List<String> uuidFields = ['created_by', 'updated_by', 'conductor_id'];
      for (final String field in uuidFields) {
        if (json[field] == null || json[field] == '') {
          json.remove(field);
        }
      }

      final Map<String, dynamic> response = await _supabase
          .from(_tableName)
          .update(json)
          .eq('id', entity.id)
          .select()
          .single();

      debugPrint('📦 SupabaseConsumoCombustibleDataSource: ✅ Registro actualizado');
      return ConsumoCombustibleSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar registro de consumo: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('📦 SupabaseConsumoCombustibleDataSource: ✅ Registro eliminado');
    } catch (e) {
      throw Exception('Error al eliminar registro de consumo: $e');
    }
  }

  @override
  Stream<List<ConsumoCombustibleEntity>> watchAll() {
    try {
      return _supabase
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .order('fecha', ascending: false)
          .map((data) {
            return data
                .map((json) => ConsumoCombustibleSupabaseModel.fromJson(json).toEntity())
                .toList();
          });
    } catch (e) {
      throw Exception('Error en stream de registros de consumo: $e');
    }
  }

  @override
  Stream<ConsumoCombustibleEntity?> watchById(String id) {
    try {
      return _supabase
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .eq('id', id)
          .map((data) {
            if (data.isEmpty) {
              return null;
            }
            return ConsumoCombustibleSupabaseModel.fromJson(data.first).toEntity();
          });
    } catch (e) {
      throw Exception('Error en stream de registro por ID: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .count();
      return response.count;
    } catch (e) {
      throw Exception('Error al contar registros de consumo: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(_tableName).delete().neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (e) {
      throw Exception('Error al limpiar registros de consumo: $e');
    }
  }

  @override
  Future<List<ConsumoCombustibleEntity>> createBatch(List<ConsumoCombustibleEntity> entities) async {
    try {
      final models = entities.map((e) => ConsumoCombustibleSupabaseModel.fromEntity(e).toJson()).toList();

      final List<dynamic> response = await _supabase
          .from(_tableName)
          .insert(models)
          .select();

      return response
          .map((json) => ConsumoCombustibleSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear registros en lote: $e');
    }
  }

  @override
  Future<List<ConsumoCombustibleEntity>> updateBatch(List<ConsumoCombustibleEntity> entities) async {
    try {
      final List<ConsumoCombustibleEntity> updated = [];
      for (final entity in entities) {
        final result = await update(entity);
        updated.add(result);
      }
      return updated;
    } catch (e) {
      throw Exception('Error al actualizar registros en lote: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar registros en lote: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();
      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia del registro: $e');
    }
  }

  // ========== MÉTODOS ESPECÍFICOS DE CONSUMO DE COMBUSTIBLE ==========

  @override
  Future<List<ConsumoCombustibleEntity>> getByVehiculo(
    String vehiculoId, {
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = _supabase
          .from(_tableName)
          .select()
          .eq('vehiculo_id', vehiculoId);

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('fecha', ascending: false);

      return response
          .map((json) => ConsumoCombustibleSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener registros por vehículo: $e');
    }
  }

  @override
  Future<List<ConsumoCombustibleEntity>> getByRangoFechas(
    DateTime fechaInicio,
    DateTime fechaFin, {
    String? empresaId,
  }) async {
    try {
      final query = _supabase
          .from(_tableName)
          .select()
          .gte('fecha', fechaInicio.toIso8601String())
          .lte('fecha', fechaFin.toIso8601String());

      if (empresaId != null) {
        query.eq('empresa_id', empresaId);
      }

      final dynamic response = await query.order('fecha', ascending: false);

      return response
          .map((json) => ConsumoCombustibleSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener registros por rango de fechas: $e');
    }
  }

  @override
  Future<List<ConsumoCombustibleEntity>> getByVehiculoYFechas(
    String vehiculoId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('vehiculo_id', vehiculoId)
          .gte('fecha', fechaInicio.toIso8601String())
          .lte('fecha', fechaFin.toIso8601String())
          .order('fecha', ascending: false);

      return response
          .map((json) => ConsumoCombustibleSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener registros por vehículo y fechas: $e');
    }
  }

  @override
  Future<ConsumoCombustibleEntity?> getUltimoRegistro(String vehiculoId) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(_tableName)
          .select()
          .eq('vehiculo_id', vehiculoId)
          .order('fecha', ascending: false)
          .order('km_vehiculo', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ConsumoCombustibleSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener último registro: $e');
    }
  }

  @override
  Future<double> getUltimoKilometraje(String vehiculoId) async {
    try {
      final ultimo = await getUltimoRegistro(vehiculoId);
      return ultimo?.kmVehiculo ?? 0.0;
    } catch (e) {
      throw Exception('Error al obtener último kilometraje: $e');
    }
  }

  @override
  Future<Map<String, double>> getEstadisticas(
    String vehiculoId, {
    int dias = 30,
  }) async {
    try {
      final fechaInicio = DateTime.now().subtract(Duration(days: dias));

      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('vehiculo_id', vehiculoId)
          .gte('fecha', fechaInicio.toIso8601String())
          .order('fecha', ascending: true);

      final registros = (response as List)
          .map((json) => ConsumoCombustibleSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      double litrosTotales = 0.0;
      double costoTotal = 0.0;
      double kmRecorridos = 0.0;
      double sumaConsumos = 0.0;
      int countConsumos = 0;

      for (final registro in registros) {
        litrosTotales += registro.litros;
        costoTotal += registro.costoTotal;

        if (registro.kmRecorridosDesdeUltimo != null) {
          kmRecorridos += registro.kmRecorridosDesdeUltimo!;
        }

        if (registro.consumoL100km != null) {
          sumaConsumos += registro.consumoL100km!;
          countConsumos++;
        }
      }

      final consumoPromedio = countConsumos > 0 ? sumaConsumos / countConsumos : 0.0;

      return {
        'consumo_promedio': consumoPromedio,
        'km_recorridos': kmRecorridos,
        'litros_totales': litrosTotales,
        'costo_total': costoTotal,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  @override
  Future<Map<String, double>> getEstadisticasFlota(
    String empresaId, {
    int dias = 30,
  }) async {
    try {
      final fechaInicio = DateTime.now().subtract(Duration(days: dias));

      final dynamic response = await _supabase
          .from(_tableName)
          .select()
          .eq('empresa_id', empresaId)
          .gte('fecha', fechaInicio.toIso8601String())
          .order('fecha', ascending: true);

      final registros = (response as List)
          .map((json) => ConsumoCombustibleSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      double litrosTotales = 0.0;
      double costoTotal = 0.0;
      double kmRecorridos = 0.0;
      double sumaConsumos = 0.0;
      int countConsumos = 0;

      for (final registro in registros) {
        litrosTotales += registro.litros;
        costoTotal += registro.costoTotal;

        if (registro.kmRecorridosDesdeUltimo != null) {
          kmRecorridos += registro.kmRecorridosDesdeUltimo!;
        }

        if (registro.consumoL100km != null) {
          sumaConsumos += registro.consumoL100km!;
          countConsumos++;
        }
      }

      final consumoPromedio = countConsumos > 0 ? sumaConsumos / countConsumos : 0.0;

      return {
        'consumo_promedio': consumoPromedio,
        'km_recorridos': kmRecorridos,
        'litros_totales': litrosTotales,
        'costo_total': costoTotal,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas de flota: $e');
    }
  }

  @override
  Future<List<ConsumoCombustibleEntity>> getByEmpresa(
    String empresaId, {
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = _supabase
          .from(_tableName)
          .select()
          .eq('empresa_id', empresaId);

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('fecha', ascending: false);

      return response
          .map((json) => ConsumoCombustibleSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener registros por empresa: $e');
    }
  }

  @override
  Future<double> getConsumoMesVehiculo(
    String vehiculoId,
    int anio,
    int mes,
  ) async {
    try {
      final fechaInicio = DateTime(anio, mes, 1);
      final fechaFin = DateTime(anio, mes + 1, 1).subtract(const Duration(days: 1));

      final dynamic response = await _supabase
          .from(_tableName)
          .select('litros')
          .eq('vehiculo_id', vehiculoId)
          .gte('fecha', fechaInicio.toIso8601String())
          .lte('fecha', fechaFin.toIso8601String());

      double total = 0.0;
      for (final row in response as List) {
        final litros = (row as Map<String, dynamic>)['litros'];
        if (litros != null) {
          total += _parseDouble(litros) ?? 0.0;
        }
      }

      return total;
    } catch (e) {
      throw Exception('Error al obtener consumo del mes: $e');
    }
  }

  @override
  Future<double> getCostoMesEmpresa(
    String empresaId,
    int anio,
    int mes,
  ) async {
    try {
      final fechaInicio = DateTime(anio, mes, 1);
      final fechaFin = DateTime(anio, mes + 1, 1).subtract(const Duration(days: 1));

      final dynamic response = await _supabase
          .from(_tableName)
          .select('costo_total')
          .eq('empresa_id', empresaId)
          .gte('fecha', fechaInicio.toIso8601String())
          .lte('fecha', fechaFin.toIso8601String());

      double total = 0.0;
      for (final row in response as List) {
        final costo = (row as Map<String, dynamic>)['costo_total'];
        if (costo != null) {
          total += _parseDouble(costo) ?? 0.0;
        }
      }

      return total;
    } catch (e) {
      throw Exception('Error al obtener costo del mes: $e');
    }
  }

  @override
  Future<double> getKmMesVehiculo(
    String vehiculoId,
    int anio,
    int mes,
  ) async {
    try {
      final fechaInicio = DateTime(anio, mes, 1);
      final fechaFin = DateTime(anio, mes + 1, 1).subtract(const Duration(days: 1));

      final dynamic response = await _supabase
          .from(_tableName)
          .select('km_recorridos_desde_ultimo')
          .eq('vehiculo_id', vehiculoId)
          .gte('fecha', fechaInicio.toIso8601String())
          .lte('fecha', fechaFin.toIso8601String());

      double total = 0.0;
      for (final row in response as List) {
        final km = (row as Map<String, dynamic>)['km_recorridos_desde_ultimo'];
        if (km != null) {
          total += _parseDouble(km) ?? 0.0;
        }
      }

      return total;
    } catch (e) {
      throw Exception('Error al obtener km del mes: $e');
    }
  }

  /// Helper para parsear doubles de forma segura
  double? _parseDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String && value.isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Helper para imprimir logs de debug
  void debugPrint(String message) {
    // ignore: avoid_print
    print(message);
  }
}
