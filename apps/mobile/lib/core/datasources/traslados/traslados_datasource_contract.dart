import 'entities/estado_traslado_enum.dart';
import 'entities/historial_estado_entity.dart';
import 'entities/traslado_entity.dart';
import 'entities/traslado_evento_entity.dart';
import 'entities/ubicacion_entity.dart';

/// Contrato abstracto para el datasource de traslados
abstract class TrasladosDataSource {
  /// Obtiene todos los traslados asignados al conductor actual
  /// Filtra por id_conductor = usuario actual
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
  /// Registra automáticamente en historial_estados_traslado
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
  /// Usado para actualizar tiempos, kilometros, etc.
  Future<TrasladoEntity> update({
    required String id,
    required Map<String, dynamic> updates,
  });

  /// Stream de traslados activos del conductor
  /// Se actualiza en tiempo real cuando hay cambios
  Stream<List<TrasladoEntity>> watchActivosByIdConductor(String idConductor);

  /// Stream de un traslado específico
  /// Se actualiza en tiempo real cuando hay cambios
  Stream<TrasladoEntity> watchById(String id);

  /// Stream de eventos de traslados para el conductor autenticado
  /// Emite eventos cuando:
  /// - Me asignan un traslado (assigned/reassigned)
  /// - Me quitan un traslado (unassigned/reassigned a otro)
  /// - Cambia el estado de un traslado mío (status_changed)
  Stream<TrasladoEventoEntity> streamEventosConductor();

  /// Cierra todos los canales Realtime activos
  /// Llamar desde el dispose del repository/cubit
  Future<void> disposeRealtimeChannels();
}
