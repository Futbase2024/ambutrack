import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Guard para proteger rutas que requieren autenticación y autorización
class AuthGuard {
  static final AuthRepository _authRepository = getIt<AuthRepository>();
  static final RoleService _roleService = getIt<RoleService>();

  /// Rutas que no requieren validación de permisos (accesibles por todos los usuarios autenticados)
  static const List<String> _publicAuthenticatedRoutes = <String>[
    '/',
    '/dashboard',
    '/perfil',
    '/403',
    '/logout',
  ];

  /// Verifica si el usuario está autenticado y tiene permisos antes de navegar
  static Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final bool isAuthenticated = _authRepository.isAuthenticated;
    final String currentRoute = state.matchedLocation;
    final bool isLoginRoute = currentRoute == '/login';

    debugPrint('🔐 AuthGuard - Verificando ruta: $currentRoute');
    debugPrint('🔐 AuthGuard - Autenticado: $isAuthenticated');

    // 1. Verificar autenticación básica
    if (!isAuthenticated && !isLoginRoute) {
      debugPrint('❌ AuthGuard - No autenticado, redirigiendo a /login');
      return '/login';
    }

    if (isAuthenticated && isLoginRoute) {
      debugPrint('✅ AuthGuard - Ya autenticado, redirigiendo a /');
      return '/';
    }

    // 2. Verificar permisos por rol (NUEVO)
    // Solo si está autenticado y no es una ruta pública
    if (isAuthenticated && !_isPublicRoute(currentRoute)) {
      try {
        debugPrint('🔍 AuthGuard - Validando permisos para: $currentRoute');

        final bool hasAccess = await _roleService.hasAccessToRoute(currentRoute);

        if (!hasAccess) {
          debugPrint('🚫 AuthGuard - Usuario sin permisos para: $currentRoute');
          return '/403';
        }

        debugPrint('✅ AuthGuard - Usuario tiene acceso a: $currentRoute');
      } catch (e) {
        debugPrint('❌ AuthGuard - Error al verificar permisos: $e');
        // En caso de error, redirigir a 403 por seguridad
        return '/403';
      }
    }

    // 3. Permitir navegación
    return null;
  }

  /// Verifica si la ruta es pública (no requiere validación de permisos)
  static bool _isPublicRoute(String route) {
    return _publicAuthenticatedRoutes.any((String publicRoute) => route == publicRoute);
  }
}