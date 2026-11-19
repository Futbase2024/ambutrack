import 'package:flutter/foundation.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../domain/repositories/auth_repository.dart';

/// Implementación del repositorio de autenticación
///
/// Actúa como pass-through directo al datasource sin conversiones.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({Future<void> Function()? alCerrarSesion})
      : _dataSource = AuthDataSourceFactory.createSupabase(),
        _cuentas = CuentasUsuarioDataSourceFactory.createSupabase(),
        _alCerrarSesion = alCerrarSesion;

  final AuthDataSource _dataSource;
  final CuentasUsuarioDataSource _cuentas;

  /// Se ejecuta con la sesión todavía abierta (p.ej. dar de baja el token push)
  final Future<void> Function()? _alCerrarSesion;

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    debugPrint('📦 [Repository] Solicitando login...');
    return await _dataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    debugPrint('📦 [Repository] Solicitando logout...');
    await _alCerrarSesion?.call();
    return await _dataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    debugPrint('📦 [Repository] Solicitando usuario actual...');
    return await _dataSource.getCurrentUser();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _dataSource.authStateChanges;
  }

  @override
  Future<String?> getEmailByDni(String dni) async {
    debugPrint('📦 [Repository] Buscando email por DNI...');
    return await _dataSource.getEmailByDni(dni);
  }

  @override
  Future<bool> debeCambiarClave() async {
    debugPrint('📦 [Repository] Comprobando si la clave es provisional...');
    return await _cuentas.debeCambiarClave();
  }

  @override
  Future<void> cambiarMiClave(String nuevaClave) async {
    debugPrint('📦 [Repository] Cambiando la clave propia...');
    return await _cuentas.cambiarMiClave(nuevaClave);
  }
}
