import 'entities/curso_entity.dart';

/// Contrato para el datasource de cursos
abstract class CursoDataSource {
  /// Obtiene todos los cursos
  Future<List<CursoEntity>> getAll();

  /// Obtiene un curso por ID
  Future<CursoEntity> getById(String id);

  /// Obtiene cursos activos
  Future<List<CursoEntity>> getActivos();

  /// Obtiene cursos por tipo
  Future<List<CursoEntity>> getByTipo(String tipo);

  /// Crea un nuevo curso
  Future<CursoEntity> create(CursoEntity entity);

  /// Actualiza un curso existente
  Future<CursoEntity> update(CursoEntity entity);

  /// Elimina un curso
  Future<void> delete(String id);

  /// Stream de todos los cursos
  Stream<List<CursoEntity>> watchAll();

  /// Stream de cursos activos
  Stream<List<CursoEntity>> watchActivos();
}
