import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../entities/estado_traslado_enum.dart';
import '../entities/historial_estado_entity.dart';
import '../entities/traslado_entity.dart';
import '../entities/traslado_evento_entity.dart';
import '../entities/ubicacion_entity.dart';
import '../models/historial_estado_supabase_model.dart';
import '../models/traslado_evento_supabase_model.dart';
import '../models/traslado_supabase_model.dart';
import '../traslados_datasource_contract.dart';

/// Implementación del datasource de traslados usando Supabase
class SupabaseTrasladosDataSource implements TrasladosDataSource {
  SupabaseTrasladosDataSource(this._client);

  final SupabaseClient _client;
  final _uuid = const Uuid();

  static const String _tableName = 'traslados';
  static const String _historialTableName = 'historial_estados_traslado';

  /// Query base con joins para datos del paciente
  String get _selectQuery => '''
    *,
    pacientes:id_paciente(nombre, primer_apellido, segundo_apellido),
    tpersonal:id_conductor(nombre, apellidos)
  ''';

  @override
  Future<List<TrasladoEntity>> getByIdConductor(String idConductor) async {
    try {
      debugPrint('📦 [TrasladosDataSource] Obteniendo traslados del conductor: $idConductor');

      final response = await _client
          .from(_tableName)
          .select(_selectQuery)
          .eq('id_conductor', idConductor)
          .order('fecha', ascending: false)
          .order('hora_programada', ascending: false);

      debugPrint('✅ [TrasladosDataSource] Encontrados ${response.length} traslados');

      return (response as List)
          .map((json) => _mapToEntity(json))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosDataSource] Error al obtener traslados: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getActivosByIdConductor(String idConductor) async {
    try {
      debugPrint('📦 [TrasladosDataSource] Obteniendo traslados activos del conductor: $idConductor');

      final response = await _client
          .from(_tableName)
          .select(_selectQuery)
          .eq('id_conductor', idConductor)
          .neq('estado', 'finalizado')
          .neq('estado', 'cancelado')
          .neq('estado', 'no_realizado')
          .neq('estado', 'suspendido')
          .order('fecha', ascending: true)
          .order('hora_programada', ascending: true);

      debugPrint('✅ [TrasladosDataSource] Encontrados ${response.length} traslados activos');

      return (response as List)
          .map((json) => _mapToEntity(json))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosDataSource] Error al obtener traslados activos: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> getById(String id) async {
    try {
      debugPrint('📦 [TrasladosDataSource] Obteniendo traslado: $id');

      final response = await _client
          .from(_tableName)
          .select(_selectQuery)
          .eq('id', id)
          .single();

      debugPrint('✅ [TrasladosDataSource] Traslado encontrado');

      return _mapToEntity(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosDataSource] Error al obtener traslado: $e');
      debugPrint('Stack trace: $stackTrace');
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
      debugPrint('📦 [TrasladosDataSource] Obteniendo traslados entre $fechaInicio y $fechaFin');

      var query = _client
          .from(_tableName)
          .select(_selectQuery)
          .gte('fecha', fechaInicio.toIso8601String().split('T')[0])
          .lte('fecha', fechaFin.toIso8601String().split('T')[0]);

      if (idConductor != null) {
        query = query.eq('id_conductor', idConductor);
      }

      final response = await query
          .order('fecha', ascending: true)
          .order('hora_programada', ascending: true);

      debugPrint('✅ [TrasladosDataSource] Encontrados ${response.length} traslados');

      return (response as List)
          .map((json) => _mapToEntity(json))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosDataSource] Error al obtener traslados por rango: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByEstado({
    required EstadoTraslado estado,
    String? idConductor,
  }) async {
    try {
      debugPrint('📦 [TrasladosDataSource] Obteniendo traslados con estado: ${estado.value}');

      var query = _client
          .from(_tableName)
          .select(_selectQuery)
          .eq('estado', estado.value);

      if (idConductor != null) {
        query = query.eq('id_conductor', idConductor);
      }

      final response = await query
          .order('fecha', ascending: true)
          .order('hora_programada', ascending: true);

      debugPrint('✅ [TrasladosDataSource] Encontrados ${response.length} traslados');

      return (response as List)
          .map((json) => _mapToEntity(json))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosDataSource] Error al obtener traslados por estado: $e');
      debugPrint('Stack trace: $stackTrace');
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
      debugPrint('📦 [TrasladosDataSource] Cambiando estado de traslado $idTraslado a ${nuevoEstado.value}');

      // 1. Obtener estado actual
      final trasladoActual = await getById(idTraslado);

      // 2. Preparar updates según el nuevo estado
      final Map<String, dynamic> updates = {
        'estado': nuevoEstado.value,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': idUsuario,
      };

      // Agregar campos específicos según el estado
      switch (nuevoEstado) {
        case EstadoTraslado.asignado:
          updates['fecha_asignacion'] = DateTime.now().toIso8601String();
          updates['usuario_asignacion'] = idUsuario;
          break;
        case EstadoTraslado.recibido:
          updates['fecha_recibido_conductor'] = DateTime.now().toIso8601String();
          break;
        case EstadoTraslado.enOrigen:
          updates['fecha_en_origen'] = DateTime.now().toIso8601String();
          if (ubicacion != null) {
            updates['ubicacion_en_origen'] = ubicacion.toJson();
          }
          break;
        case EstadoTraslado.saliendoOrigen:
          updates['fecha_saliendo_origen'] = DateTime.now().toIso8601String();
          if (ubicacion != null) {
            updates['ubicacion_saliendo_origen'] = ubicacion.toJson();
          }
          break;
        case EstadoTraslado.enDestino:
          updates['fecha_en_destino'] = DateTime.now().toIso8601String();
          if (ubicacion != null) {
            updates['ubicacion_en_destino'] = ubicacion.toJson();
          }
          break;
        case EstadoTraslado.finalizado:
          updates['fecha_finalizado'] = DateTime.now().toIso8601String();
          if (ubicacion != null) {
            updates['ubicacion_finalizado'] = ubicacion.toJson();
          }
          break;
        case EstadoTraslado.cancelado:
          updates['fecha_cancelacion'] = DateTime.now().toIso8601String();
          updates['usuario_cancelacion'] = idUsuario;
          if (observaciones != null) {
            updates['observaciones_cancelacion'] = observaciones;
          }
          break;
        case EstadoTraslado.noRealizado:
          updates['fecha_no_realizado'] = DateTime.now().toIso8601String();
          break;
        case EstadoTraslado.suspendido:
          updates['fecha_suspendido'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      // 3. Actualizar traslado
      final response = await _client
          .from(_tableName)
          .update(updates)
          .eq('id', idTraslado)
          .select(_selectQuery)
          .single();

      // 4. Registrar en historial
      await _registrarCambioEstado(
        idTraslado: idTraslado,
        estadoAnterior: trasladoActual.estado,
        estadoNuevo: nuevoEstado,
        idUsuario: idUsuario,
        ubicacion: ubicacion,
        observaciones: observaciones,
      );

      debugPrint('✅ [TrasladosDataSource] Estado cambiado exitosamente');

      return _mapToEntity(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosDataSource] Error al cambiar estado: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<HistorialEstadoEntity>> getHistorialEstados(String idTraslado) async {
    try {
      debugPrint('📦 [TrasladosDataSource] Obteniendo historial de estados del traslado: $idTraslado');

      final response = await _client
          .from(_historialTableName)
          .select()
          .eq('id_traslado', idTraslado)
          .order('fecha_cambio', ascending: false);

      debugPrint('✅ [TrasladosDataSource] Encontrados ${response.length} cambios de estado');

      return (response as List)
          .map((json) => HistorialEstadoSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosDataSource] Error al obtener historial: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> update({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      debugPrint('📦 [TrasladosDataSource] Actualizando traslado: $id');

      // Agregar campos de auditoría
      final updatesWithAudit = {
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(_tableName)
          .update(updatesWithAudit)
          .eq('id', id)
          .select(_selectQuery)
          .single();

      debugPrint('✅ [TrasladosDataSource] Traslado actualizado');

      return _mapToEntity(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosDataSource] Error al actualizar traslado: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Stream<List<TrasladoEntity>> watchActivosByIdConductor(String idConductor) {
    debugPrint('📡 [TrasladosDataSource] Iniciando stream HÍBRIDO de traslados activos para conductor: $idConductor');

    // ESTRATEGIA HÍBRIDA:
    // 1. Stream Realtime: detecta asignaciones y actualizaciones instantáneas
    // 2. Polling periódico: detecta desasignaciones (fallback)
    //
    // Razón: Supabase Realtime no emite eventos cuando una fila deja de cumplir
    // el filtro .eq(), incluso con REPLICA IDENTITY FULL.

    final controller = StreamController<List<TrasladoEntity>>.broadcast();
    StreamSubscription? realtimeSub;
    Timer? pollingTimer;

    // Función auxiliar para procesar y emitir traslados
    void emitirTraslados(List<dynamic> rows, String source) {
      if (controller.isClosed) return;

      final traslados = rows
          .map((json) => _mapToEntity(json))
          .where((traslado) {
            final esActivo = traslado.estado != EstadoTraslado.finalizado &&
                traslado.estado != EstadoTraslado.cancelado &&
                traslado.estado != EstadoTraslado.noRealizado &&
                traslado.estado != EstadoTraslado.suspendido;
            return esActivo;
          })
          .toList();

      debugPrint('📡 [TrasladosDataSource] $source: ${traslados.length} traslados activos');
      controller.add(traslados);
    }

    // 1. Suscribirse al stream de Realtime
    realtimeSub = _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id_conductor', idConductor)
        .order('fecha')
        .order('hora_programada')
        .listen(
          (rows) {
            debugPrint('📡 [TrasladosDataSource] Realtime: recibió ${rows.length} filas');
            emitirTraslados(rows, 'Realtime');
          },
          onError: (error) {
            debugPrint('❌ [TrasladosDataSource] Error en Realtime: $error');
            if (!controller.isClosed) {
              controller.addError(error);
            }
          },
        );

    // 2. Iniciar polling periódico (cada 10 segundos)
    pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async {
        try {
          debugPrint('🔄 [TrasladosDataSource] Polling: verificando traslados...');
          final traslados = await getActivosByIdConductor(idConductor);

          if (!controller.isClosed) {
            debugPrint('🔄 [TrasladosDataSource] Polling: ${traslados.length} traslados activos');
            controller.add(traslados);
          }
        } catch (e) {
          debugPrint('⚠️  [TrasladosDataSource] Error en polling: $e');
        }
      },
    );

    // Limpiar recursos cuando se cancela el stream
    controller.onCancel = () {
      debugPrint('🔌 [TrasladosDataSource] Cerrando stream híbrido');
      realtimeSub?.cancel();
      pollingTimer?.cancel();
    };

    return controller.stream;
  }

  @override
  Stream<TrasladoEntity> watchById(String id) {
    debugPrint('📡 [TrasladosDataSource] Iniciando stream del traslado: $id');

    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((rows) {
          if (rows.isEmpty) {
            throw Exception('Traslado no encontrado');
          }
          debugPrint('📡 [TrasladosDataSource] Stream del traslado actualizado');
          return _mapToEntity(rows.first);
        });
  }

  // --------------------------------------------------------------------------
  // Métodos privados auxiliares
  // --------------------------------------------------------------------------

  /// Registra un cambio de estado en el historial
  Future<void> _registrarCambioEstado({
    required String idTraslado,
    required EstadoTraslado estadoAnterior,
    required EstadoTraslado estadoNuevo,
    required String idUsuario,
    UbicacionEntity? ubicacion,
    String? observaciones,
  }) async {
    try {
      final historial = HistorialEstadoEntity(
        id: _uuid.v4(),
        idTraslado: idTraslado,
        estadoAnterior: estadoAnterior,
        estadoNuevo: estadoNuevo,
        idUsuario: idUsuario,
        ubicacion: ubicacion,
        fechaCambio: DateTime.now(),
        observaciones: observaciones,
      );

      final model = HistorialEstadoSupabaseModel.fromEntity(historial);

      await _client
          .from(_historialTableName)
          .insert(model.toJson());

      debugPrint('✅ [TrasladosDataSource] Historial registrado');
    } catch (e) {
      debugPrint('⚠️  [TrasladosDataSource] Error al registrar historial (no crítico): $e');
      // No lanzamos error porque no debe bloquear el cambio de estado
    }
  }

  /// Mapea JSON a Entity con datos desnormalizados
  TrasladoEntity _mapToEntity(Map<String, dynamic> json) {
    final model = TrasladoSupabaseModel.fromJson(json);
    final entity = model.toEntity();

    // Agregar datos desnormalizados si existen
    String? pacienteNombre;
    String? conductorNombre;

    if (json['pacientes'] != null) {
      final paciente = json['pacientes'] as Map<String, dynamic>;
      final nombre = paciente['nombre'] ?? '';
      final apellido1 = paciente['primer_apellido'] ?? '';
      final apellido2 = paciente['segundo_apellido'] ?? '';
      pacienteNombre = '$nombre $apellido1 $apellido2'.trim();
    }

    if (json['tpersonal'] != null) {
      final personal = json['tpersonal'] as Map<String, dynamic>;
      final nombre = personal['nombre'] ?? '';
      final apellidos = personal['apellidos'] ?? '';
      conductorNombre = '$nombre $apellidos'.trim();
    }

    return entity.copyWith(
      pacienteNombre: pacienteNombre,
      conductorNombre: conductorNombre,
    );
  }

  // --------------------------------------------------------------------------
  // Event Ledger: Stream de eventos para Realtime sin polling
  // --------------------------------------------------------------------------

  /// Stream de eventos de traslados para el conductor autenticado
  ///
  /// Este stream combina dos suscripciones Realtime:
  /// 1. Eventos donde SOY el new_conductor_id (me asignaron)
  /// 2. Eventos donde SOY el old_conductor_id (me quitaron)
  ///
  /// IMPORTANTE: Este stream REEMPLAZA el polling de watchActivosByIdConductor
  /// porque los eventos se emiten instantáneamente cuando:
  /// - Me asignan un traslado (assigned/reassigned)
  /// - Me quitan un traslado (unassigned/reassigned a otro)
  /// - Cambia el estado de un traslado mío (status_changed)
  @override
  Stream<TrasladoEventoEntity> streamEventosConductor() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('❌ [TrasladosDataSource] Usuario no autenticado, no se puede suscribir a eventos');
      return Stream.empty();
    }

    debugPrint('🔔 [TrasladosDataSource] Suscribiéndose a eventos de traslados para conductor: $userId');

    final controller = StreamController<TrasladoEventoEntity>.broadcast();
    final eventosRecibidos = <String>{};  // Deduplicación

    RealtimeChannel? channel;

    // Función para procesar eventos y evitar duplicados
    void procesarEvento(PostgresChangePayload payload) {
      try {
        final json = payload.newRecord;
        final evento = TrasladoEventoSupabaseModel.fromJson(json).toEntity();

        // Deduplicar (Realtime puede enviar el mismo evento por múltiples suscripciones)
        if (eventosRecibidos.contains(evento.id)) {
          debugPrint('⚠️ [TrasladosDataSource] Evento duplicado ignorado: ${evento.id}');
          return;
        }

        eventosRecibidos.add(evento.id);

        // Limpiar cache después de 100 eventos para evitar memory leak
        if (eventosRecibidos.length > 100) {
          final elementosARemover = eventosRecibidos.take(50).toList();
          eventosRecibidos.removeAll(elementosARemover);
        }

        if (!controller.isClosed) {
          debugPrint('📥 [TrasladosDataSource] Evento recibido: ${evento.eventType.label} - Traslado: ${evento.trasladoId}');
          controller.add(evento);
        }
      } catch (e) {
        debugPrint('❌ [TrasladosDataSource] Error procesando evento: $e');
      }
    }

    // Crear canal Realtime único con ID para evitar colisiones
    final channelName = 'traslados_eventos_$userId';
    channel = _client.channel(channelName);

    // SUSCRIPCIÓN 1: Eventos donde SOY el new_conductor_id (me asignaron)
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'traslados_eventos',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'new_conductor_id',
        value: userId,
      ),
      callback: (payload) {
        debugPrint('📥 [TrasladosDataSource] INSERT (new_conductor): $userId');
        procesarEvento(payload);
      },
    );

    // SUSCRIPCIÓN 2: Eventos donde SOY el old_conductor_id (me quitaron)
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'traslados_eventos',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'old_conductor_id',
        value: userId,
      ),
      callback: (payload) {
        debugPrint('📥 [TrasladosDataSource] INSERT (old_conductor): $userId');
        procesarEvento(payload);
      },
    );

    // Suscribir canal
    channel.subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        debugPrint('✅ [TrasladosDataSource] Canal Realtime suscrito: $channelName');
      } else if (status == RealtimeSubscribeStatus.channelError) {
        debugPrint('❌ [TrasladosDataSource] Error en canal Realtime: $error');
        if (!controller.isClosed) {
          controller.addError(error ?? Exception('Error en canal Realtime'));
        }
      }
    });

    // Limpiar recursos cuando se cancela el stream
    controller.onCancel = () async {
      debugPrint('🔌 [TrasladosDataSource] Cerrando stream de eventos');
      await channel?.unsubscribe();
      eventosRecibidos.clear();
    };

    return controller.stream;
  }

  /// Cierra todos los canales Realtime activos
  /// Llamar desde el dispose del repository/cubit
  @override
  Future<void> disposeRealtimeChannels() async {
    debugPrint('🔌 [TrasladosDataSource] Cerrando todos los canales Realtime');
    await _client.removeAllChannels();
  }
}
