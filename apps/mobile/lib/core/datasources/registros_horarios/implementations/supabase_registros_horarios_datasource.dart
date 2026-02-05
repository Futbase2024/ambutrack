import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/registro_horario_entity.dart';
import '../models/registro_horario_supabase_model.dart';
import '../registros_horarios_datasource_contract.dart';

/// Implementación de RegistrosHorariosDataSource usando Supabase
class SupabaseRegistrosHorariosDataSource implements RegistrosHorariosDataSource {
  SupabaseRegistrosHorariosDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<RegistroHorarioEntity> crear(RegistroHorarioEntity registro) async {
    try {
      debugPrint('🕐 [RegistrosHorarios] Creando fichaje ${registro.tipoFichaje.value}...');

      final model = RegistroHorarioSupabaseModel.fromEntity(registro);
      final response = await _client
          .from('registros_horarios')
          .insert(model.toJson())
          .select()
          .single();

      debugPrint('✅ [RegistrosHorarios] Fichaje creado: ${response['id']}');

      final createdModel = RegistroHorarioSupabaseModel.fromJson(response);
      return createdModel.toEntity();
    } catch (e) {
      debugPrint('❌ [RegistrosHorarios] Error al crear fichaje: $e');
      throw Exception('Error al crear registro horario: $e');
    }
  }

  @override
  Future<List<RegistroHorarioEntity>> obtenerPorPersonal(
    String personalId, {
    int limit = 10,
  }) async {
    try {
      debugPrint('🔍 [RegistrosHorarios] Buscando registros de personal: $personalId');

      final response = await _client
          .from('registros_horarios')
          .select()
          .eq('personal_id', personalId)
          .order('fecha_hora', ascending: false)
          .limit(limit);

      debugPrint('✅ [RegistrosHorarios] ${response.length} registros encontrados');

      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      debugPrint('❌ [RegistrosHorarios] Error al obtener registros: $e');
      return [];
    }
  }

  @override
  Future<RegistroHorarioEntity?> obtenerUltimo(String personalId) async {
    try {
      debugPrint('🔍 [RegistrosHorarios] Buscando último registro de: $personalId');

      final response = await _client
          .from('registros_horarios')
          .select()
          .eq('personal_id', personalId)
          .order('fecha_hora', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        debugPrint('ℹ️ [RegistrosHorarios] No hay registros previos');
        return null;
      }

      debugPrint('✅ [RegistrosHorarios] Último registro: ${response['tipo_fichaje']}');

      final model = RegistroHorarioSupabaseModel.fromJson(response);
      return model.toEntity();
    } catch (e) {
      debugPrint('❌ [RegistrosHorarios] Error al obtener último registro: $e');
      return null;
    }
  }

  @override
  Future<List<RegistroHorarioEntity>> obtenerPorRangoFechas(
    String personalId,
    DateTime inicio,
    DateTime fin,
  ) async {
    try {
      debugPrint('🔍 [RegistrosHorarios] Buscando registros entre $inicio y $fin');

      final response = await _client
          .from('registros_horarios')
          .select()
          .eq('personal_id', personalId)
          .gte('fecha_hora', inicio.toIso8601String())
          .lte('fecha_hora', fin.toIso8601String())
          .order('fecha_hora', ascending: false);

      debugPrint('✅ [RegistrosHorarios] ${response.length} registros en rango');

      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      debugPrint('❌ [RegistrosHorarios] Error al obtener registros por rango: $e');
      return [];
    }
  }

  @override
  Future<List<RegistroHorarioEntity>> obtenerTodos(String personalId) async {
    try {
      debugPrint('🔍 [RegistrosHorarios] Buscando TODOS los registros de: $personalId');
      debugPrint('⚠️ [RegistrosHorarios] Advertencia: Sin límite de registros');

      final response = await _client
          .from('registros_horarios')
          .select()
          .eq('personal_id', personalId)
          .order('fecha_hora', ascending: false);

      debugPrint('✅ [RegistrosHorarios] ${response.length} registros totales');

      return (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      debugPrint('❌ [RegistrosHorarios] Error al obtener todos los registros: $e');
      return [];
    }
  }
}
