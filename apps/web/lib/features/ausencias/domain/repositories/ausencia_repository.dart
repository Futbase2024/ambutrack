import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de Ausencias
abstract class AusenciaRepository {
  /// Obtiene todas las ausencias
  Future<List<AusenciaEntity>> getAll();

  /// Obtiene ausencias por personal
  Future<List<AusenciaEntity>> getByPersonal(String idPersonal);

  /// Obtiene ausencias por estado
  Future<List<AusenciaEntity>> getByEstado(EstadoAusencia estado);

  /// Obtiene ausencias en un rango de fechas
  Future<List<AusenciaEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });

  /// Obtiene una ausencia por ID
  Future<AusenciaEntity> getById(String id);

  /// Crea una nueva ausencia
  Future<AusenciaEntity> create(AusenciaEntity ausencia);

  /// Actualiza una ausencia existente
  Future<AusenciaEntity> update(AusenciaEntity ausencia);

  /// Aprueba una ausencia
  Future<AusenciaEntity> aprobar({
    required String idAusencia,
    required String aprobadoPor,
    String? observaciones,
  });

  /// Rechaza una ausencia
  Future<AusenciaEntity> rechazar({
    required String idAusencia,
    required String aprobadoPor,
    String? observaciones,
  });

  /// Elimina una ausencia
  Future<void> delete(String id);

  /// Stream de cambios en ausencias
  Stream<List<AusenciaEntity>> watchAll();

  /// Stream de cambios en ausencias de un personal específico
  Stream<List<AusenciaEntity>> watchByPersonal(String idPersonal);
}
