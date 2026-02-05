import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Guard para proteger rutas que requieren autenticación
class AuthGuard {
  static final AuthRepository _authRepository = getIt<AuthRepository>();

  /// Verifica si el usuario está autenticado antes de navegar
  static String? redirect(BuildContext context, GoRouterState state) {
    final bool isAuthenticated = _authRepository.isAuthenticated;
    final bool isLoginRoute = state.matchedLocation == '/login';

    debugPrint('AuthGuard - isAuthenticated: $isAuthenticated, route: ${state.matchedLocation}');

    // Si el usuario NO está autenticado y NO está en login, redirigir a login
    if (!isAuthenticated && !isLoginRoute) {
      debugPrint('AuthGuard - Redirigiendo a /login');
      return '/login';
    }

    // Si el usuario SÍ está autenticado y está en login, redirigir a home
    if (isAuthenticated && isLoginRoute) {
      debugPrint('AuthGuard - Usuario autenticado, redirigiendo a /');
      return '/';
    }

    // En cualquier otro caso, permitir la navegación
    return null;
  }
}