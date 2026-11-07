import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'users_contract.dart';
import '../../utils/typedefs/datasource_typedefs.dart';
import 'implementations/implementations.dart';

/// Enumeration of available datasource types
enum DataSourceType {
  firebase,
  rest,
  mock,
}

/// Factory class for creating [UsersDataSource] instances
///
/// This factory provides a centralized way to create different
/// implementations of the users datasource based on configuration
class UsersDataSourceFactory {
  /// Creates a [UsersDataSource] instance based on the specified type
  ///
  /// [type] - The type of datasource to create
  /// [config] - Configuration parameters specific to each datasource type
  ///
  /// ## Firebase Configuration
  /// ```dart
  /// {
  ///   'firestore': FirebaseFirestore.instance, // Optional
  ///   'collection': 'users', // Optional, defaults to 'users'
  /// }
  /// ```
  ///
  /// ## REST Configuration
  /// ```dart
  /// {
  ///   'dio': Dio(), // Optional, will create default if not provided
  ///   'baseUrl': 'https://api.example.com', // Required
  ///   'endpoint': 'users', // Optional, defaults to 'users'
  ///   'headers': {}, // Optional additional headers
  ///   'timeout': 30000, // Optional timeout in milliseconds
  /// }
  /// ```
  static UsersDataSource create({
    required DataSourceType type,
    DataSourceConfig? config,
  }) {
    final configMap = config ?? <String, dynamic>{};

    switch (type) {
      case DataSourceType.firebase:
        return _createFirebaseDataSource(configMap);

      case DataSourceType.rest:
        return _createRestDataSource(configMap);

      case DataSourceType.mock:
        return _createMockDataSource(configMap);
    }
  }

  /// Creates a Firebase datasource instance
  static FirebaseUserDataSource _createFirebaseDataSource(
    DataSourceConfig config,
  ) {
    final firestore = config['firestore'] as FirebaseFirestore?;
    final collectionName = config['collection'] as String? ?? 'users';

    return FirebaseUserDataSource(
      firestore: firestore,
      collectionName: collectionName,
    );
  }

  /// Creates a REST API datasource instance
  static RestUserDataSource _createRestDataSource(
    DataSourceConfig config,
  ) {
    final baseUrl = config['baseUrl'] as String?;
    if (baseUrl == null || baseUrl.isEmpty) {
      throw ArgumentError('baseUrl is required for REST datasource');
    }

    Dio dio = config['dio'] as Dio? ?? Dio();

    // Configure Dio with additional settings from config
    final headers = config['headers'] as Map<String, String>?;
    final timeout = config['timeout'] as int?;

    if (headers != null) {
      dio.options.headers.addAll(headers);
    }

    if (timeout != null) {
      dio.options.connectTimeout = Duration(milliseconds: timeout);
      dio.options.receiveTimeout = Duration(milliseconds: timeout);
      dio.options.sendTimeout = Duration(milliseconds: timeout);
    }

    final endpoint = config['endpoint'] as String? ?? 'users';

    return RestUserDataSource(
      dio: dio,
      baseUrl: baseUrl,
      usersEndpoint: endpoint,
    );
  }

  /// Creates a mock datasource instance for testing
  static UsersDataSource _createMockDataSource(
    DataSourceConfig config,
  ) {
    // For now, return a Firebase datasource as mock
    // In a real implementation, you would create a MockUserDataSource
    return _createFirebaseDataSource(config);
  }

  /// Creates a Firebase datasource with default configuration
  static UsersDataSource createFirebase({
    FirebaseFirestore? firestore,
    String collectionName = 'users',
  }) {
    return create(
      type: DataSourceType.firebase,
      config: {
        'firestore': firestore,
        'collection': collectionName,
      },
    );
  }

  /// Creates a REST datasource with default configuration
  static UsersDataSource createRest({
    required String baseUrl,
    Dio? dio,
    String endpoint = 'users',
    Map<String, String>? headers,
    int? timeoutMs,
  }) {
    return create(
      type: DataSourceType.rest,
      config: {
        'dio': dio,
        'baseUrl': baseUrl,
        'endpoint': endpoint,
        'headers': headers,
        'timeout': timeoutMs,
      },
    );
  }

  /// Creates a datasource based on environment configuration
  ///
  /// This method reads configuration from environment variables
  /// or configuration files to determine which datasource to create
  static UsersDataSource createFromEnvironment({
    Map<String, String>? environment,
  }) {
    final env = environment ?? const <String, String>{};

    // Check for Firebase configuration
    final useFirebase = env['DATASOURCE_TYPE']?.toLowerCase() == 'firebase' ||
        env['FIREBASE_PROJECT_ID'] != null;

    if (useFirebase) {
      return createFirebase(
        collectionName: env['FIREBASE_USERS_COLLECTION'] ?? 'users',
      );
    }

    // Check for REST configuration
    final restBaseUrl = env['REST_API_BASE_URL'];
    if (restBaseUrl != null && restBaseUrl.isNotEmpty) {
      final headers = <String, String>{};
      final apiKey = env['REST_API_KEY'];
      if (apiKey != null) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final timeout = int.tryParse(env['REST_API_TIMEOUT'] ?? '');

      return createRest(
        baseUrl: restBaseUrl,
        endpoint: env['REST_USERS_ENDPOINT'] ?? 'users',
        headers: headers.isNotEmpty ? headers : null,
        timeoutMs: timeout,
      );
    }

    // Default to Firebase if no specific configuration found
    return createFirebase();
  }

  /// Validates configuration for a specific datasource type
  static void validateConfig(DataSourceType type, DataSourceConfig config) {
    switch (type) {
      case DataSourceType.firebase:
        _validateFirebaseConfig(config);
        break;

      case DataSourceType.rest:
        _validateRestConfig(config);
        break;

      case DataSourceType.mock:
        // Mock datasource doesn't require specific validation
        break;
    }
  }

  /// Validates Firebase configuration
  static void _validateFirebaseConfig(DataSourceConfig config) {
    // Firebase configuration is mostly optional since it can use defaults
    final collectionName = config['collection'] as String?;
    if (collectionName != null && collectionName.isEmpty) {
      throw ArgumentError('Firebase collection name cannot be empty');
    }
  }

  /// Validates REST configuration
  static void _validateRestConfig(DataSourceConfig config) {
    final baseUrl = config['baseUrl'] as String?;
    if (baseUrl == null || baseUrl.isEmpty) {
      throw ArgumentError('baseUrl is required for REST datasource');
    }

    try {
      Uri.parse(baseUrl);
    } catch (e) {
      throw ArgumentError('Invalid baseUrl format: $baseUrl');
    }

    final endpoint = config['endpoint'] as String?;
    if (endpoint != null && endpoint.isEmpty) {
      throw ArgumentError('Endpoint cannot be empty');
    }

    final timeout = config['timeout'];
    if (timeout != null && timeout is! int) {
      throw ArgumentError('Timeout must be an integer (milliseconds)');
    }
  }

  /// Returns available datasource types
  static List<DataSourceType> get availableTypes => DataSourceType.values;

  /// Returns default configuration for a datasource type
  static DataSourceConfig getDefaultConfig(DataSourceType type) {
    switch (type) {
      case DataSourceType.firebase:
        return {
          'collection': 'users',
        };

      case DataSourceType.rest:
        return {
          'endpoint': 'users',
          'timeout': 30000,
        };

      case DataSourceType.mock:
        return <String, dynamic>{};
    }
  }

  /// Creates multiple datasource instances for different environments
  ///
  /// Useful for applications that need to support multiple data sources
  /// simultaneously (e.g., local cache + remote API)
  static Map<String, UsersDataSource> createMultiple(
    Map<String, ({DataSourceType type, DataSourceConfig? config})> configs,
  ) {
    final datasources = <String, UsersDataSource>{};

    for (final entry in configs.entries) {
      final name = entry.key;
      final config = entry.value;

      datasources[name] = create(
        type: config.type,
        config: config.config,
      );
    }

    return datasources;
  }
}