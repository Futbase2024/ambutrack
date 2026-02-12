import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio de motivos de traslado
abstract class MotivoTrasladoRepository {
  /// Obtiene todos los motivos de traslado
  Future<List<MotivoTrasladoEntity>> getAll();

  /// Obtiene un motivo de traslado por ID
  Future<MotivoTrasladoEntity?> getById(String id);

  /// Crea un nuevo motivo de traslado
  Future<void> create(MotivoTrasladoEntity motivo);

  /// Actualiza un motivo de traslado
  Future<void> update(MotivoTrasladoEntity motivo);

  /// Elimina un motivo de traslado
  Future<void> delete(String id);

  /// Stream de cambios en motivos de traslado
  Stream<List<MotivoTrasladoEntity>> watchAll();
}
