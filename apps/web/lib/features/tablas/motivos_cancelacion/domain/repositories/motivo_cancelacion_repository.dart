import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de motivos de cancelación
abstract class MotivoCancelacionRepository {
  /// Obtiene todos los motivos de cancelación
  Future<List<MotivoCancelacionEntity>> getAll();

  /// Obtiene un motivo de cancelación por ID
  Future<MotivoCancelacionEntity?> getById(String id);

  /// Crea un nuevo motivo de cancelación
  Future<void> create(MotivoCancelacionEntity motivo);

  /// Actualiza un motivo de cancelación existente
  Future<void> update(MotivoCancelacionEntity motivo);

  /// Elimina un motivo de cancelación
  Future<void> delete(String id);
}
