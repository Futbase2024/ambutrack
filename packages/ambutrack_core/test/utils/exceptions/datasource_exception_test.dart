import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ambutrack_core/ambutrack_core.dart';

void main() {
  group('DataSourceException', () {
    group('Constructor', () {
      test('should create exception with all fields', () {
        const message = 'Test error occurred';
        const code = 'TEST_ERROR';
        final originalError = Exception('Original error');
        final stackTrace = StackTrace.current;
        final context = {'key': 'value'};

        final exception = DataSourceException(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
          context: context,
        );

        expect(exception.message, equals(message));
        expect(exception.code, equals(code));
        expect(exception.originalError, equals(originalError));
        expect(exception.stackTrace, equals(stackTrace));
        expect(exception.context, equals(context));
      });

      test('should create exception with minimal fields', () {
        const message = 'Minimal error';

        final exception = DataSourceException(message: message);

        expect(exception.message, equals(message));
        expect(exception.code, isNull);
        expect(exception.originalError, isNull);
        expect(exception.stackTrace, isNull);
        expect(exception.context, isNull);
      });
    });

    group('Factory Constructors', () {
      test('should create generic exception', () {
        const message = 'Generic error';
        final originalError = Exception('Original');

        final exception = DataSourceException.generic(
          message,
          originalError: originalError,
        );

        expect(exception.message, equals(message));
        expect(exception.code, equals('GENERIC_ERROR'));
        expect(exception.originalError, equals(originalError));
      });

      test('should create network exception', () {
        const message = 'Network failed';
        final originalError = Exception('Connection lost');

        final exception = DataSourceException.network(
          message,
          originalError: originalError,
        );

        expect(exception.message, equals(message));
        expect(exception.code, equals('NETWORK_ERROR'));
        expect(exception.originalError, equals(originalError));
      });

      test('should create authentication exception', () {
        const message = 'Auth failed';

        final exception = DataSourceException.authentication(message);

        expect(exception.message, equals(message));
        expect(exception.code, equals('AUTH_ERROR'));
      });

      test('should create authorization exception', () {
        const message = 'Access denied';

        final exception = DataSourceException.authorization(message);

        expect(exception.message, equals(message));
        expect(exception.code, equals('AUTHORIZATION_ERROR'));
      });

      test('should create not found exception', () {
        const message = 'Resource not found';

        final exception = DataSourceException.notFound(message);

        expect(exception.message, equals(message));
        expect(exception.code, equals('NOT_FOUND'));
      });

      test('should create validation exception', () {
        const message = 'Validation failed';
        final validationErrors = {'email': 'Required', 'name': 'Too short'};

        final exception = DataSourceException.validation(
          message,
          validationErrors: validationErrors,
        );

        expect(exception.message, equals(message));
        expect(exception.code, equals('VALIDATION_ERROR'));
        expect(exception.context, equals(validationErrors));
      });

      test('should create conflict exception', () {
        const message = 'Resource conflict';

        final exception = DataSourceException.conflict(message);

        expect(exception.message, equals(message));
        expect(exception.code, equals('CONFLICT'));
      });

      test('should create timeout exception', () {
        const message = 'Operation timed out';

        final exception = DataSourceException.timeout(message);

        expect(exception.message, equals(message));
        expect(exception.code, equals('TIMEOUT'));
      });

      test('should create rate limit exception', () {
        const message = 'Rate limit exceeded';

        final exception = DataSourceException.rateLimit(message);

        expect(exception.message, equals(message));
        expect(exception.code, equals('RATE_LIMIT'));
      });

      test('should create serialization exception', () {
        const message = 'JSON parsing failed';

        final exception = DataSourceException.serialization(message);

        expect(exception.message, equals(message));
        expect(exception.code, equals('SERIALIZATION_ERROR'));
      });
    });

    group('toString', () {
      test('should format exception with all fields', () {
        final exception = DataSourceException(
          message: 'Test error',
          code: 'TEST_CODE',
          originalError: Exception('Original'),
          context: {'field': 'value'},
        );

        final string = exception.toString();

        expect(string, contains('DataSourceException: Test error'));
        expect(string, contains('(Code: TEST_CODE)'));
        expect(string, contains('Original error: Exception: Original'));
        expect(string, contains('Context: {field: value}'));
      });

      test('should format exception with minimal fields', () {
        final exception = DataSourceException(message: 'Simple error');

        final string = exception.toString();

        expect(string, equals('DataSourceException: Simple error'));
      });

      test('should handle null context', () {
        final exception = DataSourceException(
          message: 'Error',
          code: 'CODE',
          originalError: Exception('Original'),
          context: null,
        );

        final string = exception.toString();

        expect(string, contains('DataSourceException: Error'));
        expect(string, contains('(Code: CODE)'));
        expect(string, contains('Original error:'));
        expect(string, isNot(contains('Context:')));
      });

      test('should handle empty context', () {
        final exception = DataSourceException(
          message: 'Error',
          context: {},
        );

        final string = exception.toString();

        expect(string, contains('DataSourceException: Error'));
        expect(string, isNot(contains('Context:')));
      });
    });

    group('Error Hierarchy', () {
      test('should implement Exception interface', () {
        final exception = DataSourceException(message: 'Test');

        expect(exception, isA<Exception>());
      });

      test('should be catchable as Exception', () {
        bool caught = false;

        try {
          throw DataSourceException(message: 'Test error');
        } on Exception {
          caught = true;
        }

        expect(caught, isTrue);
      });

      test('should be catchable as DataSourceException', () {
        bool caught = false;

        try {
          throw DataSourceException.network('Network error');
        } on DataSourceException catch (e) {
          caught = true;
          expect(e.code, equals('NETWORK_ERROR'));
        }

        expect(caught, isTrue);
      });
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
      expect(exception.message, equals('User with identifier "user-123" was not found'));
      expect(exception.code, equals('ENTITY_NOT_FOUND'));
    });

    test('should include original error and stack trace', () {
      final originalError = Exception('Database error');
      final stackTrace = StackTrace.current;

      final exception = EntityNotFoundException(
        entityType: 'Product',
        identifier: 'prod-456',
        originalError: originalError,
        stackTrace: stackTrace,
      );

      expect(exception.originalError, equals(originalError));
      expect(exception.stackTrace, equals(stackTrace));
    });

    test('should inherit from DataSourceException', () {
      final exception = EntityNotFoundException(
        entityType: 'User',
        identifier: 'test-id',
      );

      expect(exception, isA<DataSourceException>());
      expect(exception, isA<Exception>());
    });

    test('should be catchable as parent types', () {
      bool caughtAsDataSource = false;
      bool caughtAsEntity = false;

      try {
        throw EntityNotFoundException(
          entityType: 'User',
          identifier: 'test-id',
        );
      } on EntityNotFoundException {
        caughtAsEntity = true;
      } on DataSourceException {
        caughtAsDataSource = true;
      }

      expect(caughtAsEntity, isTrue);
      expect(caughtAsDataSource, isFalse); // Should catch more specific first
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
      expect(exception.message, equals('User with identifier "existing-user" already exists'));
      expect(exception.code, equals('ENTITY_ALREADY_EXISTS'));
    });

    test('should inherit from DataSourceException', () {
      final exception = EntityAlreadyExistsException(
        entityType: 'Product',
        identifier: 'existing-product',
      );

      expect(exception, isA<DataSourceException>());
      expect(exception, isA<Exception>());
    });

    test('should handle special characters in identifiers', () {
      const identifier = 'user@domain.com#123';

      final exception = EntityAlreadyExistsException(
        entityType: 'User',
        identifier: identifier,
      );

      expect(exception.identifier, equals(identifier));
      expect(exception.message, contains('"$identifier"'));
    });
  });

  group('ValidationException', () {
    test('should create with validation errors map', () {
      final validationErrors = {
        'email': ['Email is required', 'Email format is invalid'],
        'name': ['Name is too short'],
        'age': ['Age must be positive'],
      };

      final exception = ValidationException(validationErrors: validationErrors);

      expect(exception.validationErrors, equals(validationErrors));
      expect(exception.message, equals('Validation failed'));
      expect(exception.code, equals('VALIDATION_ERROR'));
      expect(exception.context, equals(validationErrors));
    });

    test('should create single field validation exception', () {
      final exception = ValidationException.singleField(
        'email',
        'Email is required',
      );

      expect(exception.validationErrors, equals({
        'email': ['Email is required']
      }));
      expect(exception.message, equals('Validation failed'));
      expect(exception.code, equals('VALIDATION_ERROR'));
    });

    test('should inherit from DataSourceException', () {
      final exception = ValidationException(validationErrors: {});

      expect(exception, isA<DataSourceException>());
      expect(exception, isA<Exception>());
    });

    test('should handle empty validation errors', () {
      final exception = ValidationException(validationErrors: {});

      expect(exception.validationErrors, isEmpty);
      expect(exception.context, isEmpty);
    });

    test('should handle multiple errors per field', () {
      final exception = ValidationException(validationErrors: {
        'password': [
          'Password is required',
          'Password must be at least 8 characters',
          'Password must contain uppercase letter',
          'Password must contain number',
        ],
      });

      expect(exception.validationErrors['password']?.length, equals(4));
    });
  });

  group('Error Handling Patterns', () {
    test('should support error pattern matching', () {
      final exceptions = [
        DataSourceException.network('Network error'),
        EntityNotFoundException(entityType: 'User', identifier: 'id'),
        ValidationException.singleField('email', 'Invalid email'),
        DataSourceException.timeout('Request timeout'),
      ];

      final results = <String>[];

      for (final exception in exceptions) {
        if (exception is EntityNotFoundException) {
          results.add('not_found');
        } else if (exception is ValidationException) {
          results.add('validation');
        } else if (exception.code == 'NETWORK_ERROR') {
          results.add('network');
        } else if (exception.code == 'TIMEOUT') {
          results.add('timeout');
        } else {
          results.add('unknown');
        }
      }

      expect(results, equals(['network', 'not_found', 'validation', 'timeout']));
    });

    test('should support code-based error handling', () {
      final exceptions = [
        DataSourceException.authentication('Auth failed'),
        DataSourceException.authorization('Access denied'),
        DataSourceException.conflict('Duplicate key'),
        DataSourceException.rateLimit('Too many requests'),
      ];

      final retryable = <bool>[];

      for (final exception in exceptions) {
        switch (exception.code) {
          case 'NETWORK_ERROR':
          case 'TIMEOUT':
          case 'RATE_LIMIT':
            retryable.add(true);
            break;
          case 'AUTH_ERROR':
          case 'AUTHORIZATION_ERROR':
          case 'VALIDATION_ERROR':
          case 'CONFLICT':
            retryable.add(false);
            break;
          default:
            retryable.add(false);
        }
      }

      expect(retryable, equals([false, false, false, true]));
    });

    test('should support error context examination', () {
      final validationException = ValidationException(validationErrors: {
        'email': ['Invalid format'],
        'age': ['Must be positive'],
      });

      final conflictException = DataSourceException.conflict(
        'Duplicate entry',
        context: {'field': 'email', 'value': 'duplicate@example.com'},
      );

      expect(validationException.context?.containsKey('email'), isTrue);
      expect(conflictException.context?['field'], equals('email'));
    });
  });

  group('Real-world Scenarios', () {
    test('should handle database constraint violations', () {
      final exception = DataSourceException.conflict(
        'Unique constraint violation',
        originalError: Exception('UNIQUE constraint failed: users.email'),
        context: {
          'table': 'users',
          'column': 'email',
          'value': 'duplicate@example.com',
        },
      );

      expect(exception.code, equals('CONFLICT'));
      expect(exception.context?['table'], equals('users'));
      expect(exception.message, contains('constraint violation'));
    });

    test('should handle API rate limiting', () {
      final exception = DataSourceException.rateLimit(
        'API rate limit exceeded',
        originalError: Exception('429 Too Many Requests'),
        context: {
          'limit': 1000,
          'window': '1 hour',
          'reset_time': DateTime.now().add(Duration(minutes: 30)).toIso8601String(),
        },
      );

      expect(exception.code, equals('RATE_LIMIT'));
      expect(exception.context?['limit'], equals(1000));
    });

    test('should handle network timeouts', () {
      final exception = DataSourceException.timeout(
        'Request timeout after 30 seconds',
        originalError: TimeoutException('Connection timeout', Duration(seconds: 30)),
        context: {
          'timeout_duration': 30,
          'endpoint': '/api/users',
          'retry_attempt': 3,
        },
      );

      expect(exception.code, equals('TIMEOUT'));
      expect(exception.context?['timeout_duration'], equals(30));
    });

    test('should handle authentication failures', () {
      final exception = DataSourceException.authentication(
        'Invalid credentials',
        originalError: Exception('401 Unauthorized'),
        context: {
          'username': 'user@example.com',
          'login_attempts': 3,
          'locked_until': DateTime.now().add(Duration(minutes: 15)).toIso8601String(),
        },
      );

      expect(exception.code, equals('AUTH_ERROR'));
      expect(exception.context?['login_attempts'], equals(3));
    });

    test('should handle complex validation scenarios', () {
      final exception = ValidationException(validationErrors: {
        'email': ['Email is required', 'Email format is invalid'],
        'password': [
          'Password is required',
          'Password must be at least 8 characters',
          'Password must contain an uppercase letter',
          'Password must contain a number',
          'Password must contain a special character',
        ],
        'confirmPassword': ['Passwords do not match'],
        'terms': ['You must accept the terms and conditions'],
      });

      expect(exception.validationErrors.length, equals(4));
      expect(exception.validationErrors['password']?.length, equals(5));
      expect(exception.context, equals(exception.validationErrors));
    });
  });

  group('Performance and Memory', () {
    test('should handle many exceptions efficiently', () {
      const exceptionCount = 1000;
      final exceptions = <DataSourceException>[];
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < exceptionCount; i++) {
        exceptions.add(DataSourceException.generic(
          'Error $i',
          originalError: Exception('Original $i'),
          context: {'index': i},
        ));
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(exceptions.length, equals(exceptionCount));
    });

    test('should handle large context objects', () {
      final largeContext = Map<String, dynamic>.fromIterable(
        List.generate(1000, (i) => 'key$i'),
        value: (key) => 'value_$key',
      );

      final exception = DataSourceException.validation(
        'Large validation error',
        validationErrors: largeContext,
      );

      expect(exception.context?.length, equals(1000));
      expect(exception.toString().length, greaterThan(1000));
    });

    test('should handle stack trace efficiently', () {
      final stackTrace = StackTrace.current;

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        final exception = DataSourceException(
          message: 'Test $i',
          stackTrace: stackTrace,
        );
        expect(exception.stackTrace, equals(stackTrace));
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });
}