import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../utils/exceptions/datasource_exception.dart';
import '../../entities/notificacion_entity.dart';
import '../../models/notificacion_supabase_model.dart';
import '../../notificaciones_contract.dart';

/// Implementación de Supabase para el datasource de notificaciones
///
/// Características:
/// - Soporte para notificaciones en tiempo real con Supabase Realtime
/// - Consultas optimizadas con índices
/// - Filtrado por usuario y estado de lectura
class SupabaseNotificacionesDataSource implements NotificacionesDataSource {
  SupabaseNotificacionesDataSource({
    required String empresaId,
  }) : _empresaId = empresaId;

  final String _empresaId;
  static const String _tableName = 'tnotificaciones';

  /// Cliente de Supabase
  static SupabaseClient get _client => Supabase.instance.client;

  void _log(String message) {
    // ignore: avoid_print
    print('🔔 [NotificacionesDataSource] $message');
  }

  /// Canal de Realtime para notificaciones
  RealtimeChannel? _channel;
  final StreamController<List<NotificacionEntity>> _notificacionesController =
      StreamController<List<NotificacionEntity>>.broadcast();
  final StreamController<int> _conteoController = StreamController<int>.broadcast();

  @override
  Future<List<NotificacionEntity>> getByUsuario(String usuarioId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('usuario_destino_id', usuarioId)
          .order('created_at', ascending: false);

      return response
          .map((json) => NotificacionSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw DataSourceException(
        message: 'Error al obtener notificaciones: $e',
        code: 'QUERY_ERROR',
      );
    }
  }

  @override
  Future<List<NotificacionEntity>> getNoLeidas(String usuarioId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('usuario_destino_id', usuarioId)
          .eq('leida', false)
          .order('created_at', ascending: false);

      return response
          .map((json) => NotificacionSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw DataSourceException(
        message: 'Error al obtener notificaciones no leídas: $e',
        code: 'QUERY_ERROR',
      );
    }
  }

  @override
  Future<int> getConteoNoLeidas(String usuarioId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('usuario_destino_id', usuarioId)
          .eq('leida', false);

      return response.length;
    } catch (e) {
      throw DataSourceException(
        message: 'Error al obtener conteo de notificaciones: $e',
        code: 'QUERY_ERROR',
      );
    }
  }

  @override
  Future<void> marcarComoLeida(String id) async {
    try {
      await _client
          .from(_tableName)
          .update({'leida': true, 'fecha_lectura': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw DataSourceException(
        message: 'Error al marcar notificación como leída: $e',
        code: 'UPDATE_ERROR',
      );
    }
  }

  @override
  Future<void> marcarTodasComoLeidas(String usuarioId) async {
    try {
      await _client
          .from(_tableName)
          .update({'leida': true, 'fecha_lectura': DateTime.now().toIso8601String()})
          .eq('usuario_destino_id', usuarioId)
          .eq('leida', false);
    } catch (e) {
      throw DataSourceException(
        message: 'Error al marcar todas como leídas: $e',
        code: 'UPDATE_ERROR',
      );
    }
  }

  @override
  Future<NotificacionEntity> create(NotificacionEntity notificacion) async {
    try {
      final model = NotificacionSupabaseModel.fromEntity(notificacion);
      final json = model.toJson();

      // Eliminar el campo 'id' si está vacío para que Supabase genere uno automáticamente
      if (json['id'] == null || json['id'] == '') {
        json.remove('id');
      }

      final response = await _client.from(_tableName).insert(json).select().single();

      return NotificacionSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw DataSourceException(
        message: 'Error al crear notificación: $e',
        code: 'INSERT_ERROR',
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      _log('🗑️ delete - Eliminando notificación ID: $id');
      _log('🗑️ delete - Tabla: $_tableName');

      final response = await _client
          .from(_tableName)
          .delete()
          .eq('id', id)
          .select();

      _log('🗑️ delete - Respuesta: ${response.length} filas afectadas');
      _log('🗑️ delete - Datos: $response');

      if (response.isEmpty) {
        _log('⚠️ delete - ADVERTENCIA: No se eliminó ninguna fila (puede ser problema de RLS)');
      } else {
        _log('✅ delete - Eliminada correctamente');
      }
    } catch (e, stackTrace) {
      _log('❌ delete - Error: $e');
      _log('❌ delete - StackTrace: $stackTrace');
      throw DataSourceException(
        message: 'Error al eliminar notificación: $e',
        code: 'DELETE_ERROR',
      );
    }
  }

  @override
  Future<void> deleteAll(String usuarioId) async {
    try {
      _log('🗑️ deleteAll - Eliminando todas las notificaciones');
      _log('🗑️ deleteAll - Usuario ID: $usuarioId');
      _log('🗑️ deleteAll - Tabla: $_tableName');

      final response = await _client
          .from(_tableName)
          .delete()
          .eq('usuario_destino_id', usuarioId)
          .select();

      _log('🗑️ deleteAll - Respuesta: ${response.length} filas afectadas');

      if (response.isEmpty) {
        _log('⚠️ deleteAll - ADVERTENCIA: No se eliminó ninguna fila (puede ser problema de RLS)');
      } else {
        _log('✅ deleteAll - ${response.length} notificaciones eliminadas');
      }
    } catch (e, stackTrace) {
      _log('❌ deleteAll - Error: $e');
      _log('❌ deleteAll - StackTrace: $stackTrace');
      throw DataSourceException(
        message: 'Error al eliminar todas las notificaciones: $e',
        code: 'DELETE_ERROR',
      );
    }
  }

  @override
  Future<void> deleteMultiple(List<String> ids) async {
    try {
      _log('🗑️ deleteMultiple - Eliminando ${ids.length} notificaciones');
      _log('🗑️ deleteMultiple - IDs: $ids');
      _log('🗑️ deleteMultiple - Tabla: $_tableName');

      final response = await _client
          .from(_tableName)
          .delete()
          .inFilter('id', ids)
          .select();

      _log('🗑️ deleteMultiple - Respuesta: ${response.length} filas afectadas');

      if (response.isEmpty) {
        _log('⚠️ deleteMultiple - ADVERTENCIA: No se eliminó ninguna fila (puede ser problema de RLS)');
      } else {
        _log('✅ deleteMultiple - ${response.length} notificaciones eliminadas');
      }
    } catch (e, stackTrace) {
      _log('❌ deleteMultiple - Error: $e');
      _log('❌ deleteMultiple - StackTrace: $stackTrace');
      throw DataSourceException(
        message: 'Error al eliminar notificaciones seleccionadas: $e',
        code: 'DELETE_ERROR',
      );
    }
  }

  @override
  Stream<List<NotificacionEntity>> watchNotificaciones(String usuarioId) {
    // Cancelar suscripción anterior si existe
    _channel?.unsubscribe();

    // Lista actual de notificaciones
    List<NotificacionEntity> currentNotificaciones = [];

    // Cargar datos iniciales
    getByUsuario(usuarioId).then((notificaciones) {
      currentNotificaciones = notificaciones;
      if (!_notificacionesController.isClosed) {
        _notificacionesController.add(currentNotificaciones);
      }
    });

    // Suscribirse a cambios en tiempo real
    _channel = _client.channel("notificaciones:$usuarioId");

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
        final model = NotificacionSupabaseModel.fromJson(payload.newRecord);
        final notificacion = model.toEntity();

        switch (payload.eventType) {
          case PostgresChangeEvent.insert:
            currentNotificaciones = [notificacion, ...currentNotificaciones];
            break;
          case PostgresChangeEvent.update:
            currentNotificaciones = currentNotificaciones.map((n) {
              return n.id == notificacion.id ? notificacion : n;
            }).toList();
            break;
          case PostgresChangeEvent.delete:
            currentNotificaciones = currentNotificaciones.where((n) => n.id != notificacion.id).toList();
            break;
          default:
            break;
        }

        if (!_notificacionesController.isClosed) {
          _notificacionesController.add(currentNotificaciones);
        }
      },
    ).subscribe();

    return _notificacionesController.stream;
  }

  @override
  Stream<int> watchConteoNoLeidas(String usuarioId) {
    // Cargar conteo inicial
    getConteoNoLeidas(usuarioId).then((conteo) {
      if (!_conteoController.isClosed) {
        _conteoController.add(conteo);
      }
    });

    // Escuchar cambios en el stream de notificaciones
    watchNotificaciones(usuarioId).listen((notificaciones) {
      final conteo = notificaciones.where((n) => !n.leida).length;
      if (!_conteoController.isClosed) {
        _conteoController.add(conteo);
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
      _log('📬 notificarJefesPersonal - Llamando función PostgreSQL');
      _log('📬 Tipo: $tipo, Título: $titulo');

      // Usar función PostgreSQL con SECURITY DEFINER (bypass RLS)
      await _client.rpc('crear_notificacion_jefes_personal', params: {
        'p_tipo': tipo,
        'p_titulo': titulo,
        'p_mensaje': mensaje,
        'p_entidad_tipo': entidadTipo,
        'p_entidad_id': entidadId,
        'p_metadata': metadata,
      });

      _log('✅ notificarJefesPersonal - Notificaciones creadas exitosamente');
    } catch (e) {
      _log('❌ notificarJefesPersonal - Error: $e');
      throw DataSourceException(
        message: 'Error al notificar jefes de personal: $e',
        code: 'NOTIFY_ERROR',
      );
    }
  }

  /// Libera recursos
  void dispose() {
    _channel?.unsubscribe();
    _notificacionesController.close();
    _conteoController.close();
  }
}
