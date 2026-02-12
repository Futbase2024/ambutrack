import 'entities/servicio_recurrente_entity.dart';

/// Contrato abstracto para el DataSource de Servicios Recurrentes
/// Define las operaciones CRUD básicas para la gestión de servicios con recurrencia
abstract class ServicioRecurrenteDataSource {
  /// Obtiene todos los servicios recurrentes activos
  Future<List<ServicioRecurrenteEntity>> getAll();

  /// Obtiene un servicio recurrente por su ID
  Future<ServicioRecurrenteEntity> getById(String id);

  /// Obtiene un servicio recurrente por el ID del servicio padre
  /// [idServicio] es el FK que apunta a la tabla servicios
  Future<ServicioRecurrenteEntity> getByServicioId(String idServicio);

  /// Obtiene servicios recurrentes por paciente
  Future<List<ServicioRecurrenteEntity>> getByPaciente(String idPaciente);

  /// Obtiene servicios recurrentes por tipo de recurrencia
  /// [tipoRecurrencia] puede ser: 'unico', 'diario', 'semanal', 'semanas_alternas',
  /// 'dias_alternos', 'mensual', 'especifico'
  Future<List<ServicioRecurrenteEntity>> getByTipoRecurrencia(
    String tipoRecurrencia,
  );

  /// Obtiene servicios recurrentes activos (que están dentro del rango de fechas)
  Future<List<ServicioRecurrenteEntity>> getActivos();

  /// Obtiene servicios recurrentes que requieren generación de traslados
  /// (están en curso y no han superado su fecha de fin)
  Future<List<ServicioRecurrenteEntity>> getRequierenGeneracion();

  /// Busca servicios recurrentes por código
  Future<List<ServicioRecurrenteEntity>> searchByCodigo(String query);

  /// Crea un nuevo servicio recurrente
  ///
  /// ⚡ IMPORTANTE: Arquitectura de 3 niveles
  /// 1. Primero debe existir un registro en tabla `servicios` (padre)
  /// 2. El campo `idServicio` de `servicioRecurrente` debe apuntar a ese registro padre
  /// 3. Al insertar, el trigger `generar_traslados_al_crear_servicio_recurrente()`
  ///    genera automáticamente los traslados correspondientes
  ///
  /// Arquitectura: servicios → servicios_recurrentes → traslados
  Future<ServicioRecurrenteEntity> create(
    ServicioRecurrenteEntity servicioRecurrente,
  );

  /// Actualiza un servicio recurrente existente
  Future<ServicioRecurrenteEntity> update(
    ServicioRecurrenteEntity servicioRecurrente,
  );

  /// Elimina un servicio recurrente (soft delete, marca activo = false)
  Future<void> delete(String id);

  /// Elimina un servicio recurrente permanentemente (hard delete)
  /// ADVERTENCIA: Esto también eliminará los traslados asociados en cascada
  Future<void> hardDelete(String id);

  /// Elimina físicamente múltiples servicios_recurrentes antiguos en una sola operación
  /// Útil para limpiar duplicados al editar un servicio
  ///
  /// **Parámetros**:
  /// - [idServicio]: ID del servicio padre
  /// - [idServicioRecurrenteActual]: ID del servicio_recurrente que debe conservarse
  ///
  /// **Comportamiento**:
  /// - Busca TODOS los servicios_recurrentes con id_servicio = [idServicio]
  /// - Elimina físicamente los que NO tengan id = [idServicioRecurrenteActual]
  /// - Operación atómica en una sola query SQL (eficiente)
  Future<void> hardDeleteOldVersions({
    required String idServicio,
    required String idServicioRecurrenteActual,
  });

  /// Stream que emite cambios en tiempo real de todos los servicios recurrentes
  Stream<List<ServicioRecurrenteEntity>> watchAll();

  /// Stream que emite cambios de un servicio recurrente específico
  Stream<ServicioRecurrenteEntity?> watchById(String id);

  /// Stream que emite cambios de servicios recurrentes de un paciente específico
  Stream<List<ServicioRecurrenteEntity>> watchByPaciente(String idPaciente);
}
