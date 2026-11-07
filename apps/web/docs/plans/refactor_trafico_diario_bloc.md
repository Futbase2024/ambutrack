# Plan de Refactorización: TraficoDiarioBloc

## 🎯 Objetivo
Separar la responsabilidad de gestión de traslados diarios del ServiciosBloc a un nuevo TraficoDiarioBloc, siguiendo el principio de Single Responsibility.

## 📋 Análisis Actual

### Problema
- **ServiciosBloc** maneja tanto servicios como traslados
- **trafico_diario** usa ServiciosBloc (acoplamiento incorrecto)
- Violación de Single Responsibility Principle

### Solución
- Crear **TraficoDiarioBloc** para gestión de traslados diarios
- Mover eventos/estados relacionados con traslados
- Actualizar páginas para usar el BLoC correcto

## 🗂️ Estructura Nueva

```
features/trafico_diario/
└── presentation/
    ├── bloc/
    │   ├── trafico_diario_bloc.dart        [CREAR]
    │   ├── trafico_diario_event.dart       [CREAR]
    │   ├── trafico_diario_state.dart       [CREAR]
    │   └── (archivos .freezed.dart)        [AUTO-GENERADOS]
    ├── pages/
    │   └── planificar_servicios_page.dart  [MODIFICAR]
    └── widgets/
        ├── servicios_table.dart            [MODIFICAR]
        └── asignacion_masiva_dialog.dart   [MODIFICAR]
```

## 📝 Tareas Detalladas

### 1. Crear TraficoDiarioEvent
- [ ] Crear archivo `trafico_diario_event.dart`
- [ ] Definir eventos:
  - `started()`
  - `loadTrasladosRequested({required List<String> idsServiciosRecurrentes, required DateTime fecha})`
  - `refreshRequested()`
  - `asignarConductorRequested({required String idTraslado, required String idConductor, required String idVehiculo, required String matriculaVehiculo})`
  - `asignarConductorMasivoRequested({required List<String> idTraslados, required String idConductor, required String idVehiculo, required String matriculaVehiculo})`
  - `filterByEstadoChanged({String? estado})`
  - `filterByCentroChanged({String? idCentro})`
  - `searchChanged({required String query})`

### 2. Crear TraficoDiarioState
- [ ] Crear archivo `trafico_diario_state.dart`
- [ ] Definir estados:
  - `initial()`
  - `loading()`
  - `loaded({required List<TrasladoEntity> traslados, String? estadoFilter, String? centroFilter, String searchQuery, bool isRefreshing})`
  - `error({required String message})`

### 3. Crear TraficoDiarioBloc
- [ ] Crear archivo `trafico_diario_bloc.dart`
- [ ] Inyectar `TrasladoRepository`
- [ ] Implementar handlers:
  - `_onStarted`
  - `_onLoadTrasladosRequested`
  - `_onRefreshRequested`
  - `_onAsignarConductorRequested`
  - `_onAsignarConductorMasivoRequested`
  - `_onFilterByEstadoChanged`
  - `_onFilterByCentroChanged`
  - `_onSearchChanged`
- [ ] Agregar anotación `@injectable`

### 4. Actualizar PlanificarServiciosPage
- [ ] Cambiar `BlocProvider<ServiciosBloc>` → `BlocProvider<TraficoDiarioBloc>`
- [ ] Actualizar imports
- [ ] Cambiar eventos disparados
- [ ] Actualizar BlocBuilder/BlocListener

### 5. Actualizar ServiciosTable
- [ ] Cambiar `context.read<ServiciosBloc>()` → `context.read<TraficoDiarioBloc>()`
- [ ] Actualizar eventos de asignación
- [ ] Actualizar eventos de carga de traslados

### 6. Actualizar AsignacionMasivaDialog
- [ ] Cambiar `context.read<ServiciosBloc>()` → `context.read<TraficoDiarioBloc>()`
- [ ] Actualizar evento de asignación masiva

### 7. Limpiar ServiciosBloc
- [ ] Eliminar eventos de traslados:
  - `asignarConductorRequested`
  - `asignarConductorMasivoRequested`
  - `loadTrasladosRequested`
- [ ] Eliminar handlers correspondientes
- [ ] Eliminar `traslados` y `isLoadingTraslados` del state
- [ ] Simplificar ServiciosState

### 8. Actualizar Dependency Injection
- [ ] Verificar que TraficoDiarioBloc esté registrado (Injectable lo hará automáticamente)
- [ ] Ejecutar `build_runner`

### 9. Testing
- [ ] Verificar `flutter analyze`
- [ ] Probar carga de traslados
- [ ] Probar asignación individual
- [ ] Probar asignación masiva
- [ ] Probar filtros

## 🔄 Orden de Ejecución

1. Crear TraficoDiarioEvent
2. Crear TraficoDiarioState
3. Crear TraficoDiarioBloc
4. Ejecutar build_runner (generar .freezed.dart)
5. Actualizar PlanificarServiciosPage
6. Actualizar ServiciosTable
7. Actualizar AsignacionMasivaDialog
8. Limpiar ServiciosBloc (eventos, estados, handlers)
9. Ejecutar build_runner final
10. Ejecutar flutter analyze

## ⚠️ Consideraciones

- **ServiciosPage** (otra página) seguirá usando ServiciosBloc para gestión de servicios
- **TraficoDiarioPage** usará TraficoDiarioBloc para gestión de traslados
- Ambos BLoCs pueden coexistir sin problemas
- TraficoDiarioBloc usa TrasladoRepository (correcto)
- ServiciosBloc usa ServicioRepository (correcto)

## 📊 Impacto

### Archivos a CREAR (3)
- `lib/features/trafico_diario/presentation/bloc/trafico_diario_event.dart`
- `lib/features/trafico_diario/presentation/bloc/trafico_diario_state.dart`
- `lib/features/trafico_diario/presentation/bloc/trafico_diario_bloc.dart`

### Archivos a MODIFICAR (5)
- `lib/features/trafico_diario/presentation/pages/planificar_servicios_page.dart`
- `lib/features/trafico_diario/presentation/widgets/servicios_table.dart`
- `lib/features/trafico_diario/presentation/widgets/asignacion_masiva_dialog.dart`
- `lib/features/servicios/servicios/presentation/bloc/servicios_event.dart`
- `lib/features/servicios/servicios/presentation/bloc/servicios_state.dart`
- `lib/features/servicios/servicios/presentation/bloc/servicios_bloc.dart`

### Archivos a ELIMINAR (0)
Ninguno

## ✅ Criterios de Éxito

- [ ] `flutter analyze` sin errores
- [ ] TraficoDiarioBloc gestiona solo traslados
- [ ] ServiciosBloc gestiona solo servicios
- [ ] PlanificarServiciosPage funciona correctamente
- [ ] Asignación de conductores funciona
- [ ] Filtros y búsqueda funcionan
- [ ] No hay warnings relacionados con la refactorización
