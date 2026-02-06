import 'package:flutter_test/flutter_test.dart';
import 'package:ambutrack_core/ambutrack_core.dart';

import '../../helpers/test_data.dart';

void main() {
  group('UserEntity', () {
    late UserEntity testUser;

    setUp(() {
      testUser = TestData.createUser();
    });

    group('Constructor', () {
      test('should create a user with all fields', () {
        final user = TestData.createUser();

        expect(user.id, equals('test-user-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('Test User'));
        expect(user.photoUrl, equals('https://example.com/photo.jpg'));
        expect(user.isEmailVerified, isTrue);
        expect(user.metadata, equals({'source': 'test'}));
        expect(user.roles, equals(['user']));
        expect(user.isActive, isTrue);
        expect(user.phoneNumber, equals('+1234567890'));
        expect(user.dateOfBirth, equals(DateTime(1990, 1, 1)));
        expect(user.locale, equals('en_US'));
        expect(user.timezone, equals('UTC'));
        expect(user.createdAt, equals(TestData.baseCreatedAt));
        expect(user.updatedAt, equals(TestData.baseUpdatedAt));
      });

      test('should create a minimal user with required fields only', () {
        final user = TestData.createMinimalUser();

        expect(user.id, equals('minimal-user'));
        expect(user.email, equals('minimal@example.com'));
        expect(user.displayName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.isEmailVerified, isFalse);
        expect(user.metadata, isNull);
        expect(user.roles, isEmpty);
        expect(user.isActive, isTrue);
        expect(user.phoneNumber, isNull);
        expect(user.dateOfBirth, isNull);
        expect(user.locale, isNull);
        expect(user.timezone, isNull);
      });

      test('should have default values for optional fields', () {
        final user = UserEntity(
          id: 'default-user',
          email: 'default@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(user.displayName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.isEmailVerified, isFalse);
        expect(user.metadata, isNull);
        expect(user.roles, isEmpty);
        expect(user.isActive, isTrue);
        expect(user.phoneNumber, isNull);
        expect(user.dateOfBirth, isNull);
        expect(user.locale, isNull);
        expect(user.timezone, isNull);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testUser.toJson();

        expect(json['id'], equals('test-user-123'));
        expect(json['email'], equals('test@example.com'));
        expect(json['displayName'], equals('Test User'));
        expect(json['photoUrl'], equals('https://example.com/photo.jpg'));
        expect(json['isEmailVerified'], isTrue);
        expect(json['metadata'], equals({'source': 'test'}));
        expect(json['roles'], equals(['user']));
        expect(json['isActive'], isTrue);
        expect(json['phoneNumber'], equals('+1234567890'));
        expect(json['dateOfBirth'], equals('1990-01-01T00:00:00.000'));
        expect(json['locale'], equals('en_US'));
        expect(json['timezone'], equals('UTC'));
        expect(json['createdAt'], equals('2023-01-01T12:00:00.000'));
        expect(json['updatedAt'], equals('2023-01-01T12:30:00.000'));
      });

      test('should serialize minimal user to JSON correctly', () {
        final user = TestData.createMinimalUser();
        final json = user.toJson();

        expect(json['id'], equals('minimal-user'));
        expect(json['email'], equals('minimal@example.com'));
        expect(json['displayName'], isNull);
        expect(json['photoUrl'], isNull);
        expect(json['isEmailVerified'], isFalse);
        expect(json['metadata'], isNull);
        expect(json['roles'], isEmpty);
        expect(json['isActive'], isTrue);
        expect(json['phoneNumber'], isNull);
        expect(json['dateOfBirth'], isNull);
        expect(json['locale'], isNull);
        expect(json['timezone'], isNull);
      });

      test('should handle null dateOfBirth in JSON serialization', () {
        final user = UserEntity(
          id: 'test-null-date',
          email: 'test@example.com',
          dateOfBirth: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final json = user.toJson();

        expect(json['dateOfBirth'], isNull);
      });
    });

    group('JSON Deserialization', () {
      test('should deserialize from JSON correctly', () {
        final json = TestData.sampleUserJson;
        final user = UserEntity.fromJson(json);

        expect(user.id, equals('json-user-123'));
        expect(user.email, equals('json@example.com'));
        expect(user.displayName, equals('JSON User'));
        expect(user.photoUrl, equals('https://example.com/json-photo.jpg'));
        expect(user.isEmailVerified, isTrue);
        expect(user.metadata, equals({'source': 'json'}));
        expect(user.roles, equals(['user', 'admin']));
        expect(user.isActive, isTrue);
        expect(user.phoneNumber, equals('+9876543210'));
        expect(user.dateOfBirth, equals(DateTime.parse('1985-05-15T00:00:00.000Z')));
        expect(user.locale, equals('es_ES'));
        expect(user.timezone, equals('Europe/Madrid'));
        expect(user.createdAt, equals(DateTime.parse('2023-01-01T12:00:00.000Z')));
        expect(user.updatedAt, equals(DateTime.parse('2023-01-01T12:30:00.000Z')));
      });

      test('should handle missing optional fields in JSON', () {
        final json = {
          'id': 'partial-user',
          'email': 'partial@example.com',
          'createdAt': '2023-01-01T12:00:00.000Z',
          'updatedAt': '2023-01-01T12:30:00.000Z',
        };

        final user = UserEntity.fromJson(json);

        expect(user.id, equals('partial-user'));
        expect(user.email, equals('partial@example.com'));
        expect(user.displayName, isNull);
        expect(user.isEmailVerified, isFalse);
        expect(user.roles, isEmpty);
        expect(user.isActive, isTrue);
      });

      test('should handle null dateOfBirth in JSON deserialization', () {
        final json = Map<String, dynamic>.from(TestData.sampleUserJson);
        json['dateOfBirth'] = null;

        final user = UserEntity.fromJson(json);
        expect(user.dateOfBirth, isNull);
      });

      test('should throw when required fields are missing', () {
        final invalidJson = {
          'displayName': 'Invalid User',
          // Missing id, email, createdAt, updatedAt
        };

        expect(
          () => UserEntity.fromJson(invalidJson),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final updatedUser = testUser.copyWith(
          displayName: 'Updated Name',
          isEmailVerified: false,
          roles: ['admin', 'user'],
        );

        expect(updatedUser.id, equals(testUser.id));
        expect(updatedUser.email, equals(testUser.email));
        expect(updatedUser.displayName, equals('Updated Name'));
        expect(updatedUser.isEmailVerified, isFalse);
        expect(updatedUser.roles, equals(['admin', 'user']));
        expect(updatedUser.photoUrl, equals(testUser.photoUrl));
        expect(updatedUser.createdAt, equals(testUser.createdAt));
      });

      test('should preserve original fields when not specified', () {
        final updatedUser = testUser.copyWith(displayName: 'New Name');

        expect(updatedUser.email, equals(testUser.email));
        expect(updatedUser.photoUrl, equals(testUser.photoUrl));
        expect(updatedUser.isEmailVerified, equals(testUser.isEmailVerified));
        expect(updatedUser.metadata, equals(testUser.metadata));
        expect(updatedUser.roles, equals(testUser.roles));
        expect(updatedUser.isActive, equals(testUser.isActive));
      });

      test('should preserve fields when null is passed to copyWith', () {
        final updatedUser = testUser.copyWith(
          displayName: null,
          photoUrl: null,
          metadata: null,
        );

        // copyWith with null preserves original values
        expect(updatedUser.displayName, equals(testUser.displayName));
        expect(updatedUser.photoUrl, equals(testUser.photoUrl));
        expect(updatedUser.metadata, equals(testUser.metadata));
      });
    });

    group('Equality', () {
      test('should be equal when all fields are the same', () {
        final user1 = TestData.createUser();
        final user2 = TestData.createUser();

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final user1 = TestData.createUser();
        final user2 = TestData.createUser(displayName: 'Different Name');

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when id differs', () {
        final user1 = TestData.createUser(id: 'user1');
        final user2 = TestData.createUser(id: 'user2');

        expect(user1, isNot(equals(user2)));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        final userString = testUser.toString();

        expect(userString, contains('UserEntity'));
        expect(userString, contains('test-user-123'));
        expect(userString, contains('test@example.com'));
        expect(userString, contains('Test User'));
        expect(userString, contains('true'));
        expect(userString, contains('[user]'));
      });

      test('should handle null values in toString', () {
        final minimalUser = TestData.createMinimalUser();
        final userString = minimalUser.toString();

        expect(userString, contains('UserEntity'));
        expect(userString, contains('minimal-user'));
        expect(userString, contains('minimal@example.com'));
        expect(userString, isNot(throwsException));
      });
    });

    group('Business Logic', () {
      test('should validate email format conceptually', () {
        // This test demonstrates that we can create users with any email
        // In a real implementation, you might want email validation
        final validEmails = [
          'user@example.com',
          'test.email+tag@domain.co.uk',
          'simple@domain.org',
        ];

        for (final email in validEmails) {
          expect(
            () => TestData.createUser(email: email),
            isNot(throwsException),
          );
        }
      });

      test('should handle role management', () {
        final user = TestData.createUser(roles: ['user']);

        // Test adding roles conceptually
        final adminUser = user.copyWith(roles: [...user.roles, 'admin']);
        expect(adminUser.roles, contains('admin'));
        expect(adminUser.roles, contains('user'));

        // Test removing roles conceptually
        final basicUser = adminUser.copyWith(
          roles: adminUser.roles.where((role) => role != 'admin').toList(),
        );
        expect(basicUser.roles, isNot(contains('admin')));
        expect(basicUser.roles, contains('user'));
      });

      test('should handle user activation states', () {
        final activeUser = TestData.createUser(isActive: true);
        final inactiveUser = activeUser.copyWith(isActive: false);

        expect(activeUser.isActive, isTrue);
        expect(inactiveUser.isActive, isFalse);
      });

      test('should handle timestamp updates', () {
        final originalTime = DateTime(2023, 1, 1, 10, 0, 0);
        final updateTime = DateTime(2023, 1, 1, 11, 0, 0);

        final user = TestData.createUser(
          createdAt: originalTime,
          updatedAt: originalTime,
        );

        final updatedUser = user.copyWith(updatedAt: updateTime);

        expect(updatedUser.createdAt, equals(originalTime));
        expect(updatedUser.updatedAt, equals(updateTime));
        expect(updatedUser.updatedAt.isAfter(updatedUser.createdAt), isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle empty roles list', () {
        final user = TestData.createUser(roles: []);
        expect(user.roles, isEmpty);

        final jsonUser = UserEntity.fromJson(user.toJson());
        expect(jsonUser.roles, isEmpty);
      });

      test('should handle empty metadata', () {
        final user = TestData.createUser(metadata: {});
        expect(user.metadata, isEmpty);

        final jsonUser = UserEntity.fromJson(user.toJson());
        expect(jsonUser.metadata, isEmpty);
      });

      test('should handle large metadata objects', () {
        final largeMetadata = Map<String, dynamic>.fromIterable(
          List.generate(100, (i) => 'key$i'),
          value: (key) => 'value_$key',
        );

        final user = TestData.createUser(metadata: largeMetadata);
        expect(user.metadata?.length, equals(100));

        final jsonUser = UserEntity.fromJson(user.toJson());
        expect(jsonUser.metadata?.length, equals(100));
      });

      test('should handle special characters in fields', () {
        final user = TestData.createUser(
          displayName: 'José María O\'Brien',
          phoneNumber: '+1 (555) 123-4567',
          locale: 'es_MX',
        );

        final json = user.toJson();
        final deserializedUser = UserEntity.fromJson(json);

        expect(deserializedUser.displayName, equals('José María O\'Brien'));
        expect(deserializedUser.phoneNumber, equals('+1 (555) 123-4567'));
        expect(deserializedUser.locale, equals('es_MX'));
      });

      test('should handle future dates', () {
        final futureDate = DateTime.now().add(const Duration(days: 365));
        final user = TestData.createUser(
          dateOfBirth: futureDate,
          createdAt: futureDate,
          updatedAt: futureDate,
        );

        expect(user.dateOfBirth, equals(futureDate));
        expect(user.createdAt, equals(futureDate));
        expect(user.updatedAt, equals(futureDate));

        final jsonUser = UserEntity.fromJson(user.toJson());
        expect(jsonUser.dateOfBirth, equals(futureDate));
      });
    });

    group('Performance', () {
      test('should handle serialization/deserialization efficiently', () {
        const iterations = 1000;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < iterations; i++) {
          final user = TestData.createUser(id: 'perf-user-$i');
          final json = user.toJson();
          final deserializedUser = UserEntity.fromJson(json);
          expect(deserializedUser.id, equals('perf-user-$i'));
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
      });

      test('should handle large role lists efficiently', () {
        final largeRoleList = List.generate(100, (i) => 'role_$i');
        final user = TestData.createUser(roles: largeRoleList);

        expect(user.roles.length, equals(100));

        final jsonUser = UserEntity.fromJson(user.toJson());
        expect(jsonUser.roles.length, equals(100));
        expect(jsonUser.roles, equals(largeRoleList));
      });
    });
  });
}