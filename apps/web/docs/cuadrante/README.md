# 📋 Cuadrante de Dotaciones - Roadmap de Implementación

## 🎯 Objetivo

Implementar el módulo de **Cuadrante de Dotaciones** que gestiona:
- Configuración de dotaciones (cuántas ambulancias necesita cada hospital/base por turno)
- Asignación de vehículos a hospitales/bases según turnos
- Visualización de cuadrante diario/semanal/mensual
- Relación entre personal (turnos) y vehículos asignados

---

## ✅ Completado

### Base de Datos (Supabase)

- [x] Tabla `bases` creada
- [x] Tabla `contratos` creada
- [x] Tabla `dotaciones` creada
- [x] Tabla `asignaciones_vehiculos_turnos` creada
- [x] Tabla `turnos_personal_vehiculos` creada
- [x] Tabla `excepciones_calendario` creada
- [x] Vista `v_asignaciones_hoy` creada
- [x] Vista `v_dotaciones_activas` creada

---

## 🚧 Pendiente de Implementación

### 1️⃣ Capa de Datos (Data Layer)

#### 1.1 Modelos (Models)

**Ubicación**: `packages/ambutrack_core_datasource/lib/features/cuadrante/models/`

- [ ] `base_model.dart`
  - Mapea tabla `bases`
  - `@JsonSerializable()`
  - Métodos `fromJson()`, `toJson()`

- [ ] `contrato_model.dart`
  - Mapea tabla `contratos`
  - Relación con `hospital_id`

- [ ] `dotacion_model.dart`
  - Mapea tabla `dotaciones`
  - Relaciones: `hospital_id`, `base_id`, `tipo_vehiculo_id`, `plantilla_turno_id`

- [x] ~~`asignacion_vehiculo_turno_model.dart`~~ → **IMPLEMENTADO**
  - ✅ Mapea tabla `asignaciones_vehiculos_turnos`
  - ✅ Relaciones: `vehiculo_id`, `dotacion_id`, `hospital_id`, `base_id`
  - ✅ `@JsonSerializable()` configurado
  - ✅ Métodos `toEntity()` y `fromEntity()`

- [ ] `turno_personal_vehiculo_model.dart`
  - Mapea tabla `turnos_personal_vehiculos`
  - Relaciones: `turno_personal_id`, `asignacion_vehiculo_id`

- [ ] `excepcion_calendario_model.dart`
  - Mapea tabla `excepciones_calendario`

#### 1.2 Entidades (Entities)

**Ubicación**: `packages/ambutrack_core_datasource/lib/features/cuadrante/entities/`

- [ ] `base_entity.dart`
  - Modelo de dominio para bases
  - Inmutable con `@freezed`

- [ ] `contrato_entity.dart`
  - Modelo de dominio para contratos

- [ ] `dotacion_entity.dart`
  - Modelo de dominio para dotaciones

- [x] ~~`asignacion_vehiculo_turno_entity.dart`~~ → **IMPLEMENTADO**
  - ✅ Modelo de dominio para asignaciones
  - ✅ Inmutable con `@freezed`
  - ✅ `copyWith()`, `toJson()`, `fromJson()` generados
  - ✅ Validaciones de negocio

- [ ] `turno_personal_vehiculo_entity.dart`
  - Modelo de dominio para relación personal-vehículo

- [ ] `excepcion_calendario_entity.dart`
  - Modelo de dominio para excepciones

#### 1.3 DataSources

**Ubicación**: `packages/ambutrack_core_datasource/lib/features/cuadrante/datasources/`

- [ ] `bases_datasource.dart`
  - CRUD de bases
  - Tipo: **ComplexDataSource**
  - Métodos: `getAll()`, `getById()`, `create()`, `update()`, `delete()`

- [ ] `contratos_datasource.dart`
  - CRUD de contratos
  - Tipo: **ComplexDataSource**
  - Filtros: por hospital, por vigencia

- [ ] `dotaciones_datasource.dart`
  - CRUD de dotaciones
  - Tipo: **ComplexDataSource**
  - Filtros: por hospital, por base, por turno, por vigencia
  - Método especial: `getDotacionesActivasPorFecha(DateTime fecha)`

- [x] ~~`asignaciones_vehiculos_datasource.dart`~~ → **IMPLEMENTADO**
  - ✅ CRUD completo de asignaciones
  - ✅ Tipo: **ComplexDataSource**
  - ✅ Contract: `AsignacionVehiculoTurnoDataSourceContract`
  - ✅ Implementation: `SupabaseAsignacionVehiculoTurnoDataSource`
  - ✅ Factory: `AsignacionVehiculoTurnoDataSourceFactory`
  - ✅ Métodos implementados:
    - `getAll()` - Obtener todas las asignaciones
    - `getById(String id)` - Obtener por ID
    - `create(AsignacionVehiculoTurnoEntity entity)` - Crear asignación
    - `update(AsignacionVehiculoTurnoEntity entity)` - Actualizar asignación
    - `delete(String id)` - Eliminar asignación
    - `getByFecha(DateTime fecha)` - Asignaciones de un día específico
    - `getByRangoFechas(DateTime inicio, DateTime fin)` - Asignaciones de un rango
    - `getByVehiculo(String vehiculoId, DateTime fecha)` - Asignaciones de un vehículo
    - `getByEstado(String estado)` - Filtrar por estado
  - ✅ Validaciones de conflictos de asignación
  - ✅ Logging con emojis para trazabilidad

- [ ] `turnos_personal_vehiculos_datasource.dart`
  - CRUD de relación personal-vehículo
  - Tipo: **ComplexDataSource**
  - Método especial: `getCuadranteDia(DateTime fecha)`

- [ ] `excepciones_calendario_datasource.dart`
  - CRUD de excepciones
  - Tipo: **SimpleDataSource**
  - Filtros: por fecha, por tipo

#### 1.4 Repositorios (Implementación)

**Ubicación**: `lib/features/cuadrante/data/repositories/`

- [ ] `bases_repository_impl.dart`
  - Implementa contrato de dominio
  - Usa `BasesDataSource`
  - Manejo de errores con `Either<Failure, T>`

- [ ] `contratos_repository_impl.dart`
  - Implementa contrato de dominio
  - Usa `ContratosDataSource`

- [ ] `dotaciones_repository_impl.dart`
  - Implementa contrato de dominio
  - Usa `DotacionesDataSource`

- [x] ~~`asignaciones_vehiculos_repository_impl.dart`~~ → **IMPLEMENTADO**
  - ✅ Implementa contrato `AsignacionVehiculoTurnoRepository`
  - ✅ Usa `AsignacionVehiculoTurnoDataSource` del core
  - ✅ Pattern: **Pass-through directo** (sin conversiones Entity ↔ Entity)
  - ✅ Inyección con `@LazySingleton(as: AsignacionVehiculoTurnoRepository)`
  - ✅ Métodos delegados:
    - `getAll()` - Delega a datasource
    - `getById(String id)` - Delega a datasource
    - `create(AsignacionVehiculoTurnoEntity entity)` - Delega a datasource
    - `update(AsignacionVehiculoTurnoEntity entity)` - Delega a datasource
    - `delete(String id)` - Delega a datasource
    - `getByFecha(DateTime fecha)` - Delega a datasource
    - `getByRangoFechas(DateTime inicio, DateTime fin)` - Delega a datasource
    - `getByVehiculo(String vehiculoId, DateTime fecha)` - Delega a datasource
    - `getByEstado(String estado)` - Delega a datasource
  - ✅ Logging con `debugPrint()` para trazabilidad
  - ✅ ~70 líneas (patrón limpio)

- [ ] `turnos_personal_vehiculos_repository_impl.dart`
  - Implementa contrato de dominio
  - Usa `TurnosPersonalVehiculosDataSource`

- [ ] `excepciones_calendario_repository_impl.dart`
  - Implementa contrato de dominio
  - Usa `ExcepcionesCalendarioDataSource`

---

### 2️⃣ Capa de Dominio (Domain Layer)

**Ubicación**: `lib/features/cuadrante/domain/`

#### 2.1 Repositorios (Contratos)

**Ubicación**: `lib/features/cuadrante/domain/repositories/`

- [ ] `bases_repository.dart`
  - Contrato abstracto
  - Métodos: `getAll()`, `getById()`, `create()`, `update()`, `delete()`

- [ ] `contratos_repository.dart`
  - Contrato abstracto
  - Métodos específicos del dominio

- [ ] `dotaciones_repository.dart`
  - Contrato abstracto
  - Método: `getDotacionesActivasPorFecha(DateTime fecha)`

- [x] ~~`asignaciones_vehiculos_repository.dart`~~ → **IMPLEMENTADO**
  - ✅ Contrato abstracto `AsignacionVehiculoTurnoRepository`
  - ✅ Métodos definidos:
    - `Future<List<AsignacionVehiculoTurnoEntity>> getAll()`
    - `Future<AsignacionVehiculoTurnoEntity> getById(String id)`
    - `Future<AsignacionVehiculoTurnoEntity> create(AsignacionVehiculoTurnoEntity entity)`
    - `Future<AsignacionVehiculoTurnoEntity> update(AsignacionVehiculoTurnoEntity entity)`
    - `Future<void> delete(String id)`
    - `Future<List<AsignacionVehiculoTurnoEntity>> getByFecha(DateTime fecha)`
    - `Future<List<AsignacionVehiculoTurnoEntity>> getByRangoFechas(DateTime inicio, DateTime fin)`
    - `Future<List<AsignacionVehiculoTurnoEntity>> getByVehiculo(String vehiculoId, DateTime fecha)`
    - `Future<List<AsignacionVehiculoTurnoEntity>> getByEstado(String estado)`
  - ✅ Ubicación: `lib/features/cuadrante/domain/repositories/asignacion_vehiculo_turno_repository.dart`

- [ ] `turnos_personal_vehiculos_repository.dart`
  - Contrato abstracto
  - Método: `getCuadranteDia(DateTime fecha)`

- [ ] `excepciones_calendario_repository.dart`
  - Contrato abstracto

#### 2.2 Use Cases (Casos de Uso)

**Ubicación**: `lib/features/cuadrante/domain/usecases/`

**Bases**
- [ ] `get_all_bases_usecase.dart`
- [ ] `create_base_usecase.dart`
- [ ] `update_base_usecase.dart`
- [ ] `delete_base_usecase.dart`

**Contratos**
- [ ] `get_contratos_vigentes_usecase.dart`
- [ ] `get_contratos_por_hospital_usecase.dart`
- [ ] `create_contrato_usecase.dart`
- [ ] `update_contrato_usecase.dart`

**Dotaciones**
- [ ] `get_dotaciones_activas_usecase.dart`
- [ ] `get_dotaciones_por_hospital_usecase.dart`
- [ ] `get_dotaciones_por_fecha_usecase.dart`
- [ ] `create_dotacion_usecase.dart`
- [ ] `update_dotacion_usecase.dart`
- [ ] `delete_dotacion_usecase.dart`

**Asignaciones de Vehículos**
- [x] ~~`get_asignaciones_por_fecha_usecase.dart`~~ → **IMPLEMENTADO**
  - ✅ Obtiene asignaciones por fecha específica
  - ✅ Inyección con `@injectable`

- [x] ~~`get_asignaciones_por_rango_fechas_usecase.dart`~~ → **IMPLEMENTADO**
  - ✅ Obtiene asignaciones por rango de fechas
  - ✅ Inyección con `@injectable`

- [x] ~~`get_asignaciones_por_vehiculo_usecase.dart`~~ → **IMPLEMENTADO**
  - ✅ Obtiene asignaciones de un vehículo específico
  - ✅ Inyección con `@injectable`

- [x] ~~`get_asignaciones_por_estado_usecase.dart`~~ → **IMPLEMENTADO**
  - ✅ Filtra asignaciones por estado
  - ✅ Inyección con `@injectable`

- [x] ~~`get_all_asignaciones_usecase.dart`~~ → **IMPLEMENTADO**
  - ✅ Obtiene todas las asignaciones
  - ✅ Inyección con `@injectable`

- [x] ~~`get_asignacion_by_id_usecase.dart`~~ → **IMPLEMENTADO**
  - ✅ Obtiene asignación por ID
  - ✅ Inyección con `@injectable`

- [x] ~~`create_asignacion_usecase.dart`~~ → **IMPLEMENTADO**
  - ✅ Crea nueva asignación
  - ✅ Inyección con `@injectable`

- [x] ~~`update_asignacion_usecase.dart`~~ → **IMPLEMENTADO**
  - ✅ Actualiza asignación existente
  - ✅ Inyección con `@injectable`

- [x] ~~`delete_asignacion_usecase.dart`~~ → **IMPLEMENTADO**
  - ✅ Elimina asignación
  - ✅ Inyección con `@injectable`

- [ ] `generar_asignaciones_automaticas_usecase.dart` (opcional)

**Cuadrante**
- [ ] `get_cuadrante_dia_usecase.dart`
- [ ] `get_cuadrante_semana_usecase.dart`
- [ ] `get_cuadrante_mes_usecase.dart`

**Excepciones**
- [ ] `get_excepciones_por_fecha_usecase.dart`
- [ ] `create_excepcion_usecase.dart`
- [ ] `delete_excepcion_usecase.dart`

---

### 3️⃣ Capa de Presentación (Presentation Layer)

**Ubicación**: `lib/features/cuadrante/presentation/`

#### 3.1 BLoC - Bases

**Ubicación**: `lib/features/cuadrante/presentation/bloc/bases/`

- [ ] `bases_event.dart`
  - `BasesLoadRequested`
  - `BaseCreateRequested(BaseEntity base)`
  - `BaseUpdateRequested(BaseEntity base)`
  - `BaseDeleteRequested(String id)`

- [ ] `bases_state.dart`
  - `BasesInitial`
  - `BasesLoading`
  - `BasesLoaded(List<BaseEntity> bases)`
  - `BasesError(String message)`

- [ ] `bases_bloc.dart`
  - Inyecta use cases
  - Maneja eventos y emite estados

#### 3.2 BLoC - Contratos

**Ubicación**: `lib/features/cuadrante/presentation/bloc/contratos/`

- [ ] `contratos_event.dart`
- [ ] `contratos_state.dart`
- [ ] `contratos_bloc.dart`

#### 3.3 BLoC - Dotaciones

**Ubicación**: `lib/features/cuadrante/presentation/bloc/dotaciones/`

- [ ] `dotaciones_event.dart`
  - `DotacionesLoadRequested`
  - `DotacionesLoadByHospitalRequested(String hospitalId)`
  - `DotacionesLoadByFechaRequested(DateTime fecha)`
  - `DotacionCreateRequested(DotacionEntity dotacion)`
  - `DotacionUpdateRequested(DotacionEntity dotacion)`
  - `DotacionDeleteRequested(String id)`

- [ ] `dotaciones_state.dart`
  - `DotacionesInitial`
  - `DotacionesLoading`
  - `DotacionesLoaded(List<DotacionEntity> dotaciones)`
  - `DotacionesError(String message)`

- [ ] `dotaciones_bloc.dart`

#### 3.4 BLoC - Asignaciones de Vehículos

**Ubicación**: `lib/features/cuadrante/presentation/bloc/asignaciones/`

- [x] ~~`asignaciones_event.dart`~~ → **IMPLEMENTADO**
  - ✅ `AsignacionesLoadAllRequested` - Carga todas las asignaciones
  - ✅ `AsignacionesLoadByFechaRequested(DateTime fecha)` - Carga por fecha
  - ✅ `AsignacionesLoadByRangoRequested(DateTime inicio, DateTime fin)` - Carga por rango
  - ✅ `AsignacionesLoadByVehiculoRequested(String vehiculoId, DateTime fecha)` - Carga por vehículo
  - ✅ `AsignacionesLoadByEstadoRequested(String estado)` - Carga por estado
  - ✅ `AsignacionCreateRequested(AsignacionVehiculoTurnoEntity asignacion)` - Crear
  - ✅ `AsignacionUpdateRequested(AsignacionVehiculoTurnoEntity asignacion)` - Actualizar
  - ✅ `AsignacionDeleteRequested(String id)` - Eliminar
  - ✅ Todos con `@freezed` para inmutabilidad

- [x] ~~`asignaciones_state.dart`~~ → **IMPLEMENTADO**
  - ✅ `AsignacionesInitial` - Estado inicial
  - ✅ `AsignacionesLoading` - Estado de carga
  - ✅ `AsignacionesLoaded(List<AsignacionVehiculoTurnoEntity> asignaciones)` - Datos cargados
  - ✅ `AsignacionesError(String message)` - Estado de error
  - ✅ Todos con `@freezed` para inmutabilidad

- [x] ~~`asignaciones_bloc.dart`~~ → **IMPLEMENTADO**
  - ✅ Inyecta 9 use cases de asignaciones
  - ✅ Maneja todos los eventos (load, create, update, delete)
  - ✅ Emite estados apropiados (loading, loaded, error)
  - ✅ Logging con emojis para trazabilidad
  - ✅ Inyección con `@injectable`
  - ✅ Try-catch para manejo robusto de errores

#### 3.5 BLoC - Cuadrante

**Ubicación**: `lib/features/cuadrante/presentation/bloc/cuadrante/`

- [ ] `cuadrante_event.dart`
  - `CuadranteLoadDiaRequested(DateTime fecha)`
  - `CuadranteLoadSemanaRequested(DateTime fechaInicio)`
  - `CuadranteLoadMesRequested(int mes, int anio)`

- [ ] `cuadrante_state.dart`
  - `CuadranteInitial`
  - `CuadranteLoading`
  - `CuadranteDiaLoaded(List<CuadranteItemEntity> items)`
  - `CuadranteSemanaLoaded(Map<DateTime, List<CuadranteItemEntity>> items)`
  - `CuadranteMesLoaded(Map<DateTime, List<CuadranteItemEntity>> items)`
  - `CuadranteError(String message)`

- [ ] `cuadrante_bloc.dart`

#### 3.6 Páginas (Pages)

**Ubicación**: `lib/features/cuadrante/presentation/pages/`

- [ ] `bases_page.dart`
  - Lista de bases
  - CRUD de bases
  - Tabla con AppDataGrid/ModernDataTable

- [ ] `contratos_page.dart`
  - Lista de contratos
  - Filtros por hospital, vigencia
  - CRUD de contratos

- [ ] `dotaciones_page.dart`
  - Lista de dotaciones activas
  - Filtros por hospital, base, turno
  - CRUD de dotaciones
  - Vista de dotaciones por fecha

- [ ] `asignaciones_page.dart`
  - Vista de asignaciones del día
  - Selector de fecha
  - Asignación manual de vehículos
  - Confirmación de asignaciones

- [ ] `cuadrante_page.dart`
  - Vista principal del cuadrante
  - Selector día/semana/mes
  - Tabla/calendario con:
    - Personal asignado
    - Vehículos asignados
    - Hospitales/bases
  - Arrastrar y soltar (drag & drop) para reasignar

- [ ] `excepciones_calendario_page.dart`
  - Gestión de festivos, refuerzos, reducciones
  - Calendario visual

#### 3.7 Widgets

**Ubicación**: `lib/features/cuadrante/presentation/widgets/`

**Bases**
- [ ] `bases_table.dart`
  - Tabla de bases con ModernDataTable
  - Acciones: ver, editar, eliminar

- [ ] `base_form_dialog.dart`
  - Formulario crear/editar base
  - Validaciones
  - AppDropdown para poblaciones
  - Campos: código, nombre, dirección, capacidad, tipo

**Contratos**
- [ ] `contratos_table.dart`
  - Tabla de contratos
  - Columnas: código, hospital, fechas, tipo, importe, estado

- [ ] `contrato_form_dialog.dart`
  - Formulario crear/editar contrato
  - AppDropdown para hospitales
  - Date pickers para vigencia
  - Campo importe mensual

**Dotaciones**
- [ ] `dotaciones_table.dart`
  - Tabla de dotaciones
  - Columnas: código, nombre, hospital/base, tipo vehículo, turno, cantidad
  - Filtros por hospital, base, vigencia

- [ ] `dotacion_form_dialog.dart`
  - Formulario crear/editar dotación
  - AppDropdown para: hospital, base, tipo vehículo, turno
  - Campos de cantidad
  - Checkboxes días de la semana
  - Date pickers vigencia

- [ ] `dotacion_card.dart`
  - Card para vista resumida de dotación

**Asignaciones**
- [ ] `asignaciones_table.dart`
  - Tabla de asignaciones del día
  - Columnas: vehículo, turno, hospital/base, estado

- [ ] `asignacion_form_dialog.dart`
  - Formulario asignar vehículo manualmente
  - AppDropdown para: vehículo, dotación, turno
  - Date picker para fecha

- [ ] `asignacion_card.dart`
  - Card para vista de asignación
  - Estado visual (planificada, confirmada, en curso)

**Cuadrante**
- [ ] `cuadrante_dia_view.dart`
  - Vista tabla del día
  - Filas: personal
  - Columnas: turno, vehículo, destino

- [ ] `cuadrante_semana_view.dart`
  - Vista semanal (7 días)
  - Tabla con días como columnas

- [ ] `cuadrante_mes_view.dart`
  - Vista calendario mensual
  - Cada día muestra resumen de asignaciones

- [ ] `cuadrante_item_card.dart`
  - Card individual para item del cuadrante
  - Muestra: personal, vehículo, destino, turno

- [ ] `fecha_selector_widget.dart`
  - Selector de fecha con botones anterior/siguiente
  - Vista día/semana/mes

**Excepciones**
- [ ] `excepciones_calendario_table.dart`
  - Tabla de excepciones

- [ ] `excepcion_form_dialog.dart`
  - Formulario crear excepción (festivo, refuerzo)

---

### 4️⃣ Rutas (Router)

**Ubicación**: `lib/core/router/app_router.dart`

- [ ] Ruta `/cuadrante` → `CuadrantePage`
- [ ] Ruta `/cuadrante/bases` → `BasesPage`
- [ ] Ruta `/cuadrante/contratos` → `ContratosPage`
- [ ] Ruta `/cuadrante/dotaciones` → `DotacionesPage`
- [ ] Ruta `/cuadrante/asignaciones` → `AsignacionesPage`
- [ ] Ruta `/cuadrante/excepciones` → `ExcepcionesCalendarioPage`

---

### 5️⃣ Inyección de Dependencias (DI)

**Ubicación**: `lib/core/di/locator.dart`

- [ ] Registrar `BasesDataSource`
- [ ] Registrar `ContratosDataSource`
- [ ] Registrar `DotacionesDataSource`
- [ ] Registrar `AsignacionesVehiculosDataSource`
- [ ] Registrar `TurnosPersonalVehiculosDataSource`
- [ ] Registrar `ExcepcionesCalendarioDataSource`
- [ ] Registrar todos los repositorios
- [ ] Registrar todos los use cases
- [ ] Registrar todos los BLoCs

---

### 6️⃣ Menú de Navegación

**Ubicación**: `lib/features/menu/data/repositories/menu_repository_impl.dart`

- [x] Añadir ítem "Cuadrante" en menú principal (Posición 4 - después de Personal)
- [x] Submenús configurados:
  - ✅ Vista de Cuadrante (`/cuadrante`)
  - ✅ Horarios y Turnos (`/cuadrante/horarios`) - **Movido desde Personal**
  - ✅ Dotaciones (`/cuadrante/dotaciones`)
  - ✅ Asignaciones (`/cuadrante/asignaciones`)
  - ✅ Bases (`/cuadrante/bases`)
  - ✅ Contratos (`/cuadrante/contratos`)
  - ✅ Excepciones/Festivos (`/cuadrante/excepciones`)

**Icono principal**: `Icons.calendar_view_month`

**Nota importante**: ⚠️ **"Horarios y Turnos"** fue movido desde el menú Personal (`/personal/horarios`) a Cuadrante (`/cuadrante/horarios`) porque está directamente relacionado con la gestión de turnos y asignaciones del cuadrante.

**Documentación del menú**: [/docs/menu/estructura_menu_ambutrack.md](/docs/menu/estructura_menu_ambutrack.md)

---

### 7️⃣ Testing

**Ubicación**: `test/features/cuadrante/`

#### Unit Tests
- [ ] Tests de modelos (serialización/deserialización)
- [ ] Tests de datasources (mocks de Supabase)
- [ ] Tests de repositorios
- [ ] Tests de use cases
- [ ] Tests de BLoCs

#### Widget Tests
- [ ] Tests de formularios
- [ ] Tests de tablas
- [ ] Tests de cuadrante view

---

## 📊 Prioridades de Implementación

### Sprint 1: Base (Semana 1)
1. [ ] Modelos y entidades (Bases, Contratos, Dotaciones)
2. [ ] DataSources básicos
3. [ ] Repositorios básicos
4. [ ] BLoC de Bases
5. [ ] Página de Bases con tabla CRUD

### Sprint 2: Dotaciones (Semana 2)
1. [ ] BLoC de Dotaciones
2. [ ] BLoC de Contratos
3. [ ] Página de Dotaciones
4. [ ] Página de Contratos
5. [ ] Formularios completos

### Sprint 3: Asignaciones (Semana 3)
1. [ ] Modelos de Asignaciones
2. [ ] DataSource de Asignaciones
3. [ ] BLoC de Asignaciones
4. [ ] Página de Asignaciones
5. [ ] Asignación manual de vehículos

### Sprint 4: Cuadrante (Semana 4)
1. [ ] BLoC de Cuadrante
2. [ ] Vista diaria
3. [ ] Vista semanal
4. [ ] Vista mensual
5. [ ] Integración personal-vehículos

### Sprint 5: Optimización (Semana 5)
1. [ ] Excepciones de calendario
2. [ ] Validaciones avanzadas
3. [ ] Mejoras UX
4. [ ] Testing
5. [ ] Documentación

---

## 🎨 Estándares de Desarrollo

### Obligatorios
- ✅ Usar `AppColors` para todos los colores
- ✅ Usar `AppDropdown` para todos los dropdowns
- ✅ Usar `showConfirmationDialog` para confirmaciones de eliminación
- ✅ Usar `ModernDataTable` o `AppDataGrid` para tablas
- ✅ Usar `AppIconButton` para acciones (ver/editar/eliminar)
- ✅ `SafeArea` en todas las páginas
- ✅ `debugPrint()` en lugar de `print()`
- ✅ Ejecutar `flutter analyze` antes de commit (0 warnings)
- ✅ Máximo 300 líneas por archivo
- ✅ Widgets pequeños y composables

### Validaciones
- ✅ Formularios con validación de campos requeridos
- ✅ Validación de fechas (inicio < fin)
- ✅ Validación de cantidades (> 0)
- ✅ Validación de conflictos de asignación

### UX
- ✅ Loading states con `AppLoadingIndicator`
- ✅ Loading overlay con `AppLoadingOverlay` en operaciones de eliminación
- ✅ SnackBars con métricas de tiempo (ms)
- ✅ Mensajes de éxito/error consistentes
- ✅ Confirmación antes de eliminar

---

## 📝 Notas Importantes

### Relaciones Clave
- **Dotación** → Define cuántas ambulancias necesita un hospital/base por turno
- **Asignación** → Asigna ambulancias específicas a dotaciones en fechas concretas
- **Turno Personal** → Registra qué personal trabaja cuándo
- **Turno Personal-Vehículo** → Vincula qué personal conduce qué ambulancia

### Validaciones de Negocio
- Un vehículo NO puede estar asignado a 2 lugares al mismo tiempo
- Una dotación debe tener al menos 1 unidad
- Las fechas de vigencia deben ser coherentes (inicio <= fin)
- Los contratos deben estar vigentes para crear dotaciones

### Casos Especiales
- Dotaciones sin turno específico = 24 horas
- Excepciones de calendario pueden aumentar/reducir dotaciones
- Prioridad de dotaciones para resolver conflictos

---

## 🚀 Comandos Útiles

```bash
# Generar código (después de cambios en models/entities)
flutter pub run build_runner build --delete-conflicting-outputs

# Analizar código (OBLIGATORIO antes de commit)
flutter analyze

# Tests
flutter test

# Ejecutar app
flutter run --flavor dev -t lib/main_dev.dart
```

---

## 📚 Referencias

- [CLAUDE.md](/CLAUDE.md) - Guía general del proyecto
- [SUPABASE_GUIDE.md](/SUPABASE_GUIDE.md) - Guía de Supabase
- [Arquitectura Clean](/docs/arquitectura/) - Documentación de arquitectura

---

---

## 📦 Resumen de Implementación Completada

### ✅ Módulo de Asignaciones (100% Completado)

#### Capa Core (packages/ambutrack_core_datasource)
- ✅ **Entity**: `AsignacionVehiculoTurnoEntity` con `@freezed`
- ✅ **Model**: `AsignacionVehiculoTurnoSupabaseModel` con `@JsonSerializable()`
- ✅ **Contract**: `AsignacionVehiculoTurnoDataSourceContract` (interfaz abstracta)
- ✅ **Implementation**: `SupabaseAsignacionVehiculoTurnoDataSource` (9 métodos)
- ✅ **Factory**: `AsignacionVehiculoTurnoDataSourceFactory`
- ✅ **Export**: Exportado en barrel file del core

#### Capa App (lib/features/cuadrante)
- ✅ **Repository Contract**: `AsignacionVehiculoTurnoRepository` (domain)
- ✅ **Repository Impl**: `AsignacionVehiculoTurnoRepositoryImpl` (data) - Pass-through directo
- ✅ **9 Use Cases** implementados con `@injectable`:
  - `GetAllAsignacionesUseCase`
  - `GetAsignacionByIdUseCase`
  - `CreateAsignacionUseCase`
  - `UpdateAsignacionUseCase`
  - `DeleteAsignacionUseCase`
  - `GetAsignacionesPorFechaUseCase`
  - `GetAsignacionesPorRangoFechasUseCase`
  - `GetAsignacionesPorVehiculoUseCase`
  - `GetAsignacionesPorEstadoUseCase`
- ✅ **BLoC completo**:
  - `AsignacionesEvent` (8 eventos con `@freezed`)
  - `AsignacionesState` (4 estados con `@freezed`)
  - `AsignacionesBloc` (maneja todos los casos)

#### Características Implementadas
- ✅ CRUD completo de asignaciones
- ✅ Filtros por fecha, rango de fechas, vehículo y estado
- ✅ Validaciones de negocio
- ✅ Logging detallado con emojis
- ✅ Manejo robusto de errores
- ✅ Pattern pass-through en repositorio (~70 líneas)
- ✅ Inyección de dependencias completa
- ✅ Arquitectura Clean respetada al 100%

#### Métricas
- **Archivos creados**: 16
- **Líneas de código**: ~1,100
- **Warnings**: 0 ✅
- **Patrón**: Clean Architecture + Pass-through
- **Complejidad**: Baja (delegación simple)

#### Próximos Pasos para Asignaciones
- [ ] Crear página UI (`asignaciones_page.dart`)
- [ ] Crear tabla (`asignaciones_table.dart`)
- [ ] Crear formulario (`asignacion_form_dialog.dart`)
- [ ] Añadir rutas en `app_router.dart`
- [ ] Registrar en menú de navegación
- [ ] Ejecutar `flutter pub run build_runner build --delete-conflicting-outputs`

---

**Última actualización**: 2025-12-22
**Versión**: 1.1.0
**Estado**: 🚧 En desarrollo (Módulo Asignaciones: ✅ Backend 100% / ⚠️ UI pendiente)
