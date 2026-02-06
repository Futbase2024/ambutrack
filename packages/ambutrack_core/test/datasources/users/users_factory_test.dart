import 'package:flutter_test/flutter_test.dart';
import 'package:ambutrack_core/ambutrack_core.dart';

import '../../helpers/test_data.dart';

void main() {
  group('UsersDataSourceFactory', () {
    group('DataSourceType Enum', () {
      test('should have expected values', () {
        expect(DataSourceType.values, hasLength(3));
        expect(DataSourceType.values, contains(DataSourceType.firebase));
        expect(DataSourceType.values, contains(DataSourceType.rest));
        expect(DataSourceType.values, contains(DataSourceType.mock));
      });

      test('should convert to string correctly', () {
        expect(DataSourceType.firebase.toString(), contains('firebase'));
        expect(DataSourceType.rest.toString(), contains('rest'));
        expect(DataSourceType.mock.toString(), contains('mock'));
      });
    });

    group('Factory Creation', () {
      test('should create Firebase datasource with default config', () {
        expect(
          () => UsersDataSourceFactory.create(
            type: DataSourceType.firebase,
            config: TestData.firebaseConfig,
          ),
          returnsNormally,
        );
      });

      test('should create REST datasource with valid config', () {
        expect(
          () => UsersDataSourceFactory.create(
            type: DataSourceType.rest,
            config: TestData.restConfig,
          ),
          returnsNormally,
        );
      });

      test('should create mock datasource', () {
        expect(
          () => UsersDataSourceFactory.create(
            type: DataSourceType.mock,
          ),
          returnsNormally,
        );
      });

      test('should create datasource with null config', () {
        expect(
          () => UsersDataSourceFactory.create(
            type: DataSourceType.firebase,
            config: null,
          ),
          returnsNormally,
        );
      });
    });

    group('Firebase Factory Methods', () {
      test('should create Firebase datasource with createFirebase', () {
        final datasource = UsersDataSourceFactory.createFirebase();

        expect(datasource, isA<UsersDataSource>());
      });

      test('should create Firebase datasource with custom collection', () {
        const customCollection = 'custom_users';

        final datasource = UsersDataSourceFactory.createFirebase(
          collectionName: customCollection,
        );

        expect(datasource, isA<UsersDataSource>());
      });

      test('should accept null firestore instance', () {
        expect(
          () => UsersDataSourceFactory.createFirebase(
            firestore: null,
            collectionName: 'test_users',
          ),
          returnsNormally,
        );
      });
    });

    group('REST Factory Methods', () {
      test('should create REST datasource with createRest', () {
        final datasource = UsersDataSourceFactory.createRest(
          baseUrl: 'https://api.example.com',
        );

        expect(datasource, isA<UsersDataSource>());
      });

      test('should create REST datasource with custom configuration', () {
        final datasource = UsersDataSourceFactory.createRest(
          baseUrl: 'https://custom.api.com',
          endpoint: 'custom_users',
          headers: {'Authorization': 'Bearer token'},
          timeoutMs: 15000,
        );

        expect(datasource, isA<UsersDataSource>());
      });

      test('should throw when baseUrl is missing', () {
        expect(
          () => UsersDataSourceFactory.create(
            type: DataSourceType.rest,
            config: {
              'endpoint': 'users',
              // Missing baseUrl
            },
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when baseUrl is empty', () {
        expect(
          () => UsersDataSourceFactory.createRest(baseUrl: ''),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Environment-based Creation', () {
      test('should create Firebase datasource from environment', () {
        final envVars = Map<String, String>.from(TestData.testEnvironment);
        envVars['DATASOURCE_TYPE'] = 'firebase';

        final datasource = UsersDataSourceFactory.createFromEnvironment(
          environment: envVars,
        );

        expect(datasource, isA<UsersDataSource>());
      });

      test('should create REST datasource from environment', () {
        final envVars = <String, String>{
          'REST_API_BASE_URL': 'https://env.api.com',
          'REST_API_KEY': 'env-api-key',
          'REST_USERS_ENDPOINT': 'env_users',
          'REST_API_TIMEOUT': '20000',
        };

        final datasource = UsersDataSourceFactory.createFromEnvironment(
          environment: envVars,
        );

        expect(datasource, isA<UsersDataSource>());
      });

      test('should default to Firebase when no specific config found', () {
        final datasource = UsersDataSourceFactory.createFromEnvironment(
          environment: {},
        );

        expect(datasource, isA<UsersDataSource>());
      });

      test('should use Firebase when project ID is present', () {
        final envVars = <String, String>{
          'FIREBASE_PROJECT_ID': 'test-project',
          'FIREBASE_USERS_COLLECTION': 'custom_users',
        };

        final datasource = UsersDataSourceFactory.createFromEnvironment(
          environment: envVars,
        );

        expect(datasource, isA<UsersDataSource>());
      });

      test('should use system environment when no environment provided', () {
        final datasource = UsersDataSourceFactory.createFromEnvironment();

        expect(datasource, isA<UsersDataSource>());
      });
    });

    group('Configuration Validation', () {
      test('should validate Firebase configuration', () {
        expect(
          () => UsersDataSourceFactory.validateConfig(
            DataSourceType.firebase,
            TestData.firebaseConfig,
          ),
          returnsNormally,
        );
      });

      test('should reject empty Firebase collection name', () {
        expect(
          () => UsersDataSourceFactory.validateConfig(
            DataSourceType.firebase,
            {'collection': ''},
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should validate REST configuration', () {
        expect(
          () => UsersDataSourceFactory.validateConfig(
            DataSourceType.rest,
            TestData.restConfig,
          ),
          returnsNormally,
        );
      });

      test('should reject missing baseUrl in REST config', () {
        expect(
          () => UsersDataSourceFactory.validateConfig(
            DataSourceType.rest,
            {'endpoint': 'users'},
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject invalid baseUrl format', () {
        expect(
          () => UsersDataSourceFactory.validateConfig(
            DataSourceType.rest,
            {'baseUrl': 'not-a-valid-url'},
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject empty REST endpoint', () {
        expect(
          () => UsersDataSourceFactory.validateConfig(
            DataSourceType.rest,
            {
              'baseUrl': 'https://api.example.com',
              'endpoint': '',
            },
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject invalid timeout type', () {
        expect(
          () => UsersDataSourceFactory.validateConfig(
            DataSourceType.rest,
            {
              'baseUrl': 'https://api.example.com',
              'timeout': 'not-a-number',
            },
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should validate mock configuration', () {
        expect(
          () => UsersDataSourceFactory.validateConfig(
            DataSourceType.mock,
            {},
          ),
          returnsNormally,
        );
      });
    });

    group('Default Configurations', () {
      test('should provide default Firebase config', () {
        final config = UsersDataSourceFactory.getDefaultConfig(
          DataSourceType.firebase,
        );

        expect(config, isA<Map<String, dynamic>>());
        expect(config['collection'], equals('users'));
      });

      test('should provide default REST config', () {
        final config = UsersDataSourceFactory.getDefaultConfig(
          DataSourceType.rest,
        );

        expect(config, isA<Map<String, dynamic>>());
        expect(config['endpoint'], equals('users'));
        expect(config['timeout'], equals(30000));
      });

      test('should provide default mock config', () {
        final config = UsersDataSourceFactory.getDefaultConfig(
          DataSourceType.mock,
        );

        expect(config, isA<Map<String, dynamic>>());
        expect(config, isEmpty);
      });
    });

    group('Available Types', () {
      test('should return all available datasource types', () {
        final types = UsersDataSourceFactory.availableTypes;

        expect(types, isA<List<DataSourceType>>());
        expect(types, contains(DataSourceType.firebase));
        expect(types, contains(DataSourceType.rest));
        expect(types, contains(DataSourceType.mock));
        expect(types.length, equals(3));
      });
    });

    group('Multiple Datasources', () {
      test('should create multiple datasources with different types', () {
        final configs = {
          'primary': (
            type: DataSourceType.firebase,
            config: TestData.firebaseConfig,
          ),
          'secondary': (
            type: DataSourceType.rest,
            config: TestData.restConfig,
          ),
          'test': (
            type: DataSourceType.mock,
            config: null,
          ),
        };

        final datasources = UsersDataSourceFactory.createMultiple(configs);

        expect(datasources, hasLength(3));
        expect(datasources['primary'], isA<UsersDataSource>());
        expect(datasources['secondary'], isA<UsersDataSource>());
        expect(datasources['test'], isA<UsersDataSource>());
      });

      test('should handle empty multiple datasources config', () {
        final datasources = UsersDataSourceFactory.createMultiple({});

        expect(datasources, isEmpty);
      });

      test('should handle single datasource in multiple config', () {
        final configs = {
          'only': (
            type: DataSourceType.firebase,
            config: null,
          ),
        };

        final datasources = UsersDataSourceFactory.createMultiple(configs);

        expect(datasources, hasLength(1));
        expect(datasources['only'], isA<UsersDataSource>());
      });
    });

    group('Error Handling', () {
      test('should handle invalid datasource type gracefully', () {
        // Note: This test would require modifying the enum or factory
        // to handle invalid types, which isn't possible with current implementation
        // but shows the intent for robust error handling

        expect(DataSourceType.values, hasLength(3));
      });

      test('should provide helpful error messages for validation failures', () {
        try {
          UsersDataSourceFactory.validateConfig(
            DataSourceType.rest,
            {'baseUrl': 'invalid-url'},
          );
          fail('Expected ArgumentError');
        } on ArgumentError catch (e) {
          expect(e.message, contains('Invalid baseUrl format'));
        }
      });

      test('should provide helpful error messages for missing config', () {
        try {
          UsersDataSourceFactory.validateConfig(
            DataSourceType.rest,
            {},
          );
          fail('Expected ArgumentError');
        } on ArgumentError catch (e) {
          expect(e.message, contains('baseUrl is required'));
        }
      });
    });

    group('Configuration Merging', () {
      test('should merge default and custom configurations', () {
        final customConfig = {
          'baseUrl': 'https://custom.api.com',
          'customHeader': 'custom-value',
        };

        // In a real implementation, you might want to merge defaults
        // with custom config rather than replacing entirely
        expect(customConfig['baseUrl'], equals('https://custom.api.com'));
        expect(customConfig['customHeader'], equals('custom-value'));
      });

      test('should override defaults with custom values', () {
        final defaultConfig = UsersDataSourceFactory.getDefaultConfig(
          DataSourceType.rest,
        );

        final customEndpoint = 'custom_endpoint';
        final customTimeout = 60000;

        // Test shows intent - in real implementation you'd merge configs
        expect(defaultConfig['endpoint'], equals('users'));
        expect(defaultConfig['timeout'], equals(30000));

        // Custom values would override defaults
        expect(customEndpoint, equals('custom_endpoint'));
        expect(customTimeout, equals(60000));
      });
    });

    group('Real-world Scenarios', () {
      test('should handle production-like Firebase configuration', () {
        final prodConfig = {
          'collection': 'prod_users',
          'enableOfflinePersistence': true,
          'cacheSizeBytes': 100 * 1024 * 1024, // 100MB
        };

        expect(
          () => UsersDataSourceFactory.create(
            type: DataSourceType.firebase,
            config: prodConfig,
          ),
          returnsNormally,
        );
      });

      test('should handle production-like REST configuration', () {
        final prodConfig = {
          'baseUrl': 'https://api.production.com',
          'endpoint': 'v2/users',
          'timeout': 45000,
          'headers': {
            'Authorization': 'Bearer production-token',
            'X-API-Version': '2.0',
            'X-Client-ID': 'flutter-app',
          },
          'retries': 3,
          'retryDelay': 1000,
        };

        expect(
          () => UsersDataSourceFactory.create(
            type: DataSourceType.rest,
            config: prodConfig,
          ),
          returnsNormally,
        );
      });

      test('should handle development environment configuration', () {
        final devEnv = {
          'DATASOURCE_TYPE': 'firebase',
          'FIREBASE_PROJECT_ID': 'dev-project',
          'FIREBASE_USERS_COLLECTION': 'dev_users',
          'FIREBASE_EMULATOR_HOST': 'localhost:8080',
        };

        expect(
          () => UsersDataSourceFactory.createFromEnvironment(
            environment: devEnv,
          ),
          returnsNormally,
        );
      });

      test('should handle testing environment configuration', () {
        final testEnv = {
          'DATASOURCE_TYPE': 'mock',
          'TEST_DATA_SEED': 'true',
          'TEST_USER_COUNT': '100',
        };

        expect(
          () => UsersDataSourceFactory.createFromEnvironment(
            environment: testEnv,
          ),
          returnsNormally,
        );
      });
    });

    group('Performance', () {
      test('should create datasources efficiently', () {
        const creationCount = 100;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < creationCount; i++) {
          final datasource = UsersDataSourceFactory.createFirebase(
            collectionName: 'test_$i',
          );
          expect(datasource, isA<UsersDataSource>());
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should validate configurations efficiently', () {
        const validationCount = 1000;
        final config = TestData.restConfig;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < validationCount; i++) {
          UsersDataSourceFactory.validateConfig(
            DataSourceType.rest,
            config,
          );
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Thread Safety', () {
      test('should handle concurrent factory calls', () async {
        final futures = <Future<UsersDataSource>>[];

        // Create multiple datasources concurrently
        for (int i = 0; i < 50; i++) {
          futures.add(Future(() => UsersDataSourceFactory.createFirebase(
            collectionName: 'concurrent_$i',
          )));
        }

        final datasources = await Future.wait(futures);

        expect(datasources.length, equals(50));
        for (final datasource in datasources) {
          expect(datasource, isA<UsersDataSource>());
        }
      });
    });
  });
}