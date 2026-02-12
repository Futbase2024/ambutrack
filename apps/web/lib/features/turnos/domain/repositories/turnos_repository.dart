import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio para gestión de turnos del personal
abstract class TurnosRepository {
  /// Obtiene todos los turnos
  Future<List<TurnoEntity>> getAll();

  /// Obtiene turnos por rango de fechas
  Future<List<TurnoEntity>> getByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Obtiene turnos de un personal específico
  Future<List<TurnoEntity>> getByPersonal(String idPersonal);

  /// Crea un nuevo turno y lo devuelve con su ID asignado
  Future<TurnoEntity> create(TurnoEntity turno);

  /// Actualiza un turno existente
  Future<void> update(TurnoEntity turno);

  /// Elimina un turno
  Future<void> delete(String id);

  /// Verifica si hay conflictos de turnos
  ///
  /// [idPersonal]: ID del personal a verificar
  /// [fechaInicio]: Fecha de inicio del turno
  /// [fechaFin]: Fecha de fin del turno
  /// [excludeTurnoId]: ID del turno a excluir (para updates)
  /// [horaInicio]: Hora de inicio en formato "HH:mm" (opcional)
  /// [horaFin]: Hora de fin en formato "HH:mm" (opcional)
  Future<bool> hasConflicts({
    required String idPersonal,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? excludeTurnoId,
    String? horaInicio,
    String? horaFin,
  });
}
