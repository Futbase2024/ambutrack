import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/registro_horario_entity.dart';
import '../../models/registro_horario_supabase_model.dart';

/// Operaciones adicionales para RegistroHorarioDataSource (Supabase)
///
/// Contiene operaciones de registro, cálculos y estadísticas
mixin SupabaseRegistroHorarioOperations {
  SupabaseClient get supabase;
  String get tableName;

  // ==================== REGISTRO ENTRADA/SALIDA ====================

  Future<RegistroHorarioEntity> registrarEntrada({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    String? vehiculoId,
    String? turno,
    String? notas,
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        'personal_id': personalId,
        'nombre_personal': nombrePersonal,
        'tipo': 'entrada',
        'fecha_hora': now.toIso8601String(),
        'ubicacion': ubicacion,
        'latitud': latitud,
        'longitud': longitud,
        'vehiculo_id': vehiculoId,
        'turno': turno,
        'notas': notas,
        'estado': 'normal',
        'es_manual': false,
        'activo': true,
      };

      final response = await supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return RegistroHorarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al registrar entrada: $e');
    }
  }

  Future<RegistroHorarioEntity> registrarSalida({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    String? notas,
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        'personal_id': personalId,
        'nombre_personal': nombrePersonal,
        'tipo': 'salida',
        'fecha_hora': now.toIso8601String(),
        'ubicacion': ubicacion,
        'latitud': latitud,
        'longitud': longitud,
        'notas': notas,
        'estado': 'normal',
        'es_manual': false,
        'activo': true,
      };

      final response = await supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return RegistroHorarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al registrar salida: $e');
    }
  }

  Future<RegistroHorarioEntity> registrarManual({
    required String personalId,
    String? nombrePersonal,
    required String tipo,
    required DateTime fechaHora,
    required String usuarioManualId,
    String? ubicacion,
    String? vehiculoId,
    String? turno,
    String? notas,
  }) async {
    try {
      final data = {
        'personal_id': personalId,
        'nombre_personal': nombrePersonal,
        'tipo': tipo,
        'fecha_hora': fechaHora.toIso8601String(),
        'ubicacion': ubicacion,
        'vehiculo_id': vehiculoId,
        'turno': turno,
        'notas': notas,
        'estado': 'normal',
        'es_manual': true,
        'usuario_manual_id': usuarioManualId,
        'activo': true,
      };

      final response = await supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return RegistroHorarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al registrar manual: $e');
    }
  }

  // ==================== FICHAJE ACTIVO ====================

  Future<bool> tieneFichajeActivo(String personalId) async {
    try {
      final fichajeActivo = await getFichajeActivo(personalId);
      return fichajeActivo != null;
    } catch (e) {
      throw Exception('Error al verificar fichaje activo: $e');
    }
  }

  Future<RegistroHorarioEntity?> getFichajeActivo(String personalId) async {
    try {
      // Buscar la última entrada sin salida correspondiente
      final response = await supabase
          .from(tableName)
          .select()
          .eq('personal_id', personalId)
          .eq('tipo', 'entrada')
          .order('fecha_hora', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      final ultimaEntrada = RegistroHorarioSupabaseModel.fromJson(response).toEntity();

      // Verificar si hay una salida después de esta entrada
      final salidaResponse = await supabase
          .from(tableName)
          .select()
          .eq('personal_id', personalId)
          .eq('tipo', 'salida')
          .gt('fecha_hora', ultimaEntrada.fechaHora.toIso8601String())
          .limit(1)
          .maybeSingle();

      // Si no hay salida, la entrada está activa
      if (salidaResponse == null) {
        return ultimaEntrada;
      }

      return null;
    } catch (e) {
      throw Exception('Error al obtener fichaje activo: $e');
    }
  }

  // ==================== CÁLCULOS ====================

  double calcularHorasTrabajadas(
    RegistroHorarioEntity registroEntrada,
    RegistroHorarioEntity registroSalida,
  ) {
    final diferencia = registroSalida.fechaHora.difference(registroEntrada.fechaHora);
    return diferencia.inMinutes / 60.0;
  }

  Future<double> getHorasTrabajadasPorFecha(String personalId, DateTime fecha) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));
    return getHorasTrabajadasPorRango(personalId, inicio, fin);
  }

  Future<double> getHorasTrabajadasPorRango(
    String personalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      final response = await supabase
          .from(tableName)
          .select()
          .eq('personal_id', personalId)
          .gte('fecha_hora', fechaInicio.toIso8601String())
          .lte('fecha_hora', fechaFin.toIso8601String())
          .order('fecha_hora', ascending: true);

      final registros = (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();

      double totalHoras = 0;
      RegistroHorarioEntity? ultimaEntrada;

      for (final registro in registros) {
        if (registro.tipo == 'entrada') {
          ultimaEntrada = registro;
        } else if (registro.tipo == 'salida' && ultimaEntrada != null) {
          totalHoras += calcularHorasTrabajadas(ultimaEntrada, registro);
          ultimaEntrada = null;
        }
      }

      return totalHoras;
    } catch (e) {
      throw Exception('Error al calcular horas trabajadas: $e');
    }
  }

  // ==================== ESTADÍSTICAS ====================

  Future<Map<String, dynamic>> getEstadisticas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      var query = supabase.from(tableName).select();

      if (fechaInicio != null) {
        query = query.gte('fecha_hora', fechaInicio.toIso8601String());
      }
      if (fechaFin != null) {
        query = query.lte('fecha_hora', fechaFin.toIso8601String());
      }

      final response = await query;
      final registros = (response as List)
          .map((json) => RegistroHorarioSupabaseModel.fromJson(json).toEntity())
          .toList();

      return {
        'total': registros.length,
        'entradas': registros.where((r) => r.tipo == 'entrada').length,
        'salidas': registros.where((r) => r.tipo == 'salida').length,
        'manuales': registros.where((r) => r.esManual).length,
        'activos': registros.where((r) => r.activo).length,
        'porEstado': {
          'normal': registros.where((r) => r.estado == 'normal').length,
          'tarde': registros.where((r) => r.estado == 'tarde').length,
          'temprano': registros.where((r) => r.estado == 'temprano').length,
          'festivo': registros.where((r) => r.estado == 'festivo').length,
        },
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // ==================== ACTIVAR/DESACTIVAR ====================

  Future<RegistroHorarioEntity> deactivateRegistro(String registroId) async {
    try {
      final data = {
        'activo': false,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from(tableName)
          .update(data)
          .eq('id', registroId)
          .select()
          .single();

      return RegistroHorarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al desactivar registro: $e');
    }
  }

  Future<RegistroHorarioEntity> reactivateRegistro(String registroId) async {
    try {
      final data = {
        'activo': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from(tableName)
          .update(data)
          .eq('id', registroId)
          .select()
          .single();

      return RegistroHorarioSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al reactivar registro: $e');
    }
  }

  // ==================== IMPORTAR/EXPORTAR ====================

  Future<Map<String, dynamic>> exportRegistros({
    String? personalId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      var query = supabase.from(tableName).select();

      if (personalId != null) {
        query = query.eq('personal_id', personalId);
      }
      if (fechaInicio != null) {
        query = query.gte('fecha_hora', fechaInicio.toIso8601String());
      }
      if (fechaFin != null) {
        query = query.lte('fecha_hora', fechaFin.toIso8601String());
      }

      final response = await query.order('fecha_hora', ascending: true);

      return {
        'version': '1.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'count': (response as List).length,
        'registros': response.map((json) =>
            RegistroHorarioSupabaseModel.fromJson(json).toEntity().toJson()).toList(),
      };
    } catch (e) {
      throw Exception('Error al exportar registros: $e');
    }
  }

  Future<List<RegistroHorarioEntity>> importRegistros(
    Map<String, dynamic> registroData, {
    bool updateExisting = false,
  }) async {
    try {
      final registros = (registroData['registros'] as List)
          .map((json) => RegistroHorarioEntity.fromJson(json))
          .toList();

      final importados = <RegistroHorarioEntity>[];

      for (final registro in registros) {
        final model = RegistroHorarioSupabaseModel.fromEntity(registro);
        final data = model.toJson();

        if (updateExisting) {
          final exists = await supabase
              .from(tableName)
              .select('id')
              .eq('id', registro.id)
              .maybeSingle();

          if (exists != null) {
            data.remove('created_at');
            data['updated_at'] = DateTime.now().toIso8601String();

            final response = await supabase
                .from(tableName)
                .update(data)
                .eq('id', registro.id)
                .select()
                .single();

            importados.add(RegistroHorarioSupabaseModel.fromJson(response).toEntity());
          } else {
            data.remove('id');
            data.remove('created_at');
            data.remove('updated_at');

            final response = await supabase
                .from(tableName)
                .insert(data)
                .select()
                .single();

            importados.add(RegistroHorarioSupabaseModel.fromJson(response).toEntity());
          }
        } else {
          data.remove('id');
          data.remove('created_at');
          data.remove('updated_at');

          final response = await supabase
              .from(tableName)
              .insert(data)
              .select()
              .single();

          importados.add(RegistroHorarioSupabaseModel.fromJson(response).toEntity());
        }
      }

      return importados;
    } catch (e) {
      throw Exception('Error al importar registros: $e');
    }
  }
}
