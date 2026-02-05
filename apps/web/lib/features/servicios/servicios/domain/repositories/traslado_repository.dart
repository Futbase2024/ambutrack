import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio abstracto de traslados
///
/// Define el contrato para operaciones CRUD sobre traslados, incluyendo
/// métodos especializados para gestión del ciclo de vida (estados) y tracking GPS.
/// La implementación se encuentra en data/repositories/traslado_repository_impl.dart
abstract class TrasladoRepository {
  /// Obtener todos los traslados
  Future<List<TrasladoEntity>> getAll();

  /// Obtener un traslado por ID
  Future<TrasladoEntity> getById(String id);

  /// Obtener traslados de un servicio recurrente
  Future<List<TrasladoEntity>> getByServicioRecurrente(String idServicioRecurrente);

  /// Obtener traslados de múltiples servicios recurrentes
  /// Útil para cargar todos los traslados de varios servicios en una sola consulta
  Future<List<TrasladoEntity>> getByServiciosRecurrentes(List<String> idsServiciosRecurrentes);

  /// Obtener traslados de múltiples servicios para una fecha específica
  /// Optimiza la carga al filtrar por fecha en Supabase directamente
  Future<List<TrasladoEntity>> getByServiciosYFecha({
    required List<String> idsServiciosRecurrentes,
    required DateTime fecha,
  });

  /// Obtener traslados de un servicio (padre)
  Future<List<TrasladoEntity>> getTrasladosByServicioId(String servicioId);

  /// Obtener traslados de un paciente
  Future<List<TrasladoEntity>> getByPaciente(String idPaciente);

  /// Obtener traslados asignados a un conductor
  Future<List<TrasladoEntity>> getByConductor(String idConductor);

  /// Obtener traslados asignados a un vehículo
  Future<List<TrasladoEntity>> getByVehiculo(String idVehiculo);

  /// Obtener traslados por estado (pendiente, asignado, en_transito, etc.)
  Future<List<TrasladoEntity>> getByEstado(String estado);

  /// Obtener traslados programados para una fecha específica
  Future<List<TrasladoEntity>> getByFecha(DateTime fecha);

  /// Obtener traslados en un rango de fechas
  Future<List<TrasladoEntity>> getByRangoFechas({
    required DateTime desde,
    required DateTime hasta,
  });

  /// Obtener traslados en curso (enviado, recibido_conductor, en_origen, saliendo_origen, en_transito, en_destino)
  Future<List<TrasladoEntity>> getEnCurso();

  /// Obtener traslados que requieren asignación de recursos
  Future<List<TrasladoEntity>> getRequierenAsignacion();

  /// Crear un nuevo traslado
  ///
  /// Normalmente los traslados se crean automáticamente al crear un servicio recurrente,
  /// pero este método permite crear traslados manuales
  Future<TrasladoEntity> create(TrasladoEntity traslado);

  /// Actualizar un traslado existente
  Future<TrasladoEntity> update(TrasladoEntity traslado);

  /// Eliminar un traslado (soft delete)
  Future<void> delete(String id);

  /// Eliminar un traslado permanentemente
  Future<void> hardDelete(String id);

  /// Eliminar múltiples traslados permanentemente en una sola operación
  Future<void> hardDeleteMultiple(List<String> ids);

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS ESPECIALIZADOS PARA GESTIÓN DEL CICLO DE VIDA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Actualizar el estado de un traslado
  ///
  /// Este método actualiza el estado del traslado y automáticamente:
  /// 1. Registra la fecha/hora del cambio en la crona correspondiente
  /// 2. Opcionalmente registra la ubicación GPS en el campo correspondiente
  ///
  /// Flujo de estados:
  /// pendiente → asignado → enviado → recibido_conductor → en_origen →
  /// saliendo_origen → en_transito → en_destino → finalizado
  ///
  /// Estados alternativos finales: cancelado, no_realizado
  Future<TrasladoEntity> updateEstado({
    required String id,
    required String nuevoEstado,
    Map<String, dynamic>? ubicacion,
  });

  /// Asignar recursos (conductor, vehículo, técnico) a un traslado
  ///
  /// Este método actualiza los recursos asignados y automáticamente cambia
  /// el estado de 'pendiente' a 'asignado' si corresponde
  Future<TrasladoEntity> asignarRecursos({
    required String id,
    String? idConductor,
    String? idVehiculo,
    String? matriculaVehiculo,
    String? idTecnico,
  });

  /// Desasignar todos los recursos de un traslado
  ///
  /// Pone conductor, vehículo, matrícula y técnico en null
  /// y cambia el estado a 'pendiente'
  Future<TrasladoEntity> desasignarRecursos({
    required String id,
  });

  /// Registrar una ubicación GPS para un traslado
  ///
  /// Este método permite registrar coordenadas GPS en diferentes momentos
  /// del ciclo de vida del traslado según el estado actual
  Future<TrasladoEntity> registrarUbicacion({
    required String id,
    required Map<String, dynamic> ubicacion,
    required String estado,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // STREAMS PARA ACTUALIZACIONES EN TIEMPO REAL
  // ═══════════════════════════════════════════════════════════════════════════

  /// Observar cambios en todos los traslados en tiempo real
  Stream<List<TrasladoEntity>> watchAll();

  /// Observar cambios en un traslado específico
  Stream<TrasladoEntity?> watchById(String id);

  /// Observar cambios en traslados de un servicio recurrente
  Stream<List<TrasladoEntity>> watchByServicioRecurrente(String idServicioRecurrente);

  /// Observar cambios en traslados de un conductor
  Stream<List<TrasladoEntity>> watchByConductor(String idConductor);

  /// Observar cambios en traslados en curso
  Stream<List<TrasladoEntity>> watchEnCurso();
}
