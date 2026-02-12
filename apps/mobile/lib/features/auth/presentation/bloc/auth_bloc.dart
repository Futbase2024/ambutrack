import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC que maneja el estado de autenticación
///
/// Escucha los cambios de sesión de Supabase y mantiene
/// sincronizado el estado de autenticación de la app.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required UsuarioDataSource usuarioDataSource,
  })  : _authRepository = authRepository,
        _usuarioDataSource = usuarioDataSource,
        super(const AuthInitial()) {
    // Registrar handlers de eventos
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignInWithDniRequested>(_onAuthSignInWithDniRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Suscribirse a cambios de estado de autenticación
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        add(AuthStateChanged(user));
      },
    );
  }

  final AuthRepository _authRepository;
  final UsuarioDataSource _usuarioDataSource;
  StreamSubscription? _authStateSubscription;

  /// Handler para verificar sesión existente al iniciar
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🔍 [AuthBloc] Verificando sesión existente...');

      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        debugPrint('✅ [AuthBloc] Sesión encontrada: ${user.email}');

        // Cargar datos de personal
        final personal = await _usuarioDataSource.getById(user.id);

        if (personal != null) {
          debugPrint('✅ [AuthBloc] Datos de personal cargados: ${personal.nombreCompleto}');
        } else {
          debugPrint('⚠️ [AuthBloc] No se encontraron datos de personal para usuario_id: ${user.id}');
        }

        emit(AuthAuthenticated(user: user, personal: personal));
      } else {
        debugPrint('ℹ️ [AuthBloc] No hay sesión activa');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('❌ [AuthBloc] Error al verificar sesión: $e');
      emit(const AuthUnauthenticated());
    }
  }

  /// Handler para login
  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🔐 [AuthBloc] Iniciando login...');
      emit(const AuthLoading());

      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      debugPrint('✅ [AuthBloc] Login exitoso: ${user.email}');

      // Cargar datos de personal
      final personal = await _usuarioDataSource.getById(user.id);

      if (personal != null) {
        debugPrint('✅ [AuthBloc] Datos de personal cargados: ${personal.nombreCompleto}');
      } else {
        debugPrint('⚠️ [AuthBloc] No se encontraron datos de personal para usuario_id: ${user.id}');
      }

      emit(AuthAuthenticated(user: user, personal: personal));
    } catch (e) {
      debugPrint('❌ [AuthBloc] Error en login: $e');
      emit(AuthError(e.toString()));
      // Volver a unauthenticated después del error
      emit(const AuthUnauthenticated());
    }
  }

  /// Handler para login con DNI
  Future<void> _onAuthSignInWithDniRequested(
    AuthSignInWithDniRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🔐 [AuthBloc] Iniciando login con DNI: ${event.dni}');
      emit(const AuthLoading());

      // Buscar el email real del usuario por su DNI
      final email = await _authRepository.getEmailByDni(event.dni);

      if (email == null) {
        debugPrint('❌ [AuthBloc] DNI no encontrado: ${event.dni}');
        emit(const AuthError('DNI no encontrado en el sistema'));
        emit(const AuthUnauthenticated());
        return;
      }

      debugPrint('✅ [AuthBloc] Email encontrado para DNI: $email');

      // Autenticar con el email encontrado
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: event.password,
      );

      debugPrint('✅ [AuthBloc] Login exitoso: ${user.email}');

      // Cargar datos de personal
      final personal = await _usuarioDataSource.getById(user.id);

      if (personal != null) {
        debugPrint('✅ [AuthBloc] Datos de personal cargados: ${personal.nombreCompleto}');
      } else {
        debugPrint('⚠️ [AuthBloc] No se encontraron datos de personal para usuario_id: ${user.id}');
      }

      emit(AuthAuthenticated(user: user, personal: personal));
    } catch (e) {
      debugPrint('❌ [AuthBloc] Error en login con DNI: $e');
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  /// Handler para logout
  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🚪 [AuthBloc] Cerrando sesión...');
      emit(const AuthLoading());

      await _authRepository.signOut();

      debugPrint('✅ [AuthBloc] Sesión cerrada');
      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('❌ [AuthBloc] Error al cerrar sesión: $e');
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  /// Handler para cambios de estado de autenticación
  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      debugPrint('🔄 [AuthBloc] Estado cambiado: Autenticado');

      // Cargar datos de personal
      final personal = await _usuarioDataSource.getById(event.user!.id);

      if (personal != null) {
        debugPrint('✅ [AuthBloc] Datos de personal cargados: ${personal.nombreCompleto}');
      } else {
        debugPrint('⚠️ [AuthBloc] No se encontraron datos de personal para usuario_id: ${event.user!.id}');
      }

      emit(AuthAuthenticated(user: event.user!, personal: personal));
    } else {
      debugPrint('🔄 [AuthBloc] Estado cambiado: No autenticado');
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
