# AmbuTrack Web

## 🏗️ Arquitectura

**Backend:** Supabase (PostgreSQL + Auth + Storage + Real-Time)
**UI Framework:** iautomat_design_system + AppColors
**State Management:** BLoC + Freezed + Equatable
**DI:** GetIt + Injectable
**Navigation:** GoRouter (~80+ rutas)
**Flutter:** 3.35.3+ | **Dart:** 3.9.2+

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
| **SnackBar** | ❌ **PROHIBIDO** para acciones importantes (solo triviales) |
| **Diálogos** | ✅ **OBLIGATORIO** para confirmaciones/éxitos/errores importantes |
| **Notificaciones** | ✅ In-app dialog si app abierta, push si cerrada/minimizada |

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

## 🔔 DIÁLOGOS PROFESIONALES (OBLIGATORIO)

### ❌ PROHIBIDO usar SnackBar para:
- ✅ Eliminaciones (una, varias, todas)
- ✅ Confirmaciones de acciones destructivas
- ✅ Errores importantes
- ✅ Éxitos de operaciones importantes
- ✅ Cambios de estado que afectan el flujo de trabajo

### ✅ Cuándo SÍ usar SnackBar (SOLO excepciones):
- Confirmaciones rápidas triviales (Ej: "Copiado al portapapeles")
- Información contextual NO crítica
- Feedback inmediato de acciones triviales

### 🎨 Diseño de Diálogos Profesionales

#### Confirmación (antes de eliminar):
```dart
Future<bool?> showProfessionalConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
  Color? confirmColor,
  IconData? icon,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (confirmColor ?? Colors.red).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: confirmColor ?? Colors.red),
              ),
            if (icon != null) const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(fontSize: 15, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor ?? Colors.red,
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
```

#### Resultado (después de eliminar/éxito):
```dart
Future<void> showProfessionalResultDialog({
  required BuildContext context,
  required String title,
  required String message,
  required ResultType type,
  String buttonText = 'Entendido',
}) {
  final config = _getResultConfig(type);

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: config.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(config.icon, size: 48, color: config.color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(fontSize: 15, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: config.color,
                  foregroundColor: Colors.white,
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

enum ResultType { success, error, warning, info }
```

### 📋 Checklist Diálogos Profesionales
- ✅ `barrierDismissible: false` (no cerrar tocando fuera)
- ✅ Icono grande (48px) con fondo de color alpha 0.1
- ✅ Título claro (20px, bold)
- ✅ Mensaje descriptivo (15px, height 1.4)
- ✅ Botones full-width o Row con Expanded
- ✅ Border radius: 16 para Dialog, 10 para botones
- ✅ Padding consistente: 24px contenedor, 14px vertical botones

### 🎨 Colores según Tipo
| Tipo | Color | Icono |
|------|-------|-------|
| Éxito | `Colors.green` | `Icons.check_circle_outline` |
| Error | `Colors.red` | `Icons.error_outline` |
| Advertencia | `Colors.orange` | `Icons.warning_amber_rounded` |
| Info | `Colors.blue` | `Icons.info_outline` |

---

## 📱 NOTIFICACIONES IN-APP (REGLA BÁSICA OBLIGATORIA)

**REGLA CRÍTICA**: Las notificaciones DEBEN comportarse diferente según el estado de la aplicación.

### 🎯 Comportamiento Obligatorio

| Estado de la App | Tipo de Notificación | Ubicación |
|------------------|---------------------|-----------|
| **Primer plano** (abierta y visible) | Diálogo In-App | Centro de la pantalla |
| **Segundo plano** (minimizada) | Notificación Push | Barra de notificaciones del sistema |
| **Cerrada** | Notificación Push | Barra de notificaciones del sistema |

### ✅ Implementación Obligatoria

```dart
// 1. LocalNotificationsService DEBE tener:
class LocalNotificationsService {
  // Callback para mostrar notificación in-app
  Function(NotificacionEntity notificacion)? onShowInAppNotification;

  // Flag del estado de la app
  var _isAppInForeground = true;

  // Método para actualizar estado
  void setAppLifecycleState(bool isInForeground) {
    _isAppInForeground = isInForeground;
  }

  // Lógica de decisión
  Future<void> mostrarNotificacion({required NotificacionEntity notificacion}) async {
    // ✅ App en primer plano → Diálogo in-app
    if (_isAppInForeground) {
      onShowInAppNotification?.call(notificacion);
      return;
    }

    // ✅ App en segundo plano → Notificación push
    await _plugin.show(/* ... */);
  }
}

// 2. App widget DEBE implementar WidgetsBindingObserver:
class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Observar ciclo de vida
    WidgetsBinding.instance.addObserver(this);

    // Configurar callback
    _notificationsService.onShowInAppNotification = _mostrarNotificacionInApp;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isInForeground = state == AppLifecycleState.resumed;
    _notificationsService.setAppLifecycleState(isInForeground);
  }

  void _mostrarNotificacionInApp(notificacion) {
    // Reproducir sonido usando el servicio
    _notificationsService.reproducirSonido();

    final context = _router.routerDelegate.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => NotificacionInAppDialog(
          notificacion: notificacion,
          onAbrirNotificaciones: () {
            // Marcar como leída
            _notificacionesBloc.add(
              NotificacionesEvent.marcarComoLeida(notificacion.id),
            );
            // Navegar a Mis Servicios
            _router.push('/servicios');
          },
        ),
      );
    }
  }
}
```

### 🎨 Diseño del Diálogo In-App

**Características obligatorias**:
- Icono circular grande (48px) con fondo de color alpha 0.1
- Título en negrita, 20px, centrado
- Mensaje hasta 5 líneas con ellipsis
- Sonido + vibración (`_notificationsService.reproducirSonido()`) al aparecer
- Dos botones:
  - "Cerrar": Outlined gris (cierra el diálogo)
  - "Ver": Elevated azul (marca como leída + navega a `/servicios`)
- Border radius: 20px para dialog, 12px para botones
- Sombra con color según tipo de notificación
- Color del icono y botón:
  - Alerta: Rojo (`AppColors.error`)
  - Todos los traslados: Azul (`AppColors.primary`)
  - Otros: Azul (`AppColors.primary`)

### 📋 Estados del Ciclo de Vida

| Estado | Descripción | Comportamiento |
|--------|-------------|----------------|
| `resumed` | App visible y activa | ✅ Mostrar in-app dialog |
| `inactive` | App en transición | ❌ Notificación push |
| `paused` | App minimizada | ❌ Notificación push |
| `detached` | App cerrándose | ❌ Notificación push |

### 🚫 Reglas Importantes

- ❌ NUNCA mostrar ambas (in-app Y push) al mismo tiempo
- ❌ NUNCA usar SnackBar para notificaciones importantes
- ✅ SIEMPRE reproducir sonido (`_notificationsService.reproducirSonido()`) antes de mostrar diálogo
- ✅ SIEMPRE marcar como leída cuando el usuario toca "Ver"
- ✅ SIEMPRE navegar a `/servicios` (Mis Servicios) al tocar "Ver"
- ✅ SIEMPRE usar `barrierDismissible: true` en diálogos in-app
- ✅ SIEMPRE verificar que el context esté mounted antes de mostrar dialog
- ✅ SIEMPRE usar debugPrint para logging del estado de la app
- ✅ SIEMPRE usar color azul (`AppColors.primary`) para todos los traslados

### 📚 Archivos de Referencia

- Widget: `lib/features/notificaciones/presentation/widgets/notificacion_in_app_dialog.dart`
- Servicio: `lib/features/notificaciones/services/local_notifications_service.dart`
- App: `lib/app/app.dart`
- Documentación completa: `docs/NOTIFICACIONES_IN_APP.md`

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
