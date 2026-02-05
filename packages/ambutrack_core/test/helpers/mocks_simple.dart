import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';


/// Mock implementation of UsersDataSource for testing
class MockUsersDataSource implements UsersDataSource {
  final Map<String, UserEntity> _users = {};
  final StreamController<List<UserEntity>> _allUsersController = StreamController.broadcast();
  final Map<String, StreamController<UserEntity?>> _userControllers = {};

  @override
  Future<UserEntity> create(UserEntity entity) async {
    if (_users.containsKey(entity.id)) {
      throw EntityAlreadyExistsException(
        entityType: 'User',
        identifier: entity.id,
      );
    }

    final now = DateTime.now();
    final newEntity = entity.copyWith(
      createdAt: now,
      updatedAt: now,
    );

    _users[entity.id] = newEntity;
    _notifyAllUsersChanged();
    _notifyUserChanged(entity.id, newEntity);

    return newEntity;
  }

  @override
  Future<UserEntity?> getById(String id) async {
    return _users[id];
  }

  @override
  Future<List<UserEntity>> getAll({int? limit, int? offset}) async {
    var users = _users.values.toList();
    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset != null) {
      users = users.skip(offset).toList();
    }

    if (limit != null) {
      users = users.take(limit).toList();
    }

    return users;
  }

  @override
  Future<UserEntity> update(UserEntity entity) async {
    if (!_users.containsKey(entity.id)) {
      throw EntityNotFoundException(
        entityType: 'User',
        identifier: entity.id,
      );
    }

    final updatedEntity = entity.copyWith(updatedAt: DateTime.now());
    _users[entity.id] = updatedEntity;
    _notifyAllUsersChanged();
    _notifyUserChanged(entity.id, updatedEntity);

    return updatedEntity;
  }

  @override
  Future<void> delete(String id) async {
    if (!_users.containsKey(id)) {
      throw EntityNotFoundException(
        entityType: 'User',
        identifier: id,
      );
    }

    _users.remove(id);
    _notifyAllUsersChanged();
    _notifyUserChanged(id, null);
  }

  @override
  Future<bool> exists(String id) async {
    return _users.containsKey(id);
  }

  @override
  Stream<List<UserEntity>> watchAll() {
    return _allUsersController.stream;
  }

  @override
  Stream<UserEntity?> watchById(String id) {
    if (!_userControllers.containsKey(id)) {
      _userControllers[id] = StreamController<UserEntity?>.broadcast();
    }
    return _userControllers[id]!.stream;
  }

  @override
  Future<UserEntity?> getByEmail(String email) async {
    try {
      return _users.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
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
    final user = _users[userId];
    if (user == null) {
      throw EntityNotFoundException(entityType: 'User', identifier: userId);
    }

    final updatedUser = user.copyWith(
      displayName: displayName ?? user.displayName,
      photoUrl: photoUrl ?? user.photoUrl,
      metadata: metadata ?? user.metadata,
      phoneNumber: phoneNumber ?? user.phoneNumber,
      dateOfBirth: dateOfBirth ?? user.dateOfBirth,
      locale: locale ?? user.locale,
      timezone: timezone ?? user.timezone,
      updatedAt: DateTime.now(),
    );

    return update(updatedUser);
  }

  @override
  Future<UserEntity> updateRoles(String userId, List<String> roles) async {
    final user = _users[userId];
    if (user == null) {
      throw EntityNotFoundException(entityType: 'User', identifier: userId);
    }

    final updatedUser = user.copyWith(
      roles: roles,
      updatedAt: DateTime.now(),
    );

    return update(updatedUser);
  }

  @override
  Future<UserEntity> addRole(String userId, String role) async {
    final user = _users[userId];
    if (user == null) {
      throw EntityNotFoundException(entityType: 'User', identifier: userId);
    }

    final newRoles = List<String>.from(user.roles);
    if (!newRoles.contains(role)) {
      newRoles.add(role);
    }

    return updateRoles(userId, newRoles);
  }

  @override
  Future<UserEntity> removeRole(String userId, String role) async {
    final user = _users[userId];
    if (user == null) {
      throw EntityNotFoundException(entityType: 'User', identifier: userId);
    }

    final newRoles = List<String>.from(user.roles);
    newRoles.remove(role);

    return updateRoles(userId, newRoles);
  }

  @override
  Future<UserEntity> deactivateUser(String userId) async {
    final user = _users[userId];
    if (user == null) {
      throw EntityNotFoundException(entityType: 'User', identifier: userId);
    }

    final updatedUser = user.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );

    return update(updatedUser);
  }

  @override
  Future<UserEntity> reactivateUser(String userId) async {
    final user = _users[userId];
    if (user == null) {
      throw EntityNotFoundException(entityType: 'User', identifier: userId);
    }

    final updatedUser = user.copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );

    return update(updatedUser);
  }

  @override
  Future<List<UserEntity>> searchUsers(
    String query, {
    int? limit,
    bool onlyActive = true,
  }) async {
    var users = _users.values.where((user) {
      if (onlyActive && !user.isActive) return false;
      return user.email.toLowerCase().contains(query.toLowerCase()) ||
             (user.displayName?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    if (limit != null) {
      users = users.take(limit).toList();
    }

    return users;
  }

  @override
  Future<bool> isEmailAvailable(String email) async {
    return !_users.values.any((user) => user.email == email);
  }

  @override
  Future<List<UserEntity>> getUsersByRole(String role) async {
    return _users.values.where((user) => user.roles.contains(role)).toList();
  }

  @override
  Future<List<UserEntity>> getUsersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _users.values.where((user) {
      return user.createdAt.isAfter(startDate) && user.createdAt.isBefore(endDate);
    }).toList();
  }

  @override
  Future<UserEntity> verifyEmail(String userId) async {
    final user = _users[userId];
    if (user == null) {
      throw EntityNotFoundException(entityType: 'User', identifier: userId);
    }

    final updatedUser = user.copyWith(
      isEmailVerified: true,
      updatedAt: DateTime.now(),
    );

    return update(updatedUser);
  }

  @override
  Future<UserEntity> unverifyEmail(String userId) async {
    final user = _users[userId];
    if (user == null) {
      throw EntityNotFoundException(entityType: 'User', identifier: userId);
    }

    final updatedUser = user.copyWith(
      isEmailVerified: false,
      updatedAt: DateTime.now(),
    );

    return update(updatedUser);
  }

  @override
  Stream<UserEntity?> watchCurrentUser() {
    return Stream.value(null);
  }

  @override
  Stream<List<UserEntity>> watchUsersByRole(String role) {
    return watchAll().map((users) => users.where((user) => user.roles.contains(role)).toList());
  }

  @override
  Stream<List<UserEntity>> watchSearchResults(
    String query, {
    int? limit,
    bool onlyActive = true,
  }) {
    return watchAll().asyncMap((_) => searchUsers(query, limit: limit, onlyActive: onlyActive));
  }

  // Batch operations
  @override
  Future<List<UserEntity>> createBatch(List<UserEntity> entities) async {
    final results = <UserEntity>[];
    for (final entity in entities) {
      results.add(await create(entity));
    }
    return results;
  }

  @override
  Future<List<UserEntity>> updateBatch(List<UserEntity> entities) async {
    final results = <UserEntity>[];
    for (final entity in entities) {
      results.add(await update(entity));
    }
    return results;
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    for (final id in ids) {
      await delete(id);
    }
  }

  @override
  Future<int> count() async {
    return _users.length;
  }

  @override
  Future<void> clear() async {
    _users.clear();
    _notifyAllUsersChanged();
    for (final controller in _userControllers.values) {
      controller.add(null);
    }
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
    for (final userId in userIds) {
      final user = _users[userId];
      if (user != null) {
        final newRoles = Set<String>.from(user.roles)..addAll(roles);
        await updateRoles(userId, newRoles.toList());
      }
    }
  }

  @override
  Future<void> deactivateUsers(List<String> userIds) async {
    for (final userId in userIds) {
      await deactivateUser(userId);
    }
  }

  @override
  Future<Map<String, dynamic>> exportUsers({
    List<String>? userIds,
    bool includeMetadata = false,
  }) async {
    var users = _users.values.toList();

    if (userIds != null && userIds.isNotEmpty) {
      users = users.where((user) => userIds.contains(user.id)).toList();
    }

    final userData = users.map((user) {
      final json = user.toJson();
      if (!includeMetadata) {
        json.remove('metadata');
      }
      return json;
    }).toList();

    return {
      'users': userData,
      'exported_at': DateTime.now().toIso8601String(),
      'count': userData.length,
    };
  }

  @override
  Future<List<UserEntity>> importUsers(
    Map<String, dynamic> userData, {
    bool updateExisting = false,
  }) async {
    final usersList = userData['users'] as List<dynamic>;
    final results = <UserEntity>[];

    for (final userJson in usersList) {
      final entity = UserEntity.fromJson(userJson as Map<String, dynamic>);

      if (_users.containsKey(entity.id)) {
        if (updateExisting) {
          results.add(await update(entity));
        }
      } else {
        results.add(await create(entity));
      }
    }

    return results;
  }

  // Helper methods for testing
  void _notifyAllUsersChanged() {
    _allUsersController.add(_users.values.toList());
  }

  void _notifyUserChanged(String id, UserEntity? user) {
    if (_userControllers.containsKey(id)) {
      _userControllers[id]!.add(user);
    }
  }

  void dispose() {
    _allUsersController.close();
    for (final controller in _userControllers.values) {
      controller.close();
    }
    _userControllers.clear();
  }

  // Test utilities
  void seedUser(UserEntity user) {
    _users[user.id] = user;
  }

  void seedUsers(List<UserEntity> users) {
    for (final user in users) {
      _users[user.id] = user;
    }
  }

  Map<String, UserEntity> get allUsers => Map.unmodifiable(_users);
}