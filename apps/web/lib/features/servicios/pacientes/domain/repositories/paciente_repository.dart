import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de Pacientes
/// Define las operaciones de dominio para gestionar pacientes
abstract class PacienteRepository {
  /// Obtiene todos los pacientes activos
  Future<List<PacienteEntity>> getAll();

  /// Obtiene un paciente por su ID
  Future<PacienteEntity> getById(String id);

  /// Busca pacientes por criterios
  Future<List<PacienteEntity>> search(String query);

  /// Crea un nuevo paciente
  Future<PacienteEntity> create(PacienteEntity paciente);

  /// Actualiza un paciente existente
  Future<PacienteEntity> update(PacienteEntity paciente);

  /// Elimina un paciente (soft delete)
  Future<void> delete(String id);

  /// Stream de pacientes en tiempo real
  Stream<List<PacienteEntity>> watchAll();

  /// Stream de un paciente específico
  Stream<PacienteEntity?> watchById(String id);
}
