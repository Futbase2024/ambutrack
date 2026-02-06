import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../entities/estado_traslado_enum.dart';
import '../../entities/historial_estado_entity.dart';
import '../../entities/traslado_entity.dart';
import '../../entities/traslado_evento_entity.dart';
import '../../entities/ubicacion_entity.dart';
import '../../models/historial_estado_supabase_model.dart';
import '../../models/traslado_evento_supabase_model.dart';
import '../../models/traslado_supabase_model.dart';
import '../../traslado_contract.dart';

/// Implementación del datasource de traslados usando Supabase
class SupabaseTrasladosDataSource implements TrasladoDataSource {
  SupabaseTrasladosDataSource(this._client);

  final SupabaseClient _client;
  final _uuid = const Uuid();

  static const String _tableName = 'traslados';
  static const String _viewName = 'v_traslados_completos'; // Vista con todos los datos desnormalizados
  static const String _historialTableName = 'historial_estados_traslado';

  /// Query simple - la vista ya incluye todos los JOINs necesarios
  String get _selectQuery => '*';
  @override
  Future<List<TrasladoEntity>> getByIdConductor(String idConductor) async {
    try {
      debugPrint('📦 [TrasladosDataSource] Obteniendo traslados del conductor: $idConductor');

      final response = await _client
          .from(_viewName) // Usar vista en lugar de tabla
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
          .from(_viewName) // Usar vista en lugar de tabla
          .select(_selectQuery)
          .eq('id_conductor', idConductor)
          .neq('estado', 'finalizado')
          .neq('estado', 'cancelado')
          .neq('estado', 'no_realizado')
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
          .from(_viewName) // Usar vista en lugar de tabla
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
          .from(_viewName) // Usar vista para tener datos desnormalizados
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
          .from(_viewName) // Usar vista para tener datos desnormalizados
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
        default:
          // Estados sin campos específicos de fecha: enviado, enTransito
          break;
      }

      // 3. Actualizar traslado
      await _client
          .from(_tableName)
          .update(updates)
          .eq('id', idTraslado);

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

      // 5. Obtener traslado actualizado desde la vista con datos completos
      return getById(idTraslado);
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

      await _client
          .from(_tableName)
          .update(updatesWithAudit)
          .eq('id', id);

      debugPrint('✅ [TrasladosDataSource] Traslado actualizado');

      // Obtener traslado actualizado desde la vista con datos completos
      return getById(id);
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
                traslado.estado != EstadoTraslado.noRealizado;
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
    var entity = model.toEntity();

    // Leer datos desnormalizados directamente de la vista
    // La vista v_traslados_completos ya incluye todos estos campos

    // Nombre del paciente (concatenado desde la vista)
    final pacienteNombre = _buildNombreCompleto(
      json['paciente_nombre'] as String?,
      json['paciente_primer_apellido'] as String?,
      json['paciente_segundo_apellido'] as String?,
    );

    // Nombre del conductor (concatenado desde la vista)
    final conductorNombre = _buildNombreCompleto(
      json['conductor_nombre'] as String?,
      json['conductor_apellidos'] as String?,
    );

    // Poblaciones desde la vista
    final poblacionPaciente = json['poblacion_paciente'] as String?;
    final poblacionCentroOrigen = json['poblacion_centro_origen'] as String?;
    final poblacionCentroDestino = json['poblacion_centro_destino'] as String?;

    // Matrícula del vehículo
    final vehiculoMatricula = json['vehiculo_matricula'] as String?;

    // Heredar datos del servicio recurrente si el traslado no los tiene
    if (entity.tipoOrigen == null || entity.tipoOrigen!.isEmpty) {
      entity = entity.copyWith(
        tipoOrigen: json['sr_tipo_origen'] as String?,
        origen: json['sr_origen'] as String?,
        origenUbicacionCentro: json['sr_origen_ubicacion_centro'] as String?,
      );
    }

    if (entity.tipoDestino == null || entity.tipoDestino!.isEmpty) {
      entity = entity.copyWith(
        tipoDestino: json['sr_tipo_destino'] as String?,
        destino: json['sr_destino'] as String?,
        destinoUbicacionCentro: json['sr_destino_ubicacion_centro'] as String?,
      );
    }

    return entity.copyWith(
      pacienteNombre: pacienteNombre,
      conductorNombre: conductorNombre,
      vehiculoMatricula: vehiculoMatricula,
      poblacionPaciente: poblacionPaciente,
      poblacionCentroOrigen: poblacionCentroOrigen,
      poblacionCentroDestino: poblacionCentroDestino,
    );
  }

  /// Construye un nombre completo a partir de sus componentes
  String? _buildNombreCompleto(String? nombre, [String? apellido1, String? apellido2]) {
    final partes = [nombre, apellido1, apellido2]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return partes.isEmpty ? null : partes.join(' ').trim();
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
    final controller = StreamController<TrasladoEventoEntity>.broadcast();
    final eventosRecibidos = <String>{};  // Deduplicación

    // Inicialización asíncrona
    _initializeEventStream(controller, eventosRecibidos);

    return controller.stream;
  }

  /// Inicializa el stream de eventos de forma asíncrona
  Future<void> _initializeEventStream(
    StreamController<TrasladoEventoEntity> controller,
    Set<String> eventosRecibidos,
  ) async {
    final authUserId = _client.auth.currentUser?.id;
    if (authUserId == null) {
      debugPrint('❌ [TrasladosDataSource] Usuario no autenticado, no se puede suscribir a eventos');
      if (!controller.isClosed) {
        controller.addError(Exception('Usuario no autenticado'));
        await controller.close();
      }
      return;
    }

    debugPrint('🔔 [TrasladosDataSource] Usuario autenticado (auth.uid): $authUserId');

    // LOOKUP: Obtener el ID de tpersonal a partir de auth.uid
    String? personalId;
    try {
      final response = await _client
          .from('tpersonal')
          .select('id')
          .eq('usuario_id', authUserId)
          .maybeSingle();

      if (response == null) {
        debugPrint('❌ [TrasladosDataSource] No se encontró conductor para usuario: $authUserId');
        if (!controller.isClosed) {
          controller.addError(Exception('Conductor no encontrado'));
          await controller.close();
        }
        return;
      }

      personalId = response['id'] as String;
      debugPrint('✅ [TrasladosDataSource] ID de conductor (tpersonal.id): $personalId');
    } catch (e) {
      debugPrint('❌ [TrasladosDataSource] Error obteniendo ID de conductor: $e');
      if (!controller.isClosed) {
        controller.addError(e);
        await controller.close();
      }
      return;
    }

    debugPrint('🔔 [TrasladosDataSource] Suscribiéndose a eventos de traslados para conductor: $personalId');

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
    final channelName = 'traslados_eventos_$personalId';
    channel = _client.channel(channelName);

    // SUSCRIPCIÓN 1: Eventos donde SOY el new_conductor_id (me asignaron)
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'traslados_eventos',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'new_conductor_id',
        value: personalId,
      ),
      callback: (payload) {
        debugPrint('📥 [TrasladosDataSource] INSERT (new_conductor): $personalId');
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
        value: personalId,
      ),
      callback: (payload) {
        debugPrint('📥 [TrasladosDataSource] INSERT (old_conductor): $personalId');
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
  }

  /// Cierra todos los canales Realtime activos
  /// Llamar desde el dispose del repository/cubit
  @override
  Future<void> disposeRealtimeChannels() async {
    debugPrint('🔌 [TrasladosDataSource] Cerrando todos los canales Realtime');
    await _client.removeAllChannels();
  }

  // ========== MÉTODOS PENDIENTES DE IMPLEMENTAR (WEB) ==========

  @override
  Future<List<TrasladoEntity>> getAll() {
    throw UnimplementedError('getAll() no implementado aún para mobile');
  }

  @override
  Future<List<TrasladoEntity>> getByServicioRecurrente(String idServicioRecurrente) {
    throw UnimplementedError('getByServicioRecurrente() no implementado aún para mobile');
  }

  @override
  Future<List<TrasladoEntity>> getByServiciosRecurrentes(List<String> idsServiciosRecurrentes) {
    throw UnimplementedError('getByServiciosRecurrentes() no implementado aún para mobile');
  }

  @override
  Future<List<TrasladoEntity>> getByServiciosYFecha({
    required List<String> idsServiciosRecurrentes,
    required DateTime fecha,
  }) async {
    try {
      if (idsServiciosRecurrentes.isEmpty) {
        return [];
      }

      final fechaStr = fecha.toIso8601String().split('T')[0];
      debugPrint('📦 [TrasladosDataSource] Obteniendo traslados para fecha: $fechaStr');
      debugPrint('📦 [TrasladosDataSource] IDs de servicios recurrentes: $idsServiciosRecurrentes');

      final response = await _client
          .from(_viewName) // Usar vista para tener datos desnormalizados
          .select(_selectQuery)
          .inFilter('id_servicio_recurrente', idsServiciosRecurrentes)
          .eq('fecha', fechaStr)
          .order('hora_programada', ascending: true);

      debugPrint('✅ [TrasladosDataSource] Encontrados ${response.length} traslados con id_servicio_recurrente');

      // Si no hay resultados, intentar buscar por id_servicio también
      if ((response as List).isEmpty) {
        debugPrint('🔍 [TrasladosDataSource] No hay traslados con id_servicio_recurrente, buscando por id_servicio...');

        final responseByServicio = await _client
            .from(_viewName) // Usar vista para tener datos desnormalizados
            .select(_selectQuery)
            .inFilter('id_servicio', idsServiciosRecurrentes)
            .eq('fecha', fechaStr)
            .order('hora_programada', ascending: true);

        debugPrint('✅ [TrasladosDataSource] Encontrados ${responseByServicio.length} traslados con id_servicio');

        if ((responseByServicio as List).isNotEmpty) {
          return responseByServicio
              .map((json) => _mapToEntity(json))
              .toList();
        }
      }

      return response
          .map((json) => _mapToEntity(json))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosDataSource] Error al obtener traslados por servicios y fecha: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getTrasladosByServicioId(String servicioId) {
    throw UnimplementedError('getTrasladosByServicioId() no implementado aún para mobile');
  }

  @override
  Future<List<TrasladoEntity>> getByPaciente(String idPaciente) {
    throw UnimplementedError('getByPaciente() no implementado aún para mobile');
  }

  @override
  Future<List<TrasladoEntity>> getByVehiculo(String idVehiculo) {
    throw UnimplementedError('getByVehiculo() no implementado aún para mobile');
  }

  @override
  Future<List<TrasladoEntity>> getByFecha(DateTime fecha) {
    throw UnimplementedError('getByFecha() no implementado aún para mobile');
  }

  @override
  Future<List<TrasladoEntity>> getEnCurso() {
    throw UnimplementedError('getEnCurso() no implementado aún para mobile');
  }

  @override
  Future<List<TrasladoEntity>> getRequierenAsignacion() {
    throw UnimplementedError('getRequierenAsignacion() no implementado aún para mobile');
  }

  @override
  Future<List<TrasladoEntity>> searchByCodigo(String query) {
    throw UnimplementedError('searchByCodigo() no implementado aún para mobile');
  }

  @override
  Future<TrasladoEntity> create(TrasladoEntity traslado) {
    throw UnimplementedError('create() no implementado aún para mobile');
  }

  @override
  Future<TrasladoEntity> updateEstado({
    required String id,
    required String nuevoEstado,
    Map<String, dynamic>? ubicacion,
  }) {
    throw UnimplementedError('updateEstado() no implementado aún para mobile');
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
      debugPrint('🚗 [TrasladosDataSource] Asignando recursos al traslado: $id');
      debugPrint('   - Conductor: $idConductor');
      debugPrint('   - Vehículo: $idVehiculo');
      debugPrint('   - Matrícula: $matriculaVehiculo');
      debugPrint('   - Técnico: $idTecnico');

      // Construir el mapa de actualización solo con campos no nulos
      // Al asignar recursos también se envía automáticamente al conductor
      final DateTime ahora = DateTime.now().toUtc();
      final Map<String, dynamic> updateData = <String, dynamic>{
        'estado': 'enviado', // Asignar = Enviar al conductor
        'fecha_asignacion': ahora.toIso8601String(),
        'fecha_enviado': ahora.toIso8601String(), // Se envía automáticamente
        'updated_at': ahora.toIso8601String(),
      };

      if (idConductor != null) {
        updateData['id_conductor'] = idConductor;
      }
      if (idVehiculo != null) {
        updateData['id_vehiculo'] = idVehiculo;
      }
      if (matriculaVehiculo != null) {
        updateData['matricula_vehiculo'] = matriculaVehiculo;
      }
      if (idTecnico != null) {
        // Si hay técnico, agregarlo al array de personal_asignado
        updateData['personal_asignado'] = <String>[idTecnico];
      }

      await _client
          .from(_tableName)
          .update(updateData)
          .eq('id', id);

      debugPrint('✅ [TrasladosDataSource] Recursos asignados correctamente');

      // Obtener traslado actualizado desde la vista con datos completos
      return getById(id);
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosDataSource] Error al asignar recursos: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> desasignarRecursos({
    required String id,
  }) async {
    try {
      debugPrint('🚫 [TrasladosDataSource] Desasignando recursos del traslado: $id');

      // Actualizar el traslado: poner recursos en null y estado a pendiente
      await _client
          .from(_tableName)
          .update({
            'id_conductor': null,
            'id_vehiculo': null,
            'matricula_vehiculo': null,
            'personal_asignado': null,
            'fecha_asignacion': null,
            'usuario_asignacion': null,
            'estado': 'pendiente',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);

      debugPrint('✅ [TrasladosDataSource] Recursos desasignados correctamente');

      // Obtener traslado actualizado desde la vista con datos completos
      return getById(id);
    } catch (e, stackTrace) {
      debugPrint('❌ [TrasladosDataSource] Error al desasignar recursos: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> registrarUbicacion({
    required String id,
    required Map<String, dynamic> ubicacion,
    required String estado,
  }) {
    throw UnimplementedError('registrarUbicacion() no implementado aún para mobile');
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError('delete() no implementado aún para mobile');
  }

  @override
  Future<void> hardDelete(String id) {
    throw UnimplementedError('hardDelete() no implementado aún para mobile');
  }

  @override
  Future<void> hardDeleteMultiple(List<String> ids) {
    throw UnimplementedError('hardDeleteMultiple() no implementado aún para mobile');
  }

  @override
  Stream<List<TrasladoEntity>> watchAll() {
    throw UnimplementedError('watchAll() no implementado aún para mobile');
  }

  @override
  Stream<List<TrasladoEntity>> watchByServicioRecurrente(String idServicioRecurrente) {
    throw UnimplementedError('watchByServicioRecurrente() no implementado aún para mobile');
  }

  @override
  Stream<List<TrasladoEntity>> watchByConductor(String idConductor) {
    throw UnimplementedError('watchByConductor() no implementado aún para mobile');
  }

  @override
  Stream<List<TrasladoEntity>> watchEnCurso() {
    throw UnimplementedError('watchEnCurso() no implementado aún para mobile');
  }
}
