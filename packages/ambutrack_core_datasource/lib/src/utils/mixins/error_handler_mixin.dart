import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../exceptions/datasource_exception.dart';
import '../typedefs/datasource_typedefs.dart';

/// Mixin that provides standardized error handling for datasources
///
/// This mixin converts platform-specific errors into standard
/// [DataSourceException] instances and provides retry mechanisms
mixin ErrorHandlerMixin {
  /// Default retry policy for operations
  RetryPolicy get defaultRetryPolicy => (
        maxAttempts: 3,
        initialDelay: const Duration(milliseconds: 500),
        maxDelay: const Duration(seconds: 30),
        backoffMultiplier: 2.0,
      );

  /// Converts any error to a [DataSourceException]
  DataSourceException handleError(
    dynamic error, [
    StackTrace? stackTrace,
    String? operation,
  ]) {
    if (error is DataSourceException) {
      return error;
    }

    final context = operation != null ? {'operation': operation} : null;

    // Handle Dio errors (REST API)
    if (error is DioException) {
      return _handleDioError(error, stackTrace, context);
    }

    // Handle Firestore errors
    if (error is FirebaseException) {
      return _handleFirebaseError(error, stackTrace, context);
    }

    // Handle network errors
    if (error is SocketException) {
      return DataSourceException.network(
        'Network connection failed: ${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Handle timeout errors
    if (error is TimeoutException) {
      return DataSourceException.timeout(
        'Operation timed out: ${error.message ?? 'No message'}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Handle format exceptions (JSON parsing, etc.)
    if (error is FormatException) {
      return DataSourceException.serialization(
        'Data serialization failed: ${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Handle argument errors (validation)
    if (error is ArgumentError) {
      return DataSourceException.validation(
        'Invalid arguments: ${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Generic error
    return DataSourceException.generic(
      'An unexpected error occurred: ${error.toString()}',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Executes an operation with retry logic
  Future<T> withRetry<T>(
    Future<T> Function() operation, {
    RetryPolicy? retryPolicy,
    bool Function(dynamic error)? shouldRetry,
    String? operationName,
  }) async {
    final policy = retryPolicy ?? defaultRetryPolicy;
    var attempt = 1;
    var delay = policy.initialDelay;

    while (true) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        // Convert to DataSourceException if needed
        final dsException = error is DataSourceException
            ? error
            : handleError(error, stackTrace, operationName);

        // Check if we should retry
        final canRetry = attempt < policy.maxAttempts &&
            (shouldRetry?.call(dsException) ?? _shouldRetryError(dsException));

        if (!canRetry) {
          throw dsException;
        }

        // Wait before retry
        await Future.delayed(delay);

        // Calculate next delay with exponential backoff
        delay = Duration(
          milliseconds: min(
            (delay.inMilliseconds * policy.backoffMultiplier).round(),
            policy.maxDelay.inMilliseconds,
          ),
        );

        attempt++;
      }
    }
  }

  /// Executes an operation and returns a result type instead of throwing
  Future<DataSourceResult<T>> withErrorHandling<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      final result = await operation();
      return (data: result, error: null);
    } catch (error, stackTrace) {
      final dsException = error is DataSourceException
          ? error
          : handleError(error, stackTrace, operationName);
      return (data: null, error: dsException);
    }
  }

  /// Handles batch operations with individual error tracking
  Future<BatchResult<T>> withBatchErrorHandling<T>(
    List<Future<T> Function()> operations, {
    String? operationName,
  }) async {
    final successful = <T>[];
    final failed = <BatchError>[];

    for (var i = 0; i < operations.length; i++) {
      try {
        final result = await operations[i]();
        successful.add(result);
      } catch (error, stackTrace) {
        final dsException = error is DataSourceException
            ? error
            : handleError(error, stackTrace, operationName);
        failed.add(BatchError(
          index: i,
          error: dsException,
        ));
      }
    }

    return (successful: successful, failed: failed);
  }

  /// Handles Dio HTTP errors
  DataSourceException _handleDioError(
    DioException error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return DataSourceException.timeout(
          'HTTP operation timed out',
          originalError: error,
          stackTrace: stackTrace,
        );

      case DioExceptionType.connectionError:
        return DataSourceException.network(
          'Connection error: ${error.message}',
          originalError: error,
          stackTrace: stackTrace,
        );

      case DioExceptionType.badResponse:
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              return DataSourceException.validation(
                'Bad request: ${_extractErrorMessage(responseData)}',
                originalError: error,
                stackTrace: stackTrace,
              );
            case 401:
              return DataSourceException.authentication(
                'Authentication failed',
                originalError: error,
                stackTrace: stackTrace,
              );
            case 403:
              return DataSourceException.authorization(
                'Access forbidden',
                originalError: error,
                stackTrace: stackTrace,
              );
            case 404:
              return DataSourceException.notFound(
                'Resource not found',
                originalError: error,
                stackTrace: stackTrace,
              );
            case 409:
              return DataSourceException.conflict(
                'Resource conflict: ${_extractErrorMessage(responseData)}',
                originalError: error,
                stackTrace: stackTrace,
              );
            case 429:
              return DataSourceException.rateLimit(
                'Rate limit exceeded',
                originalError: error,
                stackTrace: stackTrace,
              );
            default:
              return DataSourceException.generic(
                'HTTP error $statusCode: ${_extractErrorMessage(responseData)}',
                originalError: error,
                stackTrace: stackTrace,
              );
          }
        }
        break;

      default:
        return DataSourceException.generic(
          'HTTP error: ${error.message}',
          originalError: error,
          stackTrace: stackTrace,
        );
    }

    return DataSourceException.generic(
      'Unexpected HTTP error: ${error.message}',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Handles Firebase/Firestore errors
  DataSourceException _handleFirebaseError(
    FirebaseException error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ) {
    switch (error.code) {
      case 'permission-denied':
        return DataSourceException.authorization(
          'Permission denied: ${error.message}',
          originalError: error,
          stackTrace: stackTrace,
        );

      case 'unauthenticated':
        return DataSourceException.authentication(
          'Authentication required: ${error.message}',
          originalError: error,
          stackTrace: stackTrace,
        );

      case 'not-found':
        return DataSourceException.notFound(
          'Document not found: ${error.message}',
          originalError: error,
          stackTrace: stackTrace,
        );

      case 'already-exists':
        return DataSourceException.conflict(
          'Document already exists: ${error.message}',
          originalError: error,
          stackTrace: stackTrace,
        );

      case 'invalid-argument':
        return DataSourceException.validation(
          'Invalid argument: ${error.message}',
          originalError: error,
          stackTrace: stackTrace,
        );

      case 'deadline-exceeded':
      case 'cancelled':
        return DataSourceException.timeout(
          'Operation timed out: ${error.message}',
          originalError: error,
          stackTrace: stackTrace,
        );

      case 'resource-exhausted':
        return DataSourceException.rateLimit(
          'Rate limit exceeded: ${error.message}',
          originalError: error,
          stackTrace: stackTrace,
        );

      case 'unavailable':
        return DataSourceException.network(
          'Service unavailable: ${error.message}',
          originalError: error,
          stackTrace: stackTrace,
        );

      default:
        return DataSourceException.generic(
          'Firebase error: ${error.message}',
          originalError: error,
          stackTrace: stackTrace,
        );
    }
  }

  /// Determines if an error should be retried
  bool _shouldRetryError(DataSourceException error) {
    switch (error.code) {
      case 'NETWORK_ERROR':
      case 'TIMEOUT':
      case 'RATE_LIMIT':
        return true;
      case 'AUTH_ERROR':
      case 'AUTHORIZATION_ERROR':
      case 'VALIDATION_ERROR':
      case 'NOT_FOUND':
      case 'CONFLICT':
        return false;
      default:
        return false;
    }
  }

  /// Extracts error message from response data
  String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return 'No additional information';

    if (responseData is Map<String, dynamic>) {
      // Try common error message fields
      for (final field in ['message', 'error', 'detail', 'description']) {
        if (responseData.containsKey(field)) {
          return responseData[field].toString();
        }
      }
    }

    return responseData.toString();
  }

  /// Safely executes an operation and logs errors
  Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    String? operationName,
    LogCallback? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      final dsException = handleError(error, stackTrace, operationName);
      onError?.call(
        'error',
        'Operation failed: ${operationName ?? 'unknown'}',
        {
          'error': dsException.toString(),
          'code': dsException.code,
        },
      );
      return null;
    }
  }
}