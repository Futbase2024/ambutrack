import 'package:flutter/foundation.dart';

import 'package:ambutrack_core/ambutrack_core.dart';
import '../../domain/repositories/traslados_repository.dart';

/// Implementación del repositorio de traslados
/// Patrón pass-through: delega directamente al datasource sin conversiones
class TrasladosRepositoryImpl implements TrasladosRepository {
  TrasladosRepositoryImpl()
      : _dataSource = TrasladoDataSourceFactory.createSupabase();

  final TrasladoDataSource _dataSource;

  @override
  Future<List<TrasladoEntity>> getByIdConductor(String idConductor) async {
    debugPrint('📦 [TrasladosRepository] Solicitando traslados del conductor');
    return await _dataSource.getByIdConductor(idConductor);
  }

  @override
  Future<List<TrasladoEntity>> getActivosByIdConductor(String idConductor) async {
    debugPrint('📦 [TrasladosRepository] Solicitando traslados activos del conductor');
    return await _dataSource.getActivosByIdConductor(idConductor);
  }

  @override
  Future<TrasladoEntity> getById(String id) async {
    debugPrint('📦 [TrasladosRepository] Solicitando traslado: $id');
    return await _dataSource.getById(id);
  }

  @override
  Future<List<TrasladoEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? idConductor,
  }) async {
    debugPrint('📦 [TrasladosRepository] Solicitando traslados por rango de fechas');
    return await _dataSource.getByRangoFechas(
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      idConductor: idConductor,
    );
  }

  @override
  Future<List<TrasladoEntity>> getByEstado({
    required EstadoTraslado estado,
    String? idConductor,
  }) async {
    debugPrint('📦 [TrasladosRepository] Solicitando traslados por estado: ${estado.value}');
    return await _dataSource.getByEstado(
      estado: estado,
      idConductor: idConductor,
    );
  }

  @override
  Future<TrasladoEntity> cambiarEstado({
    required String idTraslado,
    required EstadoTraslado nuevoEstado,
    required String idUsuario,
    UbicacionEntity? ubicacion,
    String? observaciones,
  }) async {
    debugPrint('📦 [TrasladosRepository] Cambiando estado a: ${nuevoEstado.value}');
    return await _dataSource.cambiarEstado(
      idTraslado: idTraslado,
      nuevoEstado: nuevoEstado,
      idUsuario: idUsuario,
      ubicacion: ubicacion,
      observaciones: observaciones,
    );
  }

  @override
  Future<List<HistorialEstadoEntity>> getHistorialEstados(String idTraslado) async {
    debugPrint('📦 [TrasladosRepository] Solicitando historial de estados');
    return await _dataSource.getHistorialEstados(idTraslado);
  }

  @override
  Future<TrasladoEntity> update({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    debugPrint('📦 [TrasladosRepository] Actualizando traslado');
    return await _dataSource.update(id: id, updates: updates);
  }

  @override
  Stream<List<TrasladoEntity>> watchActivosByIdConductor(String idConductor) {
    debugPrint('📡 [TrasladosRepository] Iniciando stream de traslados activos');
    return _dataSource.watchActivosByIdConductor(idConductor);
  }

  @override
  Stream<TrasladoEntity> watchById(String id) {
    debugPrint('📡 [TrasladosRepository] Iniciando stream del traslado');
    return _dataSource.watchById(id);
  }

  @override
  Stream<TrasladoEventoEntity> streamEventosConductor() {
    debugPrint('🔔 [TrasladosRepository] Iniciando stream de eventos de traslados');
    return _dataSource.streamEventosConductor();
  }

  @override
  Future<void> disposeRealtimeChannels() async {
    debugPrint('🔌 [TrasladosRepository] Cerrando canales Realtime');
    await _dataSource.disposeRealtimeChannels();
  }
}
