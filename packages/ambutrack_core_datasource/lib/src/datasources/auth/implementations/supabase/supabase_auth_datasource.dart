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

    return _buildUserEntity(response.user!);
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Alias de signInWithEmail para compatibilidad
    return signInWithEmail(email: email, password: password);
  }

  @override
  Future<String?> getEmailByDni(String dni) async {
    try {
      // Usar función RPC de Supabase (mismo método que usa web)
      // Esta función busca en la tabla usuarios con case-insensitive
      // y solo devuelve usuarios activos
      final String email = await _client.rpc<String>(
        'get_email_by_dni',
        params: <String, dynamic>{'dni_input': dni},
      );

      return email.isEmpty ? null : email;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _buildUserEntity(user);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      return user != null ? _buildUserEntity(user) : null;
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

    return _buildUserEntity(response.user!);
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

  /// Construye el UserEntity completando nombre, foto y rol con la tabla `usuarios`
  Future<UserEntity> _buildUserEntity(User user) async {
    Map<String, dynamic>? perfil;
    try {
      perfil = await _client
          .from('usuarios')
          .select('nombre, apellidos, rol, foto_url')
          .eq('id', user.id)
          .maybeSingle();
    } catch (_) {
      perfil = null;
    }
    return _mapSupabaseUserToEntity(user, perfil);
  }

  /// Convierte un User de Supabase a UserEntity
  UserEntity _mapSupabaseUserToEntity(User user, Map<String, dynamic>? perfil) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    final String? rol = _texto(perfil?['rol']);

    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      displayName: _nombreCompleto(perfil, metadata),
      photoUrl: _texto(perfil?['foto_url']) ?? _texto(metadata['photo_url']),
      phoneNumber: user.phone,
      isEmailVerified: user.emailConfirmedAt != null,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.now(),
      metadata: metadata.isNotEmpty ? metadata : null,
      roles: rol != null ? <String>[rol] : const <String>[],
      isActive: true,
    );
  }

  /// Nombre completo: tabla `usuarios` → metadatos (display_name, full_name, nombre + apellidos)
  static String? _nombreCompleto(Map<String, dynamic>? perfil, Map<String, dynamic> metadata) {
    final String? desdeTabla = _unir(perfil?['nombre'], perfil?['apellidos']);
    return desdeTabla ??
        _texto(metadata['display_name']) ??
        _texto(metadata['full_name']) ??
        _unir(metadata['nombre'], metadata['apellidos']);
  }

  static String? _unir(Object? nombre, Object? apellidos) {
    final String completo = <String?>[_texto(nombre), _texto(apellidos)].whereType<String>().join(' ');
    return completo.isEmpty ? null : completo;
  }

  static String? _texto(Object? valor) {
    if (valor is! String) return null;
    final String limpio = valor.trim();
    return limpio.isEmpty ? null : limpio;
  }
}
