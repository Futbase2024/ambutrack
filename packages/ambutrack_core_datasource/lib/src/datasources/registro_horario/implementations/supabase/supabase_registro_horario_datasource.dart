import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../registro_horario_contract.dart';
import '../../entities/registro_horario_entity.dart';
import '../../models/registro_horario_supabase_model.dart';
import 'supabase_registro_horario_operations.dart';

/// Implementación de Supabase para el datasource de registro horario
///
/// Proporciona operaciones CRUD y consultas específicas usando Supabase
class SupabaseRegistroHorarioDataSource
    with SupabaseRegistroHorarioOperations
    implements RegistroHorarioDataSource {
  final SupabaseClient _supabase;
  final String _tableName;

  SupabaseRegistroHorarioDataSource({
    SupabaseClient? supabase,
    String tableName = 'registros_horarios',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  @override
  SupabaseClient get supabase => _supabase;

  @override
  String get tableName => _tableName;

  // ==================== CRUD BÁSICO ====================

  @override
  Future<List<RegistroHorarioEntity>> getAll({int? limit, int? offset}) async {
    try {
      var query = _supabase
          .from(_tableName)
          .select()
          .order('fecha_hora', ascending: false);

      if (limit != null) query = query.limit(limit);
      if (offset != null) query = query.range(offset, offset + (limit ?? 10) - 1);

      final response = await query;
      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener registros: $e');
    }
  }

  @override
  Future<RegistroHorarioEntity?> getById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return RegistroHorarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener registro: $e');
    }
  }

  @override
  Future<RegistroHorarioEntity> create(RegistroHorarioEntity entity) async {
    try {
      final model = RegistroHorarioSupabaseModel.fromEntity(entity);
      final data = model.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      // Debug: Ver qué datos se envían a Supabase
      debugPrint('🔍 [DataSource] Datos a insertar en Supabase:');
      debugPrint('   - vehiculo_id: ${data['vehiculo_id']}');
      debugPrint('   - vehiculo_matricula: ${data['vehiculo_matricula']}');
      debugPrint('   - precision_gps: ${data['precision_gps']}');
      debugPrint('   - tipo: ${data['tipo']}');

      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('🔍 [DataSource] Respuesta de Supabase:');
      debugPrint('   - vehiculo_id: ${response['vehiculo_id']}');
      debugPrint('   - vehiculo_matricula: ${response['vehiculo_matricula']}');
      debugPrint('   - precision_gps: ${response['precision_gps']}');

      return RegistroHorarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear registro: $e');
    }
  }

  @override
  Future<RegistroHorarioEntity> update(RegistroHorarioEntity entity) async {
    try {
      final model = RegistroHorarioSupabaseModel.fromEntity(entity);
      final data = model.toJson();
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', entity.id)
          .select()
          .single();

      return RegistroHorarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar registro: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar registro: $e');
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
      throw Exception('Error al verificar existencia: $e');
    }
  }

  // ==================== STREAMING ====================

  @override
  Stream<List<RegistroHorarioEntity>> watchAll() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha_hora', ascending: false)
        .map((data) => data.map((json) =>
            RegistroHorarioSupabaseModel.fromJson(json).toEntity()).toList());
  }

  @override
  Stream<RegistroHorarioEntity?> watchById(String id) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) => data.isEmpty
            ? null
            : RegistroHorarioSupabaseModel.fromJson(data.first).toEntity());
  }

  // ==================== CONSULTAS POR PERSONAL ====================

  @override
  Future<List<RegistroHorarioEntity>> getByPersonalId(String personalId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('personal_id', personalId)
          .order('fecha_hora', ascending: false);

      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener registros por personal: $e');
    }
  }

  @override
  Future<List<RegistroHorarioEntity>> getByPersonalIdAndDateRange(
    String personalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('personal_id', personalId)
          .gte('fecha_hora', fechaInicio.toIso8601String())
          .lte('fecha_hora', fechaFin.toIso8601String())
          .order('fecha_hora', ascending: false);

      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener registros por personal y rango: $e');
    }
  }

  @override
  Future<RegistroHorarioEntity?> getUltimoRegistro(String personalId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('personal_id', personalId)
          .order('fecha_hora', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return RegistroHorarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener último registro: $e');
    }
  }

  @override
  Stream<List<RegistroHorarioEntity>> watchByPersonalId(String personalId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('personal_id', personalId)
        .order('fecha_hora', ascending: false)
        .map((data) => data.map((json) =>
            RegistroHorarioSupabaseModel.fromJson(json).toEntity()).toList());
  }

  // ==================== CONSULTAS POR FECHA ====================

  @override
  Future<List<RegistroHorarioEntity>> getByFecha(DateTime fecha) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));
    return getByDateRange(inicio, fin);
  }

  @override
  Future<List<RegistroHorarioEntity>> getByDateRange(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      // Convertir a UTC para comparación correcta con Supabase
      final DateTime fechaInicioUtc = fechaInicio.toUtc();
      final DateTime fechaFinUtc = fechaFin.toUtc();

      print('🔍 [DataSource] Consultando tabla: $_tableName');
      print('   Desde (local): ${fechaInicio.toIso8601String()}');
      print('   Desde (UTC):   ${fechaInicioUtc.toIso8601String()}');
      print('   Hasta (local): ${fechaFin.toIso8601String()}');
      print('   Hasta (UTC):   ${fechaFinUtc.toIso8601String()}');

      // Consultar con filtro de fecha en UTC
      // TODO: Agregar JOIN con tvehiculos cuando exista la foreign key
      final response = await _supabase
          .from(_tableName)
          .select()
          .gte('fecha_hora', fechaInicioUtc.toIso8601String())
          .lte('fecha_hora', fechaFinUtc.toIso8601String())
          .order('fecha_hora', ascending: false);

      print('   Registros encontrados con filtro: ${(response as List).length}');

      if ((response as List).isNotEmpty) {
        print('   Muestra de registros (hasta 5):');
        final int limit = (response as List).length > 5 ? 5 : (response as List).length;
        for (int i = 0; i < limit; i++) {
          final json = (response as List)[i];
          print('   ${i + 1}. ${json['nombre_personal'] ?? 'SIN NOMBRE'} (${json['tipo']}) - ${json['fecha_hora']}');
        }
      } else {
        print('   ⚠️  No se encontraron registros con filtro de fecha');
        print('   📅 Consultando últimos 10 registros sin filtro para diagnóstico...');

        final allResponse = await _supabase
            .from(_tableName)
            .select()
            .order('fecha_hora', ascending: false)
            .limit(10);

        if ((allResponse as List).isNotEmpty) {
          print('   📊 Total de registros encontrados sin filtro: ${(allResponse as List).length}');
          print('   📅 Últimos registros en la tabla:');
          for (final json in (allResponse as List)) {
            print('   - ${json['nombre_personal'] ?? 'SIN NOMBRE'} (${json['tipo']}) - ${json['fecha_hora']}');
          }
        } else {
          print('   ⚠️  La tabla está completamente vacía');
        }
      }

      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e, stackTrace) {
      print('❌ [DataSource] Error: $e');
      print('   StackTrace: $stackTrace');
      throw Exception('Error al obtener registros por rango: $e');
    }
  }

  @override
  Stream<List<RegistroHorarioEntity>> watchByDateRange(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) {
    // Supabase streams no soportan múltiples filtros, filtramos en cliente
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha_hora', ascending: false)
        .map((data) {
          final all = data.map((json) =>
              RegistroHorarioSupabaseModel.fromJson(json).toEntity()).toList();
          return all.where((r) =>
              r.fechaHora.isAfter(fechaInicio) &&
              r.fechaHora.isBefore(fechaFin)).toList();
        });
  }

  // ==================== CONSULTAS POR TIPO Y ESTADO ====================

  @override
  Future<List<RegistroHorarioEntity>> getByTipo(String tipo) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo', tipo)
          .order('fecha_hora', ascending: false);

      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener registros por tipo: $e');
    }
  }

  @override
  Future<List<RegistroHorarioEntity>> getByEstado(String estado) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', estado)
          .order('fecha_hora', ascending: false);

      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener registros por estado: $e');
    }
  }

  @override
  Future<List<RegistroHorarioEntity>> getActivos() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('fecha_hora', ascending: false);

      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener registros activos: $e');
    }
  }

  @override
  Future<List<RegistroHorarioEntity>> getRegistrosManuales() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('es_manual', true)
          .order('fecha_hora', ascending: false);

      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener registros manuales: $e');
    }
  }

  // ==================== MÉTODOS DE BASEDATASOURCE ====================

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(_tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Error al limpiar registros: $e');
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
      throw Exception('Error al contar registros: $e');
    }
  }

  @override
  Future<List<RegistroHorarioEntity>> createBatch(
    List<RegistroHorarioEntity> entities,
  ) async {
    try {
      final dataList = entities.map((e) {
        final model = RegistroHorarioSupabaseModel.fromEntity(e);
        final data = model.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        return data;
      }).toList();

      final response = await _supabase
          .from(_tableName)
          .insert(dataList)
          .select();

      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear registros en batch: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(_tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar registros en batch: $e');
    }
  }

  @override
  Future<List<RegistroHorarioEntity>> updateBatch(
    List<RegistroHorarioEntity> entities,
  ) async {
    try {
      final updated = <RegistroHorarioEntity>[];
      for (final entity in entities) {
        final result = await update(entity);
        updated.add(result);
      }
      return updated;
    } catch (e) {
      throw Exception('Error al actualizar registros en batch: $e');
    }
  }
}
