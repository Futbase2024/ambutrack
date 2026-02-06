import 'package:flutter_test/flutter_test.dart';
import 'package:ambutrack_core/ambutrack_core.dart';

void main() {
  group('DataSourceException', () {
    test('should create basic exception', () {
      const message = 'Test error occurred';
      final exception = DataSourceException(message: message);

      expect(exception.message, equals(message));
      expect(exception.code, isNull);
    });

    test('should create exception with code', () {
      const message = 'Test error';
      const code = 'TEST_ERROR';
      final exception = DataSourceException(message: message, code: code);

      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
    });

    test('should create network exception', () {
      final exception = DataSourceException.network('Network failed');

      expect(exception.message, equals('Network failed'));
      expect(exception.code, equals('NETWORK_ERROR'));
    });

    test('should create authentication exception', () {
      final exception = DataSourceException.authentication('Auth failed');

      expect(exception.message, equals('Auth failed'));
      expect(exception.code, equals('AUTH_ERROR'));
    });

    test('should create not found exception', () {
      final exception = DataSourceException.notFound('Resource not found');

      expect(exception.message, equals('Resource not found'));
      expect(exception.code, equals('NOT_FOUND'));
    });

    test('should implement Exception interface', () {
      final exception = DataSourceException(message: 'Test');
      expect(exception, isA<Exception>());
    });
  });

  group('EntityNotFoundException', () {
    test('should create with entity type and identifier', () {
      const entityType = 'User';
      const identifier = 'user-123';

      final exception = EntityNotFoundException(
        entityType: entityType,
        identifier: identifier,
      );

      expect(exception.entityType, equals(entityType));
      expect(exception.identifier, equals(identifier));
      expect(exception.message, contains('User'));
      expect(exception.message, contains('user-123'));
      expect(exception.code, equals('ENTITY_NOT_FOUND'));
    });

    test('should inherit from DataSourceException', () {
      final exception = EntityNotFoundException(
        entityType: 'User',
        identifier: 'test-id',
      );

      expect(exception, isA<DataSourceException>());
      expect(exception, isA<Exception>());
    });
  });

  group('EntityAlreadyExistsException', () {
    test('should create with entity type and identifier', () {
      const entityType = 'User';
      const identifier = 'existing-user';

      final exception = EntityAlreadyExistsException(
        entityType: entityType,
        identifier: identifier,
      );

      expect(exception.entityType, equals(entityType));
      expect(exception.identifier, equals(identifier));
      expect(exception.message, contains('User'));
      expect(exception.message, contains('existing-user'));
      expect(exception.code, equals('ENTITY_ALREADY_EXISTS'));
    });
  });

  group('ValidationException', () {
    test('should create with validation errors', () {
      final validationErrors = {
        'email': ['Email is required'],
        'name': ['Name is too short'],
      };

      final exception = ValidationException(validationErrors: validationErrors);

      expect(exception.validationErrors, equals(validationErrors));
      expect(exception.message, equals('Validation failed'));
      expect(exception.code, equals('VALIDATION_ERROR'));
    });

    test('should create single field validation exception', () {
      final exception = ValidationException.singleField(
        'email',
        'Email is required',
      );

      expect(exception.validationErrors, equals({
        'email': ['Email is required']
      }));
    });
  });
}