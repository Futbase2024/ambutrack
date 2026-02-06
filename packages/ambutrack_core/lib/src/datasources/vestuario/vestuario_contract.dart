import 'package:ambutrack_core/src/datasources/vestuario/entities/vestuario_entity.dart';

/// Contrato para el datasource de Vestuario
abstract class VestuarioDataSource {
  /// Obtiene todo el vestuario
  Future<List<VestuarioEntity>> getAll();

  /// Obtiene un registro de vestuario por ID
  Future<VestuarioEntity> getById(String id);

  /// Obtiene todo el vestuario de un personal específico
  Future<List<VestuarioEntity>> getByPersonalId(String personalId);

  /// Obtiene vestuario asignado (sin devolver)
  Future<List<VestuarioEntity>> getAsignado();

  /// Obtiene vestuario por tipo de prenda
  Future<List<VestuarioEntity>> getByPrenda(String prenda);

  /// Crea un nuevo registro de vestuario
  Future<VestuarioEntity> create(VestuarioEntity entity);

  /// Actualiza un registro de vestuario existente
  Future<VestuarioEntity> update(VestuarioEntity entity);

  /// Elimina un registro de vestuario
  Future<void> delete(String id);

  /// Stream de todos los registros (tiempo real)
  Stream<List<VestuarioEntity>> watchAll();

  /// Stream de vestuario por personal
  Stream<List<VestuarioEntity>> watchByPersonalId(String personalId);
}
