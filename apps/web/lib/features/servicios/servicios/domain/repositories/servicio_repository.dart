import '../entities/servicio_entity.dart';

/// Contrato del repositorio de Servicios (tabla padre)
///
/// Gestiona la tabla `servicios` que actúa como cabecera
/// para toda la jerarquía de servicios/traslados.
abstract class ServicioRepository {
  /// Obtiene todos los servicios
  Future<List<ServicioEntity>> getAll();

  /// Obtiene un servicio por ID
  Future<ServicioEntity?> getById(String id);

  /// Stream de servicios en tiempo real
  Stream<List<ServicioEntity>> watchAll();

  /// Busca servicios por query (código, paciente, etc.)
  Future<List<ServicioEntity>> search(String query);

  /// Filtra servicios por año
  Future<List<ServicioEntity>> getByYear(int year);

  /// Filtra servicios por estado
  Future<List<ServicioEntity>> getByEstado(String estado);

  /// Filtra servicios por tipo de recurrencia
  Future<List<ServicioEntity>> getByTipoRecurrencia(String tipoRecurrencia);

  /// Actualiza un servicio completo
  Future<void> update(ServicioEntity servicio);

  /// Actualiza el estado de un servicio
  Future<void> updateEstado(String id, String estado);

  /// Elimina un servicio (soft delete - marca como ELIMINADO)
  Future<void> delete(String id);

  /// Elimina permanentemente un servicio y todos sus datos relacionados
  ///
  /// ADVERTENCIA: Esta acción es IRREVERSIBLE y eliminará:
  /// - El servicio de la tabla `servicios`
  /// - El servicio recurrente de `servicios_recurrentes` (si existe)
  /// - Todos los traslados asociados de la tabla `traslados`
  Future<void> hardDelete(String id);

  /// Suspende un servicio y elimina traslados futuros
  ///
  /// Al suspender:
  /// 1. Cambia el estado del servicio a 'suspendido'
  /// 2. Elimina traslados desde la fecha actual en adelante
  /// 3. Mantiene el histórico de traslados anteriores
  Future<void> suspend(String id);

  /// Reanuda un servicio suspendido y regenera traslados
  ///
  /// Al reanudar:
  /// 1. Cambia el estado del servicio a 'activo'
  /// 2. Regenera traslados desde la fecha actual hacia adelante
  /// 3. Respeta la configuración original de recurrencia
  Future<int> reanudar(String id);
}
