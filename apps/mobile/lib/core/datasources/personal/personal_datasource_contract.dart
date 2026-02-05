import 'entities/personal_entity.dart';

/// Contrato para el datasource de personal de AmbuTrack
///
/// Define las operaciones disponibles para acceder a los datos del personal.
abstract class PersonalDataSource {
  /// Obtiene un registro de personal por su usuario_id (FK a auth.users)
  ///
  /// Retorna null si no se encuentra el registro.
  Future<PersonalEntity?> getByUsuarioId(String usuarioId);

  /// Obtiene un registro de personal por su ID
  Future<PersonalEntity?> getById(String id);

  /// Obtiene todos los registros de personal activos
  Future<List<PersonalEntity>> getAllActivos();

  /// Obtiene todos los registros de personal (activos e inactivos)
  Future<List<PersonalEntity>> getAll();

  /// Crea un nuevo registro de personal
  Future<PersonalEntity> create(PersonalEntity personal);

  /// Actualiza un registro de personal existente
  Future<PersonalEntity> update(PersonalEntity personal);

  /// Elimina (marca como inactivo) un registro de personal
  Future<void> delete(String id);
}
