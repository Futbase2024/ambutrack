import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../utils/mixins/cache_mixin.dart';
import '../../../../utils/mixins/error_handler_mixin.dart';
import '../../users_contract.dart';
import '../../entities/users_entity.dart';
import 'rest_user_model.dart';

/// REST API implementation of [UsersDataSource]
///
/// Provides user management operations using REST API endpoints
class RestUserDataSource
    with CacheMixin<UserEntity>, ErrorHandlerMixin
    implements UsersDataSource {
  final Dio _dio;
  final String _baseUrl;
  final String _usersEndpoint;

  /// Creates a new [RestUserDataSource]
  ///
  /// [dio] - The Dio instance to use for HTTP requests
  /// [baseUrl] - The base URL of the REST API
  /// [usersEndpoint] - The endpoint path for user operations (defaults to 'users')
  RestUserDataSource({
    required Dio dio,
    required String baseUrl,
    String usersEndpoint = 'users',
  })  : _dio = dio,
        _baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl,
        _usersEndpoint = usersEndpoint;

  /// Full URL for users endpoint
  String get _usersUrl => '$_baseUrl/$_usersEndpoint';

  @override
  Future<UserEntity> create(UserEntity entity) async {
    return withRetry(
      () async {
        try {
          final model = RestUserModel.fromEntity(entity);
          final response = await _dio.post(
            _usersUrl,
            data: model.toCreateRequest(),
          );

          final createdModel = RestUserModel.fromJson(response.data);
          final createdEntity = createdModel.toEntity();

          // Cache the created entity
          saveToCache(createEntityCacheKey('getById', createdEntity.id), createdEntity);
          invalidateCachePattern('getAll:.*');
          invalidateCachePattern('searchUsers:.*');

          return createdEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'create');
        }
      },
      operationName: 'create',
    );
  }

  @override
  Future<UserEntity?> getById(String id) async {
    // Check cache first
    final cached = getFromCache(createEntityCacheKey('getById', id));
    if (cached != null) return cached;

    return withRetry(
      () async {
        try {
          final response = await _dio.get('$_usersUrl/$id');

          if (response.statusCode == 404) return null;

          final model = RestUserModel.fromJson(response.data);
          final entity = model.toEntity();

          // Cache the result
          saveToCache(createEntityCacheKey('getById', id), entity);

          return entity;
        } catch (error, stackTrace) {
          if (error is DioException && error.response?.statusCode == 404) {
            return null;
          }
          throw handleError(error, stackTrace, 'getById');
        }
      },
      operationName: 'getById',
    );
  }

  @override
  Future<List<UserEntity>> getAll({int? limit, int? offset}) async {
    createQueryCacheKey('getAll', {
      'limit': limit,
      'offset': offset,
    });

    return withRetry(
      () async {
        try {
          final queryParams = <String, dynamic>{};
          if (limit != null) queryParams['limit'] = limit;
          if (offset != null) queryParams['offset'] = offset;

          final response = await _dio.get(
            _usersUrl,
            queryParameters: queryParams,
          );

          final List<dynamic> usersJson = response.data['users'] ?? response.data;
          final entities = usersJson
              .map((json) => RestUserModel.fromJson(json).toEntity())
              .toList();

          // Cache individual entities
          for (final entity in entities) {
            saveToCache(createEntityCacheKey('getById', entity.id), entity);
          }

          return entities;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getAll');
        }
      },
      operationName: 'getAll',
    );
  }

  @override
  Future<UserEntity> update(UserEntity entity) async {
    return withRetry(
      () async {
        try {
          final model = RestUserModel.fromEntity(entity);
          final response = await _dio.put(
            '$_usersUrl/${entity.id}',
            data: model.toUpdateRequest(),
          );

          final updatedModel = RestUserModel.fromJson(response.data);
          final updatedEntity = updatedModel.toEntity();

          // Update cache
          saveToCache(createEntityCacheKey('getById', entity.id), updatedEntity);
          invalidateCachePattern('getAll:.*');
          invalidateCachePattern('searchUsers:.*');
          invalidateEntityCache(entity.id);

          return updatedEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'update');
        }
      },
      operationName: 'update',
    );
  }

  @override
  Future<void> delete(String id) async {
    return withRetry(
      () async {
        try {
          await _dio.delete('$_usersUrl/$id');

          // Clear cache
          removeFromCache(createEntityCacheKey('getById', id));
          invalidateCachePattern('getAll:.*');
          invalidateCachePattern('searchUsers:.*');
          invalidateEntityCache(id);
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'delete');
        }
      },
      operationName: 'delete',
    );
  }

  @override
  Future<bool> exists(String id) async {
    // Check cache first
    final cached = getFromCache(createEntityCacheKey('getById', id));
    if (cached != null) return true;

    return withRetry(
      () async {
        try {
          final response = await _dio.head('$_usersUrl/$id');
          return response.statusCode == 200;
        } catch (error, stackTrace) {
          if (error is DioException && error.response?.statusCode == 404) {
            return false;
          }
          throw handleError(error, stackTrace, 'exists');
        }
      },
      operationName: 'exists',
    );
  }

  @override
  Stream<List<UserEntity>> watchAll() {
    // REST APIs don't natively support real-time updates
    // This could be implemented with Server-Sent Events (SSE) or WebSocket
    // For now, we'll return a periodic stream that polls the API
    return Stream.periodic(const Duration(seconds: 30))
        .asyncMap((_) => getAll())
        .handleError((error, stackTrace) {
      throw handleError(error, stackTrace, 'watchAll');
    });
  }

  @override
  Stream<UserEntity?> watchById(String id) {
    // Similar to watchAll, this would need SSE or WebSocket for real-time updates
    return Stream.periodic(const Duration(seconds: 30))
        .asyncMap((_) => getById(id))
        .handleError((error, stackTrace) {
      throw handleError(error, stackTrace, 'watchById');
    });
  }

  @override
  Future<UserEntity?> getByEmail(String email) async {
    final cacheKey = createCacheKey(['getByEmail', email]);
    final cached = getFromCache(cacheKey);
    if (cached != null) return cached;

    return withRetry(
      () async {
        try {
          final response = await _dio.get(
            '$_usersUrl/by-email/$email',
          );

          if (response.statusCode == 404) return null;

          final model = RestUserModel.fromJson(response.data);
          final entity = model.toEntity();

          // Cache the result
          saveToCache(cacheKey, entity);
          saveToCache(createEntityCacheKey('getById', entity.id), entity);

          return entity;
        } catch (error, stackTrace) {
          if (error is DioException && error.response?.statusCode == 404) {
            return null;
          }
          throw handleError(error, stackTrace, 'getByEmail');
        }
      },
      operationName: 'getByEmail',
    );
  }

  @override
  Future<UserEntity> updateProfile(
    String userId, {
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? metadata,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? locale,
    String? timezone,
  }) async {
    return withRetry(
      () async {
        try {
          final updateData = <String, dynamic>{};
          if (displayName != null) updateData['display_name'] = displayName;
          if (photoUrl != null) updateData['photo_url'] = photoUrl;
          if (metadata != null) updateData['metadata'] = metadata;
          if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
          if (dateOfBirth != null) {
            updateData['date_of_birth'] = dateOfBirth.toIso8601String();
          }
          if (locale != null) updateData['locale'] = locale;
          if (timezone != null) updateData['timezone'] = timezone;

          final response = await _dio.patch(
            '$_usersUrl/$userId/profile',
            data: updateData,
          );

          final updatedModel = RestUserModel.fromJson(response.data);
          final updatedEntity = updatedModel.toEntity();

          // Update cache
          saveToCache(createEntityCacheKey('getById', userId), updatedEntity);
          invalidateEntityCache(userId);

          return updatedEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'updateProfile');
        }
      },
      operationName: 'updateProfile',
    );
  }

  @override
  Future<UserEntity> updateRoles(String userId, List<String> roles) async {
    return withRetry(
      () async {
        try {
          final response = await _dio.patch(
            '$_usersUrl/$userId/roles',
            data: {'roles': roles},
          );

          final updatedModel = RestUserModel.fromJson(response.data);
          final updatedEntity = updatedModel.toEntity();

          // Update cache
          saveToCache(createEntityCacheKey('getById', userId), updatedEntity);
          invalidateEntityCache(userId);

          return updatedEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'updateRoles');
        }
      },
      operationName: 'updateRoles',
    );
  }

  @override
  Future<UserEntity> addRole(String userId, String role) async {
    return withRetry(
      () async {
        try {
          final response = await _dio.post(
            '$_usersUrl/$userId/roles',
            data: {'role': role},
          );

          final updatedModel = RestUserModel.fromJson(response.data);
          final updatedEntity = updatedModel.toEntity();

          // Update cache
          saveToCache(createEntityCacheKey('getById', userId), updatedEntity);
          invalidateEntityCache(userId);

          return updatedEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'addRole');
        }
      },
      operationName: 'addRole',
    );
  }

  @override
  Future<UserEntity> removeRole(String userId, String role) async {
    return withRetry(
      () async {
        try {
          final response = await _dio.delete(
            '$_usersUrl/$userId/roles/$role',
          );

          final updatedModel = RestUserModel.fromJson(response.data);
          final updatedEntity = updatedModel.toEntity();

          // Update cache
          saveToCache(createEntityCacheKey('getById', userId), updatedEntity);
          invalidateEntityCache(userId);

          return updatedEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'removeRole');
        }
      },
      operationName: 'removeRole',
    );
  }

  @override
  Future<UserEntity> deactivateUser(String userId) async {
    return withRetry(
      () async {
        try {
          final response = await _dio.patch(
            '$_usersUrl/$userId/deactivate',
          );

          final updatedModel = RestUserModel.fromJson(response.data);
          final updatedEntity = updatedModel.toEntity();

          // Update cache
          saveToCache(createEntityCacheKey('getById', userId), updatedEntity);
          invalidateEntityCache(userId);

          return updatedEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'deactivateUser');
        }
      },
      operationName: 'deactivateUser',
    );
  }

  @override
  Future<UserEntity> reactivateUser(String userId) async {
    return withRetry(
      () async {
        try {
          final response = await _dio.patch(
            '$_usersUrl/$userId/reactivate',
          );

          final updatedModel = RestUserModel.fromJson(response.data);
          final updatedEntity = updatedModel.toEntity();

          // Update cache
          saveToCache(createEntityCacheKey('getById', userId), updatedEntity);
          invalidateEntityCache(userId);

          return updatedEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'reactivateUser');
        }
      },
      operationName: 'reactivateUser',
    );
  }

  @override
  Future<List<UserEntity>> searchUsers(
    String query, {
    int? limit,
    bool onlyActive = true,
  }) async {
    return withRetry(
      () async {
        try {
          final queryParams = <String, dynamic>{
            'q': query,
            'only_active': onlyActive,
          };
          if (limit != null) queryParams['limit'] = limit;

          final response = await _dio.get(
            '$_usersUrl/search',
            queryParameters: queryParams,
          );

          final List<dynamic> usersJson = response.data['users'] ?? response.data;
          return usersJson
              .map((json) => RestUserModel.fromJson(json).toEntity())
              .toList();
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'searchUsers');
        }
      },
      operationName: 'searchUsers',
    );
  }

  @override
  Future<bool> isEmailAvailable(String email) async {
    return withRetry(
      () async {
        try {
          final response = await _dio.get(
            '$_usersUrl/email-available',
            queryParameters: {'email': email},
          );

          return response.data['available'] as bool? ?? false;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'isEmailAvailable');
        }
      },
      operationName: 'isEmailAvailable',
    );
  }

  @override
  Future<List<UserEntity>> getUsersByRole(String role) async {
    return withRetry(
      () async {
        try {
          final response = await _dio.get(
            '$_usersUrl/by-role/$role',
          );

          final List<dynamic> usersJson = response.data['users'] ?? response.data;
          return usersJson
              .map((json) => RestUserModel.fromJson(json).toEntity())
              .toList();
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getUsersByRole');
        }
      },
      operationName: 'getUsersByRole',
    );
  }

  @override
  Future<List<UserEntity>> getUsersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return withRetry(
      () async {
        try {
          final response = await _dio.get(
            '$_usersUrl/by-date-range',
            queryParameters: {
              'start_date': startDate.toIso8601String(),
              'end_date': endDate.toIso8601String(),
            },
          );

          final List<dynamic> usersJson = response.data['users'] ?? response.data;
          return usersJson
              .map((json) => RestUserModel.fromJson(json).toEntity())
              .toList();
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getUsersByDateRange');
        }
      },
      operationName: 'getUsersByDateRange',
    );
  }

  @override
  Future<UserEntity> verifyEmail(String userId) async {
    return withRetry(
      () async {
        try {
          final response = await _dio.patch(
            '$_usersUrl/$userId/verify-email',
          );

          final updatedModel = RestUserModel.fromJson(response.data);
          final updatedEntity = updatedModel.toEntity();

          // Update cache
          saveToCache(createEntityCacheKey('getById', userId), updatedEntity);
          invalidateEntityCache(userId);

          return updatedEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'verifyEmail');
        }
      },
      operationName: 'verifyEmail',
    );
  }

  @override
  Future<UserEntity> unverifyEmail(String userId) async {
    return withRetry(
      () async {
        try {
          final response = await _dio.patch(
            '$_usersUrl/$userId/unverify-email',
          );

          final updatedModel = RestUserModel.fromJson(response.data);
          final updatedEntity = updatedModel.toEntity();

          // Update cache
          saveToCache(createEntityCacheKey('getById', userId), updatedEntity);
          invalidateEntityCache(userId);

          return updatedEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'unverifyEmail');
        }
      },
      operationName: 'unverifyEmail',
    );
  }

  @override
  Stream<UserEntity?> watchCurrentUser() {
    // This would typically be implemented with WebSocket or SSE
    // For now, return an empty stream
    return Stream<UserEntity?>.empty();
  }

  @override
  Stream<List<UserEntity>> watchUsersByRole(String role) {
    // Similar to other watch methods, would need WebSocket/SSE
    return Stream.periodic(const Duration(seconds: 30))
        .asyncMap((_) => getUsersByRole(role))
        .handleError((error, stackTrace) {
      throw handleError(error, stackTrace, 'watchUsersByRole');
    });
  }

  @override
  Stream<List<UserEntity>> watchSearchResults(
    String query, {
    int? limit,
    bool onlyActive = true,
  }) {
    return Stream.periodic(const Duration(seconds: 30))
        .asyncMap((_) => searchUsers(query, limit: limit, onlyActive: onlyActive))
        .handleError((error, stackTrace) {
      throw handleError(error, stackTrace, 'watchSearchResults');
    });
  }

  // Batch operations
  @override
  Future<List<UserEntity>> createBatch(List<UserEntity> entities) async {
    return withRetry(
      () async {
        try {
          final requests = entities
              .map((entity) => RestUserModel.fromEntity(entity).toCreateRequest())
              .toList();

          final response = await _dio.post(
            '$_usersUrl/batch',
            data: {'users': requests},
          );

          final List<dynamic> usersJson = response.data['users'];
          final results = usersJson
              .map((json) => RestUserModel.fromJson(json).toEntity())
              .toList();

          // Cache created entities
          for (final entity in results) {
            saveToCache(createEntityCacheKey('getById', entity.id), entity);
          }

          invalidateCachePattern('getAll:.*');

          return results;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'createBatch');
        }
      },
      operationName: 'createBatch',
    );
  }

  @override
  Future<List<UserEntity>> updateBatch(List<UserEntity> entities) async {
    return withRetry(
      () async {
        try {
          final requests = entities
              .map((entity) => {
                    'id': entity.id,
                    ...RestUserModel.fromEntity(entity).toUpdateRequest(),
                  })
              .toList();

          final response = await _dio.put(
            '$_usersUrl/batch',
            data: {'users': requests},
          );

          final List<dynamic> usersJson = response.data['users'];
          final results = usersJson
              .map((json) => RestUserModel.fromJson(json).toEntity())
              .toList();

          // Update cache
          for (final entity in results) {
            saveToCache(createEntityCacheKey('getById', entity.id), entity);
            invalidateEntityCache(entity.id);
          }

          return results;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'updateBatch');
        }
      },
      operationName: 'updateBatch',
    );
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    return withRetry(
      () async {
        try {
          await _dio.delete(
            '$_usersUrl/batch',
            data: {'ids': ids},
          );

          // Clear cache
          for (final id in ids) {
            removeFromCache(createEntityCacheKey('getById', id));
            invalidateEntityCache(id);
          }

          invalidateCachePattern('getAll:.*');
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'deleteBatch');
        }
      },
      operationName: 'deleteBatch',
    );
  }

  @override
  Future<int> count() async {
    return withRetry(
      () async {
        try {
          final response = await _dio.get('$_usersUrl/count');
          return response.data['count'] as int? ?? 0;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'count');
        }
      },
      operationName: 'count',
    );
  }

  @override
  Future<void> clear() async {
    return withRetry(
      () async {
        try {
          await _dio.delete('$_usersUrl/clear');
          clearCache();
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'clear');
        }
      },
      operationName: 'clear',
    );
  }

  @override
  Future<List<UserEntity>> updateUsers(List<UserEntity> users) {
    return updateBatch(users);
  }

  @override
  Future<void> assignRolesToUsers(
    List<String> userIds,
    List<String> roles,
  ) async {
    return withRetry(
      () async {
        try {
          await _dio.patch(
            '$_usersUrl/assign-roles',
            data: {
              'user_ids': userIds,
              'roles': roles,
            },
          );

          // Clear cache for affected users
          for (final userId in userIds) {
            removeFromCache(createEntityCacheKey('getById', userId));
            invalidateEntityCache(userId);
          }
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'assignRolesToUsers');
        }
      },
      operationName: 'assignRolesToUsers',
    );
  }

  @override
  Future<void> deactivateUsers(List<String> userIds) async {
    return withRetry(
      () async {
        try {
          await _dio.patch(
            '$_usersUrl/deactivate-batch',
            data: {'user_ids': userIds},
          );

          // Clear cache for affected users
          for (final userId in userIds) {
            removeFromCache(createEntityCacheKey('getById', userId));
            invalidateEntityCache(userId);
          }
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'deactivateUsers');
        }
      },
      operationName: 'deactivateUsers',
    );
  }

  @override
  Future<Map<String, dynamic>> exportUsers({
    List<String>? userIds,
    bool includeMetadata = false,
  }) async {
    return withRetry(
      () async {
        try {
          final queryParams = <String, dynamic>{
            'include_metadata': includeMetadata,
          };
          if (userIds != null && userIds.isNotEmpty) {
            queryParams['user_ids'] = userIds.join(',');
          }

          final response = await _dio.get(
            '$_usersUrl/export',
            queryParameters: queryParams,
          );

          return response.data as Map<String, dynamic>;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'exportUsers');
        }
      },
      operationName: 'exportUsers',
    );
  }

  @override
  Future<List<UserEntity>> importUsers(
    Map<String, dynamic> userData, {
    bool updateExisting = false,
  }) async {
    return withRetry(
      () async {
        try {
          final response = await _dio.post(
            '$_usersUrl/import',
            data: {
              ...userData,
              'update_existing': updateExisting,
            },
          );

          final List<dynamic> usersJson = response.data['users'];
          final results = usersJson
              .map((json) => RestUserModel.fromJson(json).toEntity())
              .toList();

          // Cache imported entities
          for (final entity in results) {
            saveToCache(createEntityCacheKey('getById', entity.id), entity);
          }

          invalidateCachePattern('getAll:.*');

          return results;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'importUsers');
        }
      },
      operationName: 'importUsers',
    );
  }

  /// Disposes resources used by this datasource
  void dispose() {
    disposeCache();
  }
}