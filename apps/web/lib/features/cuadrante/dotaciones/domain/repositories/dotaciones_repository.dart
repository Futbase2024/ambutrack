import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de Dotaciones
///
/// Define las operaciones disponibles para la gestión de dotaciones
/// desde la capa de dominio de la aplicación
abstract class DotacionesRepository {
  // ==================== CRUD BÁSICO ====================

  /// Obtiene todas las dotaciones
  ///
  /// [limit] - Límite de resultados (opcional)
  /// [offset] - Offset para paginación (opcional)
  /// Devuelve lista de dotaciones ordenadas por fecha de creación
  Future<List<DotacionEntity>> getAll({int? limit, int? offset});

  /// Obtiene una dotación por ID
  ///
  /// [id] - ID de la dotación
  /// Devuelve la dotación o null si no existe
  Future<DotacionEntity?> getById(String id);

  /// Crea una nueva dotación
  ///
  /// [dotacion] - Entidad de la dotación a crear
  /// Devuelve la dotación creada con ID generado
  Future<DotacionEntity> create(DotacionEntity dotacion);

  /// Actualiza una dotación existente
  ///
  /// [dotacion] - Entidad de la dotación con datos actualizados
  /// Devuelve la dotación actualizada
  Future<DotacionEntity> update(DotacionEntity dotacion);

  /// Elimina una dotación por ID
  ///
  /// [id] - ID de la dotación a eliminar
  Future<void> delete(String id);

  /// Verifica si existe una dotación con el ID dado
  ///
  /// [id] - ID de la dotación
  /// Devuelve true si existe, false en caso contrario
  Future<bool> exists(String id);

  /// Cuenta el total de dotaciones registradas
  ///
  /// Devuelve el número total de dotaciones
  Future<int> count();

  // ==================== STREAMING ====================

  /// Observa cambios en todas las dotaciones en tiempo real
  ///
  /// Devuelve stream que emite lista actualizada cuando hay cambios
  Stream<List<DotacionEntity>> watchAll();

  /// Observa cambios en una dotación específica en tiempo real
  ///
  /// [id] - ID de la dotación a observar
  /// Devuelve stream que emite la dotación actualizada cuando hay cambios
  Stream<DotacionEntity?> watchById(String id);

  // ==================== BATCH OPERATIONS ====================

  /// Crea múltiples dotaciones de una vez
  ///
  /// [dotaciones] - Lista de dotaciones a crear
  /// Devuelve lista de dotaciones creadas con IDs generados
  Future<List<DotacionEntity>> createBatch(List<DotacionEntity> dotaciones);

  /// Actualiza múltiples dotaciones de una vez
  ///
  /// [dotaciones] - Lista de dotaciones a actualizar
  /// Devuelve lista de dotaciones actualizadas
  Future<List<DotacionEntity>> updateBatch(List<DotacionEntity> dotaciones);

  /// Elimina múltiples dotaciones de una vez
  ///
  /// [ids] - Lista de IDs de dotaciones a eliminar
  Future<void> deleteBatch(List<String> ids);

  // ==================== MÉTODOS ESPECÍFICOS ====================

  /// Obtiene todas las dotaciones activas
  ///
  /// Devuelve lista de dotaciones con activo = true
  Future<List<DotacionEntity>> getActivas();

  /// Obtiene dotaciones asociadas a un hospital
  ///
  /// [hospitalId] - ID del hospital
  /// Devuelve lista de dotaciones de ese hospital
  Future<List<DotacionEntity>> getByHospital(String hospitalId);

  /// Obtiene dotaciones asociadas a una base
  ///
  /// [baseId] - ID de la base
  /// Devuelve lista de dotaciones de esa base
  Future<List<DotacionEntity>> getByBase(String baseId);

  /// Obtiene dotaciones asociadas a un contrato
  ///
  /// [contratoId] - ID del contrato
  /// Devuelve lista de dotaciones de ese contrato
  Future<List<DotacionEntity>> getByContrato(String contratoId);

  /// Obtiene dotaciones por tipo de vehículo
  ///
  /// [tipoVehiculoId] - ID del tipo de vehículo
  /// Devuelve lista de dotaciones que usan ese tipo
  Future<List<DotacionEntity>> getByTipoVehiculo(String tipoVehiculoId);

  /// Obtiene dotaciones vigentes en una fecha específica
  ///
  /// [fecha] - Fecha a verificar
  /// Devuelve lista de dotaciones vigentes en esa fecha
  Future<List<DotacionEntity>> getVigentesEn(DateTime fecha);

  /// Obtiene dotaciones que aplican en un día de la semana
  ///
  /// [diaSemana] - Nombre del día ('lunes', 'martes', etc.)
  /// Devuelve lista de dotaciones que aplican en ese día
  Future<List<DotacionEntity>> getByDiaSemana(String diaSemana);

  /// Obtiene dotaciones con prioridad mayor o igual a un valor
  ///
  /// [prioridadMinima] - Prioridad mínima
  /// Devuelve lista ordenada por prioridad descendente
  Future<List<DotacionEntity>> getByPrioridad(int prioridadMinima);

  /// Obtiene dotaciones con cantidad de unidades mayor o igual
  ///
  /// [cantidadMinima] - Cantidad mínima de unidades
  /// Devuelve lista de dotaciones con esa capacidad o mayor
  Future<List<DotacionEntity>> getByCantidadUnidades(int cantidadMinima);

  /// Desactiva una dotación (soft delete)
  ///
  /// Establece activo = false sin eliminar el registro
  /// [dotacionId] - ID de la dotación a desactivar
  /// Devuelve la dotación desactivada
  Future<DotacionEntity> deactivate(String dotacionId);

  /// Reactiva una dotación previamente desactivada
  ///
  /// Establece activo = true
  /// [dotacionId] - ID de la dotación a reactivar
  /// Devuelve la dotación reactivada
  Future<DotacionEntity> reactivate(String dotacionId);

  /// Obtiene dotaciones que están por vencer
  ///
  /// [diasAnticipacion] - Días de anticipación
  /// Devuelve lista de dotaciones próximas a vencer
  Future<List<DotacionEntity>> getPorVencer(int diasAnticipacion);

  /// Obtiene dotaciones asociadas a una plantilla de turno
  ///
  /// [plantillaTurnoId] - ID de la plantilla de turno
  /// Devuelve lista de dotaciones que usan esa plantilla
  Future<List<DotacionEntity>> getByPlantillaTurno(String plantillaTurnoId);

  /// Actualiza la cantidad de unidades de una dotación
  ///
  /// [dotacionId] - ID de la dotación
  /// [nuevaCantidad] - Nueva cantidad
  /// Devuelve la dotación actualizada
  Future<DotacionEntity> updateCantidadUnidades(String dotacionId, int nuevaCantidad);

  /// Actualiza la prioridad de una dotación
  ///
  /// [dotacionId] - ID de la dotación
  /// [nuevaPrioridad] - Nueva prioridad
  /// Devuelve la dotación actualizada
  Future<DotacionEntity> updatePrioridad(String dotacionId, int nuevaPrioridad);

  /// Actualiza los días de aplicación de una dotación
  ///
  /// [dotacionId] - ID de la dotación
  /// [dias] - Map con los días y sus valores
  /// Devuelve la dotación actualizada
  Future<DotacionEntity> updateDiasAplicacion(String dotacionId, Map<String, bool> dias);

  /// Extiende la vigencia de una dotación
  ///
  /// [dotacionId] - ID de la dotación
  /// [nuevaFechaFin] - Nueva fecha de fin
  /// Devuelve la dotación actualizada
  Future<DotacionEntity> extenderVigencia(String dotacionId, DateTime nuevaFechaFin);
}
