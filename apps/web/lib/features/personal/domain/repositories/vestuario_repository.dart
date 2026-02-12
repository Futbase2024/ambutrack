import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio de Vestuario
abstract class VestuarioRepository {
  /// Obtiene todos los registros de vestuario
  Future<List<VestuarioEntity>> getAll();

  /// Obtiene un registro por ID
  Future<VestuarioEntity> getById(String id);

  /// Obtiene vestuario de un personal específico
  Future<List<VestuarioEntity>> getByPersonalId(String personalId);

  /// Obtiene vestuario asignado (sin devolver)
  Future<List<VestuarioEntity>> getAsignado();

  /// Obtiene vestuario por tipo de prenda
  Future<List<VestuarioEntity>> getByPrenda(String prenda);

  /// Crea un nuevo registro
  Future<VestuarioEntity> create(VestuarioEntity item);

  /// Actualiza un registro
  Future<VestuarioEntity> update(VestuarioEntity item);

  /// Elimina un registro
  Future<void> delete(String id);

  /// Stream de todos los registros
  Stream<List<VestuarioEntity>> watchAll();

  /// Stream de vestuario por personal
  Stream<List<VestuarioEntity>> watchByPersonalId(String personalId);
}
