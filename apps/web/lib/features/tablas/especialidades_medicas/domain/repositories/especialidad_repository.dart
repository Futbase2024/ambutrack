import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de especialidades médicas
abstract class EspecialidadRepository {
  /// Obtiene todas las especialidades médicas
  Future<List<EspecialidadEntity>> getAll();

  /// Obtiene una especialidad por su ID
  Future<EspecialidadEntity?> getById(String id);

  /// Crea una nueva especialidad
  Future<void> create(EspecialidadEntity especialidad);

  /// Actualiza una especialidad existente
  Future<void> update(EspecialidadEntity especialidad);

  /// Elimina una especialidad por su ID
  Future<void> delete(String id);

  /// Filtra especialidades por tipo
  Future<List<EspecialidadEntity>> filterByTipo(String tipo);

  /// Obtiene solo especialidades activas
  Future<List<EspecialidadEntity>> getActivas();
}
