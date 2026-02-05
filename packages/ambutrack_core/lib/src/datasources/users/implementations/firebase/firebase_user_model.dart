import 'package:cloud_firestore/cloud_firestore.dart';
import '../../entities/users_entity.dart';
import '../../../../core/base_model.dart';

/// Firebase-specific model for [UserEntity]
///
/// Handles conversion between Firestore documents and [UserEntity] objects
class FirebaseUserModel extends BaseModel<UserEntity> {
  final UserEntity _entity;

  FirebaseUserModel(this._entity);

  /// Creates a [FirebaseUserModel] from a [UserEntity]
  factory FirebaseUserModel.fromEntity(UserEntity entity) {
    return FirebaseUserModel(entity);
  }

  /// Creates a [FirebaseUserModel] from a Firestore document
  factory FirebaseUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    if (!doc.exists) {
      throw ArgumentError('Document does not exist');
    }

    final data = doc.data()!;
    final entity = UserEntity(
      id: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      metadata: data['metadata'] as Map<String, dynamic>?,
      roles: List<String>.from(data['roles'] ?? []),
      isActive: data['isActive'] as bool? ?? true,
      phoneNumber: data['phoneNumber'] as String?,
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      locale: data['locale'] as String?,
      timezone: data['timezone'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );

    return FirebaseUserModel(entity);
  }

  /// Creates a [FirebaseUserModel] from JSON data
  factory FirebaseUserModel.fromJson(Map<String, dynamic> json) {
    final entity = UserEntity.fromJson(json);
    return FirebaseUserModel(entity);
  }

  @override
  UserEntity toEntity() => _entity;

  @override
  Map<String, dynamic> toJson() => _entity.toJson();

  /// Converts the model to Firestore document data
  ///
  /// This method handles Firestore-specific data types like [Timestamp]
  /// and excludes the document ID (which is handled separately)
  Map<String, dynamic> toFirestore() {
    return {
      'email': _entity.email,
      'displayName': _entity.displayName,
      'photoUrl': _entity.photoUrl,
      'isEmailVerified': _entity.isEmailVerified,
      'metadata': _entity.metadata,
      'roles': _entity.roles,
      'isActive': _entity.isActive,
      'phoneNumber': _entity.phoneNumber,
      'dateOfBirth': _entity.dateOfBirth != null
          ? Timestamp.fromDate(_entity.dateOfBirth!)
          : null,
      'locale': _entity.locale,
      'timezone': _entity.timezone,
      'createdAt': Timestamp.fromDate(_entity.createdAt),
      'updatedAt': Timestamp.fromDate(_entity.updatedAt),
    };
  }

  /// Converts the model to Firestore document data for creation
  ///
  /// Uses server timestamps for createdAt and updatedAt
  Map<String, dynamic> toFirestoreForCreate() {
    return {
      'email': _entity.email,
      'displayName': _entity.displayName,
      'photoUrl': _entity.photoUrl,
      'isEmailVerified': _entity.isEmailVerified,
      'metadata': _entity.metadata,
      'roles': _entity.roles,
      'isActive': _entity.isActive,
      'phoneNumber': _entity.phoneNumber,
      'dateOfBirth': _entity.dateOfBirth != null
          ? Timestamp.fromDate(_entity.dateOfBirth!)
          : null,
      'locale': _entity.locale,
      'timezone': _entity.timezone,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Converts the model to Firestore document data for updates
  ///
  /// Uses server timestamp for updatedAt only
  Map<String, dynamic> toFirestoreForUpdate() {
    return {
      'email': _entity.email,
      'displayName': _entity.displayName,
      'photoUrl': _entity.photoUrl,
      'isEmailVerified': _entity.isEmailVerified,
      'metadata': _entity.metadata,
      'roles': _entity.roles,
      'isActive': _entity.isActive,
      'phoneNumber': _entity.phoneNumber,
      'dateOfBirth': _entity.dateOfBirth != null
          ? Timestamp.fromDate(_entity.dateOfBirth!)
          : null,
      'locale': _entity.locale,
      'timezone': _entity.timezone,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Creates partial update data for Firestore
  ///
  /// Only includes non-null fields and always includes updatedAt
  Map<String, dynamic> toPartialFirestoreUpdate({
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? metadata,
    List<String>? roles,
    bool? isActive,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? locale,
    String? timezone,
    bool? isEmailVerified,
  }) {
    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) updateData['displayName'] = displayName;
    if (photoUrl != null) updateData['photoUrl'] = photoUrl;
    if (metadata != null) updateData['metadata'] = metadata;
    if (roles != null) updateData['roles'] = roles;
    if (isActive != null) updateData['isActive'] = isActive;
    if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
    if (dateOfBirth != null) {
      updateData['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
    }
    if (locale != null) updateData['locale'] = locale;
    if (timezone != null) updateData['timezone'] = timezone;
    if (isEmailVerified != null) updateData['isEmailVerified'] = isEmailVerified;

    return updateData;
  }

  @override
  String toString() {
    return 'FirebaseUserModel(entity: $_entity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FirebaseUserModel && other._entity == _entity;
  }

  @override
  int get hashCode => _entity.hashCode;
}