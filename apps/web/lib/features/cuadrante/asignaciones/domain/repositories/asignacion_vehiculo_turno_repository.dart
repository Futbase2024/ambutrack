import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de asignaciones de vehículos a turnos
abstract class AsignacionVehiculoTurnoRepository {
  /// Obtiene todas las asignaciones
  Future<List<AsignacionVehiculoTurnoEntity>> getAll();

  /// Obtiene una asignación por ID
  Future<AsignacionVehiculoTurnoEntity> getById(String id);

  /// Crea una nueva asignación
  Future<AsignacionVehiculoTurnoEntity> create(AsignacionVehiculoTurnoEntity entity);

  /// Actualiza una asignación existente
  Future<AsignacionVehiculoTurnoEntity> update(AsignacionVehiculoTurnoEntity entity);

  /// Elimina una asignación
  Future<void> delete(String id);

  /// Obtiene asignaciones por fecha
  Future<List<AsignacionVehiculoTurnoEntity>> getByFecha(DateTime fecha);

  /// Obtiene asignaciones por rango de fechas
  Future<List<AsignacionVehiculoTurnoEntity>> getByRangoFechas(
    DateTime inicio,
    DateTime fin,
  );

  /// Obtiene asignaciones de un vehículo en una fecha
  Future<List<AsignacionVehiculoTurnoEntity>> getByVehiculo(
    String vehiculoId,
    DateTime fecha,
  );

  /// Obtiene asignaciones por estado
  Future<List<AsignacionVehiculoTurnoEntity>> getByEstado(String estado);
}
