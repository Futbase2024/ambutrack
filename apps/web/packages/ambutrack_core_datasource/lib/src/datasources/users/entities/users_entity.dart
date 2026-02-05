import '../../../core/base_entity.dart';

/// User entity representing a user in the system
///
/// This entity contains all the essential user information
/// and is data source agnostic
class UserEntity extends BaseEntity {
  /// User's email address
  final String email;

  /// User's display name (optional)
  final String? displayName;

  /// URL to user's profile photo (optional)
  final String? photoUrl;

  /// Whether the user's email has been verified
  final bool isEmailVerified;

  /// Additional metadata for the user
  final Map<String, dynamic>? metadata;

  /// List of roles assigned to the user
  final List<String> roles;

  /// Whether the user account is active
  final bool isActive;

  /// User's phone number (optional)
  final String? phoneNumber;

  /// User's date of birth (optional)
  final DateTime? dateOfBirth;

  /// User's preferred language/locale
  final String? locale;

  /// User's timezone
  final String? timezone;

  /// Creates a new [UserEntity] instance
  const UserEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.metadata,
    this.roles = const [],
    this.isActive = true,
    this.phoneNumber,
    this.dateOfBirth,
    this.locale,
    this.timezone,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'metadata': metadata,
      'roles': roles,
      'isActive': isActive,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'locale': locale,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [UserEntity] from JSON data
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? const [],
      isActive: json['isActive'] as bool? ?? true,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      locale: json['locale'] as String?,
      timezone: json['timezone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isEmailVerified,
    Map<String, dynamic>? metadata,
    List<String>? roles,
    bool? isActive,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? locale,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      metadata: metadata ?? this.metadata,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      locale: locale ?? this.locale,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        email,
        displayName,
        photoUrl,
        isEmailVerified,
        metadata,
        roles,
        isActive,
        phoneNumber,
        dateOfBirth,
        locale,
        timezone,
      ];

  @override
  String toString() {
    return 'UserEntity('
        'id: $id, '
        'email: $email, '
        'displayName: $displayName, '
        'isActive: $isActive, '
        'roles: $roles'
        ')';
  }
}