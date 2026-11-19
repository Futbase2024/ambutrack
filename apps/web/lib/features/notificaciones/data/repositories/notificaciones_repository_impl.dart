import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/notificaciones_repository.dart';

/// Implementación del repositorio de notificaciones con pass-through al datasource
@LazySingleton(as: NotificacionesRepository)
class NotificacionesRepositoryImpl implements NotificacionesRepository {
  NotificacionesRepositoryImpl() : _dataSource = NotificacionesDataSourceFactory.createSupabase(
          empresaId: 'ambutrack',
        );

  final NotificacionesDataSource _dataSource;

  @override
  Future<List<NotificacionEntity>> getByUsuario(String usuarioId) async {
    debugPrint('📬 Repository: Obteniendo notificaciones para usuario $usuarioId');
    return _dataSource.getByUsuario(usuarioId);
  }

  @override
  Future<List<NotificacionEntity>> getNoLeidas(String usuarioId) async {
    debugPrint('📬 Repository: Obteniendo notificaciones no leídas para usuario $usuarioId');
    return _dataSource.getNoLeidas(usuarioId);
  }

  @override
  Future<int> getConteoNoLeidas(String usuarioId) async {
    debugPrint('📬 Repository: Obteniendo conteo de notificaciones no leídas para usuario $usuarioId');
    return _dataSource.getConteoNoLeidas(usuarioId);
  }

  @override
  Future<void> marcarComoLeida(String id) async {
    debugPrint('📬 Repository: Marcando notificación $id como leída');
    return _dataSource.marcarComoLeida(id);
  }

  @override
  Future<void> marcarTodasComoLeidas(String usuarioId) async {
    debugPrint('📬 Repository: Marcando todas las notificaciones como leídas para usuario $usuarioId');
    return _dataSource.marcarTodasComoLeidas(usuarioId);
  }

  @override
  Future<NotificacionEntity> create(NotificacionEntity notificacion) async {
    debugPrint('📬 Repository: Creando notificación: ${notificacion.titulo}');
    return _dataSource.create(notificacion);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📬 Repository: Eliminando notificación $id');
    return _dataSource.delete(id);
  }

  @override
  Future<void> deleteAll(String usuarioId) async {
    debugPrint('📬 Repository: Eliminando todas las notificaciones para usuario $usuarioId');
    return _dataSource.deleteAll(usuarioId);
  }

  @override
  Future<void> deleteMultiple(List<String> ids) async {
    debugPrint('📬 Repository: Eliminando ${ids.length} notificaciones');
    return _dataSource.deleteMultiple(ids);
  }

  @override
  Stream<List<NotificacionEntity>> watchNotificaciones(String usuarioId) {
    debugPrint('📬 Repository: Iniciando stream de notificaciones para usuario $usuarioId');
    return _dataSource.watchNotificaciones(usuarioId);
  }

  @override
  Stream<int> watchConteoNoLeidas(String usuarioId) {
    debugPrint('📬 Repository: Iniciando stream de conteo de notificaciones para usuario $usuarioId');
    return _dataSource.watchConteoNoLeidas(usuarioId);
  }

  @override
  Future<void> notificarJefesPersonal({
    required String tipo,
    required String titulo,
    required String mensaje,
    String? entidadTipo,
    String? entidadId,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    debugPrint('📬 Repository: Notificando a jefes de personal: $titulo');
    return _dataSource.notificarJefesPersonal(
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      entidadTipo: entidadTipo,
      entidadId: entidadId,
      metadata: metadata,
    );
  }
}
