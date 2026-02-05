import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio para gestión de asignaciones de cuadrante
abstract class CuadranteAsignacionRepository {
  /// Crea una nueva asignación
  Future<CuadranteAsignacionEntity> create(CuadranteAsignacionEntity asignacion);

  /// Actualiza una asignación existente
  Future<CuadranteAsignacionEntity> update(CuadranteAsignacionEntity asignacion);

  /// Elimina (soft delete) una asignación
  Future<void> delete(String id);

  /// Obtiene una asignación por ID
  Future<CuadranteAsignacionEntity?> getById(String id);

  /// Obtiene todas las asignaciones activas
  Future<List<CuadranteAsignacionEntity>> getAll();

  /// Obtiene asignaciones de una fecha específica
  Future<List<CuadranteAsignacionEntity>> getByFecha(DateTime fecha);

  /// Obtiene asignaciones de un rango de fechas
  Future<List<CuadranteAsignacionEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });

  /// Obtiene asignaciones de un personal en una fecha
  Future<List<CuadranteAsignacionEntity>> getByPersonal({
    required String idPersonal,
    DateTime? fecha,
  });

  /// Obtiene asignaciones de un vehículo en una fecha
  Future<List<CuadranteAsignacionEntity>> getByVehiculo({
    required String idVehiculo,
    DateTime? fecha,
  });

  /// Obtiene asignaciones de una dotación en una fecha
  Future<List<CuadranteAsignacionEntity>> getByDotacion({
    required String idDotacion,
    DateTime? fecha,
  });

  /// Obtiene asignaciones por estado
  Future<List<CuadranteAsignacionEntity>> getByEstado(EstadoAsignacion estado);

  /// Verifica si hay conflicto de horario para personal
  Future<bool> hasConflictPersonal({
    required String idPersonal,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required bool cruzaMedianoche,
    String? excludeId,
  });

  /// Verifica si hay conflicto de horario para vehículo
  Future<bool> hasConflictVehiculo({
    required String idVehiculo,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required bool cruzaMedianoche,
    String? excludeId,
  });

  /// Verifica si una dotación/unidad ya está asignada
  Future<bool> isDotacionUnidadAsignada({
    required String idDotacion,
    required int numeroUnidad,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required bool cruzaMedianoche,
    String? excludeId,
  });

  /// Confirma una asignación planificada
  Future<CuadranteAsignacionEntity> confirmar({
    required String id,
    required String confirmadaPor,
  });

  /// Cancela una asignación
  Future<CuadranteAsignacionEntity> cancelar(String id);

  /// Completa una asignación
  Future<CuadranteAsignacionEntity> completar({
    required String id,
    double? kmFinal,
    int? serviciosRealizados,
    String? observaciones,
  });

  /// Stream de todas las asignaciones activas
  Stream<List<CuadranteAsignacionEntity>> watchAll();

  /// Stream de asignaciones de una fecha específica
  Stream<List<CuadranteAsignacionEntity>> watchByFecha(DateTime fecha);

  /// Stream de asignaciones de un personal
  Stream<List<CuadranteAsignacionEntity>> watchByPersonal(String idPersonal);

  /// Stream de asignaciones de una dotación
  Stream<List<CuadranteAsignacionEntity>> watchByDotacion(String idDotacion);
}
