import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../users/entities/users_entity.dart';
import '../../auth_contract.dart';

/// Implementación de AuthDataSource usando Supabase
class SupabaseAuthDataSource implements AuthDataSource {
  SupabaseAuthDataSource() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Error al iniciar sesión');
    }

    return _mapSupabaseUserToEntity(response.user!);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _mapSupabaseUserToEntity(user);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? _mapSupabaseUserToEntity(user) : null;
    });
  }

  @override
  Future<bool> isAuthenticated() async {
    return _client.auth.currentUser != null;
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );

    if (response.user == null) {
      throw Exception('Error al registrar usuario');
    }

    return _mapSupabaseUserToEntity(response.user!);
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (photoUrl != null) updates['photo_url'] = photoUrl;

    if (updates.isNotEmpty) {
      await _client.auth.updateUser(UserAttributes(data: updates));
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Convierte un User de Supabase a UserEntity
  UserEntity _mapSupabaseUserToEntity(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};

    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      displayName: metadata['display_name'] as String?,
      photoUrl: metadata['photo_url'] as String?,
      phoneNumber: user.phone,
      isEmailVerified: user.emailConfirmedAt != null,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.now(),
      metadata: metadata.isNotEmpty ? metadata : null,
      roles: const <String>[],
      isActive: true,
    );
  }
}
