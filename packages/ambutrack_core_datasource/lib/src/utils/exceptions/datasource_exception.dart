/// Base exception class for all datasource-related errors
///
/// All datasource implementations should throw this exception
/// or its subclasses when errors occur
class DataSourceException implements Exception {
  /// Human-readable error message
  final String message;

  /// Optional error code for programmatic handling
  final String? code;

  /// The original error that caused this exception
  final dynamic originalError;

  /// Stack trace from the original error
  final StackTrace? stackTrace;

  /// Additional context information
  final Map<String, dynamic>? context;

  /// Creates a new [DataSourceException]
  const DataSourceException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    this.context,
  });

  /// Creates a generic datasource exception
  factory DataSourceException.generic(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return DataSourceException(
      message: message,
      code: 'GENERIC_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates a network-related exception
  factory DataSourceException.network(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return DataSourceException(
      message: message,
      code: 'NETWORK_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates an authentication-related exception
  factory DataSourceException.authentication(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return DataSourceException(
      message: message,
      code: 'AUTH_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates an authorization-related exception
  factory DataSourceException.authorization(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return DataSourceException(
      message: message,
      code: 'AUTHORIZATION_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates a not found exception
  factory DataSourceException.notFound(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return DataSourceException(
      message: message,
      code: 'NOT_FOUND',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates a validation exception
  factory DataSourceException.validation(
    String message, {
    Map<String, dynamic>? validationErrors,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return DataSourceException(
      message: message,
      code: 'VALIDATION_ERROR',
      context: validationErrors,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates a conflict exception (e.g., duplicate key)
  factory DataSourceException.conflict(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return DataSourceException(
      message: message,
      code: 'CONFLICT',
      originalError: originalError,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates a timeout exception
  factory DataSourceException.timeout(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return DataSourceException(
      message: message,
      code: 'TIMEOUT',
      originalError: originalError,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates a rate limit exception
  factory DataSourceException.rateLimit(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return DataSourceException(
      message: message,
      code: 'RATE_LIMIT',
      originalError: originalError,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates a serialization/deserialization exception
  factory DataSourceException.serialization(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return DataSourceException(
      message: message,
      code: 'SERIALIZATION_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('DataSourceException: $message');

    if (code != null) {
      buffer.write(' (Code: $code)');
    }

    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }

    if (context != null && context!.isNotEmpty) {
      buffer.write('\nContext: $context');
    }

    return buffer.toString();
  }
}

/// Exception thrown when a required entity is not found
class EntityNotFoundException extends DataSourceException {
  /// The type of entity that was not found
  final String entityType;

  /// The identifier that was searched for
  final String identifier;

  const EntityNotFoundException({
    required this.entityType,
    required this.identifier,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: '$entityType with identifier "$identifier" was not found',
          code: 'ENTITY_NOT_FOUND',
        );
}

/// Exception thrown when trying to create an entity that already exists
class EntityAlreadyExistsException extends DataSourceException {
  /// The type of entity that already exists
  final String entityType;

  /// The identifier that conflicts
  final String identifier;

  const EntityAlreadyExistsException({
    required this.entityType,
    required this.identifier,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: '$entityType with identifier "$identifier" already exists',
          code: 'ENTITY_ALREADY_EXISTS',
        );
}

/// Exception thrown when validation fails
class ValidationException extends DataSourceException {
  /// Map of field names to validation error messages
  final Map<String, List<String>> validationErrors;

  const ValidationException({
    required this.validationErrors,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: 'Validation failed',
          code: 'VALIDATION_ERROR',
          context: validationErrors,
        );

  /// Creates a single field validation exception
  factory ValidationException.singleField(
    String field,
    String error, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ValidationException(
      validationErrors: {
        field: [error]
      },
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}