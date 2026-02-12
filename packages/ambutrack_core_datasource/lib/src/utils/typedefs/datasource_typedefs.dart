import '../exceptions/datasource_exception.dart';

/// Type alias for results that can either be successful or contain an error
typedef DataSourceResult<T> = ({T? data, DataSourceException? error});

/// Type alias for a function that creates entities from JSON
typedef EntityFromJson<T> = T Function(Map<String, dynamic> json);

/// Type alias for a function that converts entities to JSON
typedef EntityToJson<T> = Map<String, dynamic> Function(T entity);

/// Type alias for query filters in datasource operations
typedef QueryFilter = Map<String, dynamic>;

/// Type alias for sorting specifications
typedef SortSpecification = ({String field, SortOrder order});

/// Enumeration for sort orders
enum SortOrder {
  ascending,
  descending,
}

/// Type alias for pagination parameters
typedef PaginationParams = ({int? limit, int? offset, String? cursor});

/// Type alias for search parameters
typedef SearchParams = ({
  String query,
  List<String>? fields,
  int? limit,
  bool caseSensitive,
});

/// Type alias for batch operation results
typedef BatchResult<T> = ({
  List<T> successful,
  List<BatchError> failed,
});

/// Represents an error in a batch operation
class BatchError {
  /// The index of the item that failed in the original batch
  final int index;

  /// The error that occurred
  final DataSourceException error;

  /// The original item that failed (optional)
  final dynamic originalItem;

  const BatchError({
    required this.index,
    required this.error,
    this.originalItem,
  });

  @override
  String toString() {
    return 'BatchError(index: $index, error: $error)';
  }
}

/// Type alias for configuration maps
typedef DataSourceConfig = Map<String, dynamic>;

/// Type alias for metadata maps
typedef EntityMetadata = Map<String, dynamic>;

/// Type alias for audit information
typedef AuditInfo = ({
  String? createdBy,
  String? updatedBy,
  DateTime createdAt,
  DateTime updatedAt,
  String? version,
});

/// Type alias for cache keys
typedef CacheKey = String;

/// Type alias for cache entries
typedef CacheEntry<T> = ({
  T data,
  DateTime timestamp,
  Duration? ttl,
});

/// Type alias for event listeners in real-time operations
typedef DataSourceEventListener<T> = void Function(DataSourceEvent<T> event);

/// Represents an event in a datasource operation
class DataSourceEvent<T> {
  /// The type of event
  final DataSourceEventType type;

  /// The data associated with the event
  final T? data;

  /// The ID of the entity involved in the event
  final String? entityId;

  /// Additional metadata for the event
  final Map<String, dynamic>? metadata;

  /// Timestamp when the event occurred
  final DateTime timestamp;

  const DataSourceEvent({
    required this.type,
    this.data,
    this.entityId,
    this.metadata,
    required this.timestamp,
  });

  factory DataSourceEvent.created(T data, {String? entityId}) {
    return DataSourceEvent(
      type: DataSourceEventType.created,
      data: data,
      entityId: entityId,
      timestamp: DateTime.now(),
    );
  }

  factory DataSourceEvent.updated(T data, {String? entityId}) {
    return DataSourceEvent(
      type: DataSourceEventType.updated,
      data: data,
      entityId: entityId,
      timestamp: DateTime.now(),
    );
  }

  factory DataSourceEvent.deleted({String? entityId}) {
    return DataSourceEvent<T>(
      type: DataSourceEventType.deleted,
      entityId: entityId,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'DataSourceEvent(type: $type, entityId: $entityId, timestamp: $timestamp)';
  }
}

/// Types of events that can occur in datasource operations
enum DataSourceEventType {
  created,
  updated,
  deleted,
  error,
}

/// Type alias for retry policies
typedef RetryPolicy = ({
  int maxAttempts,
  Duration initialDelay,
  Duration maxDelay,
  double backoffMultiplier,
});

/// Default retry policy for datasource operations
const RetryPolicy defaultRetryPolicy = (
  maxAttempts: 3,
  initialDelay: Duration(milliseconds: 500),
  maxDelay: Duration(seconds: 30),
  backoffMultiplier: 2.0,
);

/// Type alias for connection configuration
typedef ConnectionConfig = ({
  String? host,
  int? port,
  Duration? timeout,
  Duration? keepAlive,
  Map<String, String>? headers,
  bool? useSSL,
});

/// Type alias for authentication credentials
typedef AuthCredentials = ({
  String? token,
  String? apiKey,
  String? username,
  String? password,
  Map<String, String>? customHeaders,
});

/// Type alias for monitoring and metrics callbacks
typedef MetricsCallback = void Function(String operation, Duration duration, bool success);

/// Type alias for logging callbacks
typedef LogCallback = void Function(String level, String message, Map<String, dynamic>? context);

/// Log levels for datasource operations
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Type alias for health check results
typedef HealthCheckResult = ({
  bool isHealthy,
  String? message,
  Map<String, dynamic>? details,
  DateTime timestamp,
});

/// Type alias for backup/restore operations
typedef BackupResult = ({
  bool success,
  String? backupId,
  String? filePath,
  int entityCount,
  DateTime timestamp,
});

typedef RestoreResult = ({
  bool success,
  int restoredCount,
  int skippedCount,
  List<String> errors,
  DateTime timestamp,
});