# 📱 Plan: Sistema de Layouts Responsivos

> **Fecha**: 2025-12-29
> **Feature**: Sistema de Layouts Responsivos con AppLayoutBuilder
> **Prioridad**: Alta
> **Estado**: ✅ Completado

---

## 🎯 Objetivo

Implementar un sistema completo de layouts responsivos que permita adaptar la UI a diferentes form factors (Mobile, Tablet, Desktop) siguiendo los principios de diseño Apple y actualizar la documentación del agente UI/UX Designer.

---

## 📋 Entregables

### 1. AppLayoutBuilder Widget
- Widget principal para manejar layouts responsivos
- Breakpoints definidos: Mobile (<600dp), Tablet (600-1024dp), Desktop (>1024dp)
- Soporte para portrait y landscape

### 2. Actualización uiux_designer.md
- Documentación completa del sistema de responsividad
- Templates para cada tipo de layout
- Patrones de navegación por form factor
- Checklist de responsividad

---

## 🏗️ Arquitectura

### Breakpoints
```
┌─────────────────────────────────────────────────────────────────┐
│                        BREAKPOINTS                               │
├─────────────────────────────────────────────────────────────────┤
│  Mobile    │  < 600dp    │  Smartphones                         │
│  Tablet    │  600-1024dp │  iPad Portrait, Android Tablets      │
│  Desktop   │  > 1024dp   │  iPad Landscape, macOS, Web          │
└─────────────────────────────────────────────────────────────────┘
```

### Estructura de Carpetas por Feature
```
lib/presentation/features/{feature}/
├── bloc/
├── pages/              ← PLURAL (puede haber varias)
│   └── {feature}_page.dart
├── widgets/
├── routes/
└── layouts/            ← NUEVA CARPETA
    ├── {feature}_mobile_layout.dart
    ├── {feature}_tablet_layout.dart
    └── {feature}_desktop_layout.dart
```

### Patrones de Navegación por Form Factor

**Mobile:**
- CupertinoTabScaffold con bottom tabs
- Stack de páginas simple
- Menú hamburguesa para navegación secundaria
- Full width content

**Tablet:**
- Master-detail layout
- Split view (lista + detalle)
- Tabs en toolbar
- Aprovecha espacio horizontal

**Desktop:**
- Sidebar persistente
- Multi-panel layout
- Área de contenido amplia
- Navegación lateral siempre visible

---

## 📁 Archivos a Crear/Modificar

### Crear
| Archivo | Descripción |
|---------|-------------|
| `lib/presentation/shared/layouts/app_layout_builder.dart` | Widget principal responsivo |
| `lib/presentation/shared/layouts/layout_breakpoints.dart` | Constantes y helpers de breakpoints |

### Modificar
| Archivo | Cambios |
|---------|---------|
| `.claude/agents/uiux_designer.md` | Agregar documentación completa del sistema |

---

## 🔧 Implementación

### Paso 1: Crear Layout Breakpoints
```dart
// lib/presentation/shared/layouts/layout_breakpoints.dart
class LayoutBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;

  // Helpers para detectar form factor
  static bool isMobile(BuildContext context);
  static bool isTablet(BuildContext context);
  static bool isDesktop(BuildContext context);

  // Helper para orientación
  static bool isPortrait(BuildContext context);
  static bool isLandscape(BuildContext context);
}
```

### Paso 2: Crear AppLayoutBuilder
```dart
// lib/presentation/shared/layouts/app_layout_builder.dart
class AppLayoutBuilder extends StatelessWidget {
  const AppLayoutBuilder({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    // Usar LayoutBuilder + breakpoints
    // Retornar el layout apropiado
  }
}
```

### Paso 3: Actualizar uiux_designer.md
Agregar secciones:
1. Sistema de Responsividad (breakpoints)
2. AppLayoutBuilder (código completo)
3. Templates para cada layout
4. Patrones de navegación
5. Checklist de responsividad
6. Ejemplos de uso

---

## ✅ Checklist de Implementación

### AppLayoutBuilder
- [ ] Crear `layout_breakpoints.dart`
- [ ] Crear `app_layout_builder.dart`
- [ ] Implementar detección de form factor
- [ ] Implementar detección de orientación
- [ ] Tests unitarios

### Documentación
- [ ] Agregar sección "Sistema de Responsividad" a uiux_designer.md
- [ ] Documentar AppLayoutBuilder con ejemplos
- [ ] Agregar templates de layout por form factor
- [ ] Agregar patrones de navegación
- [ ] Agregar checklist de responsividad

### Validación
- [ ] `dart fix --apply`
- [ ] `dart analyze` sin errores
- [ ] Código sigue principios Cupertino
- [ ] No hay métodos `_buildX()`

---

## 📝 Notas de Implementación

### Reglas Obligatorias
1. **SOLO Cupertino widgets** - No Material Design
2. **Widgets como clases separadas** - No métodos `_buildX()`
3. **Los 3 layouts son obligatorios** - mobile, tablet y desktop requeridos
4. **Cada layout es StatelessWidget** - Independiente y testeable

### Uso Esperado
```dart
// En cualquier page
@override
Widget build(BuildContext context) {
  return AppLayoutBuilder(
    mobile: IdeasMobileLayout(ideas: ideas),
    tablet: IdeasTabletLayout(ideas: ideas),
    desktop: IdeasDesktopLayout(ideas: ideas),
  );
}
```

---

## 🔗 Dependencias

- No requiere nuevas dependencias
- Usa solo Flutter SDK (Cupertino)

---

## ⏱️ Estado de Tareas

| Tarea | Estado |
|-------|--------|
| Crear plan | ✅ Completado |
| Crear layout_breakpoints.dart | ✅ Completado |
| Crear app_layout_builder.dart | ✅ Completado |
| Actualizar uiux_designer.md | ✅ Completado |
| Ejecutar linting | ✅ Completado |

---

## 📚 Referencias

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Flutter Cupertino Widgets](https://docs.flutter.dev/ui/widgets/cupertino)
- [Responsive Design in Flutter](https://docs.flutter.dev/ui/adaptive-responsive)
