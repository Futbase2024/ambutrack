import 'entities/solicitud_intercambio_entity.dart';

/// Contrato para el datasource de solicitudes de intercambio de turnos
///
/// Proporciona operaciones CRUD base más métodos especializados
/// para gestionar el flujo de aprobación de intercambios.
abstract class SolicitudIntercambioDataSource {
  // ===== MÉTODOS CRUD BASE =====

  /// Obtiene todas las solicitudes
  Future<List<SolicitudIntercambioEntity>> getAll({int? limit, int? offset});

  /// Obtiene una solicitud por ID
  Future<SolicitudIntercambioEntity?> getById(String id);

  /// Crea una nueva solicitud
  Future<SolicitudIntercambioEntity> create(SolicitudIntercambioEntity entity);

  /// Actualiza una solicitud existente
  Future<SolicitudIntercambioEntity> update(SolicitudIntercambioEntity entity);

  /// Elimina una solicitud por ID
  Future<void> delete(String id);

  /// Elimina múltiples solicitudes
  Future<void> deleteBatch(List<String> ids);

  /// Cuenta el total de solicitudes
  Future<int> count();

  /// Stream de todas las solicitudes
  Stream<List<SolicitudIntercambioEntity>> watchAll();

  /// Stream de una solicitud específica
  Stream<SolicitudIntercambioEntity?> watchById(String id);

  /// Limpia todos los datos
  Future<void> clear();

  /// Crea múltiples solicitudes
  Future<List<SolicitudIntercambioEntity>> createBatch(
    List<SolicitudIntercambioEntity> entities,
  );

  /// Verifica si existe una solicitud
  Future<bool> exists(String id);

  /// Actualiza múltiples solicitudes
  Future<List<SolicitudIntercambioEntity>> updateBatch(
    List<SolicitudIntercambioEntity> entities,
  );

  // ===== MÉTODOS ESPECIALIZADOS =====
  /// Obtiene solicitudes por estado
  ///
  /// [estado]: Estado de la solicitud a filtrar
  /// Returns: Lista de solicitudes en el estado especificado
  Future<List<SolicitudIntercambioEntity>> getByEstado(EstadoSolicitud estado);

  /// Obtiene solicitudes pendientes de un personal
  ///
  /// Incluye solicitudes donde el personal es solicitante o destino
  /// y el estado es pendiente de aprobación.
  ///
  /// [idPersonal]: ID del personal
  /// Returns: Lista de solicitudes pendientes del personal
  Future<List<SolicitudIntercambioEntity>> getPendientesByPersonal(
    String idPersonal,
  );

  /// Obtiene solicitudes de un personal (como solicitante)
  ///
  /// [idPersonal]: ID del personal solicitante
  /// Returns: Lista de solicitudes del personal
  Future<List<SolicitudIntercambioEntity>> getBySolicitante(String idPersonal);

  /// Obtiene solicitudes dirigidas a un personal (como destino)
  ///
  /// [idPersonal]: ID del personal destino
  /// Returns: Lista de solicitudes dirigidas al personal
  Future<List<SolicitudIntercambioEntity>> getByDestino(String idPersonal);
}
