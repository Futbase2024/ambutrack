import 'base_entity.dart';

/// Base class for data models that correspond to entities
///
/// Models are used to handle serialization/deserialization
/// specific to different data sources (Firebase, REST, etc.)
/// while entities remain data source agnostic
abstract class BaseModel<T extends BaseEntity> {
  /// Converts the model to its corresponding entity
  T toEntity();

  /// Converts the model to a JSON representation
  Map<String, dynamic> toJson();

  /// Creates a model instance from an entity
  ///
  /// This is a factory constructor that subclasses must implement
  /// as a static method or factory constructor
  // static BaseModel<T> fromEntity(T entity);

  /// Creates a model instance from JSON
  ///
  /// This is a factory constructor that subclasses must implement
  /// as a static method or factory constructor
  // static BaseModel<T> fromJson(Map<String, dynamic> json);
}

/// Extension to add model conversion capabilities to entities
extension EntityToModel<T extends BaseEntity> on T {
  /// Converts an entity to a specific model type
  ///
  /// This method should be used when you need to convert
  /// an entity to a data source specific model
  M toModel<M extends BaseModel<T>>() {
    throw UnimplementedError(
      'toModel must be implemented for ${T.toString()} -> ${M.toString()}',
    );
  }
}