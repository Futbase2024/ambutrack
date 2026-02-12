import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de traslados
/// Siguiendo el patrón pass-through, este repositorio simplemente delega al datasource
abstract class TrasladosRepository {
  /// Obtiene todos los traslados asignados al conductor actual
  Future<List<TrasladoEntity>> getByIdConductor(String idConductor);

  /// Obtiene los traslados activos del conductor (no finalizados/cancelados)
  Future<List<TrasladoEntity>> getActivosByIdConductor(String idConductor);

  /// Obtiene un traslado por ID
  Future<TrasladoEntity> getById(String id);

  /// Obtiene traslados por rango de fechas
  Future<List<TrasladoEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? idConductor,
  });

  /// Obtiene traslados por estado
  Future<List<TrasladoEntity>> getByEstado({
    required EstadoTraslado estado,
    String? idConductor,
  });

  /// Cambia el estado de un traslado
  Future<TrasladoEntity> cambiarEstado({
    required String idTraslado,
    required EstadoTraslado nuevoEstado,
    required String idUsuario,
    UbicacionEntity? ubicacion,
    String? observaciones,
  });

  /// Obtiene el historial de estados de un traslado
  Future<List<HistorialEstadoEntity>> getHistorialEstados(String idTraslado);

  /// Actualiza campos específicos de un traslado
  Future<TrasladoEntity> update({
    required String id,
    required Map<String, dynamic> updates,
  });

  /// Stream de traslados activos del conductor
  Stream<List<TrasladoEntity>> watchActivosByIdConductor(String idConductor);

  /// Stream de un traslado específico
  Stream<TrasladoEntity> watchById(String id);

  /// Stream de eventos de traslados para el conductor autenticado
  /// Emite eventos cuando:
  /// - Me asignan un traslado (assigned/reassigned)
  /// - Me quitan un traslado (unassigned/reassigned a otro)
  /// - Cambia el estado de un traslado mío (status_changed)
  Stream<TrasladoEventoEntity> streamEventosConductor();

  /// Cierra todos los canales Realtime activos
  Future<void> disposeRealtimeChannels();
}
