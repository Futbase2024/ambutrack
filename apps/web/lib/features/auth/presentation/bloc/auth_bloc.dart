import 'dart:async';

import 'package:ambutrack_web/features/auth/domain/entities/user_entity.dart';
import 'package:ambutrack_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para manejar la autenticación
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);

    // Suscribirse a cambios de estado de autenticación
    _authStateSubscription = _authRepository.authStateChanges.listen((UserEntity? user) {
      add(const AuthCheckRequested());
    });
  }

  final AuthRepository _authRepository;
  StreamSubscription<dynamic>? _authStateSubscription;

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final UserEntity? user = _authRepository.currentUser;
    if (user != null) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔐 USUARIO AUTENTICADO');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('   📧 Email: ${user.email}');
      debugPrint('   🆔 UID: ${user.uid}');
      debugPrint('   🏢 Empresa ID: ${user.empresaId ?? "NO ASIGNADA"}');
      debugPrint('   👤 Nombre: ${user.displayName ?? "Sin nombre"}');
      debugPrint('═══════════════════════════════════════════════════════');
      emit(AuthAuthenticated(user: user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      debugPrint('🔐 AuthBloc: Intentando login con ${event.email}');
      final UserEntity user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('✅ LOGIN EXITOSO');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('   📧 Email: ${user.email}');
      debugPrint('   🆔 UID: ${user.uid}');
      debugPrint('   🏢 Empresa ID: ${user.empresaId ?? "NO ASIGNADA"}');
      debugPrint('   👤 Nombre: ${user.displayName ?? "Sin nombre"}');
      debugPrint('═══════════════════════════════════════════════════════');
      emit(AuthAuthenticated(user: user));
    } on Exception catch (e) {
      debugPrint('❌ AuthBloc: Error en login - $e');
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } on Exception catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      debugPrint('📝 AuthBloc: Intentando signup con ${event.email}');
      final UserEntity user = await _authRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      debugPrint('✅ AuthBloc: Signup exitoso - User UID: ${user.uid}');
      emit(AuthAuthenticated(user: user));
    } on Exception catch (e) {
      debugPrint('❌ AuthBloc: Error en signup - $e');
      debugPrint('❌ AuthBloc: Error completo - ${e.toString()}');
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.resetPassword(email: event.email);
      emit(AuthPasswordResetSent(email: event.email));
    } on Exception catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  String _getErrorMessage(Object error) {
    final String errorString = error.toString().toLowerCase();

    // Supabase Auth error codes
    if (errorString.contains('invalid_credentials') || errorString.contains('invalid login credentials')) {
      return 'Correo electrónico o contraseña incorrectos';
    } else if (errorString.contains('user_not_found') || errorString.contains('user not found')) {
      return 'No existe una cuenta con este correo electrónico';
    } else if (errorString.contains('email_not_confirmed')) {
      return 'Por favor confirma tu correo electrónico antes de iniciar sesión';
    } else if (errorString.contains('user_already_exists') || errorString.contains('already registered')) {
      return 'Ya existe una cuenta con este correo electrónico';
    } else if (errorString.contains('weak_password') || errorString.contains('password should be')) {
      return 'La contraseña es demasiado débil. Debe tener al menos 6 caracteres';
    } else if (errorString.contains('invalid_email') || errorString.contains('invalid email')) {
      return 'Correo electrónico inválido';
    } else if (errorString.contains('user_banned') || errorString.contains('banned')) {
      return 'Esta cuenta ha sido suspendida';
    } else if (errorString.contains('over_email_send_rate_limit') || errorString.contains('rate limit')) {
      return 'Demasiados intentos. Intenta de nuevo más tarde';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Error de conexión. Verifica tu internet';
    } else if (errorString.contains('session_not_found')) {
      return 'Sesión expirada. Por favor inicia sesión nuevamente';
    } else if (errorString.contains('refresh_token_not_found')) {
      return 'Sesión expirada. Por favor inicia sesión nuevamente';
    }

    return 'Ha ocurrido un error. Intenta de nuevo';
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}