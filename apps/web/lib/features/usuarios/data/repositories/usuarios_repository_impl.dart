import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/auth_service.dart';
import '../../domain/repositories/usuarios_repository.dart';

// Instancia de GetIt para DI
final GetIt getIt = GetIt.instance;

/// Implementación del repositorio de usuarios
///
/// Patrón: Pass-through directo al datasource + operaciones de auth
@LazySingleton(as: UsuariosRepository)
class UsuariosRepositoryImpl implements UsuariosRepository {
  UsuariosRepositoryImpl()
      : _dataSource = UsuarioDataSourceFactory.createSupabase(),
        _authService = getIt<AuthService>(),
        _supabase = Supabase.instance.client;

  final UsuarioDataSource _dataSource;
  final AuthService _authService;
  final SupabaseClient _supabase;

  @override
  Future<List<UserEntity>> getAll() async {
    debugPrint('📦 UsuariosRepository: Solicitando todos los usuarios');
    return _dataSource.getAll();
  }

  @override
  Future<UserEntity?> getById(String id) async {
    debugPrint('📦 UsuariosRepository: Buscando usuario por ID: $id');
    return _dataSource.getById(id);
  }

  @override
  Future<UserEntity> create(UserEntity usuario, String password) async {
    debugPrint('📦 UsuariosRepository: Creando usuario ${usuario.email}');

    try {
      // Extraer nombre y apellidos del displayName
      String? nombre;
      String? apellidos;
      if (usuario.displayName != null && usuario.displayName!.isNotEmpty) {
        final List<String> parts = usuario.displayName!.trim().split(' ');
        if (parts.length >= 2) {
          nombre = parts.first;
          apellidos = parts.sublist(1).join(' ');
        } else {
          nombre = usuario.displayName;
        }
      }

      // ⚠️ Guardar sesión del admin ANTES de signUp
      // signUp() cambia la sesión activa al nuevo usuario
      final Session? adminSession = _supabase.auth.currentSession;
      final String? adminRefreshToken = adminSession?.refreshToken;
      debugPrint('  → Sesión del admin guardada');

      // 1. Crear en auth.users con metadata (nombre, apellidos, dni)
      debugPrint('  → Paso 1: Creando en auth.users');
      final AuthResult<AuthResponse> authResult =
          await _authService.signUpWithMetadata(
        email: usuario.email,
        password: password,
        nombre: nombre,
        apellidos: apellidos,
        dni: usuario.dni,
      );

      if (authResult.isFailure) {
        debugPrint('❌ UsuariosRepository: Error en auth.users - ${authResult.error}');
        throw authResult.error!;
      }

      final String authUserId = authResult.data!.user!.id;
      debugPrint('  ✅ Usuario creado en auth.users con ID: $authUserId');

      // 2. Restaurar sesión del admin INMEDIATAMENTE
      if (adminRefreshToken != null) {
        debugPrint('  → Restaurando sesión del admin...');
        await _supabase.auth.setSession(adminRefreshToken);
        debugPrint('  ✅ Sesión del admin restaurada');
      }

      // 3. Auto-confirmar email del usuario creado
      debugPrint('  → Paso 2: Auto-confirmando email del usuario');
      try {
        await _supabase.rpc<bool>(
          'auto_confirm_user',
          params: <String, dynamic>{'user_id': authUserId},
        );
        debugPrint('  ✅ Email confirmado automáticamente');
      } catch (e) {
        debugPrint('  ⚠️ No se pudo auto-confirmar email: $e');
        // No bloqueamos la creación por esto
      }

      // 4. Actualizar en tabla usuarios
      // El trigger on_auth_user_created ya insertó una fila básica con
      // los datos del metadata que pasamos a signUp.
      // Hacemos un UPDATE con todos los datos completos (rol, empresa, etc.)
      debugPrint('  → Paso 2: Actualizando en tabla usuarios con datos completos');
      final UserEntity usuarioCompleto = UserEntity(
        id: authUserId,
        email: usuario.email,
        displayName: usuario.displayName,
        photoUrl: usuario.photoUrl,
        phoneNumber: usuario.phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: usuario.activo ?? true,
        roles: usuario.rol != null ? <String>[usuario.rol!] : const <String>[],
        metadata: <String, dynamic>{
          'empresaId': usuario.empresaId,
          'empresaNombre': usuario.empresaNombre,
          'dni': usuario.dni,
          if (usuario.personalId != null) 'personalId': usuario.personalId,
        },
      );

      final UserEntity usuarioCreado = await _dataSource.update(usuarioCompleto);
      debugPrint('✅ UsuariosRepository: Usuario creado completamente');

      return usuarioCreado;
    } catch (e) {
      debugPrint('❌ UsuariosRepository: Error al crear usuario - $e');

      // Intentar restaurar sesión del admin en caso de error
      try {
        final Session? adminSession = _supabase.auth.currentSession;
        if (adminSession == null) {
          debugPrint('  ⚠️ Intentando restaurar sesión del admin tras error...');
          // Intentar refrescar sesión para recuperar
          await _supabase.auth.refreshSession();
        }
      } catch (_) {
        // No propagar error de restauración
      }

      rethrow;
    }
  }

  @override
  Future<UserEntity> update(UserEntity usuario) async {
    debugPrint('📦 UsuariosRepository: Actualizando usuario ${usuario.uid}');
    return _dataSource.update(usuario);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 UsuariosRepository: Eliminando usuario $id');

    try {
      // 1. Eliminar de tabla usuarios
      debugPrint('  → Paso 1: Eliminando de tabla usuarios');
      await _dataSource.delete(id);
      debugPrint('  ✅ Eliminado de tabla usuarios');

      // 2. Eliminar de auth.users usando Admin API
      debugPrint('  → Paso 2: Eliminando de auth.users (Admin API)');
      await _supabase.auth.admin.deleteUser(id);
      debugPrint('  ✅ Eliminado de auth.users');

      debugPrint('✅ UsuariosRepository: Usuario eliminado completamente');
    } catch (e) {
      debugPrint('❌ UsuariosRepository: Error al eliminar usuario - $e');
      rethrow;
    }
  }

  @override
  Future<void> cambiarEstado(String id, {required bool activo}) async {
    debugPrint('📦 UsuariosRepository: Cambiando estado de usuario $id a ${activo ? 'activo' : 'inactivo'}');
    return _dataSource.cambiarEstado(id, activo);
  }

  @override
  Future<void> resetearPassword(String userId, String newPassword) async {
    debugPrint('📦 UsuariosRepository: Reseteando contraseña de usuario $userId');

    try {
      // Usar Admin API de Supabase para cambiar password de otro usuario
      await _supabase.auth.admin.updateUserById(
        userId,
        attributes: AdminUserAttributes(password: newPassword),
      );
      debugPrint('✅ UsuariosRepository: Contraseña reseteada correctamente');
    } catch (e) {
      debugPrint('❌ UsuariosRepository: Error al resetear contraseña - $e');
      rethrow;
    }
  }

  @override
  Future<List<UserEntity>> getByRol(String rol) async {
    debugPrint('📦 UsuariosRepository: Obteniendo usuarios por rol: $rol');
    return _dataSource.getByRol(rol);
  }

  @override
  Future<List<UserEntity>> getByEmpresa(String empresaId) async {
    debugPrint('📦 UsuariosRepository: Obteniendo usuarios por empresa: $empresaId');
    return _dataSource.getByEmpresa(empresaId);
  }

  @override
  Future<List<UserEntity>> searchByEmailOrDni(String query) async {
    debugPrint('📦 UsuariosRepository: Buscando usuarios por: $query');
    return _dataSource.searchByEmailOrDni(query);
  }
}
