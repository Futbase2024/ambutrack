import 'entities/cuadrante_asignacion_entity.dart';

/// Contrato abstracto para datasource de cuadrante de asignaciones
abstract class CuadranteAsignacionDataSource {
  /// Obtiene todas las asignaciones activas
  Future<List<CuadranteAsignacionEntity>> getAll();

  /// Obtiene una asignación por su ID
  Future<CuadranteAsignacionEntity?> getById(String id);

  /// Obtiene asignaciones por fecha
  Future<List<CuadranteAsignacionEntity>> getByFecha(DateTime fecha);

  /// Obtiene asignaciones por rango de fechas
  Future<List<CuadranteAsignacionEntity>> getByFechaRange({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });

  /// Obtiene asignaciones de un personal específico
  Future<List<CuadranteAsignacionEntity>> getByPersonal(String idPersonal);

  /// Obtiene asignaciones de un personal en una fecha específica
  Future<List<CuadranteAsignacionEntity>> getByPersonalAndFecha({
    required String idPersonal,
    required DateTime fecha,
  });

  /// Obtiene asignaciones de un vehículo específico
  Future<List<CuadranteAsignacionEntity>> getByVehiculo(String idVehiculo);

  /// Obtiene asignaciones de un vehículo en una fecha específica
  Future<List<CuadranteAsignacionEntity>> getByVehiculoAndFecha({
    required String idVehiculo,
    required DateTime fecha,
  });

  /// Obtiene asignaciones de una dotación específica
  Future<List<CuadranteAsignacionEntity>> getByDotacion(String idDotacion);

  /// Obtiene asignaciones de una dotación en una fecha específica
  Future<List<CuadranteAsignacionEntity>> getByDotacionAndFecha({
    required String idDotacion,
    required DateTime fecha,
  });

  /// Obtiene asignaciones por estado
  Future<List<CuadranteAsignacionEntity>> getByEstado(EstadoAsignacion estado);

  /// Verifica si existe conflicto de horarios para un personal
  Future<bool> hasConflictPersonal({
    required String idPersonal,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required bool cruzaMedianoche,
    String? excludeAsignacionId,
  });

  /// Verifica si existe conflicto de horarios para un vehículo
  Future<bool> hasConflictVehiculo({
    required String idVehiculo,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required bool cruzaMedianoche,
    String? excludeAsignacionId,
  });

  /// Verifica si una unidad de dotación ya está asignada
  Future<bool> isDotacionUnidadAsignada({
    required String idDotacion,
    required DateTime fecha,
    required int numeroUnidad,
    String? excludeAsignacionId,
  });

  /// Crea una nueva asignación
  Future<CuadranteAsignacionEntity> create(CuadranteAsignacionEntity asignacion);

  /// Actualiza una asignación existente
  Future<CuadranteAsignacionEntity> update(CuadranteAsignacionEntity asignacion);

  /// Elimina una asignación (soft delete)
  Future<void> delete(String id);

  /// Confirma una asignación
  Future<CuadranteAsignacionEntity> confirmar({
    required String id,
    required String confirmadaPor,
  });

  /// Cancela una asignación
  Future<CuadranteAsignacionEntity> cancelar(String id);

  /// Completa una asignación con métricas finales
  Future<CuadranteAsignacionEntity> completar({
    required String id,
    double? kmFinal,
    int? serviciosRealizados,
    double? horasEfectivas,
  });

  /// Stream de asignaciones (para tiempo real)
  Stream<List<CuadranteAsignacionEntity>> watchAll();

  /// Stream de asignaciones por fecha (para tiempo real)
  Stream<List<CuadranteAsignacionEntity>> watchByFecha(DateTime fecha);

  /// Stream de asignaciones de un personal (para tiempo real)
  Stream<List<CuadranteAsignacionEntity>> watchByPersonal(String idPersonal);

  /// Stream de asignaciones de una dotación (para tiempo real)
  Stream<List<CuadranteAsignacionEntity>> watchByDotacion(String idDotacion);

  /// Copia todos los turnos de una semana a otra
  ///
  /// Parámetros:
  /// - [fechaInicioOrigen]: Fecha de inicio de la semana origen (lunes)
  /// - [fechaInicioDestino]: Fecha de inicio de la semana destino (lunes)
  /// - [idPersonal]: Lista de IDs de personal a copiar (null = copiar todos)
  ///
  /// Retorna la lista de asignaciones creadas en la semana destino
  Future<List<CuadranteAsignacionEntity>> copiarSemana({
    required DateTime fechaInicioOrigen,
    required DateTime fechaInicioDestino,
    List<String>? idPersonal,
  });
}
