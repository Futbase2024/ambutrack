import 'package:flutter/foundation.dart';
import 'package:ambutrack_core/ambutrack_core.dart';

import '../../domain/repositories/auth_repository.dart';

/// Implementación del repositorio de autenticación
///
/// Actúa como pass-through directo al datasource sin conversiones.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl() : _dataSource = AuthDataSourceFactory.createSupabase();

  final AuthDataSource _dataSource;

  @override
  Future<AuthUserEntity> signInWithEmailAndPassword({
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
    return await _dataSource.signOut();
  }

  @override
  Future<AuthUserEntity?> getCurrentUser() async {
    debugPrint('📦 [Repository] Solicitando usuario actual...');
    return await _dataSource.getCurrentUser();
  }

  @override
  Stream<AuthUserEntity?> get authStateChanges {
    return _dataSource.authStateChanges;
  }

  @override
  Future<String?> getEmailByDni(String dni) async {
    debugPrint('📦 [Repository] Buscando email por DNI...');
    return await _dataSource.getEmailByDni(dni);
  }
}
