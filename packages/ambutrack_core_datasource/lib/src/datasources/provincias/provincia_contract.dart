import '../../core/base_datasource.dart';
import 'entities/provincia_entity.dart';

/// Contrato para operaciones de datasource de provincias
///
/// Extiende [BaseDatasource] con operaciones CRUD estándar.
/// Todas las implementaciones (Supabase, Firebase, etc.) deben adherirse a este contrato.
abstract class ProvinciaDataSource extends BaseDatasource<ProvinciaEntity> {
  // El contrato base ya incluye todos los métodos necesarios:
  // - Future<List<T>> getAll({int? limit, int? offset})
  // - Future<T?> getById(String id)
  // - Future<T> create(T entity)
  // - Future<T> update(T entity)
  // - Future<void> delete(String id)
  // - Future<void> deleteBatch(List<String> ids)
  // - Future<int> count()
  // - Future<bool> exists(String id)
  // - Future<void> clear()
  // - Stream<List<T>> watchAll()
  // - Stream<T?> watchById(String id)

  // Se pueden agregar métodos específicos aquí si es necesario
  // Por ejemplo:
  // Future<List<ProvinciaEntity>> getByComunidad(String comunidadId);
}
