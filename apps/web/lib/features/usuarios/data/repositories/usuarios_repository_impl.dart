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
      // 1. Crear en auth.users usando AuthService
      debugPrint('  → Paso 1: Creando en auth.users');
      final AuthResult<AuthResponse> authResult = await _authService.signUpWithEmailAndPassword(
        email: usuario.email,
        password: password,
      );

      if (authResult.isFailure) {
        debugPrint('❌ UsuariosRepository: Error en auth.users - ${authResult.error}');
        throw authResult.error!;
      }

      final String authUserId = authResult.data!.user!.id;
      debugPrint('  ✅ Usuario creado en auth.users con ID: $authUserId');

      // 2. Crear en tabla usuarios con el ID generado por auth.users
      debugPrint('  → Paso 2: Creando en tabla usuarios');
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

      final UserEntity usuarioCreado = await _dataSource.create(usuarioCompleto);
      debugPrint('✅ UsuariosRepository: Usuario creado completamente');

      return usuarioCreado;
    } catch (e) {
      debugPrint('❌ UsuariosRepository: Error al crear usuario - $e');
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
