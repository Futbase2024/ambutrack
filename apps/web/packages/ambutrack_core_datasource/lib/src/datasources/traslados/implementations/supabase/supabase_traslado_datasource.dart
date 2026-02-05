import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/traslado_entity.dart';
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
        '📦 SupabaseTrasladoDataSource: Obteniendo todos los traslados...',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos',
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
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados del servicio: $idServicioRecurrente',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id_servicio_recurrente', idServicioRecurrente)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos',
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
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados de ${idsServiciosRecurrentes.length} servicios',
      );
      debugPrint('   IDs de servicios buscados: $idsServiciosRecurrentes');

      final response = await _supabase
          .from(_tableName)
          .select()
          .inFilter('id_servicio', idsServiciosRecurrentes)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos',
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
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados del servicio padre: $servicioId',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id_servicio', servicioId)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos',
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
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados del paciente: $idPaciente',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id_paciente', idPaciente)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos',
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
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados del conductor: $idConductor',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id_conductor', idConductor)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos',
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
  Future<List<TrasladoEntity>> getByVehiculo(String idVehiculo) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados del vehículo: $idVehiculo',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id_vehiculo', idVehiculo)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos',
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
  Future<List<TrasladoEntity>> getByEstado(String estado) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados con estado: $estado',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', estado)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos',
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
    required DateTime desde,
    required DateTime hasta,
  }) async {
    try {
      final desdeStr = desde.toIso8601String().split('T').first;
      final hastaStr = hasta.toIso8601String().split('T').first;

      debugPrint(
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados entre $desdeStr y $hastaStr',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .gte('fecha', desdeStr)
          .lte('fecha', hastaStr)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados obtenidos',
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
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados en curso...',
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

      final response = await _supabase
          .from(_tableName)
          .select()
          .inFilter('estado', estadosEnCurso)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados en curso',
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
        '📦 SupabaseTrasladoDataSource: Obteniendo traslados que requieren asignación...',
      );

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', 'pendiente')
          .or('id_conductor.is.null,id_vehiculo.is.null')
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados pendientes de asignación',
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
        '📦 SupabaseTrasladoDataSource: Buscando traslados con código: "$query"',
      );

      if (query.isEmpty) {
        return getAll();
      }

      final response = await _supabase
          .from(_tableName)
          .select()
          .ilike('codigo', '%$query%')
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: true);

      debugPrint(
        '📦 SupabaseTrasladoDataSource: ✅ ${response.length} traslados encontrados',
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
  Future<TrasladoEntity> update(TrasladoEntity traslado) async {
    try {
      debugPrint(
        '📦 SupabaseTrasladoDataSource: Actualizando traslado: ${traslado.codigo}',
      );

      final model = TrasladoSupabaseModel.fromEntity(traslado);
      final json = model.toJson();

      // Remover campos de auditoría
      json.remove('created_at');
      json.remove('created_by');
      json.remove('updated_at');

      // Incluir JOINs con pacientes y tmotivos_traslado para mantener datos embebidos
      final response = await _supabase
          .from(_tableName)
          .update(json)
          .eq('id', traslado.id)
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

      // Si se asignan recursos y el estado era 'pendiente', pasar a 'asignado'
      final currentData =
          await _supabase.from(_tableName).select('estado').eq('id', id).single();

      if (currentData['estado'] == 'pendiente') {
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
      '📦 SupabaseTrasladoDataSource: Iniciando stream de traslados...',
    );

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: false)
        .order('hora_programada', ascending: true)
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
      '📦 SupabaseTrasladoDataSource: Iniciando stream de traslados del servicio: $idServicioRecurrente',
    );

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) {
          debugPrint(
            '📦 SupabaseTrasladoDataSource: 🔄 Stream actualizó ${data.length} traslados',
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
      '📦 SupabaseTrasladoDataSource: Iniciando stream de traslados del conductor: $idConductor',
    );

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) {
          debugPrint(
            '📦 SupabaseTrasladoDataSource: 🔄 Stream actualizó ${data.length} traslados',
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
      '📦 SupabaseTrasladoDataSource: Iniciando stream de traslados en curso...',
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
            '📦 SupabaseTrasladoDataSource: 🔄 Stream actualizó ${data.length} traslados en curso',
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
}
