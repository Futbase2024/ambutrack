import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../utils/exceptions/datasource_exception.dart';
import '../../../../utils/mixins/cache_mixin.dart';
import '../../../../utils/mixins/error_handler_mixin.dart';
import '../../users_contract.dart';
import '../../entities/users_entity.dart';
import 'firebase_user_model.dart';

/// Firebase implementation of [UsersDataSource]
///
/// Provides user management operations using Cloud Firestore
class FirebaseUserDataSource
    with CacheMixin<UserEntity>, ErrorHandlerMixin
    implements UsersDataSource {
  final FirebaseFirestore _firestore;
  final String _collectionName;

  /// Creates a new [FirebaseUserDataSource]
  ///
  /// [firestore] - The Firestore instance to use (defaults to default instance)
  /// [collectionName] - The name of the users collection (defaults to 'users')
  FirebaseUserDataSource({
    FirebaseFirestore? firestore,
    String collectionName = 'users',
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _collectionName = collectionName;

  /// Reference to the users collection
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  @override
  Future<UserEntity> create(UserEntity entity) async {
    return withRetry(
      () async {
        try {
          final model = FirebaseUserModel.fromEntity(entity);
          final docRef = _collection.doc(entity.id);

          // Check if user already exists
          final exists = await docRef.get();
          if (exists.exists) {
            throw EntityAlreadyExistsException(
              entityType: 'User',
              identifier: entity.id,
            );
          }

          await docRef.set(model.toFirestoreForCreate());

          // Get the created document to return updated timestamps
          final createdDoc = await docRef.get();
          final createdModel = FirebaseUserModel.fromFirestore(createdDoc);
          final createdEntity = createdModel.toEntity();

          // Cache the created entity
          saveToCache(createEntityCacheKey('getById', entity.id), createdEntity);
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
          final doc = await _collection.doc(id).get();
          if (!doc.exists) return null;

          final model = FirebaseUserModel.fromFirestore(doc);
          final entity = model.toEntity();

          // Cache the result
          saveToCache(createEntityCacheKey('getById', id), entity);

          return entity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getById');
        }
      },
      operationName: 'getById',
    );
  }

  @override
  Future<List<UserEntity>> getAll({int? limit, int? offset}) async {
    final cacheKey = createQueryCacheKey('getAll', {
      'limit': limit,
      'offset': offset,
    });

    // Check cache first
    final cached = getFromCache(cacheKey);
    if (cached != null) return [cached];

    return withRetry(
      () async {
        try {
          Query<Map<String, dynamic>> query = _collection
              .orderBy('createdAt', descending: true);

          if (offset != null) {
            // For offset, we need to get documents and skip
            final skipDocs = await _collection
                .orderBy('createdAt', descending: true)
                .limit(offset)
                .get();

            if (skipDocs.docs.isNotEmpty) {
              query = query.startAfterDocument(skipDocs.docs.last);
            }
          }

          if (limit != null) {
            query = query.limit(limit);
          }

          final snapshot = await query.get();
          final entities = snapshot.docs
              .map((doc) => FirebaseUserModel.fromFirestore(doc).toEntity())
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
          final docRef = _collection.doc(entity.id);

          // Check if entity exists
          final exists = await docRef.get();
          if (!exists.exists) {
            throw EntityNotFoundException(
              entityType: 'User',
              identifier: entity.id,
            );
          }

          final model = FirebaseUserModel.fromEntity(entity);
          await docRef.update(model.toFirestoreForUpdate());

          // Get the updated document
          final updatedDoc = await docRef.get();
          final updatedModel = FirebaseUserModel.fromFirestore(updatedDoc);
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
          final docRef = _collection.doc(id);

          // Check if entity exists
          final exists = await docRef.get();
          if (!exists.exists) {
            throw EntityNotFoundException(
              entityType: 'User',
              identifier: id,
            );
          }

          await docRef.delete();

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
          final doc = await _collection.doc(id).get();
          return doc.exists;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'exists');
        }
      },
      operationName: 'exists',
    );
  }

  @override
  Stream<List<UserEntity>> watchAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirebaseUserModel.fromFirestore(doc).toEntity())
          .toList();
    }).handleError((error, stackTrace) {
      throw handleError(error, stackTrace, 'watchAll');
    });
  }

  @override
  Stream<UserEntity?> watchById(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FirebaseUserModel.fromFirestore(doc).toEntity();
    }).handleError((error, stackTrace) {
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
          final snapshot = await _collection
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (snapshot.docs.isEmpty) return null;

          final model = FirebaseUserModel.fromFirestore(snapshot.docs.first);
          final entity = model.toEntity();

          // Cache the result
          saveToCache(cacheKey, entity);
          saveToCache(createEntityCacheKey('getById', entity.id), entity);

          return entity;
        } catch (error, stackTrace) {
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
          final docRef = _collection.doc(userId);

          // Check if entity exists
          final exists = await docRef.get();
          if (!exists.exists) {
            throw EntityNotFoundException(
              entityType: 'User',
              identifier: userId,
            );
          }

          final model = FirebaseUserModel.fromEntity(
            FirebaseUserModel.fromFirestore(exists).toEntity(),
          );

          final updateData = model.toPartialFirestoreUpdate(
            displayName: displayName,
            photoUrl: photoUrl,
            metadata: metadata,
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
            locale: locale,
            timezone: timezone,
          );

          await docRef.update(updateData);

          // Get the updated document
          final updatedDoc = await docRef.get();
          final updatedModel = FirebaseUserModel.fromFirestore(updatedDoc);
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
          final docRef = _collection.doc(userId);

          await docRef.update({
            'roles': roles,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Get the updated document
          final updatedDoc = await docRef.get();
          final updatedModel = FirebaseUserModel.fromFirestore(updatedDoc);
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
          final docRef = _collection.doc(userId);

          await docRef.update({
            'roles': FieldValue.arrayUnion([role]),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Get the updated document
          final updatedDoc = await docRef.get();
          final updatedModel = FirebaseUserModel.fromFirestore(updatedDoc);
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
          final docRef = _collection.doc(userId);

          await docRef.update({
            'roles': FieldValue.arrayRemove([role]),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Get the updated document
          final updatedDoc = await docRef.get();
          final updatedModel = FirebaseUserModel.fromFirestore(updatedDoc);
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
          final docRef = _collection.doc(userId);

          await docRef.update({
            'isActive': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Get the updated document
          final updatedDoc = await docRef.get();
          final updatedModel = FirebaseUserModel.fromFirestore(updatedDoc);
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
          final docRef = _collection.doc(userId);

          await docRef.update({
            'isActive': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Get the updated document
          final updatedDoc = await docRef.get();
          final updatedModel = FirebaseUserModel.fromFirestore(updatedDoc);
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
          Query<Map<String, dynamic>> firestoreQuery = _collection;

          // Add active filter
          if (onlyActive) {
            firestoreQuery = firestoreQuery.where('isActive', isEqualTo: true);
          }

          // Firestore doesn't support full-text search, so we'll search by email prefix
          // For more complex search, consider using Algolia or ElasticSearch
          if (query.contains('@')) {
            // Search by email
            firestoreQuery = firestoreQuery
                .where('email', isGreaterThanOrEqualTo: query)
                .where('email', isLessThan: '$query\uf8ff');
          } else {
            // Search by display name prefix
            firestoreQuery = firestoreQuery
                .where('displayName', isGreaterThanOrEqualTo: query)
                .where('displayName', isLessThan: '$query\uf8ff');
          }

          if (limit != null) {
            firestoreQuery = firestoreQuery.limit(limit);
          }

          final snapshot = await firestoreQuery.get();
          return snapshot.docs
              .map((doc) => FirebaseUserModel.fromFirestore(doc).toEntity())
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
          final snapshot = await _collection
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          return snapshot.docs.isEmpty;
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
          final snapshot = await _collection
              .where('roles', arrayContains: role)
              .get();

          return snapshot.docs
              .map((doc) => FirebaseUserModel.fromFirestore(doc).toEntity())
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
          final snapshot = await _collection
              .where('createdAt',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
              .where('createdAt',
                  isLessThanOrEqualTo: Timestamp.fromDate(endDate))
              .get();

          return snapshot.docs
              .map((doc) => FirebaseUserModel.fromFirestore(doc).toEntity())
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
          final docRef = _collection.doc(userId);

          await docRef.update({
            'isEmailVerified': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Get the updated document
          final updatedDoc = await docRef.get();
          final updatedModel = FirebaseUserModel.fromFirestore(updatedDoc);
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
          final docRef = _collection.doc(userId);

          await docRef.update({
            'isEmailVerified': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Get the updated document
          final updatedDoc = await docRef.get();
          final updatedModel = FirebaseUserModel.fromFirestore(updatedDoc);
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
    // This would typically be implemented with Firebase Auth
    // For now, return an empty stream
    return Stream<UserEntity?>.empty();
  }

  @override
  Stream<List<UserEntity>> watchUsersByRole(String role) {
    return _collection
        .where('roles', arrayContains: role)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirebaseUserModel.fromFirestore(doc).toEntity())
          .toList();
    }).handleError((error, stackTrace) {
      throw handleError(error, stackTrace, 'watchUsersByRole');
    });
  }

  @override
  Stream<List<UserEntity>> watchSearchResults(
    String query, {
    int? limit,
    bool onlyActive = true,
  }) {
    Query<Map<String, dynamic>> firestoreQuery = _collection;

    if (onlyActive) {
      firestoreQuery = firestoreQuery.where('isActive', isEqualTo: true);
    }

    if (query.contains('@')) {
      firestoreQuery = firestoreQuery
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: '$query\uf8ff');
    } else {
      firestoreQuery = firestoreQuery
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: '$query\uf8ff');
    }

    if (limit != null) {
      firestoreQuery = firestoreQuery.limit(limit);
    }

    return firestoreQuery.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FirebaseUserModel.fromFirestore(doc).toEntity())
          .toList();
    }).handleError((error, stackTrace) {
      throw handleError(error, stackTrace, 'watchSearchResults');
    });
  }

  // Batch operations
  @override
  Future<List<UserEntity>> createBatch(List<UserEntity> entities) async {
    return withRetry(
      () async {
        try {
          final batch = _firestore.batch();
          final results = <UserEntity>[];

          for (final entity in entities) {
            final docRef = _collection.doc(entity.id);
            final model = FirebaseUserModel.fromEntity(entity);
            batch.set(docRef, model.toFirestoreForCreate());
          }

          await batch.commit();

          // Get all created documents
          for (final entity in entities) {
            final doc = await _collection.doc(entity.id).get();
            final model = FirebaseUserModel.fromFirestore(doc);
            final createdEntity = model.toEntity();
            results.add(createdEntity);

            // Cache the created entity
            saveToCache(createEntityCacheKey('getById', entity.id), createdEntity);
          }

          // Invalidate relevant caches
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
          final batch = _firestore.batch();
          final results = <UserEntity>[];

          for (final entity in entities) {
            final docRef = _collection.doc(entity.id);
            final model = FirebaseUserModel.fromEntity(entity);
            batch.update(docRef, model.toFirestoreForUpdate());
          }

          await batch.commit();

          // Get all updated documents
          for (final entity in entities) {
            final doc = await _collection.doc(entity.id).get();
            final model = FirebaseUserModel.fromFirestore(doc);
            final updatedEntity = model.toEntity();
            results.add(updatedEntity);

            // Update cache
            saveToCache(createEntityCacheKey('getById', entity.id), updatedEntity);
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
          final batch = _firestore.batch();

          for (final id in ids) {
            final docRef = _collection.doc(id);
            batch.delete(docRef);
          }

          await batch.commit();

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
          final snapshot = await _collection.count().get();
          return snapshot.count ?? 0;
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
          // This is a dangerous operation - consider adding confirmation
          final snapshot = await _collection.get();
          final batch = _firestore.batch();

          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
          }

          await batch.commit();
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
          final batch = _firestore.batch();

          for (final userId in userIds) {
            final docRef = _collection.doc(userId);
            batch.update(docRef, {
              'roles': FieldValue.arrayUnion(roles),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }

          await batch.commit();

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
          final batch = _firestore.batch();

          for (final userId in userIds) {
            final docRef = _collection.doc(userId);
            batch.update(docRef, {
              'isActive': false,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }

          await batch.commit();

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
          Query<Map<String, dynamic>> query = _collection;

          if (userIds != null && userIds.isNotEmpty) {
            // Export specific users
            final futures = userIds.map((id) => _collection.doc(id).get());
            final docs = await Future.wait(futures);
            final users = docs
                .where((doc) => doc.exists)
                .map((doc) => FirebaseUserModel.fromFirestore(doc).toJson())
                .toList();

            return {
              'users': users,
              'exported_at': DateTime.now().toIso8601String(),
              'count': users.length,
            };
          } else {
            // Export all users
            final snapshot = await query.get();
            final users = snapshot.docs
                .map((doc) => FirebaseUserModel.fromFirestore(doc).toJson())
                .toList();

            if (!includeMetadata) {
              // Remove metadata fields from each user
              for (final user in users) {
                user.remove('metadata');
              }
            }

            return {
              'users': users,
              'exported_at': DateTime.now().toIso8601String(),
              'count': users.length,
            };
          }
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
          final usersList = userData['users'] as List<dynamic>;
          final entities = usersList
              .map((userJson) => UserEntity.fromJson(userJson as Map<String, dynamic>))
              .toList();

          final results = <UserEntity>[];
          final batch = _firestore.batch();

          for (final entity in entities) {
            final docRef = _collection.doc(entity.id);
            final model = FirebaseUserModel.fromEntity(entity);

            if (updateExisting) {
              batch.set(docRef, model.toFirestoreForCreate(), SetOptions(merge: true));
            } else {
              // Check if exists first
              final existingDoc = await docRef.get();
              if (!existingDoc.exists) {
                batch.set(docRef, model.toFirestoreForCreate());
              }
            }
          }

          await batch.commit();

          // Get all imported documents
          for (final entity in entities) {
            final doc = await _collection.doc(entity.id).get();
            if (doc.exists) {
              final model = FirebaseUserModel.fromFirestore(doc);
              final importedEntity = model.toEntity();
              results.add(importedEntity);

              // Cache the imported entity
              saveToCache(createEntityCacheKey('getById', entity.id), importedEntity);
            }
          }

          // Invalidate relevant caches
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