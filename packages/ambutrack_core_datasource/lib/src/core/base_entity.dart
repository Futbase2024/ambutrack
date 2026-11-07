import 'package:equatable/equatable.dart';

/// Base class for all entities in the datasource layer
///
/// All entities must extend this class to ensure consistency
/// across the application's data layer
abstract class BaseEntity extends Equatable {
  /// Unique identifier for the entity
  final String id;

  /// Timestamp when the entity was created
  final DateTime createdAt;

  /// Timestamp when the entity was last updated
  final DateTime updatedAt;

  /// Creates a new [BaseEntity] instance
  const BaseEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts the entity to a JSON representation
  ///
  /// This method must be implemented by all subclasses
  /// to provide their specific serialization logic
  Map<String, dynamic> toJson();

  /// Creates a copy of this entity with modified fields
  ///
  /// Subclasses should override this method to provide
  /// their own copyWith implementation
  BaseEntity copyWith();

  @override
  List<Object?> get props => [id, createdAt, updatedAt];

  @override
  bool get stringify => true;
}