import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';

/// Repositorio abstracto de personal
abstract class PersonalRepository {
  /// Obtener todo el personal
  Future<List<PersonalEntity>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
  });

  /// Obtener un miembro del personal por ID
  Future<PersonalEntity> getById(String id);

  /// Crear un nuevo miembro del personal
  Future<PersonalEntity> create(PersonalEntity personal);

  /// Actualizar un miembro del personal existente
  Future<PersonalEntity> update(PersonalEntity personal);

  /// Eliminar un miembro del personal
  Future<void> delete(String id);

  /// Contar personal
  Future<int> count();

  /// Buscar personal por nombre
  Future<List<PersonalEntity>> searchByNombre(String nombre);
}
