# Plan de Implementación: Checklist de Ambulancia Mobile v1.0

**Fecha:** 2026-02-13
**Feature:** Checklist de Ambulancia
**Perfil:** TES/Conductor de Ambulancia
**Estado:** ✅ DataSource existente | 🚧 Repository + BLoC + UI pendientes

---

## 📋 Contexto

### Objetivo
Implementar funcionalidad completa de **Checklist de Ambulancia** para que los TES/Conductores puedan:
- Realizar checklist pre-servicio al inicio del turno
- Ver historial de checklists realizados
- Garantizar cumplimiento normativo y seguridad

### Flujo de Usuario
1. **TES llega al turno** → Abre app → Sección "Checklist"
2. **Selecciona tipo:** Pre-Servicio / Post-Servicio / Mensual
3. **Selecciona vehículo asignado** (si tiene varios)
4. **Completa checklist:**
   - Verifica cada categoría (Equipos de Traslado, Ventilación, Diagnóstico, etc.)
   - Marca cada ítem como: Presente ✅ / Ausente ❌ / No Aplica ⚪
   - Añade observaciones en ítems ausentes
5. **Completa datos adicionales:**
   - Kilometraje actual del vehículo
   - Observaciones generales (opcional)
   - Firma digital (opcional)
6. **Guarda** → Se registra en Supabase con timestamp + usuario
7. **Puede revisar historial** → Últimos 10 checklists

---

## ✅ Componentes Ya Existentes

### 1. DataSource (Core) - ✅ COMPLETO
**Ubicación:** `packages/ambutrack_core_datasource/lib/src/datasources/checklist_vehiculo/`

**Entities:**
- `ChecklistVehiculoEntity` - Checklist principal
- `ItemChecklistEntity` - Item individual del checklist
- `TipoChecklist` - Enum: mensual, preServicio, postServicio
- `CategoriaChecklist` - Enum: 7 categorías (equipos, documentación, etc.)
- `ResultadoItem` - Enum: presente, ausente, noAplica

**Models:**
- `ChecklistVehiculoSupabaseModel` + JSON serialization
- `ItemChecklistSupabaseModel` + JSON serialization

**Contract:**
```dart
abstract class ChecklistVehiculoDataSource {
  Future<List<ChecklistVehiculoEntity>> getAll();
  Future<ChecklistVehiculoEntity> getById(String id);
  Future<List<ChecklistVehiculoEntity>> getByVehiculoId(String vehiculoId);
  Future<ChecklistVehiculoEntity?> getUltimoChecklist(String vehiculoId, TipoChecklist tipo);
  Future<List<ItemChecklistEntity>> getPlantillaItems(TipoChecklist tipo);
  Future<ChecklistVehiculoEntity> create(ChecklistVehiculoEntity entity);
  Future<ChecklistVehiculoEntity> update(ChecklistVehiculoEntity entity);
  Future<void> delete(String id);
  Stream<List<ChecklistVehiculoEntity>> watchByVehiculoId(String vehiculoId);
}
```

**Implementation:**
- `SupabaseChecklistVehiculoDataSource` - Completa

**Factory:**
- `ChecklistVehiculoDataSourceFactory.createSupabase()`

---

## 🚧 Componentes a Implementar

### 2. Repository Pattern

#### 2.1 Contrato de Repository (Domain)
**Archivo:** `lib/features/checklist_ambulancia/domain/repositories/checklist_repository.dart`

```dart
abstract class ChecklistRepository {
  Future<List<ChecklistVehiculoEntity>> getMisChecklists();
  Future<List<ChecklistVehiculoEntity>> getHistorialVehiculo(String vehiculoId);
  Future<ChecklistVehiculoEntity?> getUltimoChecklist(String vehiculoId, TipoChecklist tipo);
  Future<List<ItemChecklistEntity>> getPlantillaItems(TipoChecklist tipo);
  Future<ChecklistVehiculoEntity> crearChecklist(ChecklistVehiculoEntity checklist);
  Stream<List<ChecklistVehiculoEntity>> watchMisChecklists();
}
```

#### 2.2 Implementación de Repository (Data)
**Archivo:** `lib/features/checklist_ambulancia/data/repositories/checklist_repository_impl.dart`

**Características:**
- ✅ Pass-through directo al DataSource (sin conversiones Entity ↔ Entity)
- ✅ Logging con `debugPrint`
- ✅ Un solo import de core
- ✅ Usar Factory para crear datasource

**Patrón:**
```dart
@LazySingleton(as: ChecklistRepository)
class ChecklistRepositoryImpl implements ChecklistRepository {
  ChecklistRepositoryImpl()
      : _dataSource = ChecklistVehiculoDataSourceFactory.createSupabase();

  final ChecklistVehiculoDataSource _dataSource;

  @override
  Future<List<ChecklistVehiculoEntity>> getMisChecklists() async {
    debugPrint('📦 Repository: Solicitando mis checklists...');
    return await _dataSource.getAll();
  }

  // ... resto de métodos pass-through
}
```

---

### 3. BLoC (Estados y Eventos con Freezed)

#### 3.1 Eventos
**Archivo:** `lib/features/checklist_ambulancia/presentation/bloc/checklist_event.dart`

```dart
@freezed
class ChecklistEvent with _$ChecklistEvent {
  const factory ChecklistEvent.started() = _Started;
  const factory ChecklistEvent.cargarHistorial(String vehiculoId) = _CargarHistorial;
  const factory ChecklistEvent.cargarPlantilla(TipoChecklist tipo) = _CargarPlantilla;
  const factory ChecklistEvent.iniciarNuevoChecklist({
    required String vehiculoId,
    required TipoChecklist tipo,
  }) = _IniciarNuevoChecklist;
  const factory ChecklistEvent.actualizarItem({
    required int index,
    required ResultadoItem resultado,
    String? observaciones,
  }) = _ActualizarItem;
  const factory ChecklistEvent.guardarChecklist({
    required double kilometraje,
    String? observacionesGenerales,
    String? firmaUrl,
  }) = _GuardarChecklist;
  const factory ChecklistEvent.cancelarChecklist() = _CancelarChecklist;
}
```

#### 3.2 Estados
**Archivo:** `lib/features/checklist_ambulancia/presentation/bloc/checklist_state.dart`

```dart
@freezed
class ChecklistState with _$ChecklistState {
  const factory ChecklistState.initial() = _Initial;
  const factory ChecklistState.loading() = _Loading;

  // Estado: Listado de checklists (historial)
  const factory ChecklistState.historialCargado({
    required List<ChecklistVehiculoEntity> checklists,
    required String vehiculoId,
  }) = _HistorialCargado;

  // Estado: Creando nuevo checklist
  const factory ChecklistState.creandoChecklist({
    required String vehiculoId,
    required TipoChecklist tipo,
    required List<ItemChecklistEntity> items,
    required Map<int, ResultadoItem> resultados,
    required Map<int, String> observaciones,
  }) = _CreandoChecklist;

  // Estado: Guardando
  const factory ChecklistState.guardando() = _Guardando;

  // Estado: Checklist guardado con éxito
  const factory ChecklistState.checklistGuardado({
    required ChecklistVehiculoEntity checklist,
  }) = _ChecklistGuardado;

  // Estado: Error
  const factory ChecklistState.error({
    required String mensaje,
  }) = _Error;
}
```

#### 3.3 BLoC
**Archivo:** `lib/features/checklist_ambulancia/presentation/bloc/checklist_bloc.dart`

**Responsabilidades:**
- Cargar historial de checklists de un vehículo
- Cargar plantilla de ítems para un tipo de checklist
- Gestionar estado temporal durante creación (resultados parciales)
- Validar que todos los ítems estén verificados antes de guardar
- Calcular estadísticas (itemsPresentes, itemsAusentes, checklistCompleto)
- Guardar checklist completo en Supabase

---

### 4. UI - Páginas y Widgets

#### 4.1 Estructura de Navegación
```
ChecklistAmbulanciaPage (lista/historial)
  ├─ AppBar: "Checklist de Ambulancia"
  ├─ FAB: "Nuevo Checklist"
  └─ Body:
      ├─ Selector de vehículo (si tiene varios asignados)
      ├─ Lista de checklists recientes (últimos 10)
      │   └─ ChecklistCard (resumen: fecha, tipo, resultado)
      └─ EmptyState (si no hay checklists)

NuevoChecklistPage (crear checklist)
  ├─ AppBar: "Nuevo Checklist"
  ├─ Stepper o ScrollView
  └─ Body:
      ├─ 1. Selección de tipo (Pre/Post/Mensual)
      ├─ 2. Lista de ítems por categoría
      │   └─ ItemChecklistTile (checkbox + observaciones)
      ├─ 3. Datos adicionales
      │   ├─ Campo: Kilometraje (number input)
      │   ├─ Campo: Observaciones generales (textarea)
      │   └─ Firma digital (opcional - placeholder v1.0)
      └─ Botón: "Guardar Checklist"

DetalleChecklistPage (ver checklist pasado - solo lectura)
  ├─ AppBar: "Detalle de Checklist"
  └─ Body:
      ├─ Cabecera (fecha, tipo, usuario, vehículo)
      ├─ Estadísticas (% completado, ítems OK/NOK)
      ├─ Lista de ítems verificados
      └─ Observaciones generales
```

#### 4.2 Páginas a Crear

| Archivo | Descripción | Widgets principales |
|---------|-------------|---------------------|
| `checklist_ambulancia_page.dart` | Lista/historial de checklists | `ChecklistCard`, `EmptyState`, FAB |
| `nuevo_checklist_page.dart` | Formulario de nuevo checklist | `ItemChecklistTile`, `AppTextField`, `AppButton` |
| `detalle_checklist_page.dart` | Ver checklist guardado (read-only) | `ChecklistHeader`, `ItemRow`, `StatsCard` |

#### 4.3 Widgets a Crear

| Widget | Archivo | Responsabilidad |
|--------|---------|-----------------|
| `ChecklistCard` | `checklist_card.dart` | Tarjeta resumen en lista (fecha, tipo, badge resultado) |
| `ItemChecklistTile` | `item_checklist_tile.dart` | Tile para verificar un ítem (checkbox + observaciones) |
| `CategoriaSection` | `categoria_section.dart` | Sección colapsable por categoría |
| `ChecklistStatsCard` | `checklist_stats_card.dart` | Card con estadísticas (ítems OK/NOK, %) |
| `TipoChecklistSelector` | `tipo_checklist_selector.dart` | Selector de tipo de checklist (chips o radio) |
| `EmptyChecklistView` | `empty_checklist_view.dart` | EmptyState cuando no hay checklists |

---

### 5. Registro en DI (GetIt + Injectable)

**Archivo:** `lib/core/di/injection.dart`

```dart
// Repository
@module
abstract class ChecklistModule {
  @lazySingleton
  ChecklistRepository get checklistRepository => ChecklistRepositoryImpl();
}

// BLoC (no registrar en DI, crear con BlocProvider en página)
```

---

### 6. Rutas (GoRouter)

**Archivo:** `lib/core/router/router_config.dart`

```dart
GoRoute(
  path: '/checklist',
  name: 'checklist',
  builder: (context, state) => const ChecklistAmbulanciaPage(),
  routes: [
    GoRoute(
      path: 'nuevo',
      name: 'nuevo_checklist',
      builder: (context, state) {
        final vehiculoId = state.uri.queryParameters['vehiculoId'];
        return NuevoChecklistPage(vehiculoId: vehiculoId!);
      },
    ),
    GoRoute(
      path: ':id',
      name: 'detalle_checklist',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetalleChecklistPage(checklistId: id!);
      },
    ),
  ],
),
```

---

## 📊 Modelo de Datos (Supabase)

### Tabla: `tchecklists_vehiculos`
```sql
CREATE TABLE tchecklists_vehiculos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
  realizado_por UUID NOT NULL REFERENCES usuarios(id),
  realizado_por_nombre TEXT NOT NULL, -- MAYÚSCULAS
  fecha_realizacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  tipo TEXT NOT NULL CHECK (tipo IN ('mensual', 'pre_servicio', 'post_servicio')),
  kilometraje DECIMAL(10,2) NOT NULL,
  items_presentes INTEGER NOT NULL DEFAULT 0,
  items_ausentes INTEGER NOT NULL DEFAULT 0,
  checklist_completo BOOLEAN NOT NULL DEFAULT FALSE,
  observaciones_generales TEXT,
  firma_url TEXT,
  empresa_id UUID NOT NULL REFERENCES empresas(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);
```

### Tabla: `titems_checklist`
```sql
CREATE TABLE titems_checklist (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  checklist_id UUID NOT NULL REFERENCES tchecklists_vehiculos(id) ON DELETE CASCADE,
  categoria TEXT NOT NULL,
  item_nombre TEXT NOT NULL,
  cantidad_requerida INTEGER,
  resultado TEXT NOT NULL CHECK (resultado IN ('presente', 'ausente', 'noAplica')),
  observaciones TEXT,
  orden INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Tabla: `tplantillas_checklist` (ítems predefinidos)
```sql
CREATE TABLE tplantillas_checklist (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo TEXT NOT NULL CHECK (tipo IN ('mensual', 'pre_servicio', 'post_servicio')),
  categoria TEXT NOT NULL,
  item_nombre TEXT NOT NULL,
  cantidad_requerida INTEGER,
  orden INTEGER NOT NULL,
  es_activo BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## 🎨 Diseño de UI (Material + AppColors)

### Paleta de Colores
- **Presente (✅):** `AppColors.success` (verde)
- **Ausente (❌):** `AppColors.error` (rojo)
- **No Aplica (⚪):** `AppColors.gray400`
- **Botón Guardar:** `AppColors.primary` (azul)
- **Estadísticas:** Badge con colores según porcentaje
  - 100% → Verde
  - 80-99% → Amarillo/Warning
  - <80% → Rojo/Error

### Componentes Material
- `Card` con elevation 1 para checklists en lista
- `ExpansionTile` para categorías colapsables
- `CheckboxListTile` para ítems individuales
- `TextField` con `TextInputType.number` para kilometraje
- `FloatingActionButton` para "Nuevo Checklist"
- Badges con `IntrinsicWidth` + `Align` (ajustados al texto)

---

## ✅ Checklist de Implementación

### Paso 1: Repository
- [ ] Crear carpeta `lib/features/checklist_ambulancia/domain/repositories/`
- [ ] Crear `checklist_repository.dart` (contrato)
- [ ] Crear carpeta `lib/features/checklist_ambulancia/data/repositories/`
- [ ] Crear `checklist_repository_impl.dart` (implementación)
- [ ] Registrar en `injection.dart`
- [ ] Ejecutar `flutter pub run build_runner build --delete-conflicting-outputs`

### Paso 2: BLoC
- [ ] Crear carpeta `lib/features/checklist_ambulancia/presentation/bloc/`
- [ ] Crear `checklist_event.dart` con Freezed
- [ ] Crear `checklist_state.dart` con Freezed
- [ ] Crear `checklist_bloc.dart`
- [ ] Ejecutar `flutter pub run build_runner build --delete-conflicting-outputs`

### Paso 3: UI - Widgets Compartidos
- [ ] Crear carpeta `lib/features/checklist_ambulancia/presentation/widgets/`
- [ ] Crear `checklist_card.dart`
- [ ] Crear `item_checklist_tile.dart`
- [ ] Crear `categoria_section.dart`
- [ ] Crear `checklist_stats_card.dart`
- [ ] Crear `tipo_checklist_selector.dart`
- [ ] Crear `empty_checklist_view.dart`

### Paso 4: UI - Páginas
- [ ] Actualizar `checklist_ambulancia_page.dart` (lista/historial)
- [ ] Crear `nuevo_checklist_page.dart` (formulario)
- [ ] Crear `detalle_checklist_page.dart` (read-only)

### Paso 5: Rutas y Navegación
- [ ] Actualizar `router_config.dart` con rutas de checklist
- [ ] Añadir enlace en menú principal (drawer/bottom nav)

### Paso 6: Validación
- [ ] Ejecutar `flutter analyze` → 0 warnings
- [ ] Probar flujo completo:
  - [ ] Ver lista vacía (EmptyState)
  - [ ] Crear nuevo checklist Pre-Servicio
  - [ ] Marcar ítems como presente/ausente
  - [ ] Añadir observaciones en ítems ausentes
  - [ ] Guardar con kilometraje
  - [ ] Ver checklist en historial
  - [ ] Abrir detalle de checklist guardado
- [ ] Verificar que se guarda correctamente en Supabase

---

## 🚀 Orden de Ejecución Recomendado

1. **Repository** (30 min)
2. **BLoC + Estados/Eventos** (45 min)
3. **Widgets compartidos** (60 min)
4. **Página de lista/historial** (30 min)
5. **Página de nuevo checklist** (90 min) ← Más compleja
6. **Página de detalle** (30 min)
7. **Rutas + DI** (15 min)
8. **Testing manual + flutter analyze** (30 min)

**Estimado total:** ~5-6 horas de trabajo

---

## 📝 Notas Importantes

### Reglas del Proyecto
- ✅ `SafeArea` obligatorio en todas las páginas
- ✅ `AppColors` para todos los colores (excepto white/black/transparent)
- ✅ Nunca usar métodos `_buildX()` que devuelvan Widget → Usar clases de widgets separadas
- ✅ Badges con `IntrinsicWidth` + `Align` para ajustar al texto
- ✅ `debugPrint` SIEMPRE (nunca `print()`)
- ✅ `flutter analyze` → 0 warnings antes de dar por terminado
- ❌ NO usar SnackBar para operaciones importantes → Usar diálogos profesionales
- ✅ Formularios con `barrierDismissible: false`

### Datos del Usuario Actual
- Obtener desde `AuthBloc`:
  ```dart
  final authState = context.read<AuthBloc>().state;
  final String userId = authState is AuthAuthenticated ? authState.personal!.id : '';
  final String nombreCompleto = authState is AuthAuthenticated
      ? authState.personal!.nombreCompleto.toUpperCase()
      : '';
  ```

### Vehículo Asignado
- Si el TES tiene vehículo asignado hoy → Obtener desde tabla `asignaciones_vehiculos_turnos`
- Si tiene varios asignados → Mostrar selector
- Si no tiene asignado → Permitir seleccionar de lista de vehículos disponibles

---

## 🔄 Próximas Iteraciones (v2.0)

- [ ] Fotos de evidencia (cámara + galería)
- [ ] Firma digital con canvas
- [ ] Checklists personalizables por tipo de vehículo
- [ ] Notificación automática a mantenimiento si hay ítems ausentes críticos
- [ ] Exportar checklist a PDF
- [ ] Comparación de checklists (ver diferencias entre fechas)
- [ ] Estadísticas: tendencias de ítems ausentes más frecuentes

---

**Autor:** Claude Sonnet 4.5
**Fecha de creación:** 2026-02-13
**Versión del plan:** 1.0
