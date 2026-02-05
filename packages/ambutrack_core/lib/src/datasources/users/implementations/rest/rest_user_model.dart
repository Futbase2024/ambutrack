import '../../entities/users_entity.dart';
import '../../../../core/base_model.dart';

/// REST API specific model for [UserEntity]
///
/// Handles JSON serialization/deserialization for REST API communication
class RestUserModel extends BaseModel<UserEntity> {
  final UserEntity _entity;

  RestUserModel(this._entity);

  /// Creates a [RestUserModel] from a [UserEntity]
  factory RestUserModel.fromEntity(UserEntity entity) {
    return RestUserModel(entity);
  }

  /// Creates a [RestUserModel] from JSON data
  factory RestUserModel.fromJson(Map<String, dynamic> json) {
    return _fromJsonHelper(json);
  }

  @override
  UserEntity toEntity() => _entity;

  @override
  Map<String, dynamic> toJson() => _toJsonHelper();

  /// User ID
  String get id => _entity.id;

  /// User's email address
  String get email => _entity.email;

  /// User's display name
  String? get displayName => _entity.displayName;

  /// URL to user's profile photo
  String? get photoUrl => _entity.photoUrl;

  /// Whether the user's email has been verified
  bool get isEmailVerified => _entity.isEmailVerified;

  /// Additional metadata for the user
  Map<String, dynamic>? get metadata => _entity.metadata;

  /// List of roles assigned to the user
  List<String> get roles => _entity.roles;

  /// Whether the user account is active
  bool get isActive => _entity.isActive;

  /// User's phone number
  String? get phoneNumber => _entity.phoneNumber;

  /// User's date of birth
  DateTime? get dateOfBirth => _entity.dateOfBirth;

  /// User's preferred language/locale
  String? get locale => _entity.locale;

  /// User's timezone
  String? get timezone => _entity.timezone;

  /// Timestamp when the entity was created
  DateTime get createdAt => _entity.createdAt;

  /// Timestamp when the entity was last updated
  DateTime get updatedAt => _entity.updatedAt;

  /// Creates a request body for user creation
  Map<String, dynamic> toCreateRequest() {
    return {
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'metadata': metadata,
      'roles': roles,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'locale': locale,
      'timezone': timezone,
    };
  }

  /// Creates a request body for user updates
  Map<String, dynamic> toUpdateRequest() {
    return {
      'display_name': displayName,
      'photo_url': photoUrl,
      'metadata': metadata,
      'roles': roles,
      'is_active': isActive,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'locale': locale,
      'timezone': timezone,
      'email_verified': isEmailVerified,
    };
  }

  /// Creates a partial update request with only specified fields
  Map<String, dynamic> toPartialUpdateRequest({
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
    final updateData = <String, dynamic>{};

    if (displayName != null) updateData['display_name'] = displayName;
    if (photoUrl != null) updateData['photo_url'] = photoUrl;
    if (metadata != null) updateData['metadata'] = metadata;
    if (roles != null) updateData['roles'] = roles;
    if (isActive != null) updateData['is_active'] = isActive;
    if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
    if (dateOfBirth != null) {
      updateData['date_of_birth'] = dateOfBirth.toIso8601String();
    }
    if (locale != null) updateData['locale'] = locale;
    if (timezone != null) updateData['timezone'] = timezone;
    if (isEmailVerified != null) updateData['email_verified'] = isEmailVerified;

    return updateData;
  }

  @override
  String toString() {
    return 'RestUserModel(entity: $_entity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestUserModel && other._entity == _entity;
  }

  @override
  int get hashCode => _entity.hashCode;

  /// Helper method to create a RestUserModel from JSON
  static RestUserModel _fromJsonHelper(Map<String, dynamic> json) {
    final entity = UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      isEmailVerified: json['email_verified'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? const [],
      isActive: json['is_active'] as bool? ?? true,
      phoneNumber: json['phone_number'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      locale: json['locale'] as String?,
      timezone: json['timezone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

    return RestUserModel(entity);
  }

  /// Helper method to convert RestUserModel to JSON
  Map<String, dynamic> _toJsonHelper() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'email_verified': isEmailVerified,
      'metadata': metadata,
      'roles': roles,
      'is_active': isActive,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'locale': locale,
      'timezone': timezone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}