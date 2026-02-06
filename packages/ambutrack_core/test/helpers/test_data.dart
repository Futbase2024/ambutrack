import 'package:flutter_test/flutter_test.dart';
import 'package:ambutrack_core/ambutrack_core.dart';

/// Test data utilities for creating consistent test entities
class TestData {
  // Base timestamps for consistent testing
  static final DateTime baseCreatedAt = DateTime(2023, 1, 1, 12, 0, 0);
  static final DateTime baseUpdatedAt = DateTime(2023, 1, 1, 12, 30, 0);

  /// Creates a sample UserEntity for testing
  static UserEntity createUser({
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
      id: id ?? 'test-user-123',
      email: email ?? 'test@example.com',
      displayName: displayName ?? 'Test User',
      photoUrl: photoUrl ?? 'https://example.com/photo.jpg',
      isEmailVerified: isEmailVerified ?? true,
      metadata: metadata ?? {'source': 'test'},
      roles: roles ?? ['user'],
      isActive: isActive ?? true,
      phoneNumber: phoneNumber ?? '+1234567890',
      dateOfBirth: dateOfBirth ?? DateTime(1990, 1, 1),
      locale: locale ?? 'en_US',
      timezone: timezone ?? 'UTC',
      createdAt: createdAt ?? baseCreatedAt,
      updatedAt: updatedAt ?? baseUpdatedAt,
    );
  }

  /// Creates a minimal UserEntity for testing
  static UserEntity createMinimalUser({String? id}) {
    return UserEntity(
      id: id ?? 'minimal-user',
      email: 'minimal@example.com',
      createdAt: baseCreatedAt,
      updatedAt: baseUpdatedAt,
    );
  }

  /// Creates multiple users for batch testing
  static List<UserEntity> createUsers(int count, {String? prefix}) {
    return List.generate(count, (index) {
      final idPrefix = prefix ?? 'user';
      return createUser(
        id: '$idPrefix-$index',
        email: '$idPrefix$index@example.com',
        displayName: 'User $index',
      );
    });
  }

  /// Sample JSON data for testing serialization
  static Map<String, dynamic> get sampleUserJson => {
        'id': 'json-user-123',
        'email': 'json@example.com',
        'displayName': 'JSON User',
        'photoUrl': 'https://example.com/json-photo.jpg',
        'isEmailVerified': true,
        'metadata': {'source': 'json'},
        'roles': ['user', 'admin'],
        'isActive': true,
        'phoneNumber': '+9876543210',
        'dateOfBirth': '1985-05-15T00:00:00.000Z',
        'locale': 'es_ES',
        'timezone': 'Europe/Madrid',
        'createdAt': '2023-01-01T12:00:00.000Z',
        'updatedAt': '2023-01-01T12:30:00.000Z',
      };

  /// Invalid JSON data for testing error handling
  static Map<String, dynamic> get invalidUserJson => {
        // Missing required fields
        'displayName': 'Invalid User',
        'email': null, // Invalid null email
        'roles': 'not-a-list', // Invalid roles type
      };

  /// Sample configuration for datasource factories
  static Map<String, dynamic> get firebaseConfig => {
        'collection': 'test_users',
      };

  static Map<String, dynamic> get restConfig => {
        'baseUrl': 'https://test-api.example.com',
        'endpoint': 'users',
        'timeout': 5000,
        'headers': {
          'Authorization': 'Bearer test-token',
          'Content-Type': 'application/json',
        },
      };

  /// Environment variables for testing factory
  static Map<String, String> get testEnvironment => {
        'DATASOURCE_TYPE': 'firebase',
        'FIREBASE_USERS_COLLECTION': 'test_users',
        'REST_API_BASE_URL': 'https://test-api.example.com',
        'REST_API_KEY': 'test-api-key',
        'REST_USERS_ENDPOINT': 'users',
        'REST_API_TIMEOUT': '10000',
      };

  /// Creates test DataSourceException instances
  static DataSourceException createNetworkException([String? message]) {
    return DataSourceException.network(
      message ?? 'Test network error',
      originalError: Exception('Network failure'),
    );
  }

  static EntityNotFoundException createNotFoundException([String? id]) {
    return EntityNotFoundException(
      entityType: 'User',
      identifier: id ?? 'not-found-id',
    );
  }

  static ValidationException createValidationException([Map<String, List<String>>? errors]) {
    return ValidationException(
      validationErrors: errors ?? {
        'email': ['Email is required', 'Email format is invalid'],
        'displayName': ['Display name is too short'],
      },
    );
  }

  /// Cache keys for testing
  static String getUserCacheKey(String id) => 'getById:$id';
  static String getEmailCacheKey(String email) => 'getByEmail:$email';
  static String getQueryCacheKey(Map<String, dynamic> params) {
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final paramString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return 'getAll:query:$paramString';
  }

  /// Mock responses for REST API testing
  static Map<String, dynamic> get restSuccessResponse => {
        'success': true,
        'data': sampleUserJson,
      };

  static Map<String, dynamic> get restErrorResponse => {
        'success': false,
        'error': {
          'code': 'USER_NOT_FOUND',
          'message': 'User not found',
        },
      };

  static Map<String, dynamic> get restUsersListResponse => {
        'success': true,
        'data': {
          'users': [sampleUserJson],
          'total': 1,
          'page': 1,
          'limit': 10,
        },
      };

  /// Firestore mock data
  static Map<String, dynamic> get firestoreUserData => {
        'email': 'firestore@example.com',
        'displayName': 'Firestore User',
        'photoUrl': 'https://example.com/firestore-photo.jpg',
        'isEmailVerified': true,
        'metadata': {'source': 'firestore'},
        'roles': ['user'],
        'isActive': true,
        'phoneNumber': '+1111111111',
        'dateOfBirth': null,
        'locale': 'en_US',
        'timezone': 'UTC',
        // Note: createdAt and updatedAt will be Timestamp objects in Firestore
      };

  /// Timing utilities for testing
  static Duration get shortDelay => const Duration(milliseconds: 100);
  static Duration get longDelay => const Duration(seconds: 1);

  /// Common test assertions
  static void assertUserEquals(UserEntity expected, UserEntity actual) {
    expect(actual.id, equals(expected.id));
    expect(actual.email, equals(expected.email));
    expect(actual.displayName, equals(expected.displayName));
    expect(actual.photoUrl, equals(expected.photoUrl));
    expect(actual.isEmailVerified, equals(expected.isEmailVerified));
    expect(actual.metadata, equals(expected.metadata));
    expect(actual.roles, equals(expected.roles));
    expect(actual.isActive, equals(expected.isActive));
    expect(actual.phoneNumber, equals(expected.phoneNumber));
    expect(actual.dateOfBirth, equals(expected.dateOfBirth));
    expect(actual.locale, equals(expected.locale));
    expect(actual.timezone, equals(expected.timezone));
    expect(actual.createdAt, equals(expected.createdAt));
    expect(actual.updatedAt, equals(expected.updatedAt));
  }

  /// Performance testing utilities
  static Future<Duration> measureExecutionTime(Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Generates large datasets for performance testing
  static List<UserEntity> generateLargeUserSet(int size) {
    return List.generate(size, (index) => createUser(
      id: 'perf-user-$index',
      email: 'perf$index@example.com',
      displayName: 'Performance User $index',
    ));
  }
}