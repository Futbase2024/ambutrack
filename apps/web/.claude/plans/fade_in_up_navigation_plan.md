# Plan: Transiciones de Navegación Fade-In-Up

> **Fecha**: 2025-12-29
> **Objetivo**: Reemplazar las transiciones de slide lateral por animaciones fade-in-up suaves y elegantes
> **Archivos afectados**: ~10 archivos

---

## 📋 Resumen

Actualmente go_router usa las transiciones nativas de Cupertino (slide horizontal). Queremos implementar una transición personalizada **fade + slide vertical (desde abajo hacia arriba)** que sea elegante y consistente en toda la app.

---

## 🎯 Estrategia de Implementación

### Enfoque Centralizado en Core

Crear las transiciones en `lib/core/navigation/` para:
- Separación clara de concerns (navegación en core)
- Reutilización desde cualquier feature
- Extensible para futuras animaciones

---

## 📁 Archivos a Crear/Modificar

### 1. CREAR: `lib/core/navigation/fade_in_up_page.dart`
CustomTransitionPage con animación fade-in-up.

### 2. CREAR: `lib/core/navigation/navigation_constants.dart`
Constantes de duración, curvas y offsets.

### 3. MODIFICAR: Rutas de features
- `lib/presentation/features/auth/routes/auth_routes.dart`
- `lib/presentation/features/dashboard/routes/dashboard_routes.dart`
- `lib/presentation/features/ideas/routes/ideas_routes.dart`
- `lib/presentation/features/scripts/routes/scripts_routes.dart`
- `lib/presentation/features/calendar/routes/calendar_routes.dart`
- `lib/presentation/features/settings/routes/settings_routes.dart`

### 4. CREAR: Tests
- `test/unit/core/navigation/fade_in_up_page_test.dart`

---

## 🔧 Implementación Detallada

### Paso 1: Crear Constantes de Navegación

```dart
// lib/core/navigation/navigation_constants.dart
import 'package:flutter/animation.dart';

/// Constantes para animaciones de navegación
class NavigationConstants {
  NavigationConstants._();

  /// Duración de la transición de entrada
  static const Duration enterDuration = Duration(milliseconds: 300);

  /// Duración de la transición de salida
  static const Duration exitDuration = Duration(milliseconds: 250);

  /// Offset vertical del slide (en fracción de pantalla)
  static const double slideOffset = 0.05;

  /// Curva de entrada
  static const Curve enterCurve = Curves.easeOutCubic;

  /// Curva de salida
  static const Curve exitCurve = Curves.easeInCubic;
}
```

### Paso 2: Crear `FadeInUpPage` (CustomTransitionPage)

```dart
// lib/core/navigation/fade_in_up_page.dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'navigation_constants.dart';

/// Página con transición fade-in-up personalizada
///
/// Combina:
/// - Fade in (opacidad de 0 a 1)
/// - Slide up (desde abajo hacia posición original)
/// - Curva ease out cubic para suavidad
class FadeInUpPage<T> extends CustomTransitionPage<T> {
  FadeInUpPage({
    required super.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
          transitionDuration: NavigationConstants.enterDuration,
          reverseTransitionDuration: NavigationConstants.exitDuration,
          transitionsBuilder: _buildTransition,
        );

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: NavigationConstants.enterCurve,
      reverseCurve: NavigationConstants.exitCurve,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, NavigationConstants.slideOffset),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}
```

### Paso 3: Modificar Rutas de Features

Cada archivo de rutas usará `pageBuilder` en lugar de `builder`:

```dart
// Ejemplo: lib/presentation/features/ideas/routes/ideas_routes.dart
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/fade_in_up_page.dart';
import '../page/ideas_page.dart';

class IdeasRoute extends GoRouteData {
  const IdeasRoute();

  static const String name = 'ideas';
  static const String path = '/ideas';

  static GoRoute route({List<RouteBase> routes = const []}) {
    return GoRoute(
      name: name,
      path: path,
      pageBuilder: (context, state) => FadeInUpPage(
        key: state.pageKey,
        name: name,
        child: const IdeasPage(),
      ),
      routes: routes,
    );
  }

  static void go(BuildContext context) => context.goNamed(name);
  static Future<void> push(BuildContext context) => context.pushNamed(name);
}
```

---

## 📋 Checklist de Implementación

### Fase 1: Infraestructura
- [ ] Crear carpeta `lib/core/navigation/`
- [ ] Crear `navigation_constants.dart` con constantes
- [ ] Crear `fade_in_up_page.dart` con `FadeInUpPage`
- [ ] Ejecutar `dart fix --apply && dart analyze`

### Fase 2: Actualizar Rutas
- [ ] Actualizar `auth_routes.dart` (LoginRoute, RegisterRoute, ForgotPasswordRoute)
- [ ] Actualizar `dashboard_routes.dart`
- [ ] Actualizar `ideas_routes.dart`
- [ ] Actualizar `scripts_routes.dart`
- [ ] Actualizar `calendar_routes.dart`
- [ ] Actualizar `settings_routes.dart`
- [ ] Ejecutar `dart fix --apply && dart analyze`

### Fase 3: Testing
- [ ] Crear test para `FadeInUpPage`
- [ ] Verificar cobertura 85%+
- [ ] Ejecutar `flutter test --coverage`

### Fase 4: Verificación Final
- [ ] Probar navegación entre todas las pantallas
- [ ] Verificar transición en push y pop
- [ ] Verificar que back gesture funciona correctamente

---

## 🎨 Especificaciones de la Animación

| Propiedad | Valor |
|-----------|-------|
| Duración entrada | 300ms |
| Duración salida | 250ms |
| Curva entrada | `easeOutCubic` |
| Curva salida | `easeInCubic` |
| Offset vertical | 20px (0.2 en Offset) |
| Opacidad inicio | 0.0 |
| Opacidad final | 1.0 |

---

## 🔄 Estructura Final

```
lib/
└── core/
    └── navigation/
        ├── navigation_constants.dart # Constantes
        └── fade_in_up_page.dart      # CustomTransitionPage

test/
└── unit/
    └── core/
        └── navigation/
            └── fade_in_up_page_test.dart
```

---

## ⚠️ Consideraciones

1. **Shell Routes**: El `ShellRoute` para el `AppShellPage` no necesita transición ya que es el contenedor de tabs
2. **Back Gesture iOS**: Las transiciones custom mantienen el gesto de swipe back
3. **Performance**: Usar `CurvedAnimation` cached para evitar recreaciones
4. **Consistencia**: Aplicar la misma transición a TODAS las rutas para UX uniforme

---

## 📊 Estimación

- **Archivos nuevos**: 2 (navigation_constants.dart, fade_in_up_page.dart)
- **Archivos modificados**: 6 rutas
- **Tests nuevos**: 1
- **Complejidad**: Baja
