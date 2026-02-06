import 'entities/estado_traslado_enum.dart';
import 'entities/historial_estado_entity.dart';
import 'entities/traslado_entity.dart';
import 'entities/traslado_evento_entity.dart';
import 'entities/ubicacion_entity.dart';

/// Contrato abstracto para el DataSource de Traslados
/// Define las operaciones CRUD y de seguimiento de traslados individuales
/// Incluye métodos para web (gestión) y mobile (conductores)
abstract class TrasladoDataSource {
  /// Obtiene todos los traslados
  Future<List<TrasladoEntity>> getAll();

  /// Obtiene un traslado por su ID
  Future<TrasladoEntity> getById(String id);

  /// Obtiene traslados de un servicio recurrente específico
  Future<List<TrasladoEntity>> getByServicioRecurrente(
    String idServicioRecurrente,
  );

  /// Obtiene traslados de múltiples servicios recurrentes en una sola consulta
  /// Útil para cargar todos los traslados de varios servicios de forma eficiente
  Future<List<TrasladoEntity>> getByServiciosRecurrentes(
    List<String> idsServiciosRecurrentes,
  );

  /// Obtiene traslados de múltiples servicios para una fecha específica
  /// Optimiza la consulta filtrando por id_servicio y fecha directamente en Supabase
  Future<List<TrasladoEntity>> getByServiciosYFecha({
    required List<String> idsServiciosRecurrentes,
    required DateTime fecha,
  });

  /// Obtiene traslados de un servicio padre (id_servicio)
  Future<List<TrasladoEntity>> getTrasladosByServicioId(String servicioId);

  /// Obtiene traslados por paciente
  Future<List<TrasladoEntity>> getByPaciente(String idPaciente);

  /// Obtiene todos los traslados asignados a un conductor específico
  Future<List<TrasladoEntity>> getByIdConductor(String idConductor);

  /// Obtiene traslados por vehículo
  Future<List<TrasladoEntity>> getByVehiculo(String idVehiculo);

  /// Obtiene traslados por estado
  /// Opcionalmente filtra por conductor específico
  Future<List<TrasladoEntity>> getByEstado({
    required EstadoTraslado estado,
    String? idConductor,
  });

  /// Obtiene traslados por fecha
  Future<List<TrasladoEntity>> getByFecha(DateTime fecha);

  /// Obtiene traslados en un rango de fechas
  /// Opcionalmente filtra por conductor específico
  Future<List<TrasladoEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? idConductor,
  });

  /// Obtiene traslados activos (que están en curso: estados que no son
  /// finalizado, cancelado ni no_realizado)
  Future<List<TrasladoEntity>> getEnCurso();

  /// Obtiene traslados que requieren asignación de recursos
  /// (estado 'pendiente' y sin conductor/vehículo asignado)
  Future<List<TrasladoEntity>> getRequierenAsignacion();

  /// Busca traslados por código
  Future<List<TrasladoEntity>> searchByCodigo(String query);

  /// Crea un nuevo traslado
  /// NOTA: Normalmente los traslados se crean automáticamente por el trigger
  /// al crear un servicio recurrente, pero este método permite crear
  /// traslados manuales si es necesario
  Future<TrasladoEntity> create(TrasladoEntity traslado);

  /// Actualiza campos específicos de un traslado con mapa dinámico
  /// Usado para actualizar tiempos, kilómetros, etc.
  Future<TrasladoEntity> update({
    required String id,
    required Map<String, dynamic> updates,
  });

  /// Actualiza el estado de un traslado y registra la fecha/hora
  /// automáticamente en la crona correspondiente
  Future<TrasladoEntity> updateEstado({
    required String id,
    required String nuevoEstado,
    Map<String, dynamic>? ubicacion,
  });

  /// Asigna recursos (conductor, vehículo, técnico) a un traslado
  Future<TrasladoEntity> asignarRecursos({
    required String id,
    String? idConductor,
    String? idVehiculo,
    String? matriculaVehiculo,
    String? idTecnico,
  });

  /// Desasigna todos los recursos de un traslado (pone conductor, vehículo y matrícula en null)
  /// Cambia el estado a 'pendiente' automáticamente
  Future<TrasladoEntity> desasignarRecursos({
    required String id,
  });

  /// Registra una ubicación GPS en un traslado
  Future<TrasladoEntity> registrarUbicacion({
    required String id,
    required Map<String, dynamic> ubicacion,
    required String estado,
  });

  /// Elimina un traslado (soft delete, marca como cancelado)
  Future<void> delete(String id);

  /// Elimina un traslado permanentemente (hard delete)
  Future<void> hardDelete(String id);

  /// Elimina múltiples traslados permanentemente en una sola operación
  Future<void> hardDeleteMultiple(List<String> ids);

  /// Stream que emite cambios en tiempo real de todos los traslados
  Stream<List<TrasladoEntity>> watchAll();

  /// Stream que emite cambios de un traslado específico
  Stream<TrasladoEntity> watchById(String id);

  /// Stream que emite cambios de traslados de un servicio recurrente específico
  Stream<List<TrasladoEntity>> watchByServicioRecurrente(
    String idServicioRecurrente,
  );

  /// Stream que emite cambios de traslados por conductor
  Stream<List<TrasladoEntity>> watchByConductor(String idConductor);

  /// Stream que emite cambios de traslados en curso (activos)
  Stream<List<TrasladoEntity>> watchEnCurso();

  /// Stream que emite cambios de traslados específicos por lista de IDs
  /// Usado por web para observar cambios en los traslados cargados en la tabla
  /// Solo emite cuando hay UPDATE en campos de estado/horas (cambios de mobile)
  Stream<TrasladoEntity> watchByIds(List<String> ids);

  // ========== MÉTODOS ESPECÍFICOS PARA MOBILE (Conductores) ==========

  /// Obtiene los traslados activos del conductor (no finalizados/cancelados)
  /// Usado por la app mobile para mostrar servicios en curso
  Future<List<TrasladoEntity>> getActivosByIdConductor(String idConductor);

  /// Cambia el estado de un traslado usando EstadoTraslado enum
  /// Registra automáticamente en historial_estados_traslado
  /// Usado por conductores para actualizar estados desde la app mobile
  Future<TrasladoEntity> cambiarEstado({
    required String idTraslado,
    required EstadoTraslado nuevoEstado,
    required String idUsuario,
    UbicacionEntity? ubicacion,
    String? observaciones,
  });

  /// Obtiene el historial de estados de un traslado
  /// Permite ver el seguimiento completo de cambios de estado
  Future<List<HistorialEstadoEntity>> getHistorialEstados(String idTraslado);

  /// Stream de traslados activos del conductor
  /// Se actualiza en tiempo real cuando hay cambios
  /// Usado por mobile para mantener la UI sincronizada
  Stream<List<TrasladoEntity>> watchActivosByIdConductor(String idConductor);

  /// Stream de eventos de traslados para el conductor autenticado
  /// Emite eventos cuando:
  /// - Me asignan un traslado (assigned/reassigned)
  /// - Me quitan un traslado (unassigned/reassigned a otro)
  /// - Cambia el estado de un traslado mío (status_changed)
  /// Usado por mobile para notificaciones push y actualizaciones en tiempo real
  Stream<TrasladoEventoEntity> streamEventosConductor();

  /// Cierra todos los canales Realtime activos
  /// Llamar desde el dispose del repository/cubit para evitar leaks de memoria
  Future<void> disposeRealtimeChannels();
}
