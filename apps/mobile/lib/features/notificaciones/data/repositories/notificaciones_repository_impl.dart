import 'package:flutter/foundation.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/repositories/notificaciones_repository.dart';

/// Implementación del repositorio de notificaciones
///
/// Actúa como pass-through al datasource del core,
/// inyectando automáticamente el usuario_id del usuario autenticado
class NotificacionesRepositoryImpl implements NotificacionesRepository {
  NotificacionesRepositoryImpl({
    required AuthBloc authBloc,
  })  : _authBloc = authBloc,
        _dataSource = NotificacionesDataSourceFactory.createSupabase(
          // El datasource filtra por usuario_id (RLS); empresaId no se usa en las consultas
          empresaId: 'ambutrack',
        );

  final AuthBloc _authBloc;
  final NotificacionesDataSource _dataSource;

  /// Obtiene el ID del usuario autenticado desde el AuthBloc
  String? get _currentUserId {
    final state = _authBloc.state;
    if (state is AuthAuthenticated) {
      return state.user.id;
    }
    return null;
  }

  @override
  Future<List<NotificacionEntity>> getNotificaciones({
    int limit = 50,
    bool soloNoLeidas = false,
  }) async {
    final usuarioId = _currentUserId;
    if (usuarioId == null) {
      debugPrint('❌ [NotificacionesRepository] Usuario no autenticado');
      return [];
    }

    debugPrint(
      '📦 [NotificacionesRepository] Obteniendo notificaciones (limit: $limit, soloNoLeidas: $soloNoLeidas)',
    );

    try {
      if (soloNoLeidas) {
        return await _dataSource.getNoLeidas(usuarioId);
      }
      return await _dataSource.getByUsuario(usuarioId);
    } catch (e) {
      debugPrint('❌ [NotificacionesRepository] Error al obtener notificaciones: $e');
      rethrow;
    }
  }

  @override
  Future<int> getConteoNoLeidas() async {
    final usuarioId = _currentUserId;
    if (usuarioId == null) {
      debugPrint('❌ [NotificacionesRepository] Usuario no autenticado');
      return 0;
    }

    debugPrint('📦 [NotificacionesRepository] Obteniendo conteo de no leídas');

    try {
      return await _dataSource.getConteoNoLeidas(usuarioId);
    } catch (e) {
      debugPrint('❌ [NotificacionesRepository] Error al obtener conteo: $e');
      rethrow;
    }
  }

  @override
  Future<void> marcarComoLeida(String id) async {
    debugPrint('📦 [NotificacionesRepository] Marcando notificación $id como leída');

    try {
      await _dataSource.marcarComoLeida(id);
      debugPrint('✅ [NotificacionesRepository] Notificación marcada como leída');
    } catch (e) {
      debugPrint('❌ [NotificacionesRepository] Error al marcar como leída: $e');
      rethrow;
    }
  }

  @override
  Future<void> marcarTodasComoLeidas() async {
    final usuarioId = _currentUserId;
    if (usuarioId == null) {
      debugPrint('❌ [NotificacionesRepository] Usuario no autenticado');
      return;
    }

    debugPrint('📦 [NotificacionesRepository] Marcando todas como leídas');

    try {
      await _dataSource.marcarTodasComoLeidas(usuarioId);
      debugPrint('✅ [NotificacionesRepository] Todas las notificaciones marcadas como leídas');
    } catch (e) {
      debugPrint('❌ [NotificacionesRepository] Error al marcar todas: $e');
      rethrow;
    }
  }

  @override
  Stream<List<NotificacionEntity>> watchNotificaciones() {
    final usuarioId = _currentUserId;
    if (usuarioId == null) {
      debugPrint('❌ [NotificacionesRepository] Usuario no autenticado para stream');
      return Stream.value([]);
    }

    debugPrint('📡 [NotificacionesRepository] Iniciando stream de notificaciones en tiempo real');

    return _dataSource.watchNotificaciones(usuarioId);
  }

  @override
  Stream<int> watchConteoNoLeidas() {
    final usuarioId = _currentUserId;
    if (usuarioId == null) {
      debugPrint('❌ [NotificacionesRepository] Usuario no autenticado para stream de conteo');
      return Stream.value(0);
    }

    debugPrint('📡 [NotificacionesRepository] Iniciando stream de conteo no leídas');

    return _dataSource.watchConteoNoLeidas(usuarioId);
  }

  @override
  Future<void> eliminar(String id) async {
    debugPrint('📦 [NotificacionesRepository] Eliminando notificación $id');

    try {
      await _dataSource.delete(id);
      debugPrint('✅ [NotificacionesRepository] Notificación eliminada');
    } catch (e) {
      debugPrint('❌ [NotificacionesRepository] Error al eliminar: $e');
      rethrow;
    }
  }

  @override
  Future<void> eliminarTodas() async {
    final usuarioId = _currentUserId;
    if (usuarioId == null) {
      debugPrint('❌ [NotificacionesRepository] Usuario no autenticado');
      return;
    }

    debugPrint('📦 [NotificacionesRepository] Eliminando todas las notificaciones');

    try {
      await _dataSource.deleteAll(usuarioId);
      debugPrint('✅ [NotificacionesRepository] Todas las notificaciones eliminadas');
    } catch (e) {
      debugPrint('❌ [NotificacionesRepository] Error al eliminar todas: $e');
      rethrow;
    }
  }

  @override
  Future<void> eliminarSeleccionadas(List<String> ids) async {
    debugPrint('📦 [NotificacionesRepository] Eliminando ${ids.length} notificaciones seleccionadas');

    try {
      await _dataSource.deleteMultiple(ids);
      debugPrint('✅ [NotificacionesRepository] Notificaciones seleccionadas eliminadas');
    } catch (e) {
      debugPrint('❌ [NotificacionesRepository] Error al eliminar seleccionadas: $e');
      rethrow;
    }
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
    debugPrint('📬 [NotificacionesRepository] Notificando a jefes de personal: $titulo');

    try {
      await _dataSource.notificarJefesPersonal(
        tipo: tipo,
        titulo: titulo,
        mensaje: mensaje,
        entidadTipo: entidadTipo,
        entidadId: entidadId,
        metadata: metadata,
      );
      debugPrint('✅ [NotificacionesRepository] Notificación enviada a jefes de personal');
    } catch (e) {
      debugPrint('❌ [NotificacionesRepository] Error al notificar jefes: $e');
      // No hacemos rethrow para no romper el flujo principal si falla la notificación
    }
  }

  @override
  Future<void> notificarGestoresFlota({
    required String tipo,
    required String titulo,
    required String mensaje,
    String? entidadTipo,
    String? entidadId,
    Map<String, dynamic> metadata = const {},
    String? excluirUsuarioId,
  }) async {
    debugPrint('🚗 [NotificacionesRepository] Notificando a gestores de flota: $titulo');
    if (excluirUsuarioId != null) {
      debugPrint('🚫 [NotificacionesRepository] Excluyendo usuario: $excluirUsuarioId');
    }

    try {
      await _dataSource.notificarGestoresFlota(
        tipo: tipo,
        titulo: titulo,
        mensaje: mensaje,
        entidadTipo: entidadTipo,
        entidadId: entidadId,
        metadata: metadata,
        excluirUsuarioId: excluirUsuarioId,
      );
      debugPrint('✅ [NotificacionesRepository] Notificación enviada a gestores de flota');
    } catch (e) {
      debugPrint('❌ [NotificacionesRepository] Error al notificar gestores: $e');
      // No hacemos rethrow para no romper el flujo principal si falla la notificación
    }
  }

  @override
  Future<void> dispose() async {
    debugPrint('🔌 [NotificacionesRepository] Cerrando conexiones Realtime');
    // El datasource del core maneja internamente el cierre de canales
    // No necesitamos hacer nada aquí por ahora
  }
}
