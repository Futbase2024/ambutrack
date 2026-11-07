import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio para gestionar las ausencias del personal.
/// Interfaz que define las operaciones disponibles para ausencias.
abstract class AusenciasRepository {
  /// Obtiene todas las ausencias.
  Future<List<AusenciaEntity>> getAll();

  /// Obtiene las ausencias de un personal específico.
  Future<List<AusenciaEntity>> getByPersonal(String idPersonal);

  /// Obtiene las ausencias por estado.
  Future<List<AusenciaEntity>> getByEstado(EstadoAusencia estado);

  /// Obtiene las ausencias en un rango de fechas.
  Future<List<AusenciaEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });

  /// Obtiene una ausencia por su ID.
  Future<AusenciaEntity> getById(String id);

  /// Crea una nueva solicitud de ausencia.
  Future<AusenciaEntity> create(AusenciaEntity ausencia);

  /// Actualiza una solicitud de ausencia existente.
  Future<AusenciaEntity> update(AusenciaEntity ausencia);

  /// Elimina una solicitud de ausencia.
  Future<void> delete(String id);

  /// Observa cambios en todas las ausencias (stream).
  Stream<List<AusenciaEntity>> watchAll();

  /// Observa cambios en las ausencias de un personal (stream).
  Stream<List<AusenciaEntity>> watchByPersonal(String idPersonal);
}
