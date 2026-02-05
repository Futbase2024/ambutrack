import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio abstracto de servicios recurrentes
///
/// Define el contrato para operaciones CRUD sobre servicios recurrentes.
/// La implementación se encuentra en data/repositories/servicio_recurrente_repository_impl.dart
abstract class ServicioRecurrenteRepository {
  /// Obtener todos los servicios recurrentes
  Future<List<ServicioRecurrenteEntity>> getAll();

  /// Obtener un servicio recurrente por ID
  Future<ServicioRecurrenteEntity> getById(String id);

  /// Obtener un servicio recurrente por el ID del servicio padre
  /// Busca por el campo id_servicio (FK)
  Future<ServicioRecurrenteEntity> getByServicioId(String idServicio);

  /// Obtener servicios recurrentes por paciente
  Future<List<ServicioRecurrenteEntity>> getByPaciente(String idPaciente);

  /// Obtener servicios recurrentes por tipo de recurrencia
  Future<List<ServicioRecurrenteEntity>> getByTipoRecurrencia(String tipoRecurrencia);

  /// Obtener servicios recurrentes activos
  Future<List<ServicioRecurrenteEntity>> getActivos();

  /// Obtener servicios que requieren generación de traslados
  Future<List<ServicioRecurrenteEntity>> getRequierenGeneracion();

  /// Buscar servicios por código
  Future<List<ServicioRecurrenteEntity>> searchByCodigo(String query);

  /// Crear un nuevo servicio recurrente
  ///
  /// ⚡ IMPORTANTE: Al crear un servicio, el trigger generar_traslados_al_crear_servicio
  /// en Supabase generará automáticamente los traslados según la configuración de recurrencia
  Future<ServicioRecurrenteEntity> create(ServicioRecurrenteEntity servicioRecurrente);

  /// Actualizar un servicio recurrente existente
  Future<ServicioRecurrenteEntity> update(ServicioRecurrenteEntity servicioRecurrente);

  /// Eliminar un servicio recurrente (soft delete)
  Future<void> delete(String id);

  /// Eliminar un servicio recurrente permanentemente
  Future<void> hardDelete(String id);

  /// Eliminar físicamente múltiples servicios_recurrentes antiguos
  /// Útil para limpiar duplicados al editar un servicio
  Future<void> hardDeleteOldVersions({
    required String idServicio,
    required String idServicioRecurrenteActual,
  });

  /// Observar cambios en todos los servicios recurrentes en tiempo real
  Stream<List<ServicioRecurrenteEntity>> watchAll();

  /// Observar cambios en un servicio recurrente específico
  Stream<ServicioRecurrenteEntity?> watchById(String id);

  /// Observar cambios en servicios de un paciente específico
  Stream<List<ServicioRecurrenteEntity>> watchByPaciente(String idPaciente);
}
