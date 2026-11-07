import 'entities/tpersonal_entity.dart';

/// Contrato para el datasource de tpersonal
///
/// Define las operaciones disponibles para gestionar datos de personal
abstract class TPersonalDataSource {
  /// Obtiene un registro de personal por ID
  Future<TPersonalEntity?> getById(String id);

  /// Obtiene un registro de personal por usuario_id (vinculado con auth.users)
  Future<TPersonalEntity?> getByUsuarioId(String usuarioId);

  /// Obtiene todos los registros de personal
  Future<List<TPersonalEntity>> getAll();

  /// Obtiene registros de personal activos
  Future<List<TPersonalEntity>> getActivos();

  /// Busca personal por DNI
  Future<TPersonalEntity?> getByDni(String dni);

  /// Busca personal por email
  Future<TPersonalEntity?> getByEmail(String email);
}
