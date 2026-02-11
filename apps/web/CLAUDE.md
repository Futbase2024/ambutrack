# AmbuTrack Web - Sistema de Gestión de Ambulancias

> **Proyecto**: AmbuTrack Web
> **Stack**: Flutter + Supabase + Material Design 3
> **Backend**: Supabase (PostgreSQL + Auth + Storage + Real-Time)
> **Supabase Project ID**: `ycmopmnrhrpnnzkvnihr`

---

## 🎯 Identidad del Proyecto

**AmbuTrack Web** es una aplicación Flutter para la gestión integral de servicios de ambulancias y emergencias médicas. Permite gestionar flota de vehículos, personal sanitario, planificación de servicios, tracking GPS, mantenimiento y tablas maestras.

### Usuarios Principales
- Coordinadores de servicios de ambulancias
- Despachadores médicos
- Personal sanitario
- Gestores de flota
- Administradores

### Paleta de Colores
- **Azul médico** (#1E40AF) - Confianza y serenidad
- **Verde médico** (#059669) - Salud y estados positivos
- **Rojo emergencia** (#DC2626) - Alertas críticas

---

## 🏗️ Stack Tecnológico

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Framework | Flutter | 3.35.3+ |
| Dart | 3.9.2+ | - |
| Backend | Supabase (PostgreSQL + Auth + Storage + Real-Time) | 2.x |
| UI Framework | **Material Design 3** | Flutter SDK |
| State Management | **BLoC + Freezed + Equatable** | 9.x |
| DI | **GetIt + Injectable** | 7.x / 2.x |
| Navigation | **GoRouter** | 14.x |

## 🗄️ Supabase Project ID

```
ycmopmnrhrpnnzkvnihr
```

**Acceso MCP**: Tienes acceso total al MCP de Supabase con todos los privilegios.

---

## 🤖 Sistema Multi-Agente

Para TODA tarea, Claude DEBE: leer agente → ejecutar → validar con QA

| Tarea | Agente | Archivo |
|-------|--------|---------|
| Feature E2E | Todos | `.claude/commands/feature.md` |
| Entity/DataSource | 🟣 Datasource | `.claude/agents/AmbuTrackDatasourceAgent.md` |
| Repository/BLoC | 🟠 FeatureBuilder | `.claude/agents/AmbuTrackFeatureBuilderAgent.md` |
| Page/Widget/UI | 🔵 UIDesigner | `.claude/agents/AmbuTrackUIDesignerAgent.md` |
| Validar código | 🔴 QA | `.claude/agents/AmbuTrackQAValidatorAgent.md` |
| Arquitectura | 🔵 Architect | `.claude/agents/AmbuTrackArchitectAgent.md` |
| **Supabase (tablas, RLS, SQL)** | 🗄️ **SupabaseSpecialist** | `.claude/agents/supabase_specialist.md` |

## Comandos

```
/prd [título] [desc]              # PRD → Trello
/plan [card-id]                   # Trello → Plan (genera en docs/plans/)
/ambutrack-feature [nombre]       # Feature E2E
/ambutrack-validate [nombre]      # Validar
```

---

## 🚨 Reglas Críticas (Resumen Rápido)

| Regla | Acción |
|-------|--------|
| `flutter analyze` | ✅ **OBLIGATORIO** después de cada cambio → 0 warnings |
| Git write | ❌ Solo PROPONER `git add/commit/push` |
| Firebase | ❌ **PROHIBIDO** - Usar Supabase SIEMPRE |
| Cupertino | ❌ **PROHIBIDO** - Usar Material Design 3 |
| `domain/entities/` en features | ❌ PROHIBIDO (usar ambutrack_core_datasource) |
| `data/` en features | ❌ PROHIBIDO (excepto repositories impl) |
| Colores | ✅ `AppColors` SIEMPRE (excepto white/black/transparent) |
| Textos | ✅ Localizar con `context.tr()` |
| SafeArea | ✅ OBLIGATORIO en todas las páginas |
| Widgets | ✅ Clases extraídas, NO métodos `_buildXxx()` que retornan Widget |
| Loading | ✅ `AppLoadingOverlay` + `CrudOperationHandler` |
| DataSources | ✅ Entidades en `packages/ambutrack_core_datasource/` |
| Planes | ✅ Guardar en `docs/plans/`, NUNCA en `.claude/` |
| Ejecutar app | ❌ NO ejecutar app, solo implementar + analyze |
| Dropdowns | ✅ `AppDropdown` (≤10 items) / `AppSearchableDropdown` (>10) |
| CRUD feedback | ✅ `CrudOperationHandler` + `showResultDialog` (NO SnackBar) |
| Eliminar | ✅ `showConfirmationDialog` SIEMPRE |
| Formularios | ✅ `barrierDismissible: false` en create/edit |
| debugPrint | ✅ SIEMPRE (NUNCA `print()`) |

---

## 🚫 PROHIBICIONES DETALLADAS

- ❌ **NO usar Cupertino** (AmbuTrack usa Material Design 3)
- ❌ **NO usar Firebase** (migrado completamente a Supabase)
- ❌ **NO usar datos MOCK** (SIEMPRE usar Supabase real)
- ❌ **NO usar StatefulWidget** cuando BLoC es apropiado
- ❌ **NO crear métodos que devuelvan Widget** (usar clases separadas)
- ❌ **NO usar `_buildX()` patterns** - extraer a widgets dedicados
- ❌ **NO crear `domain/entities/`** en features (usar `ambutrack_core_datasource`)
- ❌ **NO crear `data/`** en features (excepto repositories impl)
- ❌ **NO hardcodear colores** (usar `AppColors`)

---

## ✅ OBLIGACIONES DETALLADAS

- ✅ **Material Design 3 widgets** SIEMPRE (Scaffold, AppBar, FilledButton, etc.)
- ✅ **AppColors** para todos los colores (excepto white/black/transparent)
- ✅ **SafeArea** OBLIGATORIO en todas las páginas
- ✅ **BLoC + Freezed** para estados/eventos
- ✅ **Repository pass-through** directo al datasource
- ✅ **Widgets como clases** separadas (NO métodos `_buildXxx()`)
- ✅ **Traducciones** con `context.tr()` o `context.lang()`
- ✅ **`flutter analyze`** OBLIGATORIO → 0 warnings después de cada cambio
- ✅ **Diálogos profesionales** para notificaciones importantes (NO SnackBar)

---

## 📏 Límites de Archivos (IRROMPIBLES)

| Elemento | Límite |
|----------|--------|
| **Archivo** | 300 (soft) / **400 líneas (HARD LIMIT)** |
| **Widget** | 150 líneas máximo |
| **Método/Función** | 40 líneas máximo |
| **Profundidad anidación** | 3 niveles máximo |
| **Línea** | 120 caracteres máximo |

**SI UN ARCHIVO SUPERA 350 LÍNEAS**: ⛔ DETENER → Proponer división → Implementar después de aprobación.

---

## 📁 Estructura del Proyecto

```
lib/
├── app/                    # Widget raíz (MaterialApp)
├── core/
│   ├── config/            # Configuraciones globales
│   ├── di/                # Inyección de dependencias (GetIt)
│   ├── services/          # AuthService, etc.
│   ├── layout/            # MainLayout (AppBar + menú)
│   ├── router/            # GoRouter + AuthGuard
│   ├── theme/             # AppColors, AppSizes
│   ├── widgets/           # Widgets compartidos (AppDropdown, ModernDataTable, etc.)
│   └── lang/              # i18n (es.json, en.json)
└── features/              # Features por dominio
    ├── auth/              # Login + AuthBloc
    ├── home/              # Dashboard
    ├── personal/          # Personal sanitario
    ├── vehiculos/         # Flota de ambulancias
    ├── trafico_diario/    # Planificación de servicios
    ├── itv_revisiones/    # ITV y revisiones
    ├── mantenimiento/     # Mantenimiento preventivo
    ├── almacen/           # Productos y proveedores
    ├── tablas/            # Tablas maestras (20+ submódulos)
    └── [otros módulos]

packages/
└── ambutrack_core_datasource/   # Entidades + DataSources + Models
    └── lib/src/datasources/[feature]/
        ├── entities/
        ├── models/
        ├── implementations/supabase/
        ├── [feature]_contract.dart
        └── [feature]_factory.dart

docs/
├── plans/              # Planes de implementación
├── vehiculos/          # Docs de vehículos
├── personal/           # Docs de personal
├── tablas/             # Docs de tablas maestras
├── servicios/          # Docs de servicios
└── arquitectura/       # Docs técnicos
```

---

## 🏗️ Arquitectura (Clean Architecture Estricta)

### Páginas → Solo orquestación
```dart
class VehiculosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (_) => getIt<VehiculosBloc>(),
        child: const _VehiculosView(),
      ),
    );
  }
}
// ❌ NO: lógica de negocio, cálculos, llamadas a repos
```

### BLoC → Estado inmutable, sin UI
```dart
@injectable
class VehiculosBloc extends Bloc<VehiculosEvent, VehiculosState> {
  final VehiculoRepository _repository;
  // ❌ NO: BuildContext, showDialog, snackbars
}
```

### Repositorios → Pass-through directo
```dart
@LazySingleton(as: VehiculoRepository)
class VehiculoRepositoryImpl implements VehiculoRepository {
  VehiculoRepositoryImpl() : _dataSource = VehiculoDataSourceFactory.createSupabase();
  final VehiculoDataSource _dataSource;

  @override
  Future<List<VehiculoEntity>> getAll() async {
    return await _dataSource.getAll();  // ✅ Pass-through, sin conversión
  }
}
// ❌ NO: conversiones Entity↔Entity, imports dobles (as core/as app)
// ✅ SÍ: UN solo import del core, logging con debugPrint, rethrow errores
```

### DataSource (Core) → Model↔Entity aquí
```dart
// En ambutrack_core_datasource
Future<List<VehiculoEntity>> getAll() async {
  final data = await _supabase.from('vehiculos').select();
  return data.map((json) => VehiculoSupabaseModel.fromJson(json).toEntity()).toList();
}
```

---

## 🎨 UI Obligatorio

### Colores
```dart
// ✅ AppColors.primary, AppColors.error, AppColors.success, etc.
// ❌ Colors.blue, Color(0xFF...) (excepto white/black/transparent)
```

### CRUD → CrudOperationHandler (NO SnackBar)
```dart
// En BlocListener:
CrudOperationHandler.handleSuccess(context: context, isSaving: _isSaving, isEditing: _isEditing, entityName: 'Vehículo', onClose: () => setState(() => _isSaving = false));
CrudOperationHandler.handleError(context: context, isSaving: _isSaving, isEditing: _isEditing, entityName: 'Vehículo', errorMessage: state.message, onClose: () => setState(() => _isSaving = false));
```

### Diálogos de Confirmación (OBLIGATORIO)

**REGLA**: SIEMPRE usar `showSimpleConfirmationDialog` para acciones destructivas o confirmaciones.

#### Para confirmaciones simples (eliminar notificación, marcar, etc.)
```dart
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';

final bool? confirmed = await showSimpleConfirmationDialog(
  context: context,
  title: 'Eliminar notificación',
  message: '¿Estás seguro de que deseas eliminar esta notificación?\n\nEsta acción no se puede deshacer.',
  confirmText: 'Eliminar',
  icon: Icons.delete_outline,
  // iconColor: AppColors.error (por defecto)
  // cancelText: 'Cancelar' (por defecto)
  // confirmButtonColor: AppColors.error (por defecto)
);

if (confirmed == true) {
  // Realizar acción
}
```

#### Para confirmaciones críticas (eliminar vehículo, usuario, etc.)
```dart
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';

final bool? confirmed = await showConfirmationDialog(
  context: context,
  title: 'Confirmar Eliminación',
  message: 'Esta acción es permanente y no se puede deshacer.',
  confirmText: 'Eliminar',
  itemDetails: {
    'Matrícula': vehiculo.matricula,
    'Marca': vehiculo.marca,
    'Modelo': vehiculo.modelo,
  },
  warningMessage: 'Se eliminarán también todos los registros asociados.',
  icon: Icons.delete_forever,
  iconColor: AppColors.error,
  confirmButtonColor: AppColors.error,
);

if (confirmed == true) {
  // Realizar acción (con doble confirmación automática)
}
```

**❌ NO USAR**:
- AlertDialog genérico
- SnackBar para acciones destructivas
- Diálogos sin estilos consistentes

**📍 Ubicación**: `lib/core/widgets/dialogs/confirmation_dialog.dart`

### Loading Overlays
| Operación | Mensaje | Color | Icono |
|-----------|---------|-------|-------|
| Crear | "Creando [entidad]..." | `AppColors.primary` | `Icons.add_circle_outline` |
| Editar | "Actualizando [entidad]..." | `AppColors.secondary` | `Icons.edit` |
| Eliminar | "Eliminando [entidad]..." | `AppColors.emergency` | `Icons.delete_forever` |

### Botones de Formulario
| Operación | Label | Icono |
|-----------|-------|-------|
| Crear | "Guardar" | `Icons.add` |
| Editar | "Actualizar" | `Icons.save` |
| Ambos | `onPressed: _isSaving ? null : _onSave` |

### Iconos de Acción en Tablas (AppIconButton, size: 36)
| Acción | Icono | Color |
|--------|-------|-------|
| Ver | `Icons.visibility_outlined` | `AppColors.info` |
| Editar | `Icons.edit_outlined` | `AppColors.secondaryLight` |
| Eliminar | `Icons.delete_outline` | `AppColors.error` |

### Dropdowns
- **≤10 items**: `AppDropdown` (`lib/core/widgets/dropdowns/app_dropdown.dart`)
- **>10 items**: `AppSearchableDropdown` (`lib/core/widgets/dropdowns/app_searchable_dropdown.dart`)

### Paginación (AppDataGridV5)
- 25 items/página, 4 botones navegación, badge azul "Página X de Y"
- Filtros arriba fijos, Expanded en tabla, paginación abajo fija

### Formularios
- `barrierDismissible: false` en create/edit
- `textInputAction: TextInputAction.next` (campos simples) / `.newline` (multilínea)
- `AppLoadingIndicator` mientras cargan datos asíncronos

### Badges en Tablas
```dart
// ✅ Envolver en Align + IntrinsicWidth para ajustar al texto
Align(alignment: Alignment.centerLeft, child: IntrinsicWidth(child: Container(...)))
```

---

## 📊 Contexto de Negocio

**AmbuTrack** = Gestión integral de servicios de ambulancias:
- Flota de ambulancias y vehículos médicos
- Personal sanitario (turnos, formación, certificaciones)
- Planificación y seguimiento de servicios médicos
- Tracking GPS en tiempo real
- Mantenimiento de vehículos (ITV, revisiones)
- Tablas maestras (20+ catálogos)
- Informes y analytics

**Usuarios**: Coordinadores, despachadores, personal sanitario, gestores de flota, administradores.

**Paleta**: Azul médico (#1E40AF) + Verde salud (#059669)

---

## 🔧 Comandos Dev

```bash
flutter analyze                                           # OBLIGATORIO → 0 warnings
flutter pub run build_runner build --delete-conflicting-outputs  # Freezed/Injectable/JSON
flutter gen-l10n                                          # i18n (cuando se active)
./scripts/run_dev.sh                                      # Ejecutar dev
./scripts/run_prod.sh                                     # Ejecutar prod
```

**Flavors**: `flutter run --flavor dev -t lib/main_dev.dart`

---

## 📚 Referencias

| Qué | Dónde |
|-----|-------|
| Convenciones y templates | `.claude/memory/CONVENTIONS.md` |
| Flujo de agentes | `.claude/ORCHESTRATOR.md` |
| Entities disponibles | `packages/ambutrack_core_datasource/` |
| Planes de implementación | `docs/plans/` |
| Design System | `iautomat_design_system` (Git) |
| Patrón repos/datasources | `docs/arquitectura/patron_repositorios_datasources.md` |
| Auth referencia | `lib/core/services/auth_service.dart` |
| Widgets core | `lib/core/widgets/` |
| AppColors | `lib/core/theme/app_colors.dart` |
| AppSizes | `lib/core/theme/app_sizes.dart` |
| Supabase Guide | `SUPABASE_GUIDE.md` |

---

## 🚀 Proceso Obligatorio

### Al escribir código:
1. **ANTES**: Confirmar estructura, verificar límites de líneas
2. **DURANTE**: Clean Architecture, AppColors, sin hardcoded strings, sin magic values
3. **DESPUÉS**: `flutter analyze` → 0 warnings → explicar al usuario

### Checklist nuevo DataSource/Repository:
- [ ] Entity en `core/entities/`
- [ ] Model en `core/models/` con `@JsonSerializable()`
- [ ] Contract, Implementation, Factory en core
- [ ] Exports en barrel file del core
- [ ] Repository interface en `app/domain/repositories/`
- [ ] Repository impl pass-through en `app/data/repositories/`
- [ ] `build_runner build --delete-conflicting-outputs`
- [ ] `flutter analyze` → 0 warnings

### Flujo de trabajo:
```
Claude implementa → flutter analyze → corrige warnings → explica
Usuario prueba → reporta errores → Claude itera
```

---

## ⚠️ Estado de Migración Firebase → Supabase

| Estado | Elemento |
|--------|----------|
| ✅ Completado | Auth, AuthBloc, AuthGuard, AuthService |
| 🚧 En proceso | DataSources individuales, Firestore→PostgreSQL, Real-time, Storage |
| ❌ NUNCA | Agregar nuevas dependencias de Firebase |

---

**⚠️ SIEMPRE consultar `.claude/memory/CONVENTIONS.md` para templates de código**
**⚠️ SIEMPRE ejecutar `flutter analyze` → 0 warnings antes de dar por terminada cualquier tarea**
