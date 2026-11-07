# ⚡ Quickstart - Guía Rápida

> Content Engine App - Comandos y referencias rápidas

---

## 🔴 Hooks Obligatorios

### Post-Modificación de .dart (SIEMPRE)
```bash
dart fix --apply && dart analyze
```

### Post-Build Runner
```bash
dart run build_runner build --delete-conflicting-outputs && dart fix --apply
```

### Pre-Commit
```bash
dart fix --apply && dart analyze && flutter test --coverage
```

---

## 🚀 Comandos Frecuentes

### Desarrollo

```bash
# Ejecutar en DEV
flutter run -t lib/main_dev.dart --dart-define-from-file=.env.dev

# Ejecutar en PROD
flutter run -t lib/main_prod.dart --dart-define-from-file=.env.prod

# Ejecutar en Chrome (web)
flutter run -d chrome -t lib/main_dev.dart --dart-define-from-file=.env.dev
```

### Code Generation

```bash
# Build una vez
dart run build_runner build --delete-conflicting-outputs

# Watch (desarrollo continuo)
dart run build_runner watch --delete-conflicting-outputs

# Limpiar y regenerar
dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
# Ejecutar todos los tests
flutter test

# Con coverage
flutter test --coverage

# Generar reporte HTML de coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Test específico
flutter test test/unit/presentation/features/ideas/bloc/ideas_bloc_test.dart

# Tests con output verbose
flutter test --reporter expanded
```

### Análisis y Linting

```bash
# Analizar código
dart analyze

# Aplicar fixes automáticos
dart fix --apply

# Formatear código
dart format lib/ test/

# Verificar formato
dart format --output=none --set-exit-if-changed lib/
```

### FVM (Flutter Version Manager)

```bash
# Verificar versión actual
fvm flutter --version

# Usar versión del proyecto
fvm use

# Ejecutar comando con FVM
fvm flutter run
fvm dart analyze
```

---

## 📁 Estructura de Feature

```
lib/presentation/features/{feature_name}/
├── bloc/
│   ├── {feature}_bloc.dart
│   ├── {feature}_event.dart      # Freezed
│   └── {feature}_state.dart      # Freezed
├── page/
│   └── {feature}_page.dart
├── widgets/
│   ├── {feature}_loaded_view.dart    # ✅ Widget separado
│   ├── {feature}_empty_view.dart     # ✅ Widget separado
│   └── {feature}_card.dart
└── routes/
    └── {feature}_route.dart      # GoRouteData
```

---

## 🎨 Widgets Cupertino Comunes

```dart
// Navigation
CupertinoNavigationBar
CupertinoTabScaffold
CupertinoTabBar
CupertinoPageScaffold

// Inputs
CupertinoTextField
CupertinoSearchTextField
CupertinoButton
CupertinoSwitch
CupertinoSlider
CupertinoSegmentedControl
CupertinoPicker
CupertinoDatePicker

// Feedback
CupertinoActivityIndicator
CupertinoAlertDialog
CupertinoActionSheet
CupertinoContextMenu

// Containers
CupertinoListSection
CupertinoListTile
CupertinoFormSection
CupertinoFormRow

// Refresh
CupertinoSliverRefreshControl
CustomScrollView + Slivers
```

---

## 📝 Snippets Rápidos

### Nuevo Modelo Freezed

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{name}_model.freezed.dart';
part '{name}_model.g.dart';

@freezed
class {Name}Model with _${Name}Model {
  const factory {Name}Model({
    required String id,
    // campos...
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _{Name}Model;

  factory {Name}Model.fromJson(Map<String, dynamic> json) =>
      _${Name}ModelFromJson(json);
}
```

### Nuevo BLoC Event

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{name}_event.freezed.dart';

@freezed
class {Name}Event with _${Name}Event {
  const factory {Name}Event.started() = _Started;
  const factory {Name}Event.loadRequested() = _LoadRequested;
  const factory {Name}Event.refreshRequested() = _RefreshRequested;
}
```

### Nuevo BLoC State

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{name}_state.freezed.dart';

@freezed
class {Name}State with _${Name}State {
  const factory {Name}State.initial() = _Initial;
  const factory {Name}State.loading() = _Loading;
  const factory {Name}State.loaded({required List<{Name}Model> items}) = _Loaded;
  const factory {Name}State.error({required String message}) = _Error;
}
```

### Nueva Ruta GoRouteData

```dart
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class {Name}Route extends GoRouteData {
  static const routeName = '/{name}';
  static const routePath = '{name}';

  static GoRoute goRoute({List<RouteBase> routes = const []}) {
    return GoRoute(
      name: routeName,
      path: routePath,
      builder: (context, state) => const {Name}Page(),
      routes: routes,
    );
  }

  static Future<void> pushNamed(BuildContext context) =>
      context.pushNamed(routeName);

  static void goNamed(BuildContext context) =>
      context.goNamed(routeName);
}
```

### Widget Separado (NO método)

```dart
// ✅ CORRECTO: Widget como clase separada
class {Name}LoadedView extends StatelessWidget {
  const {Name}LoadedView({
    super.key,
    required this.items,
  });

  final List<{Name}Model> items;

  @override
  Widget build(BuildContext context) {
    // UI aquí
  }
}

// ❌ INCORRECTO: Método que devuelve Widget
Widget _buildLoadedView() {
  // NUNCA hacer esto
}
```

---

## 🗄️ Supabase MCP

El agente `supabase_specialist.md` tiene acceso al MCP de Supabase para:

- Consultar schemas
- Ejecutar queries
- Crear migraciones
- Verificar RLS policies

Ver `agents/supabase_specialist.md` para detalles.

---

## 🚨 REGLA OBLIGATORIA: Planes de Implementación

**ANTES de comenzar cualquier tarea no trivial, SIEMPRE:**

1. Crear plan en `.claude/plans/{feature}_plan.md`
2. Documentar fases, archivos a crear/modificar
3. Listar agentes involucrados
4. Definir comandos de validación

**Esto aplica a:**
- Nuevas features completas
- Refactors significativos
- Implementación de layouts responsivos
- Cualquier cambio que afecte múltiples archivos

---

## 📋 Checklist Rápida

### Nueva Feature
```
□ CREAR PLAN en .claude/plans/{feature}_plan.md
□ Crear modelo Freezed
□ Crear contrato repository (domain/)
□ Crear implementación repository (data/)
□ Crear BLoC + Events + States
□ Crear Page (Cupertino)
□ Crear Widgets separados (NO métodos _buildX)
□ Crear Route (GoRouteData)
□ Registrar en DI
□ Añadir al router
□ build_runner
□ dart fix --apply
□ Tests 85%+
```

### Nuevo Widget
```
□ Crear como clase StatelessWidget
□ Usar solo Cupertino widgets
□ Parámetros en constructor
□ Widget test
□ dart fix --apply
```

---

## 🔗 Referencias

| Recurso | Ubicación |
|---------|-----------|
| Prompt maestro | `.claude/CLAUDE.md` |
| Orquestador | `.claude/orchestrator.md` |
| Feature Generator | `.claude/agents/feature_generator.md` |
| Apple Design | `.claude/agents/apple_design.md` |
| UI/UX Designer | `.claude/agents/uiux_designer.md` |
| Supabase Specialist | `.claude/agents/supabase_specialist.md` |
| QA Validation | `.claude/agents/qa_validation.md` |
