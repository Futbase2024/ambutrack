# Plan de Implementación: Tablas Maestras y CRUDs

## 📋 Análisis de Situación Actual

### Tablas en el Menú (Implementadas en UI)
- ✅ Centros Hospitalarios
- ✅ Motivos de Traslado
- ✅ Tipos de Traslado
- ✅ Localidades
- ✅ Vehículos (catálogo)
- ✅ Motivos de Cancelación
- ✅ Facultativos
- ✅ Tipos de Paciente
- ✅ Protocolos y Normativas
- ✅ Categorías de Vehículos
- ✅ Especialidades Médicas

### Tablas en Base de Datos (Mencionadas)
- `tcategorias`
- `tcontratos`
- `tipo_vehiculos`
- `tpoblaciones`
- `tprovincias`
- `tpuestos`
- `tsit_laboral`

---

## 🎯 Mapeo: Base de Datos → Menú

| Tabla BBDD | Menú Actual | Estado | Acción Requerida |
|------------|-------------|--------|------------------|
| `tprovincias` | ✅ Provincias | **✅ COMPLETADO** | Feature + menú implementados |
| `tpoblaciones` | ✅ Localidades | **✅ COMPLETADO** | CRUD implementado |
| `tipo_vehiculos` | Categorías de Vehículos | Existe menú | Implementar CRUD |
| `tcategorias` | ❓ Ambiguo | Revisar | Clarificar propósito |
| `tcontratos` | ❌ No existe | Falta | Crear feature + menú |
| `tpuestos` | ❌ No existe | Falta | Crear feature + menú |
| `tsit_laboral` | ❌ No existe | Falta | Crear feature + menú |

---

## 📐 Propuesta de Estructura de Menú Reorganizada

### 1. TABLAS (Menú Principal)

#### 1.1 Geografía
```dart
MenuItem(
  key: 'tablas_geografia',
  label: 'Geografía',
  icon: Icons.public,
  children: [
    MenuItem(
      key: 'tablas_provincias',
      label: 'Provincias',
      icon: Icons.map,
      route: '/tablas/provincias',
    ),
    MenuItem(
      key: 'tablas_localidades',
      label: 'Localidades/Poblaciones',
      icon: Icons.location_city,
      route: '/tablas/localidades',
    ),
  ],
)
```

#### 1.2 Centros y Facultativos
```dart
MenuItem(
  key: 'tablas_centros',
  label: 'Centros y Facultativos',
  icon: Icons.local_hospital,
  children: [
    MenuItem(
      key: 'tablas_centros_hospitalarios',
      label: 'Centros Hospitalarios',
      icon: Icons.local_hospital,
      route: '/tablas/centros-hospitalarios',
    ),
    MenuItem(
      key: 'tablas_facultativos',
      label: 'Facultativos',
      icon: Icons.medical_services,
      route: '/tablas/facultativos',
    ),
    MenuItem(
      key: 'tablas_especialidades',
      label: 'Especialidades Médicas',
      icon: Icons.medical_information,
      route: '/tablas/especialidades',
    ),
  ],
)
```

#### 1.3 Servicios y Traslados
```dart
MenuItem(
  key: 'tablas_servicios',
  label: 'Servicios y Traslados',
  icon: Icons.local_shipping,
  children: [
    MenuItem(
      key: 'tablas_motivos_traslado',
      label: 'Motivos de Traslado',
      icon: Icons.description,
      route: '/tablas/motivos-traslado',
    ),
    MenuItem(
      key: 'tablas_tipos_traslado',
      label: 'Tipos de Traslado',
      icon: Icons.swap_horiz,
      route: '/tablas/tipos-traslado',
    ),
    MenuItem(
      key: 'tablas_motivos_cancelacion',
      label: 'Motivos de Cancelación',
      icon: Icons.cancel,
      route: '/tablas/motivos-cancelacion',
    ),
    MenuItem(
      key: 'tablas_tipos_paciente',
      label: 'Tipos de Paciente',
      icon: Icons.people,
      route: '/tablas/tipos-paciente',
    ),
  ],
)
```

#### 1.4 Vehículos
```dart
MenuItem(
  key: 'tablas_vehiculos',
  label: 'Vehículos',
  icon: Icons.directions_car,
  children: [
    MenuItem(
      key: 'tablas_tipos_vehiculos',
      label: 'Tipos de Vehículos',
      icon: Icons.local_shipping,
      route: '/tablas/tipos-vehiculos',
    ),
    MenuItem(
      key: 'tablas_categorias_vehiculos',
      label: 'Categorías de Vehículos',
      icon: Icons.category,
      route: '/tablas/categorias-vehiculos',
    ),
    MenuItem(
      key: 'tablas_modelos_vehiculos',
      label: 'Modelos de Vehículos',
      icon: Icons.directions_car,
      route: '/tablas/modelos-vehiculos',
    ),
  ],
)
```

#### 1.5 Personal (NUEVO)
```dart
MenuItem(
  key: 'tablas_personal',
  label: 'Personal',
  icon: Icons.badge,
  children: [
    MenuItem(
      key: 'tablas_puestos',
      label: 'Puestos de Trabajo',
      icon: Icons.work,
      route: '/tablas/puestos',
    ),
    MenuItem(
      key: 'tablas_situacion_laboral',
      label: 'Situación Laboral',
      icon: Icons.business_center,
      route: '/tablas/situacion-laboral',
    ),
    MenuItem(
      key: 'tablas_tipos_contrato',
      label: 'Tipos de Contrato',
      icon: Icons.description,
      route: '/tablas/tipos-contrato',
    ),
  ],
)
```

#### 1.6 Categorías Generales (NUEVO - Revisar)
```dart
MenuItem(
  key: 'tablas_categorias',
  label: 'Categorías',
  icon: Icons.category,
  children: [
    MenuItem(
      key: 'tablas_categorias_generales',
      label: 'Categorías Generales',
      icon: Icons.label,
      route: '/tablas/categorias',
    ),
  ],
)
```

#### 1.7 Normativas (Ya existe)
```dart
MenuItem(
  key: 'tablas_normativas',
  label: 'Normativas',
  icon: Icons.gavel,
  children: [
    MenuItem(
      key: 'tablas_protocolos',
      label: 'Protocolos y Normativas',
      icon: Icons.gavel,
      route: '/tablas/protocolos',
    ),
  ],
)
```

---

## 🚀 Plan de Implementación por Prioridad

### FASE 1: Tablas Críticas (Alta Prioridad)
**Objetivo**: Completar las tablas fundamentales para el funcionamiento del sistema

#### 1.1 Provincias
- **Ruta**: `/tablas/provincias`
- **Feature**: `lib/features/tablas/provincias/`
- **Tabla BBDD**: `tprovincias`
- **Campos**:
  - `id` (PK)
  - `codigo` (código INE)
  - `nombre`
  - `comunidad_autonoma`
  - `activo`
- **Relaciones**: 1:N con `tpoblaciones`

#### 1.2 Localidades/Poblaciones
- **Ruta**: `/tablas/localidades`
- **Feature**: `lib/features/tablas/localidades/`
- **Tabla BBDD**: `tpoblaciones`
- **Campos**:
  - `id` (PK)
  - `provincia_id` (FK)
  - `codigo_postal`
  - `nombre`
  - `activo`
- **Relaciones**: N:1 con `tprovincias`

#### 1.3 Tipos de Vehículos
- **Ruta**: `/tablas/tipos-vehiculos`
- **Feature**: `lib/features/tablas/tipos_vehiculos/`
- **Tabla BBDD**: `tipo_vehiculos`
- **Campos**:
  - `id` (PK)
  - `codigo`
  - `nombre`
  - `descripcion`
  - `requiere_equipamiento_medico`
  - `capacidad_pasajeros`
  - `activo`
- **Relaciones**: 1:N con vehículos

#### 1.4 Puestos de Trabajo
- **Ruta**: `/tablas/puestos`
- **Feature**: `lib/features/tablas/puestos/`
- **Tabla BBDD**: `tpuestos`
- **Campos**:
  - `id` (PK)
  - `codigo`
  - `nombre`
  - `descripcion`
  - `categoria` (sanitario/no sanitario)
  - `requiere_certificacion`
  - `activo`
- **Relaciones**: 1:N con personal

#### 1.5 Situación Laboral
- **Ruta**: `/tablas/situacion-laboral`
- **Feature**: `lib/features/tablas/situacion_laboral/`
- **Tabla BBDD**: `tsit_laboral`
- **Campos**:
  - `id` (PK)
  - `codigo`
  - `nombre`
  - `descripcion`
  - `activo`
- **Valores típicos**: Activo, Baja temporal, Baja definitiva, Excedencia, etc.

### FASE 2: Tablas Complementarias (Media Prioridad)

#### 2.1 Tipos de Contrato
- **Ruta**: `/tablas/tipos-contrato`
- **Feature**: `lib/features/tablas/tipos_contrato/`
- **Tabla BBDD**: `tcontratos`
- **Campos**:
  - `id` (PK)
  - `codigo`
  - `nombre`
  - `descripcion`
  - `duracion_meses` (null si indefinido)
  - `activo`
- **Valores típicos**: Indefinido, Temporal, Prácticas, etc.

#### 2.2 Categorías de Vehículos
- **Ruta**: `/tablas/categorias-vehiculos`
- **Feature**: `lib/features/tablas/categorias_vehiculos/`
- **Tabla BBDD**: Relacionada con `tipo_vehiculos`
- **Campos**:
  - `id` (PK)
  - `codigo`
  - `nombre`
  - `descripcion`
  - `activo`
- **Valores típicos**: UVI Móvil, SVB, SVA, etc.

#### 2.3 Centros Hospitalarios
- **Ruta**: `/tablas/centros-hospitalarios`
- **Feature**: `lib/features/tablas/centros_hospitalarios/`
- **Tabla BBDD**: `tcentros_hospitalarios`
- **Campos**:
  - `id` (PK)
  - `codigo`
  - `nombre`
  - `direccion`
  - `localidad_id` (FK)
  - `telefono`
  - `email`
  - `coordenadas_gps`
  - `tipo_centro` (Hospital, Centro Salud, Clínica)
  - `especialidades` (JSON array)
  - `activo`

#### 2.4 Facultativos
- **Ruta**: `/tablas/facultativos`
- **Feature**: `lib/features/tablas/facultativos/`
- **Tabla BBDD**: `tfacultativos`
- **Campos**:
  - `id` (PK)
  - `nombre`
  - `apellidos`
  - `num_colegiado`
  - `especialidad_id` (FK)
  - `centro_id` (FK)
  - `telefono`
  - `email`
  - `activo`

#### 2.5 Especialidades Médicas
- **Ruta**: `/tablas/especialidades`
- **Feature**: `lib/features/tablas/especialidades/`
- **Tabla BBDD**: `tespecialidades`
- **Campos**:
  - `id` (PK)
  - `codigo`
  - `nombre`
  - `descripcion`
  - `activo`

### FASE 3: Tablas de Servicios (Media-Baja Prioridad)

#### 3.1 Motivos de Traslado
- **Ruta**: `/tablas/motivos-traslado`
- **Feature**: `lib/features/tablas/motivos_traslado/`
- **Campos**:
  - `id`, `codigo`, `nombre`, `descripcion`, `prioridad`, `activo`

#### 3.2 Tipos de Traslado
- **Ruta**: `/tablas/tipos-traslado`
- **Feature**: `lib/features/tablas/tipos_traslado/`
- **Campos**:
  - `id`, `codigo`, `nombre`, `descripcion`, `requiere_personal_medico`, `activo`

#### 3.3 Motivos de Cancelación
- **Ruta**: `/tablas/motivos-cancelacion`
- **Feature**: `lib/features/tablas/motivos_cancelacion/`
- **Campos**:
  - `id`, `codigo`, `nombre`, `descripcion`, `activo`

#### 3.4 Tipos de Paciente
- **Ruta**: `/tablas/tipos-paciente`
- **Feature**: `lib/features/tablas/tipos_paciente/`
- **Campos**:
  - `id`, `codigo`, `nombre`, `descripcion`, `requiere_cuidados_especiales`, `activo`

### FASE 4: Normativas (Baja Prioridad)

#### 4.1 Protocolos y Normativas
- **Ruta**: `/tablas/protocolos`
- **Feature**: `lib/features/tablas/protocolos/`
- **Campos**:
  - `id`, `codigo`, `nombre`, `descripcion`, `documento_url`, `fecha_vigencia`, `activo`

### FASE 5: Revisar Necesidad (Pendiente de Clarificación)

#### 5.1 Categorías Generales
- **Tabla BBDD**: `tcategorias`
- **⚠️ ACCIÓN REQUERIDA**: Clarificar el propósito de esta tabla
- **Preguntas**:
  - ¿Es una tabla genérica para categorizar múltiples entidades?
  - ¿Se refiere a categorías de personal, servicios, o algo más?
  - ¿Puede fusionarse con otra tabla existente?

---

## 📊 Resumen de CRUDs a Implementar

### Total de Features/CRUDs: 15

#### Alta Prioridad (5)
1. ✅ **Provincias** - COMPLETADO (2025-12-17)
2. ✅ **Localidades/Poblaciones** - COMPLETADO (2025-12-17)
3. ✅ **Tipos de Vehículos** - COMPLETADO (2025-12-17)
4. ⏳ Puestos de Trabajo - PENDIENTE
5. ⏳ Situación Laboral - PENDIENTE

#### Media Prioridad (6)
6. ⏳ Tipos de Contrato - PENDIENTE
7. ⏳ Categorías de Vehículos - PENDIENTE
8. ✅ **Centros Hospitalarios** - COMPLETADO (2025-12-17)
9. ⏳ Facultativos - PENDIENTE
10. ⏳ Especialidades Médicas - PENDIENTE
11. ✅ **Motivos de Traslado** - COMPLETADO (2025-12-17)

#### Baja Prioridad (4)
12. ✅ **Tipos de Traslado** - COMPLETADO (2025-12-18)
13. ✅ **Motivos de Cancelación** - COMPLETADO (2025-12-17)
14. ⏳ Tipos de Paciente - PENDIENTE
15. ⏳ Protocolos y Normativas - PENDIENTE

#### Pendiente de Clarificación (1)
16. ❓ Categorías Generales

---

## 🏗️ Estructura de Feature Estándar

Cada CRUD debe seguir esta estructura de Clean Architecture:

```
lib/features/tablas/[nombre]/
├── domain/
│   ├── entities/
│   │   └── [nombre]_entity.dart
│   └── repositories/
│       └── [nombre]_repository.dart
├── data/
│   ├── models/
│   │   └── [nombre]_model.dart
│   ├── datasources/
│   │   └── [nombre]_datasource.dart
│   └── repositories/
│       └── [nombre]_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── [nombre]_event.dart
    │   ├── [nombre]_state.dart
    │   └── [nombre]_bloc.dart
    ├── pages/
    │   └── [nombre]_page.dart
    └── widgets/
        ├── [nombre]_table.dart
        ├── [nombre]_form_dialog.dart
        └── [nombre]_card.dart
```

---

## 🎨 Patrón UI Estándar

Todas las páginas de tablas maestras deben seguir este patrón:

### Componentes UI Requeridos

1. **Página Principal** (`[nombre]_page.dart`)
   - SafeArea (OBLIGATORIO)
   - Título de la página
   - Botón "Agregar" en esquina superior derecha
   - Tabla con datos
   - Paginación

2. **Tabla** (`[nombre]_table.dart`)
   - Columnas: ID, Código, Nombre, Descripción, Estado, Acciones
   - Botones de acción: Editar, Eliminar
   - Indicador de estado (Activo/Inactivo) con colores

3. **Formulario** (`[nombre]_form_dialog.dart`)
   - Modo Crear/Editar
   - Validaciones de campos
   - Botones: Cancelar, Guardar
   - Indicador de carga mientras se guardan datos
   - Usar `AppDropdown` para selects
   - Usar `AppColors` para todos los colores

4. **Estados del BLoC**
   - `Initial`
   - `Loading`
   - `Loaded`
   - `Error`
   - `Creating`
   - `Updating`
   - `Deleting`

---

## 🔗 Relaciones entre Tablas

### Diagrama de Relaciones Principales

```
tprovincias (1) ──→ (N) tpoblaciones
                         ↓
                     (N) tcentros_hospitalarios
                              ↓
                          (N) tfacultativos
                              ↑
                    tespecialidades (1)

tipo_vehiculos (1) ──→ (N) vehiculos

tpuestos (1) ──→ (N) personal
                      ↑
                 tsit_laboral (1)
                      ↑
                 tcontratos (1)

tmotivos_traslado (1) ──→ (N) servicios
ttipos_traslado (1) ──→ (N) servicios
ttipos_paciente (1) ──→ (N) servicios
```

---

## ✅ Checklist por Feature

Para cada tabla maestra, verificar:

### Desarrollo
- [ ] Entity creada en dominio
- [ ] Repository contract definido
- [ ] Model con @JsonSerializable
- [ ] DataSource con Supabase
- [ ] Repository implementation
- [ ] BLoC con eventos y estados
- [ ] Página principal con SafeArea
- [ ] Tabla con paginación
- [ ] Formulario crear/editar
- [ ] Validaciones de campos
- [ ] Manejo de errores

### Calidad
- [ ] `flutter analyze` → 0 warnings
- [ ] Límites de líneas respetados (<350)
- [ ] AppColors usado en toda la UI
- [ ] AppDropdown para selects
- [ ] Textos localizados (español)
- [ ] SafeArea en página
- [ ] Código limpio y comentado

### Integración
- [ ] Ruta registrada en GoRouter
- [ ] Menú actualizado en MenuRepository
- [ ] DI configurada con @injectable
- [ ] Build runner ejecutado
- [ ] Probado en navegador

---

## 🚦 Orden de Implementación Recomendado

1. ✅ **Provincias** (sin dependencias) - COMPLETADO
2. ✅ **Localidades** (depende de Provincias) - COMPLETADO
3. ✅ **Tipos de Vehículos** (sin dependencias) - COMPLETADO
4. ✅ **Centros Hospitalarios** (depende de Localidades) - COMPLETADO
5. ✅ **Motivos de Traslado** (sin dependencias) - COMPLETADO
6. ✅ **Motivos de Cancelación** (sin dependencias) - COMPLETADO
7. ✅ **Tipos de Traslado** (sin dependencias) - COMPLETADO
8. ⏳ **Especialidades Médicas** (sin dependencias) - SIGUIENTE
9. ⏳ **Facultativos** (depende de Centros + Especialidades)
10. ⏳ **Puestos de Trabajo** (sin dependencias)
11. ⏳ **Situación Laboral** (sin dependencias)
12. ⏳ **Tipos de Contrato** (sin dependencias)
13. ⏳ **Categorías de Vehículos** (sin dependencias)
14. ⏳ **Tipos de Paciente** (sin dependencias)
15. ⏳ **Protocolos y Normativas** (sin dependencias)

---

## 📝 Notas Finales

### Consideraciones Importantes

1. **Migración Supabase**: TODAS las tablas deben usar Supabase, NO Firebase
2. **Ubicación de Modelos**: Los modelos se crean en `packages/ambutrack_core_datasource/`
3. **Tipo de DataSource**: Usar `SimpleDataSource` para tablas maestras estáticas
4. **Cache**: Configurar cache largo (24-48h) para tablas maestras
5. **Paginación**: Implementar para tablas con >100 registros
6. **Búsqueda**: Añadir filtros de búsqueda en tablas grandes
7. **Export**: Considerar exportación CSV/Excel en futuro

### Próximos Pasos

1. ✅ Revisar y aprobar este plan
2. ✅ Clarificar propósito de tabla `tcategorias`
3. ✅ Definir estructura de BBDD en Supabase para cada tabla
4. ✅ Crear modelos en `ambutrack_core_datasource`
5. ✅ Implementar CRUDs según prioridad
6. ✅ Testing de cada feature
7. ✅ Documentación de uso

---

## 📈 Progreso de Implementación

### CRUDs Completados: 7/15 (47%)

#### ✅ Completados
1. **Provincias**
   - 📅 Fecha: 2025-12-17
   - 📦 Ubicación: `lib/features/tablas/provincias/`
   - 🗄️ Tabla: `tprovincias`
   - ✨ Características:
     - CRUD completo (Crear, Leer, Actualizar, Eliminar)
     - Filtro por Comunidad Autónoma
     - Búsqueda por texto
     - Ordenamiento por columnas
     - Dropdown de comunidades autónomas en formulario
     - JOIN con `tcomunidades`
   - ✅ Sin warnings en `flutter analyze`
   - 🔗 Ruta: `/tablas/provincias`

2. **Localidades/Poblaciones**
   - 📅 Fecha: 2025-12-17
   - 📦 Ubicación: `lib/features/tablas/localidades/`
   - 🗄️ Tabla: `tpoblaciones`
   - ✨ Características:
     - CRUD completo (Crear, Leer, Actualizar, Eliminar)
     - Filtro por Provincia
     - Búsqueda por texto (nombre, código postal, provincia)
     - Ordenamiento por columnas
     - Dropdown de provincias en formulario
     - JOIN con `tprovincias`
     - Columnas: C.P., Localidad, Provincia
   - ✅ Sin warnings en `flutter analyze`
   - 🔗 Ruta: `/tablas/localidades`

3. **Tipos de Vehículos**
   - 📅 Fecha: 2025-12-17
   - 📦 Ubicación: `lib/features/tablas/tipos_vehiculo/`
   - 🗄️ Tabla: `tipos_vehiculo`
   - ✨ Características:
     - CRUD completo (Crear, Leer, Actualizar, Eliminar)
     - Búsqueda por texto (nombre, descripción)
     - Ordenamiento por columnas (ORDEN, NOMBRE, DESCRIPCIÓN, ESTADO)
     - Switch activo/inactivo en formulario
     - Campo orden numérico
     - Columnas: ORDEN, NOMBRE, DESCRIPCIÓN, ESTADO
   - ✅ Sin warnings en `flutter analyze`
   - 🔗 Ruta: `/tablas/tipos-vehiculo`

4. **Centros Hospitalarios**
   - 📅 Fecha: 2025-12-17
   - 📦 Ubicación: `lib/features/tablas/centros_hospitalarios/`
   - 🗄️ Tabla: `tcentros_hospitalarios`
   - ✨ Características:
     - CRUD completo (Crear, Leer, Actualizar, Eliminar)
     - Búsqueda por texto (nombre, localidad, provincia, tipo)
     - Ordenamiento por columnas (NOMBRE, TIPO, LOCALIDAD, TELÉFONO, ESTADO)
     - Dropdowns en formulario: Provincia, Localidad, Tipo de Centro
     - Campos: Nombre, Dirección, Teléfono, Email, Tipo, Localidad, Provincia
     - JOIN con `tpoblaciones` y `tprovincias`
     - Loading indicator mientras cargan datos del formulario
     - Indicador de carga en operaciones (Crear/Editar)
   - ✅ Sin warnings en `flutter analyze`
   - 🔗 Ruta: `/tablas/centros-hospitalarios`

5. **Motivos de Traslado**
   - 📅 Fecha: 2025-12-17
   - 📦 Ubicación: `lib/features/tablas/motivos_traslado/`
   - 🗄️ Tabla: `tmotivos_traslado`
   - ✨ Características:
     - CRUD completo (Crear, Leer, Actualizar, Eliminar)
     - Búsqueda por texto (nombre, descripción)
     - Ordenamiento por columnas (NOMBRE, DESCRIPCIÓN, ESTADO)
     - Switch activo/inactivo en formulario
     - Campos: Nombre, Descripción, Estado
     - Validaciones: Nombre (min 3 chars), Descripción (min 5 chars)
     - Loading overlay en operaciones (Crear/Editar)
     - Stack con AppLoadingIndicator
   - ✅ Sin warnings en `flutter analyze`
   - 🔗 Ruta: `/tablas/motivos-traslado`
   - 📄 Documentación completa: `docs/tablas/motivos_traslado.md`
   - 🗄️ Script SQL para Supabase incluido

6. **Motivos de Cancelación**
   - 📅 Fecha: 2025-12-17
   - 📦 Ubicación: `lib/features/tablas/motivos_cancelacion/`
   - 🗄️ Tabla: `tmotivos_cancelacion`
   - ✨ Características:
     - CRUD completo (Crear, Leer, Actualizar, Eliminar)
     - Búsqueda por texto (nombre, descripción)
     - Ordenamiento por columnas (NOMBRE, DESCRIPCIÓN, ESTADO)
     - Switch activo/inactivo en formulario
     - Campos: Nombre, Descripción, Estado
     - Validaciones: Nombre (min 3 chars), Descripción (min 5 chars)
     - Loading overlay estándar en operaciones (Crear/Editar)
     - Patrón de eliminación con context management
     - ModernDataTable con acciones (Editar/Eliminar)
   - ✅ Sin warnings en `flutter analyze`
   - 🔗 Ruta: `/tablas/motivos-cancelacion`
   - 📄 Documentación completa: `docs/tablas/motivos_cancelacion.md`
   - 🗄️ Script SQL con 15 registros seed incluido

7. **Tipos de Traslado**
   - 📅 Fecha: 2025-12-18
   - 📦 Ubicación: `lib/features/tablas/tipos_traslado/`
   - 🗄️ Tabla: `ttipos_traslado`
   - ✨ Características:
     - CRUD completo (Crear, Leer, Actualizar, Eliminar)
     - Búsqueda por texto (nombre, descripción)
     - Ordenamiento por columnas (NOMBRE, DESCRIPCIÓN, ESTADO)
     - Switch activo/inactivo en formulario
     - Campos: Nombre, Descripción, Estado
     - Validaciones: Nombre (min 3 chars), Descripción (min 5 chars)
     - Loading overlay estándar en operaciones (Crear/Editar)
     - Patrón estandarizado (personal, motivos_cancelacion)
     - ModernDataTable con acciones (Editar/Eliminar)
   - ✅ Sin warnings en `flutter analyze`
   - 🔗 Ruta: `/tablas/tipos-traslado`
   - 📄 Documentación completa: `docs/tablas/tipos_traslado.md`
   - 🗄️ Script SQL con 10 registros seed incluido

8. **Especialidades Médicas**
   - 📅 Fecha: 2025-12-18
   - 📦 Ubicación: `lib/features/tablas/especialidades_medicas/`
   - 🗄️ Tabla: `tespecialidades`
   - ✨ Características:
     - CRUD completo (Crear, Leer, Actualizar, Eliminar)
     - Búsqueda por texto (nombre, descripción, tipo)
     - Ordenamiento por columnas (NOMBRE, TIPO)
     - Dropdown para tipo_especialidad (medica, quirurgica, diagnostica, apoyo, enfermeria, tecnica)
     - Switch requiere_certificacion en formulario
     - Switch activo/inactivo
     - Chips de color por tipo de especialidad
     - Columnas: NOMBRE, TIPO, CERTIFICACIÓN, ESTADO
     - Loading overlay en eliminación con métricas de tiempo
     - Patrón estandarizado con BlocListener + AppLoadingOverlay
   - ✅ Sin warnings en `flutter analyze`
   - 🔗 Ruta: `/tablas/especialidades`
   - 🌱 20 registros seed incluidos en migración

#### 🎯 Próximo en la Lista
9. **Facultativos** - 🔄 MEJORAR (ConfirmationDialog con detalles)
   - 📅 Iniciado: 2025-12-18 (mejoras FK)
   - 🗄️ Migración SQL:
     - `supabase/migrations/004_crear_tabla_facultativos.sql` (creación)
     - `supabase/migrations/006_migrar_facultativos_especialidad_fk_clean.sql` (FK)
   - 📦 Ubicación: `lib/features/tablas/facultativos/`
   - 🗄️ Tabla: `tfacultativos`
   - ✨ Características:
     - CRUD completo implementado
     - Relación FK con `tespecialidades` (especialidad_id UUID)
     - Dropdown de especialidades con carga asíncrona
     - Loading indicator durante carga de datos del formulario
     - Validación de email
     - Campos: Nombre, Apellidos, Nº Colegiado, Especialidad, Teléfono, Email, Estado
     - Patrón estandarizado con BlocListener + AppLoadingOverlay
   - 🔗 Ruta: `/tablas/facultativos`
   - 📄 Documentación: `docs/tablas/facultativos.md`

### Estadísticas
- **Total de features**: 15
- **Completadas**: 8 (Especialidades Médicas ✅)
- **En mejoras**: 7 (actualizar ConfirmationDialog con detalles)
- **Pendientes**: 0
- **Progreso**: 53% (8/15)
- **Próxima tarea**: Estandarizar ConfirmationDialog en todos los CRUDs

### Notas de Implementación
- Todos los CRUDs siguen la misma estructura de Clean Architecture
- Uso consistente de `AppColors`, `AppDropdown`, y widgets reutilizables
- Tablas modernas con filtros, búsqueda y ordenamiento
- Formularios con validaciones y loading states
- Loading overlay en operaciones Crear/Editar (Stack + AppLoadingIndicator)
- 0 warnings en `flutter analyze` para cada módulo
- Documentación completa para cada módulo en `docs/tablas/`
- Scripts SQL para Supabase incluidos en documentación

### Mejoras Recientes
- ✅ **Loading Overlay (2025-12-17)**: Implementado patrón estándar con Stack + AppLoadingIndicator
- ✅ **Centros Hospitalarios (2025-12-17)**: CRUD completo con relaciones FK (provincia, localidad)
- ✅ **Motivos de Traslado (2025-12-17)**: CRUD completo con documentación exhaustiva
- ✅ **Validaciones (2025-12-17)**: Formularios con validaciones robustas
- ✅ **Feedback Visual (2025-12-17)**: SnackBars de éxito/error en todas las operaciones
- ✅ **Estandarización de Loading/Edición (2025-12-17 PM)**:
  - Todos los form_dialog ahora siguen el patrón de Personal
  - BlocListener escucha `*Loaded` en lugar de `*Created`/`*Updated`
  - Loading overlay con `showDialog` + `AppLoadingOverlay`
  - Cierre automático de diálogos (loading + formulario)
  - Logs consistentes con `debugPrint` (no `print`)
  - Mensajes de éxito/error estandarizados
  - Iconos en botones: `Icons.save` (crear), `Icons.check` (editar)
  - **Archivos estandarizados**:
    - `motivo_traslado_form_dialog.dart`
    - `motivo_traslado_table.dart` (eliminación mejorada)
    - `centro_hospitalario_form_dialog.dart`
    - `tipo_vehiculo_form_dialog.dart`
    - `localidad_form_dialog.dart` (ya estaba correcto)
    - `provincia_form_dialog.dart` (ya estaba correcto)

- ✅ **Estandarización de UI de Tablas (2025-12-18)**:
  - **9 tablas** ahora siguen exactamente el patrón de `motivos_cancelacion_table.dart`
  - BlocListener + BlocBuilder para gestión de estados
  - Loading overlay en eliminación con métricas de tiempo (ms)
  - Context management seguro con `_loadingDialogContext`
  - Confirmación doble con `showConfirmationDialog`
  - Timestamp tracking con `_deleteStartTime`
  - Import de `dart:async` para `unawaited`
  - AppLoadingOverlay con icono `Icons.delete_forever` y color `AppColors.emergency`
  - SnackBars con tiempo de operación: "✅ X eliminado exitosamente (Xms)"
  - **Tablas estandarizadas**:
    1. ✅ Motivos de Cancelación (referencia)
    2. ✅ Motivos de Traslado
    3. ✅ Tipos de Traslado
    4. ✅ Especialidades Médicas
    5. ✅ Facultativos
    6. ✅ Centros Hospitalarios
    7. ✅ Localidades
    8. ✅ Provincias
    9. ✅ Tipos de Vehículo

---

**Creado**: 2025-12-17
**Última actualización**: 2025-12-18 14:30
**Versión**: 1.8
**Estado**: En progreso (8/15 completados - 53%, 9 tablas estandarizadas)
