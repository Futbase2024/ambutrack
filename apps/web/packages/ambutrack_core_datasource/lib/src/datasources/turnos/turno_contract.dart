import 'entities/turno_entity.dart';

/// Contrato para el datasource de turnos
///
/// Proporciona operaciones CRUD base más métodos especializados
/// para la gestión de turnos de personal.
abstract class TurnoDataSource {
  // ===== MÉTODOS CRUD BASE =====

  /// Obtiene todos los turnos
  Future<List<TurnoEntity>> getAll({int? limit, int? offset});

  /// Obtiene un turno por ID
  Future<TurnoEntity?> getById(String id);

  /// Crea un nuevo turno
  Future<TurnoEntity> create(TurnoEntity entity);

  /// Actualiza un turno existente
  Future<TurnoEntity> update(TurnoEntity entity);

  /// Elimina un turno por ID
  Future<void> delete(String id);

  /// Elimina múltiples turnos
  Future<void> deleteBatch(List<String> ids);

  /// Cuenta el total de turnos
  Future<int> count();

  /// Stream de todos los turnos
  Stream<List<TurnoEntity>> watchAll();

  /// Stream de un turno específico
  Stream<TurnoEntity?> watchById(String id);

  /// Limpia todos los datos
  Future<void> clear();

  /// Crea múltiples turnos
  Future<List<TurnoEntity>> createBatch(List<TurnoEntity> entities);

  /// Verifica si existe un turno
  Future<bool> exists(String id);

  /// Actualiza múltiples turnos
  Future<List<TurnoEntity>> updateBatch(List<TurnoEntity> entities);

  // ===== MÉTODOS ESPECIALIZADOS =====
  /// Obtiene turnos que se solapan con un rango de fechas
  ///
  /// Retorna turnos donde:
  /// - fechaInicio <= [endDate] AND fechaFin >= [startDate]
  ///
  /// [startDate]: Fecha inicio del rango
  /// [endDate]: Fecha fin del rango
  /// Returns: Lista de turnos que se solapan con el rango
  Future<List<TurnoEntity>> getByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Obtiene todos los turnos activos de un personal específico
  ///
  /// [idPersonal]: ID del personal (FK → personal.id)
  /// Returns: Lista de turnos del personal ordenados por fecha descendente
  Future<List<TurnoEntity>> getByPersonal(String idPersonal);

  /// Verifica si existe conflicto de horarios para un personal
  ///
  /// Detecta solapamiento de turnos en el mismo rango de fechas y horarios.
  /// Dos turnos NO entran en conflicto si están en fechas diferentes
  /// o si sus horarios no se solapan.
  ///
  /// La verificación de horarios maneja correctamente:
  /// - Turnos normales (ej: 08:00-16:00)
  /// - Turnos que cruzan medianoche (ej: 23:00-07:00)
  ///
  /// [idPersonal]: ID del personal a verificar
  /// [fechaInicio]: Fecha de inicio del turno a validar
  /// [fechaFin]: Fecha de fin del turno a validar
  /// [excludeTurnoId]: ID de turno a excluir (para updates)
  /// [horaInicio]: Hora de inicio en formato "HH:mm" (opcional)
  /// [horaFin]: Hora de fin en formato "HH:mm" (opcional)
  /// Returns: `true` si hay conflictos, `false` en caso contrario
  Future<bool> hasConflicts({
    required String idPersonal,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? excludeTurnoId,
    String? horaInicio,
    String? horaFin,
  });

  /// Obtiene solo los turnos activos
  ///
  /// Returns: Lista de turnos con activo=true
  Future<List<TurnoEntity>> getActivos();

  /// Copia turnos de una semana a otra semana destino
  ///
  /// Crea copias de los turnos existentes en la semana origen
  /// para la semana destino, ajustando las fechas automáticamente.
  ///
  /// [fechaInicioOrigen]: Lunes de la semana origen (00:00:00)
  /// [fechaInicioDestino]: Lunes de la semana destino (00:00:00)
  /// [idPersonal]: Lista de IDs de personal a copiar (null = todos)
  /// Returns: Lista de turnos creados en la semana destino
  Future<List<TurnoEntity>> copiarSemana({
    required DateTime fechaInicioOrigen,
    required DateTime fechaInicioDestino,
    List<String>? idPersonal,
  });
}
