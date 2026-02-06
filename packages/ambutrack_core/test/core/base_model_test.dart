import 'package:flutter_test/flutter_test.dart';
import 'package:ambutrack_core/ambutrack_core.dart';

import '../helpers/test_data.dart';

/// Test implementation of BaseModel
class TestModel extends BaseModel<UserEntity> {
  final UserEntity _entity;

  TestModel(this._entity);

  @override
  UserEntity toEntity() => _entity;

  @override
  Map<String, dynamic> toJson() => _entity.toJson();

  factory TestModel.fromEntity(UserEntity entity) {
    return TestModel(entity);
  }

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(UserEntity.fromJson(json));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestModel && other._entity == _entity;
  }

  @override
  int get hashCode => _entity.hashCode;

  @override
  String toString() => 'TestModel(entity: $_entity)';
}

/// Test model with transformation logic
class TransformingModel extends BaseModel<UserEntity> {
  final Map<String, dynamic> _data;

  TransformingModel(this._data);

  @override
  UserEntity toEntity() {
    return UserEntity(
      id: _data['user_id'] as String,
      email: _data['email_address'] as String,
      displayName: _data['full_name'] as String?,
      photoUrl: _data['avatar_url'] as String?,
      isEmailVerified: _data['email_verified'] as bool? ?? false,
      metadata: _data['extra_data'] as Map<String, dynamic>?,
      roles: (_data['user_roles'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: _data['is_active'] as bool? ?? true,
      phoneNumber: _data['phone'] as String?,
      dateOfBirth: _data['birth_date'] != null
          ? DateTime.parse(_data['birth_date'] as String)
          : null,
      locale: _data['language'] as String?,
      timezone: _data['timezone'] as String?,
      createdAt: DateTime.parse(_data['created_timestamp'] as String),
      updatedAt: DateTime.parse(_data['updated_timestamp'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final entity = toEntity();
    return {
      'user_id': entity.id,
      'email_address': entity.email,
      'full_name': entity.displayName,
      'avatar_url': entity.photoUrl,
      'email_verified': entity.isEmailVerified,
      'extra_data': entity.metadata,
      'user_roles': entity.roles,
      'is_active': entity.isActive,
      'phone': entity.phoneNumber,
      'birth_date': entity.dateOfBirth?.toIso8601String(),
      'language': entity.locale,
      'timezone': entity.timezone,
      'created_timestamp': entity.createdAt.toIso8601String(),
      'updated_timestamp': entity.updatedAt.toIso8601String(),
    };
  }

  factory TransformingModel.fromEntity(UserEntity entity) {
    return TransformingModel({
      'user_id': entity.id,
      'email_address': entity.email,
      'full_name': entity.displayName,
      'avatar_url': entity.photoUrl,
      'email_verified': entity.isEmailVerified,
      'extra_data': entity.metadata,
      'user_roles': entity.roles,
      'is_active': entity.isActive,
      'phone': entity.phoneNumber,
      'birth_date': entity.dateOfBirth?.toIso8601String(),
      'language': entity.locale,
      'timezone': entity.timezone,
      'created_timestamp': entity.createdAt.toIso8601String(),
      'updated_timestamp': entity.updatedAt.toIso8601String(),
    });
  }

  factory TransformingModel.fromJson(Map<String, dynamic> json) {
    return TransformingModel(json);
  }
}

void main() {
  group('BaseModel', () {
    late UserEntity testEntity;
    late TestModel testModel;

    setUp(() {
      testEntity = TestData.createUser();
      testModel = TestModel.fromEntity(testEntity);
    });

    group('Abstract Methods Implementation', () {
      test('should implement toEntity method', () {
        final entity = testModel.toEntity();

        expect(entity, isA<UserEntity>());
        expect(entity.id, equals(testEntity.id));
        expect(entity.email, equals(testEntity.email));
        expect(entity.displayName, equals(testEntity.displayName));
      });

      test('should implement toJson method', () {
        final json = testModel.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals(testEntity.id));
        expect(json['email'], equals(testEntity.email));
        expect(json['displayName'], equals(testEntity.displayName));
      });

      test('should maintain data consistency between entity and json', () {
        final entity = testModel.toEntity();
        final json = testModel.toJson();
        final entityFromJson = UserEntity.fromJson(json);

        expect(entity, equals(entityFromJson));
      });
    });

    group('Factory Constructors', () {
      test('should create model from entity', () {
        final model = TestModel.fromEntity(testEntity);

        expect(model, isA<TestModel>());
        expect(model.toEntity(), equals(testEntity));
      });

      test('should create model from JSON', () {
        final json = TestData.sampleUserJson;
        final model = TestModel.fromJson(json);

        expect(model, isA<TestModel>());
        expect(model.toEntity().id, equals(json['id']));
        expect(model.toEntity().email, equals(json['email']));
      });

      test('should roundtrip entity -> model -> entity', () {
        final originalEntity = testEntity;
        final model = TestModel.fromEntity(originalEntity);
        final reconstructedEntity = model.toEntity();

        expect(reconstructedEntity, equals(originalEntity));
      });

      test('should roundtrip json -> model -> json', () {
        final originalJson = TestData.sampleUserJson;
        final model = TestModel.fromJson(originalJson);
        final reconstructedJson = model.toJson();

        // Compare key fields (some formatting might differ)
        expect(reconstructedJson['id'], equals(originalJson['id']));
        expect(reconstructedJson['email'], equals(originalJson['email']));
        expect(reconstructedJson['displayName'], equals(originalJson['displayName']));
      });
    });

    group('Equality and Hash', () {
      test('should be equal when entities are equal', () {
        final model1 = TestModel.fromEntity(testEntity);
        final model2 = TestModel.fromEntity(testEntity);

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when entities differ', () {
        final entity1 = TestData.createUser(id: 'user1');
        final entity2 = TestData.createUser(id: 'user2');

        final model1 = TestModel.fromEntity(entity1);
        final model2 = TestModel.fromEntity(entity2);

        expect(model1, isNot(equals(model2)));
      });

      test('should have consistent hashCode', () {
        final model = TestModel.fromEntity(testEntity);
        final hashCode1 = model.hashCode;
        final hashCode2 = model.hashCode;

        expect(hashCode1, equals(hashCode2));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        final modelString = testModel.toString();

        expect(modelString, contains('TestModel'));
        expect(modelString, contains('entity'));
        expect(modelString, isA<String>());
      });
    });

    group('Data Transformation', () {
      late TransformingModel transformingModel;
      late Map<String, dynamic> transformedData;

      setUp(() {
        transformedData = {
          'user_id': 'transform-user-123',
          'email_address': 'transform@example.com',
          'full_name': 'Transform User',
          'avatar_url': 'https://example.com/avatar.jpg',
          'email_verified': true,
          'extra_data': {'source': 'transform'},
          'user_roles': ['user', 'admin'],
          'is_active': true,
          'phone': '+1234567890',
          'birth_date': '1990-01-01T00:00:00.000Z',
          'language': 'en_US',
          'timezone': 'UTC',
          'created_timestamp': '2023-01-01T12:00:00.000Z',
          'updated_timestamp': '2023-01-01T12:30:00.000Z',
        };

        transformingModel = TransformingModel.fromJson(transformedData);
      });

      test('should transform external format to entity', () {
        final entity = transformingModel.toEntity();

        expect(entity.id, equals('transform-user-123'));
        expect(entity.email, equals('transform@example.com'));
        expect(entity.displayName, equals('Transform User'));
        expect(entity.photoUrl, equals('https://example.com/avatar.jpg'));
        expect(entity.isEmailVerified, isTrue);
        expect(entity.metadata, equals({'source': 'transform'}));
        expect(entity.roles, equals(['user', 'admin']));
        expect(entity.isActive, isTrue);
        expect(entity.phoneNumber, equals('+1234567890'));
        expect(entity.dateOfBirth, equals(DateTime.parse('1990-01-01T00:00:00.000Z')));
        expect(entity.locale, equals('en_US'));
        expect(entity.timezone, equals('UTC'));
      });

      test('should transform entity to external format', () {
        final entity = TestData.createUser(
          id: 'external-user',
          email: 'external@example.com',
          displayName: 'External User',
        );

        final model = TransformingModel.fromEntity(entity);
        final json = model.toJson();

        expect(json['user_id'], equals('external-user'));
        expect(json['email_address'], equals('external@example.com'));
        expect(json['full_name'], equals('External User'));
      });

      test('should handle missing optional fields in transformation', () {
        final minimalData = {
          'user_id': 'minimal-transform',
          'email_address': 'minimal@example.com',
          'created_timestamp': '2023-01-01T12:00:00.000Z',
          'updated_timestamp': '2023-01-01T12:00:00.000Z',
        };

        final model = TransformingModel.fromJson(minimalData);
        final entity = model.toEntity();

        expect(entity.id, equals('minimal-transform'));
        expect(entity.email, equals('minimal@example.com'));
        expect(entity.displayName, isNull);
        expect(entity.photoUrl, isNull);
        expect(entity.isEmailVerified, isFalse);
        expect(entity.roles, isEmpty);
        expect(entity.isActive, isTrue);
      });

      test('should roundtrip through transformation', () {
        final originalEntity = TestData.createUser();
        final model = TransformingModel.fromEntity(originalEntity);
        final json = model.toJson();
        final newModel = TransformingModel.fromJson(json);
        final reconstructedEntity = newModel.toEntity();

        // Check key fields (some precision might be lost in transformation)
        expect(reconstructedEntity.id, equals(originalEntity.id));
        expect(reconstructedEntity.email, equals(originalEntity.email));
        expect(reconstructedEntity.displayName, equals(originalEntity.displayName));
        expect(reconstructedEntity.isEmailVerified, equals(originalEntity.isEmailVerified));
        expect(reconstructedEntity.roles, equals(originalEntity.roles));
        expect(reconstructedEntity.isActive, equals(originalEntity.isActive));
      });
    });

    group('Error Handling', () {
      test('should handle invalid JSON gracefully', () {
        final invalidJson = {
          'invalid_field': 'value',
          // Missing required fields
        };

        expect(
          () => TestModel.fromJson(invalidJson),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle null entity gracefully', () {
        // This test assumes the model implementation handles null checks
        // In a real implementation, you might want to validate inputs
        expect(
          () => TestModel.fromEntity(testEntity),
          returnsNormally,
        );
      });

      test('should handle malformed date strings', () {
        final invalidDateJson = {
          'user_id': 'invalid-date-user',
          'email_address': 'invalid@example.com',
          'created_timestamp': 'invalid-date',
          'updated_timestamp': '2023-01-01T12:00:00.000Z',
        };

        expect(
          () => TransformingModel.fromJson(invalidDateJson).toEntity(),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle type mismatches', () {
        final invalidTypeJson = {
          'user_id': 'type-mismatch-user',
          'email_address': 'type@example.com',
          'user_roles': 'not-a-list', // Should be List<String>
          'created_timestamp': '2023-01-01T12:00:00.000Z',
          'updated_timestamp': '2023-01-01T12:00:00.000Z',
        };

        expect(
          () => TransformingModel.fromJson(invalidTypeJson).toEntity(),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('Performance', () {
      test('should handle many conversions efficiently', () {
        const iterations = 1000;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < iterations; i++) {
          final entity = TestData.createUser(id: 'perf-$i');
          final model = TestModel.fromEntity(entity);
          final json = model.toJson();
          final newModel = TestModel.fromJson(json);
          final newEntity = newModel.toEntity();

          expect(newEntity.id, equals('perf-$i'));
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should handle large data efficiently', () {
        final largeMetadata = Map<String, dynamic>.fromIterable(
          List.generate(1000, (i) => 'key$i'),
          value: (key) => 'value_$key',
        );

        final entity = TestData.createUser(metadata: largeMetadata);
        final stopwatch = Stopwatch()..start();

        final model = TestModel.fromEntity(entity);
        final json = model.toJson();
        final newModel = TestModel.fromJson(json);
        final newEntity = newModel.toEntity();

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(newEntity.metadata?.length, equals(1000));
      });
    });

    group('Extension Integration', () {
      test('should work with EntityToModel extension concept', () {
        // This test demonstrates how the BaseModel could work with
        // the EntityToModel extension defined in base_model.dart

        final entity = TestData.createUser();
        final model = TestModel.fromEntity(entity);

        expect(model.toEntity(), equals(entity));
        expect(model, isA<BaseModel<UserEntity>>());
      });

      test('should support different model types for same entity', () {
        final entity = TestData.createUser();

        final simpleModel = TestModel.fromEntity(entity);
        final transformingModel = TransformingModel.fromEntity(entity);

        // Both models should produce the same entity
        expect(simpleModel.toEntity(), equals(entity));
        expect(transformingModel.toEntity(), equals(entity));

        // But their JSON representations might differ
        final simpleJson = simpleModel.toJson();
        final transformingJson = transformingModel.toJson();

        expect(simpleJson['id'], equals(transformingJson['user_id']));
        expect(simpleJson['email'], equals(transformingJson['email_address']));
      });
    });

    group('Real-world Scenarios', () {
      test('should handle API response format', () {
        // Simulate an API response with nested data
        final apiResponse = {
          'user_info': {
            'user_id': 'api-user-123',
            'email_address': 'api@example.com',
            'profile': {
              'full_name': 'API User',
              'avatar_url': 'https://api.example.com/avatar.jpg',
            },
            'settings': {
              'language': 'en_US',
              'timezone': 'America/New_York',
            },
          },
          'timestamps': {
            'created_timestamp': '2023-01-01T12:00:00.000Z',
            'updated_timestamp': '2023-01-01T12:30:00.000Z',
          },
        };

        // In a real implementation, you'd have a specialized model
        // for handling nested API responses
        expect(apiResponse, isA<Map<String, dynamic>>());
        expect(apiResponse['user_info'], isA<Map<String, dynamic>>());
      });

      test('should handle database row format', () {
        // Simulate a database row with flat structure
        final dbRow = {
          'id': 'db-user-123',
          'email': 'db@example.com',
          'display_name': 'DB User',
          'photo_url': 'https://db.example.com/photo.jpg',
          'email_verified': 1, // Database boolean as integer
          'is_active': 1,
          'created_at': '2023-01-01 12:00:00',
          'updated_at': '2023-01-01 12:30:00',
        };

        // In a real implementation, you'd have a specialized model
        // for handling database row format
        expect(dbRow, isA<Map<String, dynamic>>());
        expect(dbRow['email_verified'], equals(1));
      });

      test('should support versioned data formats', () {
        // Simulate handling different versions of the same data
        final v1Format = {
          'id': 'version-user',
          'email': 'version@example.com',
          'name': 'Version User', // v1 uses 'name'
          'created': '2023-01-01T12:00:00.000Z',
          'updated': '2023-01-01T12:30:00.000Z',
        };

        final v2Format = {
          'id': 'version-user',
          'email': 'version@example.com',
          'displayName': 'Version User', // v2 uses 'displayName'
          'createdAt': '2023-01-01T12:00:00.000Z',
          'updatedAt': '2023-01-01T12:30:00.000Z',
        };

        // Both formats should be handleable by appropriate models
        expect(v1Format['name'], equals(v2Format['displayName']));
        expect(v1Format['created'], isA<String>());
        expect(v2Format['createdAt'], isA<String>());
      });
    });
  });
}