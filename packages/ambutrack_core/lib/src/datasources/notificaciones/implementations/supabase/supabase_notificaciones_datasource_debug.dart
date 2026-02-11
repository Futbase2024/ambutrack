import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../utils/exceptions/datasource_exception.dart';
import '../../entities/notificacion_entity.dart';
import '../../models/notificacion_supabase_model.dart';
import '../../notificaciones_contract.dart';

/// Implementación de Supabase para el datasource de notificaciones
/// con logs adicionales para diagnóstico de problemas
///
/// Características:
/// - Soporte para notificaciones en tiempo real con Supabase Realtime
/// - Consultas optimizadas con índices
/// - Filtrado por usuario y estado de lectura
/// - Logs exhaustivos para diagnóstico
class SupabaseNotificacionesDataSourceDebug implements NotificacionesDataSource {
  SupabaseNotificacionesDataSourceDebug({
    required String empresaId,
    this.enableDebugLogs = true,
  }) : _empresaId = empresaId {
    _log('Inicializado con empresaId: $_empresaId');
  }

  final String _empresaId;
  final bool enableDebugLogs;
  static const String _tableName = 'tnotificaciones';

  /// Cliente de Supabase
  static SupabaseClient get _client => Supabase.instance.client;

  /// Canal de Realtime para notificaciones
  RealtimeChannel? _channel;
  final StreamController<List<NotificacionEntity>> _notificacionesController =
      StreamController<List<NotificacionEntity>>.broadcast();
  final StreamController<int> _conteoController = StreamController<int>.broadcast();

  void _log(String message) {
    if (enableDebugLogs) {
      print('🔔 [NotificacionesDataSource] $message');
    }
  }

  @override
  Future<List<NotificacionEntity>> getByUsuario(String usuarioId) async {
    try {
      _log('getByUsuario - Usuario ID: $usuarioId');
      _log('getByUsuario - Tabla: $_tableName');

      final response = await _client
          .from(_tableName)
          .select()
          .eq('usuario_destino_id', usuarioId)
          .order('created_at', ascending: false);

      _log('getByUsuario - Respuesta: ${response.length} notificaciones');

      final entities = response
          .map((json) => NotificacionSupabaseModel.fromJson(json).toEntity())
          .toList();

      _log('getByUsuario - Entidades convertidas: ${entities.length}');

      return entities;
    } catch (e) {
      _log('❌ Error en getByUsuario: $e');
      throw DataSourceException(
        message: 'Error al obtener notificaciones: $e',
        code: 'QUERY_ERROR',
      );
    }
  }

  @override
  Future<List<NotificacionEntity>> getNoLeidas(String usuarioId) async {
    try {
      _log('getNoLeidas - Usuario ID: $usuarioId');

      final response = await _client
          .from(_tableName)
          .select()
          .eq('usuario_destino_id', usuarioId)
          .eq('leida', false)
          .order('created_at', ascending: false);

      _log('getNoLeidas - Respuesta: ${response.length} no leídas');

      return response
          .map((json) => NotificacionSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _log('❌ Error en getNoLeidas: $e');
      throw DataSourceException(
        message: 'Error al obtener notificaciones no leídas: $e',
        code: 'QUERY_ERROR',
      );
    }
  }

  @override
  Future<int> getConteoNoLeidas(String usuarioId) async {
    try {
      _log('getConteoNoLeidas - Usuario ID: $usuarioId');

      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('usuario_destino_id', usuarioId)
          .eq('leida', false);

      final conteo = response.length;
      _log('getConteoNoLeidas - Resultado: $conteo no leídas');

      return conteo;
    } catch (e) {
      _log('❌ Error en getConteoNoLeidas: $e');
      throw DataSourceException(
        message: 'Error al obtener conteo de notificaciones: $e',
        code: 'QUERY_ERROR',
      );
    }
  }

  @override
  Future<void> marcarComoLeida(String id) async {
    try {
      _log('marcarComoLeida - ID: $id');

      await _client
          .from(_tableName)
          .update({'leida': true, 'fecha_lectura': DateTime.now().toIso8601String()})
          .eq('id', id);

      _log('marcarComoLeida - Marcada como leída');
    } catch (e) {
      _log('❌ Error en marcarComoLeida: $e');
      throw DataSourceException(
        message: 'Error al marcar notificación como leída: $e',
        code: 'UPDATE_ERROR',
      );
    }
  }

  @override
  Future<void> marcarTodasComoLeidas(String usuarioId) async {
    try {
      _log('marcarTodasComoLeidas - Usuario ID: $usuarioId');

      await _client
          .from(_tableName)
          .update({'leida': true, 'fecha_lectura': DateTime.now().toIso8601String()})
          .eq('usuario_destino_id', usuarioId)
          .eq('leida', false);

      _log('marcarTodasComoLeidas - Todas marcadas como leídas');
    } catch (e) {
      _log('❌ Error en marcarTodasComoLeidas: $e');
      throw DataSourceException(
        message: 'Error al marcar todas como leídas: $e',
        code: 'UPDATE_ERROR',
      );
    }
  }

  @override
  Future<NotificacionEntity> create(NotificacionEntity notificacion) async {
    try {
      _log('create - Creando notificación: ${notificacion.titulo}');
      _log('create - Para usuario: ${notificacion.usuarioDestinoId}');
      _log('create - Tipo: ${notificacion.tipo.value}');

      final model = NotificacionSupabaseModel.fromEntity(notificacion);
      final json = model.toJson();

      // Eliminar el campo 'id' si está vacío para que Supabase genere uno automáticamente
      if (json['id'] == null || json['id'] == '') {
        json.remove('id');
        _log('create - Campo id vacío removido, Supabase generará uno');
      }

      _log('create - Model JSON: $json');

      final response = await _client.from(_tableName).insert(json).select().single();

      _log('create - Insertado con ID: ${response['id']}');

      return NotificacionSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      _log('❌ Error en create: $e');
      throw DataSourceException(
        message: 'Error al crear notificación: $e',
        code: 'INSERT_ERROR',
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      _log('delete - ID: $id');

      await _client.from(_tableName).delete().eq('id', id);

      _log('delete - Eliminada correctamente');
    } catch (e) {
      _log('❌ Error en delete: $e');
      throw DataSourceException(
        message: 'Error al eliminar notificación: $e',
        code: 'DELETE_ERROR',
      );
    }
  }

  @override
  Future<void> deleteAll(String usuarioId) async {
    try {
      _log('deleteAll - Usuario ID: $usuarioId');

      await _client.from(_tableName).delete().eq('usuario_destino_id', usuarioId);

      _log('deleteAll - Todas las notificaciones eliminadas');
    } catch (e) {
      _log('❌ Error en deleteAll: $e');
      throw DataSourceException(
        message: 'Error al eliminar todas las notificaciones: $e',
        code: 'DELETE_ERROR',
      );
    }
  }

  @override
  Future<void> deleteMultiple(List<String> ids) async {
    try {
      _log('deleteMultiple - ${ids.length} notificaciones a eliminar');
      _log('deleteMultiple - IDs: $ids');

      await _client.from(_tableName).delete().inFilter('id', ids);

      _log('deleteMultiple - Notificaciones seleccionadas eliminadas');
    } catch (e) {
      _log('❌ Error en deleteMultiple: $e');
      throw DataSourceException(
        message: 'Error al eliminar notificaciones seleccionadas: $e',
        code: 'DELETE_ERROR',
      );
    }
  }

  @override
  Stream<List<NotificacionEntity>> watchNotificaciones(String usuarioId) {
    _log('═════════════════════════════════════════════════════════');
    _log('watchNotificaciones - Iniciando para usuario: $usuarioId');

    // Cancelar suscripción anterior si existe
    _channel?.unsubscribe();
    _log('watchNotificaciones - Suscripción anterior cancelada');

    // Lista actual de notificaciones
    List<NotificacionEntity> currentNotificaciones = [];

    // Cargar datos iniciales
    _log('watchNotificaciones - Cargando datos iniciales...');
    getByUsuario(usuarioId).then((notificaciones) {
      currentNotificaciones = notificaciones;
      _log('watchNotificaciones - Datos iniciales cargados: ${notificaciones.length} notificaciones');
      if (!_notificacionesController.isClosed) {
        _notificacionesController.add(currentNotificaciones);
        _log('watchNotificaciones - Enviadas al stream');
      }
    }).catchError((error) {
      _log('❌ Error cargando datos iniciales: $error');
    });

    // Suscribirse a cambios en tiempo real
    final channelName = "notificaciones:$usuarioId";
    _log('watchNotificaciones - Creando canal: $channelName');
    _log('watchNotificaciones - Tabla: $_tableName');
    _log('watchNotificaciones - Filtro: usuario_destino_id = $usuarioId');

    _channel = _client.channel(channelName);

    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: _tableName,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'usuario_destino_id',
        value: usuarioId,
      ),
      callback: (payload) {
        _log('🎯 EVENTO RECIBIDO: ${payload.eventType}');
        _log('🎯 Payload: ${payload.newRecord}');

        try {
          final model = NotificacionSupabaseModel.fromJson(payload.newRecord);
          final notificacion = model.toEntity();

          switch (payload.eventType) {
            case PostgresChangeEvent.insert:
              _log('➕ INSERT - Nueva notificación: ${notificacion.titulo}');
              currentNotificaciones = [notificacion, ...currentNotificaciones];
              _log('➕ Total en lista: ${currentNotificaciones.length}');
              break;
            case PostgresChangeEvent.update:
              _log('✏️ UPDATE - Notificación actualizada: ${notificacion.titulo}');
              currentNotificaciones = currentNotificaciones.map((n) {
                return n.id == notificacion.id ? notificacion : n;
              }).toList();
              _log('✏️ Total en lista: ${currentNotificaciones.length}');
              break;
            case PostgresChangeEvent.delete:
              _log('🗑️ DELETE - Notificación eliminada: ${notificacion.id}');
              currentNotificaciones = currentNotificaciones.where((n) => n.id != notificacion.id).toList();
              _log('🗑️ Total en lista: ${currentNotificaciones.length}');
              break;
            default:
              _log('❓ Evento desconocido: ${payload.eventType}');
              break;
          }

          if (!_notificacionesController.isClosed) {
            _notificacionesController.add(currentNotificaciones);
            _log('📤 Enviadas ${currentNotificaciones.length} notificaciones al stream');
          }
        } catch (e) {
          _log('❌ Error procesando evento: $e');
        }
      },
    ).subscribe((status, [error]) {
      _log('📡 STATUS SUSCRIPCIÓN: $status');
      if (error != null) {
        _log('❌ ERROR SUSCRIPCIÓN: $error');
      }
    });

    _log('═════════════════════════════════════════════════════════');

    return _notificacionesController.stream;
  }

  @override
  Stream<int> watchConteoNoLeidas(String usuarioId) {
    _log('watchConteoNoLeidas - Usuario ID: $usuarioId');

    // Cargar conteo inicial
    getConteoNoLeidas(usuarioId).then((conteo) {
      if (!_conteoController.isClosed) {
        _conteoController.add(conteo);
        _log('watchConteoNoLeidas - Conteo inicial: $conteo');
      }
    });

    // Escuchar cambios en el stream de notificaciones
    watchNotificaciones(usuarioId).listen((notificaciones) {
      final conteo = notificaciones.where((n) => !n.leida).length;
      if (!_conteoController.isClosed) {
        _conteoController.add(conteo);
        _log('watchConteoNoLeidas - Conteo actualizado: $conteo');
      }
    });

    return _conteoController.stream;
  }

  @override
  Future<void> notificarJefesPersonal({
    required String tipo,
    required String titulo,
    required String mensaje,
    String? entidadTipo,
    String? entidadId,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      _log('notificarJefesPersonal - Iniciando');
      _log('notificarJefesPersonal - Tipo: $tipo');
      _log('notificarJefesPersonal - Título: $titulo');

      // Buscar todos los jefes de personal y administradores
      final personalResponse = await _client
          .from('tpersonal')
          .select('usuario_id, nombre, apellidos')
          .inFilter('categoria', ['admin', 'jefe_personal', 'jefe_trafico'])
          .eq('activo', true);

      _log('notificarJefesPersonal - ${personalResponse.length} jefes encontrados');

      // Crear notificación para cada jefe
      for (final p in personalResponse) {
        final usuarioId = p['usuario_id'] as String;
        final nombre = p['nombre'] as String?;
        final apellidos = p['apellidos'] as String?;

        _log('notificarJefesPersonal - Enviando a: $nombre $apellidos ($usuarioId)');

        final notificacion = NotificacionEntity(
          id: '', // Se generará en la BD
          empresaId: _empresaId,
          usuarioDestinoId: usuarioId,
          tipo: NotificacionTipo.fromString(tipo),
          titulo: titulo,
          mensaje: mensaje,
          entidadTipo: entidadTipo,
          entidadId: entidadId,
          leida: false,
          fechaLectura: null,
          metadata: metadata,
          createdAt: DateTime.now(),
          updatedAt: null,
        );

        await create(notificacion);
      }

      _log('notificarJefesPersonal - Completado');
    } catch (e) {
      _log('❌ Error en notificarJefesPersonal: $e');
      throw DataSourceException(
        message: 'Error al notificar jefes de personal: $e',
        code: 'NOTIFY_ERROR',
      );
    }
  }

  /// Libera recursos
  void dispose() {
    _log('dispose - Liberando recursos');
    _channel?.unsubscribe();
    _notificacionesController.close();
    _conteoController.close();
    _log('dispose - Recursos liberados');
  }
}
