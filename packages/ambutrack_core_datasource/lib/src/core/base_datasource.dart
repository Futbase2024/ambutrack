import 'base_entity.dart';

/// Base interface for all datasource implementations
///
/// Provides CRUD operations and real-time streaming capabilities
/// for entities in the data layer
abstract class BaseDatasource<T extends BaseEntity> {
  /// Creates a new entity in the datasource
  ///
  /// Returns the created entity with server-generated fields
  /// such as id and timestamps if applicable
  Future<T> create(T entity);

  /// Retrieves an entity by its unique identifier
  ///
  /// Returns null if the entity does not exist
  Future<T?> getById(String id);

  /// Retrieves all entities with optional pagination
  ///
  /// [limit] - Maximum number of entities to return
  /// [offset] - Number of entities to skip
  Future<List<T>> getAll({int? limit, int? offset});

  /// Updates an existing entity
  ///
  /// Returns the updated entity
  /// Throws [Exception] if the entity does not exist
  Future<T> update(T entity);

  /// Deletes an entity by its unique identifier
  ///
  /// Throws [Exception] if the entity does not exist
  Future<void> delete(String id);

  /// Checks if an entity exists with the given identifier
  Future<bool> exists(String id);

  /// Creates a stream that emits all entities and updates
  ///
  /// The stream will emit the initial data and then
  /// any subsequent changes to the collection
  Stream<List<T>> watchAll();

  /// Creates a stream that emits a specific entity and its updates
  ///
  /// The stream will emit null if the entity is deleted
  Stream<T?> watchById(String id);

  /// Performs a batch create operation
  ///
  /// Returns the list of created entities
  Future<List<T>> createBatch(List<T> entities);

  /// Performs a batch update operation
  ///
  /// Returns the list of updated entities
  Future<List<T>> updateBatch(List<T> entities);

  /// Performs a batch delete operation
  ///
  /// Deletes all entities with the given identifiers
  Future<void> deleteBatch(List<String> ids);

  /// Counts the total number of entities
  Future<int> count();

  /// Clears all entities from the datasource
  ///
  /// Use with caution - this operation is usually irreversible
  Future<void> clear();
}