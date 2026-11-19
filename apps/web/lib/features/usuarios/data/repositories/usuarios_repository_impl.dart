import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/usuarios_repository.dart';

/// Implementación del repositorio de usuarios
///
/// - Lecturas: pass-through a [UsuarioDataSource] (tabla `usuarios`, con RLS)
/// - Escrituras: pass-through a [CuentasUsuarioDataSource] (Edge Function
///   `admin-users`, que valida rol y jerarquía en servidor)
@LazySingleton(as: UsuariosRepository)
class UsuariosRepositoryImpl implements UsuariosRepository {
  UsuariosRepositoryImpl()
      : _dataSource = UsuarioDataSourceFactory.createSupabase(),
        _cuentas = CuentasUsuarioDataSourceFactory.createSupabase();

  final UsuarioDataSource _dataSource;
  final CuentasUsuarioDataSource _cuentas;

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
    final String id = await _cuentas.crear(usuario, password);
    return await _dataSource.getById(id) ?? usuario.copyWith(id: id);
  }

  @override
  Future<UserEntity> update(UserEntity usuario) async {
    debugPrint('📦 UsuariosRepository: Actualizando usuario ${usuario.uid}');
    await _cuentas.actualizar(usuario);
    return await _dataSource.getById(usuario.id) ?? usuario;
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 UsuariosRepository: Eliminando usuario $id');
    return _cuentas.eliminar(id);
  }

  @override
  Future<void> cambiarEstado(String id, {required bool activo}) async {
    debugPrint('📦 UsuariosRepository: ${activo ? 'Activando' : 'Desactivando'} usuario $id');
    return _cuentas.cambiarEstado(id, activo: activo);
  }

  @override
  Future<void> resetearPassword(String userId, String newPassword) async {
    debugPrint('📦 UsuariosRepository: Restableciendo clave de usuario $userId');
    return _cuentas.restablecerClave(userId, newPassword);
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
