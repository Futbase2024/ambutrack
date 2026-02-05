import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio de tipos de paciente
abstract class TipoPacienteRepository {
  /// Obtiene todos los tipos de paciente
  Future<List<TipoPacienteEntity>> getAll();

  /// Obtiene un tipo de paciente por ID
  Future<TipoPacienteEntity?> getById(String id);

  /// Crea un nuevo tipo de paciente
  Future<TipoPacienteEntity> create(TipoPacienteEntity tipoPaciente);

  /// Actualiza un tipo de paciente existente
  Future<TipoPacienteEntity> update(TipoPacienteEntity tipoPaciente);

  /// Elimina un tipo de paciente
  Future<void> delete(String id);

  /// Obtiene todos los tipos de paciente activos
  Future<List<TipoPacienteEntity>> getActivos();
}
