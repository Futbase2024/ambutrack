import '../../core/base_datasource.dart';
import 'entities/users_entity.dart';

/// Contract for user datasource operations
///
/// Extends [BaseDatasource] with user-specific operations
/// All implementations must adhere to this contract
abstract class UsersDataSource extends BaseDatasource<UserEntity> {
  /// Retrieves a user by their email address
  ///
  /// Returns null if no user exists with the given email
  Future<UserEntity?> getByEmail(String email);

  /// Updates user profile information
  ///
  /// Only updates the provided fields, leaving others unchanged
  /// Returns the updated user entity
  Future<UserEntity> updateProfile(
    String userId, {
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? metadata,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? locale,
    String? timezone,
  });

  /// Updates user roles
  ///
  /// Replaces the current roles with the provided list
  Future<UserEntity> updateRoles(String userId, List<String> roles);

  /// Adds a role to the user
  ///
  /// Does nothing if the role already exists
  Future<UserEntity> addRole(String userId, String role);

  /// Removes a role from the user
  ///
  /// Does nothing if the role doesn't exist
  Future<UserEntity> removeRole(String userId, String role);

  /// Deactivates a user account
  ///
  /// Sets isActive to false without deleting the user data
  Future<UserEntity> deactivateUser(String userId);

  /// Reactivates a user account
  ///
  /// Sets isActive to true
  Future<UserEntity> reactivateUser(String userId);

  /// Searches for users by display name or email
  ///
  /// Returns a list of users matching the search query
  /// [limit] - Maximum number of results to return
  /// [onlyActive] - Whether to include only active users
  Future<List<UserEntity>> searchUsers(
    String query, {
    int? limit,
    bool onlyActive = true,
  });

  /// Checks if an email address is available (not already used)
  ///
  /// Returns true if the email is available, false otherwise
  Future<bool> isEmailAvailable(String email);

  /// Retrieves users by their role
  ///
  /// Returns a list of users that have the specified role
  Future<List<UserEntity>> getUsersByRole(String role);

  /// Retrieves users created within a date range
  ///
  /// [startDate] - Start of the date range (inclusive)
  /// [endDate] - End of the date range (inclusive)
  Future<List<UserEntity>> getUsersByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Verifies a user's email address
  ///
  /// Sets isEmailVerified to true
  Future<UserEntity> verifyEmail(String userId);

  /// Unverifies a user's email address
  ///
  /// Sets isEmailVerified to false
  Future<UserEntity> unverifyEmail(String userId);

  /// Creates a stream that emits the current authenticated user
  ///
  /// This is typically used for real-time user session management
  Stream<UserEntity?> watchCurrentUser();

  /// Creates a stream that emits users with a specific role
  ///
  /// Useful for monitoring role-based user lists
  Stream<List<UserEntity>> watchUsersByRole(String role);

  /// Creates a stream that emits users matching a search query
  ///
  /// Updates in real-time as users are added, modified, or removed
  Stream<List<UserEntity>> watchSearchResults(
    String query, {
    int? limit,
    bool onlyActive = true,
  });

  /// Bulk updates user information
  ///
  /// Updates multiple users in a single operation
  /// Returns the list of updated users
  Future<List<UserEntity>> updateUsers(List<UserEntity> users);

  /// Bulk role assignment
  ///
  /// Assigns roles to multiple users efficiently
  Future<void> assignRolesToUsers(
    List<String> userIds,
    List<String> roles,
  );

  /// Bulk user deactivation
  ///
  /// Deactivates multiple users in a single operation
  Future<void> deactivateUsers(List<String> userIds);

  /// Exports user data
  ///
  /// Returns user data in a format suitable for export/backup
  /// [userIds] - Specific users to export, or null for all users
  /// [includeMetadata] - Whether to include user metadata
  Future<Map<String, dynamic>> exportUsers({
    List<String>? userIds,
    bool includeMetadata = false,
  });

  /// Imports user data
  ///
  /// Creates users from exported data
  /// [userData] - Map containing user data to import
  /// [updateExisting] - Whether to update existing users or skip them
  Future<List<UserEntity>> importUsers(
    Map<String, dynamic> userData, {
    bool updateExisting = false,
  });
}