import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/estado_traslado.dart';
import '../../entities/evento_traslado_type.dart';
import '../../entities/historial_estado_entity.dart';
import '../../entities/traslado_entity.dart';
import '../../entities/traslado_evento_entity.dart';
import '../../entities/ubicacion_entity.dart';
import '../../models/traslado_supabase_model.dart';
import '../../traslado_contract.dart';

/// Implementación del DataSource de Traslados usando Supabase
/// Maneja traslados individuales generados desde servicios recurrentes
/// Incluye tracking de estados (cronas) y ubicaciones GPS
class SupabaseTrasladoDataSource implements TrasladoDataSource {
  SupabaseTrasladoDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'traslados';

  @override
  Future<List<TrasladoEntity>> getAll() async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo todos los traslados (con paciente y motivo embebidos)...',
      );

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados: $e',
      );
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> getById(String id) async {
    try {
      debugPrint('📦 SupabaseTrasladoDataSource: Obteniendo traslado ID: $id');

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .eq('id', id)
          .single();

      debugPrint('📦 SupabaseTrasladoDataSource: ✅ Traslado obtenido');

      // 🔍 LOGGING: Verificar si viene con paciente embebido
      final tienePaciente = response.containsKey('pacientes') && response['pacientes'] != null;
      debugPrint('🔍 [getById] id_paciente=${response['id_paciente']}, tienePaciente=$tienePaciente');
      if (tienePaciente) {
        final pacienteJson = response['pacientes'] as Map<String, dynamic>?;
        debugPrint('   👤 Paciente embebido: nombre=${pacienteJson?['nombre']}, apellido1=${pacienteJson?['primer_apellido']}');
      } else {
        debugPrint('   ⚠️  Paciente NO embebido (pacientes=null o clave no existe)');
      }

      return TrasladoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslado: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByServicioRecurrente(
    String idServicioRecurrente,
  ) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados del servicio: $idServicioRecurrente (con paciente y motivo embebidos)',
      );

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .eq('id_servicio_recurrente', idServicioRecurrente)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados por servicio: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByServiciosRecurrentes(
    List<String> idsServiciosRecurrentes,
  ) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados de ${idsServiciosRecurrentes.length} servicios (con paciente y motivo embebidos)',
      );
      debugPrint('   IDs de servicios buscados: $idsServiciosRecurrentes');

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .inFilter('id_servicio', idsServiciosRecurrentes)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos con paciente y motivo',
      );

      if (response.isEmpty) {
        debugPrint('⚠️ No se encontraron traslados para los IDs de servicios proporcionados');
        debugPrint('   Verifica que:');
        debugPrint('   1. Los traslados existan en la tabla "traslados" de Supabase');
        debugPrint('   2. La columna "id_servicio" tenga estos valores exactos');
        debugPrint('   3. No haya problemas de permisos RLS (Row Level Security)');
        debugPrint('   4. Los IDs no sean NULL en la base de datos');
      } else {
        debugPrint('   Primeros traslados obtenidos:');
        for (final item in response.take(3)) {
          debugPrint('   - ID: ${item['id']}, Fecha: ${item['fecha']}, IdServicio: ${item['id_servicio']}, IdServicioRecurrente: ${item['id_servicio_recurrente']}');
        }
      }

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados por servicios: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByServiciosYFecha({
    required List<String> idsServiciosRecurrentes,
    required DateTime fecha,
  }) async {
    try {
      // Normalizar fecha a medianoche (eliminar hora)
      final DateTime fechaNormalizada = DateTime(fecha.year, fecha.month, fecha.day);
      final String fechaString = fechaNormalizada.toIso8601String().split('T')[0];

      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados de ${idsServiciosRecurrentes.length} servicios para fecha $fechaString (con paciente y motivo traslado embebidos)',
      );
      debugPrint('   IDs de servicios: $idsServiciosRecurrentes');

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .inFilter('id_servicio', idsServiciosRecurrentes)
          .eq('fecha', fechaString)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos con paciente y motivo para $fechaString',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados por servicios y fecha: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getTrasladosByServicioId(
    String servicioId,
  ) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados del servicio padre: $servicioId (con paciente y motivo embebidos)',
      );

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .eq('id_servicio', servicioId)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados por servicio padre: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByPaciente(String idPaciente) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados del paciente: $idPaciente (con paciente y motivo embebidos)',
      );

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .eq('id_paciente', idPaciente)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados por paciente: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByConductor(String idConductor) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados del conductor: $idConductor (con paciente y motivo embebidos)',
      );

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .eq('id_conductor', idConductor)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados por conductor: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByIdConductor(String idConductor) async {
    // Alias de getByConductor para compatibilidad
    return getByConductor(idConductor);
  }

  @override
  Future<List<TrasladoEntity>> getActivosByIdConductor(
    String idConductor,
  ) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados activos del conductor: $idConductor (con paciente y motivo embebidos)',
      );

      // Estados activos (en curso)
      final estadosActivos = [
        'asignado',
        'enviado',
        'recibido_conductor',
        'en_origen',
        'saliendo_origen',
        'en_transito',
        'en_destino',
      ];

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .eq('id_conductor', idConductor)
          .inFilter('estado', estadosActivos)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados activos obtenidos con paciente y motivo',
      );

      // 🔍 LOGGING: Inspeccionar qué devuelve Supabase para diagnosticar
      for (var i = 0; i < (response as List).length; i++) {
        final trasladoJson = response[i];
        final tienePaciente = trasladoJson.containsKey('pacientes') && trasladoJson['pacientes'] != null;
        debugPrint('🔍 [Traslado $i] id=${trasladoJson['id']}, id_paciente=${trasladoJson['id_paciente']}, tienePaciente=$tienePaciente');
        if (tienePaciente) {
          final pacienteJson = trasladoJson['pacientes'] as Map<String, dynamic>?;
          debugPrint('   👤 Paciente embebido: nombre=${pacienteJson?['nombre']}, apellido1=${pacienteJson?['primer_apellido']}');
        } else {
          debugPrint('   ⚠️  Paciente NO embebido (pacientes=null o clave no existe)');
        }
      }

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados activos por conductor: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByVehiculo(String idVehiculo) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados del vehículo: $idVehiculo (con paciente y motivo embebidos)',
      );

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .eq('id_vehiculo', idVehiculo)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados por vehículo: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByEstado({
    required EstadoTraslado estado,
    String? idConductor,
  }) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados con estado: ${estado.value}${idConductor != null ? ' para conductor: $idConductor' : ''} (con paciente y motivo embebidos)',
      );

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      var query = _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .eq('estado', estado.value);

      if (idConductor != null) {
        query = query.eq('id_conductor', idConductor);
      }

      final response = await query
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados por estado: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByFecha(DateTime fecha) async {
    try {
      final fechaStr = fecha.toIso8601String().split('T').first;

      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados de la fecha: $fechaStr (con paciente y motivo traslado embebidos)',
      );

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .eq('fecha', fechaStr)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados por fecha: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? idConductor,
  }) async {
    try {
      final desdeStr = fechaInicio.toIso8601String().split('T').first;
      final hastaStr = fechaFin.toIso8601String().split('T').first;

      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados entre $desdeStr y $hastaStr${idConductor != null ? ' para conductor: $idConductor' : ''} (con paciente y motivo embebidos)',
      );

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      var query = _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .gte('fecha', desdeStr)
          .lte('fecha', hastaStr);

      if (idConductor != null) {
        query = query.eq('id_conductor', idConductor);
      }

      final response = await query
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados por rango: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getEnCurso() async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados en curso (con paciente y motivo embebidos)...',
      );

      // Estados EN CURSO: pendiente, asignado, enviado, recibido_conductor,
      // en_origen, saliendo_origen, en_transito, en_destino
      final estadosEnCurso = [
        'pendiente',
        'asignado',
        'enviado',
        'recibido_conductor',
        'en_origen',
        'saliendo_origen',
        'en_transito',
        'en_destino',
      ];

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .inFilter('estado', estadosEnCurso)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados en curso con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados en curso: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getRequierenAsignacion() async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados que requieren asignación (con paciente y motivo embebidos)...',
      );

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .eq('estado', 'pendiente')
          .or('id_conductor.is.null,id_vehiculo.is.null')
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados pendientes de asignación con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener traslados pendientes: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> searchByCodigo(String query) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Buscando traslados con código: "$query" (con paciente y motivo embebidos)',
      );

      if (query.isEmpty) {
        return getAll();
      }

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .ilike('codigo', '%$query%')
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados encontrados con paciente y motivo',
      );

      return (response as List)
          .map((json) => TrasladoSupabaseModel.fromJson(
                json as Map<String, dynamic>,
              ).toEntity())
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error en búsqueda: $e',
      );
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> create(TrasladoEntity traslado) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Creando traslado manual: ${traslado.codigo}',
      );

      final model = TrasladoSupabaseModel.fromEntity(traslado);
      final json = model.toJson();

      // Remover campos autogenerados
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');

      // Incluir JOINs con pacientes y tmotivos_traslado para obtener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .insert(json)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .single();

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ Traslado creado exitosamente',
      );

      return TrasladoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al crear traslado: $e',
      );
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> update({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Actualizando traslado ID: $id',
      );

      // Remover campos de auditoría que no deben actualizarse manualmente
      final updateData = Map<String, dynamic>.from(updates);
      updateData.remove('created_at');
      updateData.remove('created_by');
      updateData.remove('updated_at');

      // Incluir JOINs con pacientes y tmotivos_traslado para mantener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .single();

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ Traslado actualizado exitosamente',
      );

      return TrasladoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al actualizar traslado: $e',
      );
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> cambiarEstado({
    required String idTraslado,
    required EstadoTraslado nuevoEstado,
    required String idUsuario,
    UbicacionEntity? ubicacion,
    String? observaciones,
  }) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Cambiando estado de traslado $idTraslado a ${nuevoEstado.value}',
      );

      // Obtener estado anterior
      final trasladoActual = await getById(idTraslado);
      final estadoAnterior = trasladoActual.estado;

      // Actualizar estado usando updateEstado (que ya maneja las cronas)
      final trasladoActualizado = await updateEstado(
        id: idTraslado,
        nuevoEstado: nuevoEstado.value,
        ubicacion: ubicacion?.toJson(),
      );

      // Registrar en historial de estados
      await _supabase.from('historial_estados_traslado').insert({
        'id_traslado': idTraslado,
        'estado_anterior': estadoAnterior,
        'estado_nuevo': nuevoEstado.value,
        'fecha_cambio': DateTime.now().toIso8601String(),
        'id_usuario': idUsuario,
        if (ubicacion != null) 'ubicacion': ubicacion.toJson(),
        if (observaciones != null) 'observaciones': observaciones,
      });

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ Estado cambiado y registrado en historial',
      );

      return trasladoActualizado;
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al cambiar estado: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<HistorialEstadoEntity>> getHistorialEstados(
    String idTraslado,
  ) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo historial de estados del traslado: $idTraslado',
      );

      final response = await _supabase
          .from('historial_estados_traslado')
          .select()
          .eq('id_traslado', idTraslado)
          .order('fecha_cambio', ascending: false);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} cambios de estado obtenidos',
      );

      return (response as List)
          .map((json) => HistorialEstadoEntity.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al obtener historial: $e',
      );
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> updateEstado({
    required String id,
    required String nuevoEstado,
    Map<String, dynamic>? ubicacion,
  }) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Actualizando estado a "$nuevoEstado" para traslado ID: $id',
      );

      // Construir JSON de actualización según el estado
      final updateData = <String, dynamic>{'estado': nuevoEstado};
      final now = DateTime.now().toIso8601String();

      // Estados anormales (terminaciones no exitosas)
      const estadosAnormales = ['cancelado', 'suspendido', 'no_realizado'];
      final esEstadoAnormal = estadosAnormales.contains(nuevoEstado);

      // Si cambiamos a un estado normal, limpiar todas las fechas de estados anormales
      if (!esEstadoAnormal) {
        updateData['fecha_cancelacion'] = null;
        updateData['fecha_suspendido'] = null;
        updateData['fecha_no_realizado'] = null;
      }

      // Actualizar la crona correspondiente según el nuevo estado
      switch (nuevoEstado) {
        case 'enviado':
          updateData['fecha_enviado'] = now;
        case 'recibido_conductor':
          updateData['fecha_recibido_conductor'] = now;
        case 'en_origen':
          updateData['fecha_en_origen'] = now;
          if (ubicacion != null) {
            updateData['ubicacion_en_origen'] = ubicacion;
          }
        case 'saliendo_origen':
          updateData['fecha_saliendo_origen'] = now;
          if (ubicacion != null) {
            updateData['ubicacion_saliendo_origen'] = ubicacion;
          }
        case 'en_transito':
          updateData['fecha_en_transito'] = now;
          if (ubicacion != null) {
            updateData['ubicacion_en_transito'] = ubicacion;
          }
        case 'en_destino':
          updateData['fecha_en_destino'] = now;
          if (ubicacion != null) {
            updateData['ubicacion_en_destino'] = ubicacion;
          }
        case 'finalizado':
          updateData['fecha_finalizado'] = now;
          if (ubicacion != null) {
            updateData['ubicacion_finalizado'] = ubicacion;
          }
        case 'cancelado':
          updateData['fecha_cancelacion'] = now;
        case 'suspendido':
          updateData['fecha_suspendido'] = now;
        case 'no_realizado':
          updateData['fecha_no_realizado'] = now;
      }

      // Incluir JOINs con pacientes y tmotivos_traslado para mantener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .single();

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ Estado actualizado exitosamente',
      );

      return TrasladoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al actualizar estado: $e',
      );
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> asignarRecursos({
    required String id,
    String? idConductor,
    String? idVehiculo,
    String? matriculaVehiculo,
    String? idTecnico,
  }) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Asignando recursos al traslado ID: $id',
      );

      final updateData = <String, dynamic>{};
      // Usar id_conductor que es el nombre correcto de la columna en Supabase
      if (idConductor != null) updateData['id_conductor'] = idConductor;
      if (idVehiculo != null) updateData['id_vehiculo'] = idVehiculo;
      if (matriculaVehiculo != null) updateData['matricula_vehiculo'] = matriculaVehiculo;
      if (idTecnico != null) updateData['id_tecnico'] = idTecnico;

      // Obtener estado actual del traslado
      final currentData =
          await _supabase.from(_tableName).select('estado').eq('id', id).single();
      final estadoActual = currentData['estado'] as String;

      // Estados que deben resetear al reasignar
      const estadosAvanzados = [
        'enviado',
        'recibido_conductor',
        'en_origen',
        'saliendo_origen',
        'en_transito',
        'en_destino',
      ];

      // Si el traslado tiene un estado avanzado (fue desasignado y reasignado), resetear a 'asignado'
      if (estadosAvanzados.contains(estadoActual)) {
        debugPrint(
          '📦 SupabaseTrasladoDataSource: ⚠️ Traslado con estado avanzado "$estadoActual" siendo reasignado. Reseteando a "asignado"',
        );
        updateData['estado'] = 'asignado';
        updateData['fecha_asignacion'] = DateTime.now().toIso8601String();
        final userId = _supabase.auth.currentUser?.id;
        if (userId != null) {
          updateData['usuario_asignacion'] = userId;
          updateData['updated_by'] = userId;
        }

        // Limpiar fechas de estados avanzados al resetear
        updateData['fecha_enviado'] = null;
        updateData['fecha_recibido_conductor'] = null;
        updateData['fecha_en_origen'] = null;
        updateData['fecha_saliendo_origen'] = null;
        updateData['fecha_en_transito'] = null;
        updateData['fecha_en_destino'] = null;
        updateData['ubicacion_en_origen'] = null;
        updateData['ubicacion_saliendo_origen'] = null;
        updateData['ubicacion_en_transito'] = null;
        updateData['ubicacion_en_destino'] = null;
      } else if (estadoActual == 'pendiente') {
        // Si el estado era 'pendiente', pasar a 'asignado' normalmente
        updateData['estado'] = 'asignado';
        // ✅ Establecer campos de auditoría de asignación
        updateData['fecha_asignacion'] = DateTime.now().toIso8601String();
        final userId = _supabase.auth.currentUser?.id;
        if (userId != null) {
          updateData['usuario_asignacion'] = userId;
          updateData['updated_by'] = userId;
        }
      }

      // Incluir JOINs con pacientes y tmotivos_traslado para mantener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .single();

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ Recursos asignados exitosamente',
      );

      return TrasladoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al asignar recursos: $e',
      );
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> desasignarRecursos({
    required String id,
  }) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Desasignando recursos del traslado ID: "$id"',
      );
      debugPrint('   - Longitud del ID: ${id.length}');
      debugPrint('   - ID contiene sufijos: ${id.contains('_ida') || id.contains('_vuelta')}');

      // Limpiar posibles sufijos _ida o _vuelta del ID
      final String idLimpio = id.replaceAll('_ida', '').replaceAll('_vuelta', '');
      if (idLimpio != id) {
        debugPrint('   - ID limpio (sin sufijos): "$idLimpio"');
      }

      // Primero verificar si el traslado existe
      final existeResponse = await _supabase
          .from(_tableName)
          .select('id, estado, id_conductor')
          .eq('id', idLimpio)
          .maybeSingle();

      if (existeResponse == null) {
        debugPrint(
          '📦 SupabaseTrasladoDataSource: ❌ No se encontró traslado con ID: "$idLimpio"',
        );
        throw Exception('No se encontró el traslado con ID: $idLimpio');
      }

      debugPrint(
        '   - Traslado encontrado. Estado actual: ${existeResponse['estado']}, Conductor: ${existeResponse['id_conductor']}',
      );

      // Poner explícitamente null en todos los campos de recursos
      // y cambiar estado a 'pendiente'
      // Usar id_conductor que es el nombre correcto de la columna en Supabase
      final updateData = <String, dynamic>{
        'id_conductor': null,
        'id_vehiculo': null,
        'matricula_vehiculo': null,
        'estado': 'pendiente',
      };

      // Incluir JOINs con pacientes y tmotivos_traslado para mantener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', idLimpio)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .single();

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ Recursos desasignados exitosamente',
      );

      return TrasladoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al desasignar recursos: $e',
      );
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> registrarUbicacion({
    required String id,
    required Map<String, dynamic> ubicacion,
    required String estado,
  }) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Registrando ubicación para traslado ID: $id (estado: $estado)',
      );

      // Actualizar la ubicación en el campo correspondiente según el estado
      final updateData = <String, dynamic>{};

      switch (estado) {
        case 'en_origen':
          updateData['ubicacion_en_origen'] = ubicacion;
        case 'saliendo_origen':
          updateData['ubicacion_saliendo_origen'] = ubicacion;
        case 'en_transito':
          updateData['ubicacion_en_transito'] = ubicacion;
        case 'en_destino':
          updateData['ubicacion_en_destino'] = ubicacion;
        case 'finalizado':
          updateData['ubicacion_finalizado'] = ubicacion;
      }

      // Incluir JOINs con pacientes y tmotivos_traslado para mantener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select('*, pacientes(*), tmotivos_traslado(*)')
          .single();

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ Ubicación registrada exitosamente',
      );

      return TrasladoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al registrar ubicación: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Cancelando traslado ID: $id',
      );

      await _supabase.from(_tableName).update({
        'estado': 'cancelado',
        'fecha_cancelacion': DateTime.now().toIso8601String(),
      }).eq('id', id);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ Traslado cancelado exitosamente',
      );
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al cancelar traslado: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> hardDelete(String id) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Eliminando permanentemente traslado ID: $id',
      );

      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ Traslado eliminado permanentemente',
      );
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al eliminar permanentemente: $e',
      );
      rethrow;
    }
  }

  /// Eliminar múltiples traslados permanentemente en una sola operación
  @override
  Future<void> hardDeleteMultiple(List<String> ids) async {
    if (ids.isEmpty) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ⚠️ Lista de IDs vacía, no se eliminará nada',
      );
      return;
    }

    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Eliminando permanentemente ${ids.length} traslados...',
      );

      // Eliminación masiva usando .in()
      await _supabase.from(_tableName).delete().inFilter('id', ids);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${ids.length} traslados eliminados permanentemente',
      );
    } catch (e) {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: ❌ Error al eliminar múltiples traslados: $e',
      );
      rethrow;
    }
  }

  @override
  Stream<List<TrasladoEntity>> watchAll() {
    debugPrint(
      '📦 SupabaseTrasladoDataSource: Iniciando stream de traslados (con paciente y motivo embebidos)...',
    );

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) {
          debugPrint(
            '📦 SupabaseTrasladoDataSource: 🔄 Stream actualizó ${data.length} traslados',
          );
          return data
              .map((json) => TrasladoSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<TrasladoEntity?> watchById(String id) {
    debugPrint(
      '📦 SupabaseTrasladoDataSource: Iniciando stream del traslado ID: $id',
    );

    return _supabase.from(_tableName).stream(primaryKey: ['id']).map((data) {
          debugPrint(
            '📦 SupabaseTrasladoDataSource: 🔄 Stream actualizó traslado',
          );
          // Buscar el traslado con el ID especificado
          final traslado = data.where((json) => json['id'] == id).firstOrNull;
          if (traslado == null) return null;
          return TrasladoSupabaseModel.fromJson(traslado).toEntity();
        });
  }

  @override
  Stream<List<TrasladoEntity>> watchByServicioRecurrente(
    String idServicioRecurrente,
  ) {
    debugPrint(
      '📦 SupabaseTrasladoDataSource: Iniciando stream de traslados del servicio: $idServicioRecurrente (con paciente y motivo embebidos)',
    );

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) {
          debugPrint(
            '📦 SupabaseTrasladoDataSource: 🔄 Stream actualizó ${data.length} traslados con paciente y motivo',
          );
          // Filtrar y ordenar en la transformación del stream
          final filtrados = data
              .where((json) => json['id_servicio_recurrente'] == idServicioRecurrente)
              .toList();
          // Ordenar por fecha descendente y hora_programada ascendente
          filtrados.sort((a, b) {
            final cmpFecha = (b['fecha'] as String).compareTo(a['fecha'] as String);
            if (cmpFecha != 0) return cmpFecha;
            return (a['hora_programada'] as String).compareTo(b['hora_programada'] as String);
          });
          return filtrados
              .map((json) => TrasladoSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<List<TrasladoEntity>> watchByConductor(String idConductor) {
    debugPrint(
      '📦 SupabaseTrasladoDataSource: Iniciando stream de traslados del conductor: $idConductor (con paciente y motivo embebidos)',
    );

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) {
          debugPrint(
            '📦 SupabaseTrasladoDataSource: 🔄 Stream actualizó ${data.length} traslados del conductor con paciente y motivo',
          );
          // Filtrar y ordenar en la transformación del stream
          final filtrados = data
              .where((json) => json['id_conductor'] == idConductor)
              .toList();
          // Ordenar por fecha descendente y hora_programada ascendente
          filtrados.sort((a, b) {
            final cmpFecha = (b['fecha'] as String).compareTo(a['fecha'] as String);
            if (cmpFecha != 0) return cmpFecha;
            return (a['hora_programada'] as String).compareTo(b['hora_programada'] as String);
          });
          return filtrados
              .map((json) => TrasladoSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<List<TrasladoEntity>> watchEnCurso() {
    debugPrint(
      '📦 SupabaseTrasladoDataSource: Iniciando stream de traslados en curso (con paciente y motivo embebidos)...',
    );

    final estadosEnCurso = [
      'pendiente',
      'asignado',
      'enviado',
      'recibido_conductor',
      'en_origen',
      'saliendo_origen',
      'en_transito',
      'en_destino',
    ];

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) {
          debugPrint(
            '📦 SupabaseTrasladoDataSource: 🔄 Stream actualizó ${data.length} traslados en curso con paciente y motivo',
          );
          // Filtrar por estados en curso y ordenar en la transformación del stream
          final filtrados = data
              .where((json) => estadosEnCurso.contains(json['estado']))
              .toList();
          // Ordenar por fecha descendente y hora_programada ascendente
          filtrados.sort((a, b) {
            final cmpFecha = (b['fecha'] as String).compareTo(a['fecha'] as String);
            if (cmpFecha != 0) return cmpFecha;
            return (a['hora_programada'] as String).compareTo(b['hora_programada'] as String);
          });
          return filtrados
              .map((json) => TrasladoSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<List<TrasladoEntity>> watchByIds(List<String> ids) {
    debugPrint(
      '📦 SupabaseTrasladoDataSource: Iniciando stream de ${ids.length} traslados específicos (con paciente y motivo embebidos)...',
    );

    if (ids.isEmpty) {
      return Stream.value([]);
    }

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', ids.first) // Supabase stream doesn't support .in() directly
        .map((data) {
          debugPrint(
            '📦 SupabaseTrasladoDataSource: 🔄 Stream actualizó ${data.length} traslados con paciente y motivo',
          );
          // Filtrar por los IDs solicitados
          final filtrados = data
              .where((json) => ids.contains(json['id'] as String))
              .toList();
          return filtrados
              .map((json) => TrasladoSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<List<TrasladoEntity>> watchActivosByIdConductor(
    String idConductor,
  ) {
    debugPrint(
      '📦 SupabaseTrasladoDataSource: Iniciando stream de traslados activos del conductor: $idConductor (con paciente y motivo embebidos)',
    );

    // Estados activos (en curso)
    final estadosActivos = [
      'asignado',
      'enviado',
      'recibido_conductor',
      'en_origen',
      'saliendo_origen',
      'en_transito',
      'en_destino',
    ];

    // Incluir JOINs con pacientes y tmotivos_traslado en el stream
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) {
          debugPrint(
            '📦 SupabaseTrasladoDataSource: 🔄 Stream actualizó ${data.length} traslados con paciente y motivo',
          );
          // Filtrar por conductor y estados activos
          final filtrados = data
              .where((json) =>
                  json['id_conductor'] == idConductor &&
                  estadosActivos.contains(json['estado']))
              .toList();
          // Ordenar por fecha descendente y hora_programada ascendente
          filtrados.sort((a, b) {
            final cmpFecha = (b['fecha'] as String).compareTo(a['fecha'] as String);
            if (cmpFecha != 0) return cmpFecha;
            return (a['hora_programada'] as String).compareTo(b['hora_programada'] as String);
          });
          return filtrados
              .map((json) => TrasladoSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }

  @override
  Stream<TrasladoEventoEntity> streamEventosConductor([String? idConductor]) {
    debugPrint(
      '📦 SupabaseTrasladoDataSource: Iniciando stream de eventos para conductor',
    );

    final miId = idConductor ?? _supabase.auth.currentUser?.id;
    if (miId == null) {
      debugPrint('⚠️ [TrasladosDataSource] No hay ID de conductor disponible, retornando stream vacío');
      return const Stream.empty();
    }

    debugPrint('✅ [TrasladosDataSource] ID del conductor: $miId (origen: ${idConductor != null ? "parámetro" : "auth"})');

    // Crear canal Realtime para escuchar cambios en la tabla traslados
    // Usar un ID único para el canal basado en si recibimos parámetro o no
    final sourceIndicator = idConductor != null ? 'param' : 'auth';
    final channelName = 'traslados_eventos_conductor_${miId}_$sourceIndicator';
    debugPrint('📡 [TrasladosDataSource] Creando canal: $channelName');

    final channel = _supabase.channel(channelName);

    // Stream controller para emitir eventos con callback de cancelación
    // Declarar como nullable para poder referenciarlo en onCancel
    StreamController<TrasladoEventoEntity>? streamController;
    streamController = StreamController<TrasladoEventoEntity>(
      onCancel: () {
        debugPrint('🔌 [TrasladosDataSource] Cancelando stream de eventos');
        _supabase.removeChannel(channel);
        streamController?.close();
      },
    );

    // Contador para generar IDs únicos de eventos temporales
    var eventoCounter = 0;

    // Suscribirse a cambios en la tabla traslados (INSERT, UPDATE, DELETE)
    // ⚠️ NOTA: No usamos filtro Realtime porque tiene problemas de confiabilidad
    // En su lugar, escuchamos TODOS los cambios y filtramos en el callback
    debugPrint('📡 [TrasladosDataSource] Suscribiendo a TODOS los cambios en tabla $_tableName');
    debugPrint('   - Filtrado por cliente: id_conductor == $miId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _tableName,
          callback: (payload, [ref]) {
            debugPrint('📦 [TrasladosDataSource] ⭐⭐⭐ CAMBIO DETECTADO EN TRASLADOS ⭐⭐⭐');
            debugPrint('   - Event type: ${payload.eventType}');
            debugPrint('   - Old: ${payload.oldRecord}');
            debugPrint('   - New: ${payload.newRecord}');

            final oldRecord = payload.oldRecord as Map<String, dynamic>?;
            final newRecord = payload.newRecord as Map<String, dynamic>?;

            // Determinar el tipo de evento basado en el cambio
            EventoTrasladoType? eventType;
            String? trasladoId;
            String? oldConductorId;
            String? newConductorId;
            String? oldEstado;
            String? newEstado;

            if (newRecord != null) {
              trasladoId = newRecord['id'] as String?;
              newConductorId = newRecord['id_conductor'] as String?;
              newEstado = newRecord['estado'] as String?;
            }

            if (oldRecord != null) {
              oldConductorId = oldRecord['id_conductor'] as String?;
              oldEstado = oldRecord['estado'] as String?;
            }

            if (trasladoId == null) {
              debugPrint('⚠️ [TrasladosDataSource] No se pudo determinar trasladoId');
              return;
            }

            debugPrint('   - Traslado ID: $trasladoId');
            debugPrint('   - Mi ID: $miId');
            debugPrint('   - Old conductor: $oldConductorId');
            debugPrint('   - New conductor: $newConductorId');

            // Analizar el tipo de evento basado en el eventType del payload
            final eventTypeStr = payload.eventType.toString();

            if (eventTypeStr.contains('insert')) {
              // Si se inserta un traslado con mi conductor, es una asignación
              if (newConductorId == miId) {
                eventType = EventoTrasladoType.assigned;
                debugPrint('✅ [TrasladosDataSource] INSERT: Traslado asignado a mí');
              }
            } else if (eventTypeStr.contains('update')) {
              // Cambio de conductor
              if (oldConductorId != newConductorId) {
                if (newConductorId == miId) {
                  eventType = EventoTrasladoType.reassigned;
                  debugPrint('✅ [TrasladosDataSource] UPDATE: Traslado reasignado a mí');
                } else if (oldConductorId == miId) {
                  eventType = EventoTrasladoType.unassigned;
                  debugPrint('✅ [TrasladosDataSource] UPDATE: Traslado desasignado de mí');
                }
              }
              // Cambio de estado (mismo conductor)
              else if (oldEstado != newEstado && newConductorId == miId) {
                eventType = EventoTrasladoType.statusChanged;
                debugPrint('✅ [TrasladosDataSource] UPDATE: Estado cambió de $oldEstado a $newEstado');
              }
            } else if (eventTypeStr.contains('delete')) {
              // Traslado eliminado
              if (oldConductorId == miId) {
                eventType = EventoTrasladoType.cancelled;
                debugPrint('✅ [TrasladosDataSource] DELETE: Traslado cancelado');
              }
            }

            // Si determinamos un tipo de evento, emitirlo
            if (eventType != null) {
              eventoCounter++;
              final evento = TrasladoEventoEntity(
                // Generar ID temporal único para el evento Realtime
                id: 'evt_${DateTime.now().millisecondsSinceEpoch}_$eventoCounter',
                trasladoId: trasladoId,
                eventType: eventType,
                timestamp: DateTime.now(),
                conductorId: newConductorId ?? oldConductorId,
                estadoAnterior: oldEstado,
                estadoNuevo: newEstado,
              );
              streamController!.add(evento);
              debugPrint('📤 [TrasladosDataSource] ✅✅✅ EVENTO EMITIDO: ${eventType.label} ✅✅✅');
            } else {
              debugPrint('⚠️ [TrasladosDataSource] Evento NO procesado (no coincide con mi ID)');
            }
          },
        )
        .subscribe((status, [error]) {
          debugPrint('📡 [TrasladosDataSource] Estado del canal: $status');
          if (error != null) {
            debugPrint('❌ [TrasladosDataSource] Error en suscripción: $error');
          }
        });

    debugPrint('✅ [TrasladosDataSource] Stream de eventos iniciado correctamente');

    return streamController.stream;
  }

  @override
  Future<void> disposeRealtimeChannels() async {
    debugPrint(
      '📦 SupabaseTrasladoDataSource: Liberando canales de Realtime',
    );
    // Los canales de Supabase se limpian automáticamente cuando se cierra el stream
    // No hay acción específica requerida
  }
}
