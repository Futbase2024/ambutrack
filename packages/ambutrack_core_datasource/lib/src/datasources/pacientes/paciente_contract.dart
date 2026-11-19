import 'entities/paciente_entity.dart';

/// Contrato abstracto para el DataSource de Pacientes
/// Define las operaciones CRUD básicas
abstract class PacienteDataSource {
  /// Obtiene todos los pacientes activos
  Future<List<PacienteEntity>> getAll();

  /// Obtiene un paciente por su ID
  Future<PacienteEntity> getById(String id);

  /// Busca pacientes por criterios (nombre, apellido, documento)
  Future<List<PacienteEntity>> search(String query);

  /// Crea un nuevo paciente
  Future<PacienteEntity> create(PacienteEntity paciente);

  /// Actualiza un paciente existente
  Future<PacienteEntity> update(PacienteEntity paciente);

  /// Elimina un paciente (soft delete, marca activo = false)
  Future<void> delete(String id);

  /// Elimina un paciente permanentemente (hard delete)
  Future<void> hardDelete(String id);

  /// Stream que emite cambios en tiempo real de pacientes
  Stream<List<PacienteEntity>> watchAll();

  /// Stream que emite cambios de un paciente específico
  Stream<PacienteEntity?> watchById(String id);
}
