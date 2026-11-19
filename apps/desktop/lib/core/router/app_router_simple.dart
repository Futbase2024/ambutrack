import 'dart:async';

import 'package:ambutrack_desktop/core/di/locator.dart';
import 'package:ambutrack_desktop/core/layout/main_layout_simple.dart';
import 'package:ambutrack_desktop/core/widgets/placeholder_page.dart';
import 'package:ambutrack_desktop/features/auth/domain/repositories/auth_repository.dart';
import 'package:ambutrack_desktop/features/auth/presentation/pages/login_page.dart';
import 'package:ambutrack_desktop/features/error/pages/forbidden_page.dart';
import 'package:ambutrack_desktop/features/home/home_page_integral.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transición profesional Fade + Scale para todas las páginas
Page<T> _buildPageWithTransition<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

/// Configuración simplificada del enrutamiento para Desktop
/// Solo incluye las rutas básicas: login, home, error
/// TODO(dev): Agregar más rutas cuando se copien las features correspondientes
final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/home',
  redirect: (BuildContext context, GoRouterState state) {
    return authGuardSimple(context, state);
  },
  routes: <RouteBase>[
    // Ruta de login
    GoRoute(
      path: '/login',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return _buildPageWithTransition<void>(
          key: state.pageKey,
          child: const LoginPage(),
        );
      },
    ),

    // Rutas protegidas (requieren autenticación)
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainLayoutSimple(child: child);
      },
      routes: <RouteBase>[
        // Home
        GoRoute(
          path: '/home',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _buildPageWithTransition<void>(
              key: state.pageKey,
              child: const HomePageIntegral(),
            );
          },
        ),

        // TODO(dev): Agregar más rutas aquí cuando se copien las features
        // Ejemplo de placeholder para futuras páginas
        GoRoute(
          path: '/vehiculos',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _buildPageWithTransition<void>(
              key: state.pageKey,
              child: const PlaceholderPage(
                title: 'Vehículos',
                subtitle: 'Esta página se agregará próximamente',
              ),
            );
          },
        ),

        GoRoute(
          path: '/personal',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _buildPageWithTransition<void>(
              key: state.pageKey,
              child: const PlaceholderPage(
                title: 'Personal',
                subtitle: 'Esta página se agregará próximamente',
              ),
            );
          },
        ),

        // Página de acceso denegado
        GoRoute(
          path: '/forbidden',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _buildPageWithTransition<void>(
              key: state.pageKey,
              child: const ForbiddenPage(),
            );
          },
        ),
      ],
    ),
  ],

  // Manejo de errores
  errorBuilder: (BuildContext context, GoRouterState state) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              '404 - Página no encontrada',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('La página que buscas no existe'),
          ],
        ),
      ),
    );
  },
);

/// AuthGuard simplificado para Desktop
FutureOr<String?> authGuardSimple(BuildContext context, GoRouterState state) {
  final AuthRepository authRepository = getIt<AuthRepository>();
  final bool isAuthenticated = authRepository.isAuthenticated;
  final bool isLoginRoute = state.matchedLocation == '/login';

  // Si está autenticado y trata de ir a login, redirigir a home
  if (isAuthenticated && isLoginRoute) {
    return '/home';
  }

  // Si no está autenticado y no está en login, redirigir a login
  if (!isAuthenticated && !isLoginRoute) {
    return '/login';
  }

  // Permitir la navegación
  return null;
}
