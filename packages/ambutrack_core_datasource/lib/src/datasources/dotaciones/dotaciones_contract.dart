import '../../core/base_datasource.dart';
import 'entities/dotacion_entity.dart';

/// Contrato para operaciones de datasource de dotaciones
///
/// Extiende [BaseDatasource] con operaciones específicas de dotaciones
/// Todas las implementaciones deben adherirse a este contrato
abstract class DotacionesDataSource extends BaseDatasource<DotacionEntity> {
  /// Obtiene solo dotaciones activas
  ///
  /// Devuelve lista de dotaciones con activo = true
  Future<List<DotacionEntity>> getActivas();

  /// Obtiene dotaciones por hospital
  ///
  /// [hospitalId] - ID del hospital
  /// Devuelve lista de dotaciones asignadas a ese hospital
  Future<List<DotacionEntity>> getByHospital(String hospitalId);

  /// Obtiene dotaciones por base
  ///
  /// [baseId] - ID de la base
  /// Devuelve lista de dotaciones asignadas a esa base
  Future<List<DotacionEntity>> getByBase(String baseId);

  /// Obtiene dotaciones por contrato
  ///
  /// [contratoId] - ID del contrato
  /// Devuelve lista de dotaciones asociadas a ese contrato
  Future<List<DotacionEntity>> getByContrato(String contratoId);

  /// Obtiene dotaciones por tipo de vehículo
  ///
  /// [tipoVehiculoId] - ID del tipo de vehículo
  /// Devuelve lista de dotaciones que usan ese tipo de vehículo
  Future<List<DotacionEntity>> getByTipoVehiculo(String tipoVehiculoId);

  /// Obtiene dotaciones vigentes en una fecha específica
  ///
  /// [fecha] - Fecha a verificar
  /// Devuelve lista de dotaciones vigentes en esa fecha
  /// (fecha_inicio <= fecha && (fecha_fin == null || fecha_fin >= fecha))
  Future<List<DotacionEntity>> getVigentesEn(DateTime fecha);

  /// Obtiene dotaciones que aplican en un día de la semana específico
  ///
  /// [diaSemana] - Nombre del día ('lunes', 'martes', etc.)
  /// Devuelve lista de dotaciones que aplican en ese día
  Future<List<DotacionEntity>> getByDiaSemana(String diaSemana);

  /// Obtiene dotaciones con prioridad mayor o igual a un valor
  ///
  /// [prioridadMinima] - Prioridad mínima
  /// Devuelve lista de dotaciones ordenadas por prioridad descendente
  Future<List<DotacionEntity>> getByPrioridad(int prioridadMinima);

  /// Obtiene dotaciones con cantidad de unidades mayor o igual a un valor
  ///
  /// [cantidadMinima] - Cantidad mínima de unidades
  /// Devuelve lista de dotaciones con esa capacidad o mayor
  Future<List<DotacionEntity>> getByCantidadUnidades(int cantidadMinima);

  /// Desactiva una dotación
  ///
  /// Establece activo a false sin eliminar los datos
  Future<DotacionEntity> deactivate(String dotacionId);

  /// Reactiva una dotación
  ///
  /// Establece activo a true
  Future<DotacionEntity> reactivate(String dotacionId);

  /// Obtiene dotaciones que están por vencer
  ///
  /// [diasAnticipacion] - Días de anticipación para considerar "por vencer"
  /// Devuelve lista de dotaciones cuya fecha_fin está próxima
  Future<List<DotacionEntity>> getPorVencer(int diasAnticipacion);

  /// Obtiene dotaciones asociadas a una plantilla de turno
  ///
  /// [plantillaTurnoId] - ID de la plantilla de turno
  /// Devuelve lista de dotaciones que usan esa plantilla
  Future<List<DotacionEntity>> getByPlantillaTurno(String plantillaTurnoId);

  /// Actualiza la cantidad de unidades de una dotación
  ///
  /// [dotacionId] - ID de la dotación
  /// [nuevaCantidad] - Nueva cantidad de unidades
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
  /// [dias] - Map con los días (ej: {'lunes': true, 'martes': false, ...})
  /// Devuelve la dotación actualizada
  Future<DotacionEntity> updateDiasAplicacion(String dotacionId, Map<String, bool> dias);

  /// Extiende la fecha de fin de una dotación
  ///
  /// [dotacionId] - ID de la dotación
  /// [nuevaFechaFin] - Nueva fecha de fin
  /// Devuelve la dotación actualizada
  Future<DotacionEntity> extenderVigencia(String dotacionId, DateTime nuevaFechaFin);
}
