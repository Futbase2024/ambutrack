# Integración de Roles con GoRouter

## 📋 Resumen

Este documento explica cómo integrar el sistema de roles con GoRouter para proteger rutas según los permisos del usuario.

## 🎯 Objetivo

Implementar un sistema de protección de rutas que:
- Verifica el rol del usuario antes de navegar
- Redirige a una página de error si no tiene permisos
- Mantiene la experiencia de usuario fluida
- Utiliza el `RoleService` para validaciones

## 🔧 Paso 1: Crear RoleGuard

Primero, necesitamos crear un guard similar a `AuthGuard` pero para verificar permisos de roles:

```dart
// lib/core/router/role_guard.dart
import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Guard para proteger rutas basado en roles y permisos
class RoleGuard {
  /// Verifica si el usuario tiene acceso a una ruta específica
  static Future<String?> redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final String location = state.matchedLocation;

    // Rutas públicas que no requieren verificación de rol
    if (location == '/login' || location == '/unauthorized') {
      return null;
    }

    try {
      final RoleService roleService = getIt<RoleService>();

      // Verificar si tiene acceso a la ruta
      final bool hasAccess = await roleService.hasAccessToRoute(location);

      if (!hasAccess) {
        debugPrint('🔐 RoleGuard: Acceso denegado a $location');
        return '/unauthorized';
      }

      debugPrint('🔐 RoleGuard: Acceso concedido a $location');
      return null; // Permite el acceso
    } catch (e) {
      debugPrint('🔐 RoleGuard: ❌ Error al verificar permisos: $e');
      return '/unauthorized';
    }
  }

  /// Verifica si el usuario tiene acceso a un módulo específico
  static Future<bool> hasAccessToModule(AppModule module) async {
    try {
      final RoleService roleService = getIt<RoleService>();
      return await roleService.hasAccessToModule(module);
    } catch (e) {
      debugPrint('🔐 RoleGuard: ❌ Error al verificar módulo: $e');
      return false;
    }
  }
}
```

## 🔧 Paso 2: Actualizar app_router.dart

Agregar el `RoleGuard` a las rutas protegidas:

```dart
// lib/core/router/app_router.dart
import 'package:ambutrack_web/core/router/auth_guard.dart';
import 'package:ambutrack_web/core/router/role_guard.dart'; // ← Agregar import

final GoRouter appRouter = GoRouter(
  redirect: (BuildContext context, GoRouterState state) async {
    // 1. Primero verificar autenticación
    final String? authRedirect = AuthGuard.redirect(context, state);
    if (authRedirect != null) {
      return authRedirect; // Usuario no autenticado → /login
    }

    // 2. Luego verificar permisos de rol
    final String? roleRedirect = await RoleGuard.redirect(context, state);
    if (roleRedirect != null) {
      return roleRedirect; // Sin permisos → /unauthorized
    }

    return null; // Todo OK, permite navegar
  },
  refreshListenable: GoRouterRefreshStream(
    getIt<AuthRepository>().authStateChanges,
  ),
  routes: <RouteBase>[
    // ... rutas existentes
  ],
);
```

## 🔧 Paso 3: Crear página de No Autorizado

```dart
// lib/core/widgets/unauthorized_page.dart
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página mostrada cuando el usuario no tiene permisos para acceder
class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingXl),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Icono de advertencia
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingXl),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: AppColors.warning,
                ),
              ),

              const SizedBox(height: AppSizes.spacingLarge),

              // Título
              Text(
                'Acceso Restringido',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.spacing),

              // Mensaje
              Text(
                'No tienes permisos para acceder a esta sección.\n'
                'Contacta con el administrador si crees que esto es un error.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondaryLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.spacingLarge),

              // Botón volver al inicio
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Volver al Inicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXl,
                    vertical: AppSizes.paddingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 🔧 Paso 4: Agregar ruta /unauthorized

```dart
// lib/core/router/app_router.dart

GoRoute(
  path: '/unauthorized',
  name: 'unauthorized',
  builder: (BuildContext context, GoRouterState state) {
    return const UnauthorizedPage();
  },
),
```

## 🔧 Paso 5: Filtrar menú según rol

Actualizar el menú para mostrar solo las opciones permitidas:

```dart
// lib/features/menu/presentation/widgets/menu_drawer.dart
import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:ambutrack_web/core/di/locator.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  final RoleService _roleService = getIt<RoleService>();
  List<AppModule> _allowedModules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllowedModules();
  }

  Future<void> _loadAllowedModules() async {
    try {
      final List<AppModule> modules = await _roleService.getAllowedModules();
      if (mounted) {
        setState(() {
          _allowedModules = modules;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar módulos permitidos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _canShowMenuItem(AppModule module) {
    return _allowedModules.contains(module);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Text(
              'AmbuTrack',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          // Dashboard (siempre visible)
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => context.go('/'),
          ),

          // Personal (solo si tiene permiso)
          if (_canShowMenuItem(AppModule.personal))
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Personal'),
              onTap: () => context.go('/personal'),
            ),

          // Vehículos (solo si tiene permiso)
          if (_canShowMenuItem(AppModule.vehiculos))
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Vehículos'),
              onTap: () => context.go('/vehiculos'),
            ),

          // ... más items del menú
        ],
      ),
    );
  }
}
```

## 🔧 Paso 6: Verificar permisos en tiempo de ejecución

Para acciones específicas dentro de una página:

```dart
// Ejemplo: Mostrar botón de eliminar solo si es admin
import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:ambutrack_web/core/di/locator.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final RoleService _roleService = getIt<RoleService>();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final bool isAdmin = await _roleService.isAdmin();
    if (mounted) {
      setState(() {
        _canDelete = isAdmin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // Contenido de la página

          // Botón eliminar (solo admin)
          if (_canDelete)
            ElevatedButton(
              onPressed: _onDelete,
              child: const Text('Eliminar'),
            ),
        ],
      ),
    );
  }

  void _onDelete() {
    // Lógica de eliminación
  }
}
```

## 📊 Flujo de Verificación

```
Usuario navega a /personal
    ↓
AuthGuard verifica autenticación
    ↓ (autenticado)
RoleGuard verifica permisos
    ↓
RoleService.hasAccessToRoute('/personal')
    ↓
Obtiene PersonalEntity del usuario
    ↓
Extrae categoria (rol)
    ↓
UserRole.fromString(categoria)
    ↓
RolePermissions.hasAccessToRoute(role, '/personal')
    ↓
¿Tiene acceso?
    ├─ Sí → Navega a la página
    └─ No → Redirige a /unauthorized
```

## ✅ Checklist de Integración

- [ ] Crear `RoleGuard` en `lib/core/router/role_guard.dart`
- [ ] Actualizar `app_router.dart` con verificación de roles
- [ ] Crear `UnauthorizedPage` en `lib/core/widgets/unauthorized_page.dart`
- [ ] Agregar ruta `/unauthorized`
- [ ] Actualizar menú para filtrar según permisos
- [ ] Probar navegación con diferentes roles
- [ ] Verificar que admin tiene acceso a todo
- [ ] Verificar que operador solo tiene lectura
- [ ] Verificar redirección correcta cuando no hay permisos

## 🧪 Testing

```dart
// test/core/router/role_guard_test.dart
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/router/role_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoleGuard', () {
    test('Admin tiene acceso a todas las rutas', () async {
      // Setup: Mock RoleService con rol admin

      // Act: Verificar acceso a ruta protegida
      final String? redirect = await RoleGuard.redirect(context, state);

      // Assert: No debería redirigir
      expect(redirect, isNull);
    });

    test('Operador es redirigido de rutas protegidas', () async {
      // Setup: Mock RoleService con rol operador

      // Act: Verificar acceso a ruta de administración
      final String? redirect = await RoleGuard.redirect(context, state);

      // Assert: Debería redirigir a /unauthorized
      expect(redirect, equals('/unauthorized'));
    });
  });
}
```

## 📝 Notas Importantes

1. **Performance**: El `RoleService` tiene cache de 5 minutos para evitar consultas repetidas
2. **Seguridad**: Siempre verificar permisos en backend también (RLS en Supabase)
3. **UX**: Mantener la navegación fluida, evitar múltiples redirects
4. **Debugging**: Usar `debugPrint` para rastrear verificaciones de permisos

## 🔗 Referencias

- [Sistema de Roles - Documentación completa](./sistema_roles.md)
- [Ejemplo de Administración de Usuarios](./ejemplo_admin_usuarios.md)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
