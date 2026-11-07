import '../../core/base_datasource.dart';
import 'entities/asignacion_vehiculo_turno_entity.dart';

/// Contrato para operaciones de datasource de asignaciones de vehículos a turnos
///
/// Extiende [BaseDatasource] con operaciones específicas de asignaciones
/// Todas las implementaciones deben adherirse a este contrato
abstract class AsignacionVehiculoTurnoDataSource
    extends BaseDatasource<AsignacionVehiculoTurnoEntity> {
  /// Obtiene asignaciones por fecha
  ///
  /// [fecha] - Fecha de las asignaciones
  /// Devuelve lista de asignaciones para esa fecha
  Future<List<AsignacionVehiculoTurnoEntity>> getByFecha(DateTime fecha);

  /// Obtiene asignaciones por rango de fechas
  ///
  /// [inicio] - Fecha de inicio del rango
  /// [fin] - Fecha de fin del rango
  /// Devuelve lista de asignaciones en ese rango
  Future<List<AsignacionVehiculoTurnoEntity>> getByRangoFechas(
    DateTime inicio,
    DateTime fin,
  );

  /// Obtiene asignaciones de un vehículo en una fecha
  ///
  /// [vehiculoId] - ID del vehículo
  /// [fecha] - Fecha a consultar
  /// Devuelve lista de asignaciones del vehículo en esa fecha
  Future<List<AsignacionVehiculoTurnoEntity>> getByVehiculo(
    String vehiculoId,
    DateTime fecha,
  );

  /// Obtiene asignaciones por estado
  ///
  /// [estado] - Estado a filtrar (planificada, activa, completada, cancelada)
  /// Devuelve lista de asignaciones con ese estado
  Future<List<AsignacionVehiculoTurnoEntity>> getByEstado(String estado);

  /// Obtiene asignaciones por dotación
  ///
  /// [dotacionId] - ID de la dotación
  /// Devuelve lista de asignaciones de esa dotación
  Future<List<AsignacionVehiculoTurnoEntity>> getByDotacion(String dotacionId);

  /// Obtiene asignaciones por turno
  ///
  /// [turnoId] - ID del turno
  /// Devuelve lista de asignaciones de ese turno
  Future<List<AsignacionVehiculoTurnoEntity>> getByTurno(String turnoId);

  /// Obtiene asignaciones por hospital
  ///
  /// [hospitalId] - ID del hospital
  /// Devuelve lista de asignaciones asociadas a ese hospital
  Future<List<AsignacionVehiculoTurnoEntity>> getByHospital(String hospitalId);

  /// Obtiene asignaciones por base
  ///
  /// [baseId] - ID de la base
  /// Devuelve lista de asignaciones asociadas a esa base
  Future<List<AsignacionVehiculoTurnoEntity>> getByBase(String baseId);

  /// Obtiene solo asignaciones activas
  ///
  /// Devuelve lista de asignaciones con activo = true
  Future<List<AsignacionVehiculoTurnoEntity>> getActivas();

  /// Desactiva una asignación
  ///
  /// Establece activo a false sin eliminar los datos
  Future<AsignacionVehiculoTurnoEntity> deactivate(String asignacionId);

  /// Reactiva una asignación
  ///
  /// Establece activo a true
  Future<AsignacionVehiculoTurnoEntity> reactivate(String asignacionId);

  /// Actualiza el estado de una asignación
  ///
  /// [asignacionId] - ID de la asignación
  /// [nuevoEstado] - Nuevo estado (planificada, activa, completada, cancelada)
  /// Devuelve la asignación actualizada
  Future<AsignacionVehiculoTurnoEntity> updateEstado(
    String asignacionId,
    String nuevoEstado,
  );

  /// Obtiene asignaciones que tienen conflictos de horario
  ///
  /// [vehiculoId] - ID del vehículo a verificar
  /// [fecha] - Fecha a verificar
  /// Devuelve lista de asignaciones que podrían tener conflicto
  Future<List<AsignacionVehiculoTurnoEntity>> getConflictos(
    String vehiculoId,
    DateTime fecha,
  );

  /// Cancela una asignación
  ///
  /// Cambia el estado a 'cancelada' y opcionalmente añade observaciones
  Future<AsignacionVehiculoTurnoEntity> cancelar(
    String asignacionId,
    String motivo,
  );
}
