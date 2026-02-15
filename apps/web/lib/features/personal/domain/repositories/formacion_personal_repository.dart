import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio para formación personal
abstract class FormacionPersonalRepository {
  /// Obtiene todos los registros de formación
  Future<List<FormacionPersonalEntity>> getAll();

  /// Obtiene un registro por ID
  Future<FormacionPersonalEntity> getById(String id);

  /// Obtiene formación por personal
  Future<List<FormacionPersonalEntity>> getByPersonalId(String personalId);

  /// Obtiene formación vigente
  Future<List<FormacionPersonalEntity>> getVigentes();

  /// Obtiene formación próxima a vencer (30 días)
  Future<List<FormacionPersonalEntity>> getProximasVencer();

  /// Obtiene formación vencida
  Future<List<FormacionPersonalEntity>> getVencidas();

  /// Obtiene formación por estado
  Future<List<FormacionPersonalEntity>> getByEstado(String estado);

  /// Crea un nuevo registro
  Future<FormacionPersonalEntity> create(FormacionPersonalEntity entity);

  /// Actualiza un registro
  Future<FormacionPersonalEntity> update(FormacionPersonalEntity entity);

  /// Elimina un registro
  Future<void> delete(String id);

  /// Stream de todos los registros
  Stream<List<FormacionPersonalEntity>> watchAll();

  /// Stream de formación por personal
  Stream<List<FormacionPersonalEntity>> watchByPersonalId(String personalId);
}
