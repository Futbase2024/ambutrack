# Especialidades Médicas - CRUD Completo

**Fecha de creación**: 2025-12-18
**Módulo**: Tablas Maestras
**Feature**: `lib/features/tablas/especialidades_medicas/`

---

## 📋 Descripción General

Módulo de gestión de **especialidades médicas y certificaciones profesionales** para el sistema AmbuTrack. Permite administrar el catálogo completo de especialidades que pueden tener los profesionales sanitarios del sistema.

### Características Principales

- ✅ **CRUD Completo** (Crear, Leer, Actualizar, Eliminar)
- 🔍 **Búsqueda avanzada** por nombre, código o descripción
- 🏷️ **Filtrado por tipo** de especialidad
- 🎨 **Etiquetas visuales** con códigos de color por tipo
- 🔒 **Control de certificaciones** requeridas
- 📊 **20 especialidades precargadas** en seed data
- ⚡ **Estado activo/inactivo** para cada especialidad

---

## 🗄️ Estructura de Datos

### Tabla: `tespecialidades`

| Campo | Tipo | Descripción | Requerido |
|-------|------|-------------|-----------|
| `id` | UUID | Identificador único (PK) | ✅ |
| `codigo` | TEXT | Código normalizado (único) | ✅ |
| `nombre` | TEXT | Nombre de la especialidad | ✅ |
| `descripcion` | TEXT | Descripción detallada | ❌ |
| `requiere_certificacion` | BOOLEAN | Si requiere certificación específica | ✅ (default: true) |
| `tipo_especialidad` | TEXT | Tipo de especialidad | ✅ (default: 'medica') |
| `activo` | BOOLEAN | Estado activo/inactivo | ✅ (default: true) |
| `created_at` | TIMESTAMP | Fecha de creación | ✅ (auto) |
| `updated_at` | TIMESTAMP | Fecha de actualización | ✅ (auto) |

### Tipos de Especialidad

```sql
CONSTRAINT check_tipo_especialidad CHECK (
    tipo_especialidad IN ('medica', 'quirurgica', 'diagnostica', 'apoyo', 'enfermeria', 'tecnica')
)
```

#### Tipos Disponibles

1. **`medica`** - Especialidades Médicas
   🎨 Color: Azul primario
   📝 Ejemplos: Medicina de Urgencias, Cardiología, Pediatría

2. **`quirurgica`** - Especialidades Quirúrgicas
   🎨 Color: Verde secundario
   📝 Ejemplos: Traumatología, Cirugía General, Neurocirugía

3. **`diagnostica`** - Especialidades Diagnósticas
   🎨 Color: Azul info
   📝 Ejemplos: Radiología, Laboratorio Clínico

4. **`apoyo`** - Especialidades de Apoyo
   🎨 Color: Amarillo warning
   📝 Ejemplos: Anestesiología, Farmacia Hospitalaria

5. **`enfermeria`** - Enfermería
   🎨 Color: Rosa
   📝 Ejemplos: Enfermería, Enfermería de Urgencias, Auxiliar de Enfermería

6. **`tecnica`** - Técnicos
   🎨 Color: Púrpura
   📝 Ejemplos: TES, Conductor de Ambulancia, Técnico de Laboratorio

---

## 📊 Datos Iniciales (Seed)

### Total: 20 especialidades precargadas

#### Especialidades Médicas (5)
- `MED-URG` - Medicina de Urgencias
- `MED-INT` - Medicina Interna
- `CARDIO` - Cardiología
- `PEDIATRIA` - Pediatría
- `GERIATRIA` - Geriatría

#### Especialidades Quirúrgicas (3)
- `TRAUMATO` - Traumatología
- `CIRUGIA-GEN` - Cirugía General
- `NEURO-CIR` - Neurocirugía

#### Especialidades Diagnósticas (2)
- `RADIOLOGIA` - Radiología
- `LAB-CLINICO` - Laboratorio Clínico

#### Especialidades de Apoyo (2)
- `ANESTESIA` - Anestesiología
- `FARMACIA` - Farmacia Hospitalaria

#### Enfermería (4)
- `ENFERMERIA` - Enfermería (general)
- `ENF-URG` - Enfermería de Urgencias
- `ENF-UCI` - Enfermería de UCI
- `AUX-ENF` - Auxiliar de Enfermería (sin certificación)

#### Técnicos (4)
- `TES` - Técnico en Emergencias Sanitarias
- `TEC-RADIO` - Técnico en Radiología
- `TEC-LAB` - Técnico de Laboratorio
- `CONDUCTOR` - Conductor de Ambulancia

---

## 🏗️ Arquitectura (Clean Architecture)

```
lib/features/tablas/especialidades_medicas/
├── domain/
│   ├── entities/
│   │   └── especialidad_entity.dart          # Entidad de dominio
│   └── repositories/
│       └── especialidad_repository.dart       # Contrato abstracto
├── data/
│   ├── models/
│   │   ├── especialidad_model.dart           # DTO con @JsonSerializable
│   │   └── especialidad_model.g.dart         # Generado por build_runner
│   ├── datasources/
│   │   └── especialidad_datasource.dart      # Acceso a Supabase
│   └── repositories/
│       └── especialidad_repository_impl.dart  # Implementación del contrato
└── presentation/
    ├── bloc/
    │   ├── especialidad_event.dart           # Eventos del BLoC
    │   ├── especialidad_state.dart           # Estados del BLoC
    │   └── especialidad_bloc.dart            # Lógica de negocio
    ├── pages/
    │   └── especialidades_medicas_page.dart  # Página principal
    └── widgets/
        ├── especialidad_header.dart          # Header con búsqueda y filtros
        ├── especialidad_table.dart           # Tabla de especialidades
        └── especialidad_form_dialog.dart     # Formulario crear/editar
```

---

## 🎨 Interfaz de Usuario

### Página Principal

**Ruta**: `/tablas/especialidades`
**Nombre**: `tablas_especialidades`

#### Componentes UI

1. **Header** (`EspecialidadHeader`)
   - Título: "Especialidades Médicas"
   - Subtítulo descriptivo
   - **Botón "Agregar Especialidad"** (esquina superior derecha)
   - **Barra de búsqueda** (nombre, código, descripción)
   - **Dropdown de filtro** por tipo de especialidad

2. **Tabla** (`EspecialidadTable`)
   - Columnas: CÓDIGO, NOMBRE, TIPO, CERTIFICACIÓN, DESCRIPCIÓN, ESTADO, ACCIONES
   - **Código**: Badge con fondo gris
   - **Nombre**: Texto en negrita
   - **Tipo**: Badge con color según tipo
   - **Certificación**: Icono + texto (Sí/No)
   - **Descripción**: Max 300px, ellipsis si es largo
   - **Estado**: Badge con punto (Activo verde / Inactivo rojo)
   - **Acciones**: Botones Editar (azul) y Eliminar (rojo)

3. **Formulario** (`EspecialidadFormDialog`)
   - **Modo Crear** (título: "Nueva Especialidad")
   - **Modo Editar** (título: "Editar Especialidad")
   - Campos:
     - Código * (mayúsculas automáticas)
     - Nombre * (min 3 caracteres)
     - Tipo de Especialidad * (dropdown)
     - Descripción (opcional, textarea 3 líneas)
     - Requiere Certificación (switch)
     - Estado Activo (switch)
   - Botones: "Cancelar" (texto) y "Crear"/"Actualizar" (primario)

---

## 🔄 Flujo de Datos

### 1. Carga Inicial

```
Usuario accede a /tablas/especialidades
         ↓
EspecialidadesMedicasPage inicializa
         ↓
EspecialidadBloc.add(LoadAllRequested)
         ↓
EspecialidadDataSource.getAll() → Supabase
         ↓
Especialidades ordenadas por nombre
         ↓
EspecialidadLoaded(especialidades)
         ↓
EspecialidadTable renderiza datos
```

### 2. Búsqueda

```
Usuario escribe en barra de búsqueda
         ↓
EspecialidadBloc.add(SearchRequested(query))
         ↓
EspecialidadDataSource.search(query) → Supabase
         ↓
Búsqueda con OR: nombre/código/descripción (ilike)
         ↓
EspecialidadLoaded(resultados)
         ↓
Tabla actualizada con resultados filtrados
```

### 3. Filtro por Tipo

```
Usuario selecciona tipo en dropdown
         ↓
EspecialidadBloc.add(FilterByTipoRequested(tipo))
         ↓
EspecialidadDataSource.filterByTipo(tipo) → Supabase
         ↓
EspecialidadLoaded(especialidades_filtradas)
         ↓
Tabla muestra solo ese tipo
```

### 4. Crear Especialidad

```
Usuario click "Agregar Especialidad"
         ↓
showDialog(EspecialidadFormDialog())
         ↓
Usuario llena formulario y guarda
         ↓
EspecialidadBloc.add(CreateRequested(especialidad))
         ↓
EspecialidadCreating (loading overlay)
         ↓
EspecialidadDataSource.create() → Supabase INSERT
         ↓
Recarga lista completa
         ↓
EspecialidadLoaded(especialidades)
         ↓
Cierra dialogs y muestra SnackBar de éxito
```

### 5. Editar Especialidad

```
Usuario click icono Editar en tabla
         ↓
showDialog(EspecialidadFormDialog(especialidad))
         ↓
Formulario precargado con datos
         ↓
Usuario modifica y guarda
         ↓
EspecialidadBloc.add(UpdateRequested(especialidad))
         ↓
EspecialidadUpdating (loading overlay)
         ↓
EspecialidadDataSource.update() → Supabase UPDATE
         ↓
Recarga lista completa
         ↓
EspecialidadLoaded(especialidades)
         ↓
Cierra dialogs y muestra SnackBar de éxito
```

### 6. Eliminar Especialidad

```
Usuario click icono Eliminar en tabla
         ↓
showConfirmationDialog()
         ↓
Usuario confirma eliminación
         ↓
EspecialidadBloc.add(DeleteRequested(id))
         ↓
EspecialidadDeleting
         ↓
EspecialidadDataSource.delete(id) → Supabase DELETE
         ↓
Recarga lista completa
         ↓
EspecialidadLoaded(especialidades)
         ↓
SnackBar de éxito con tiempo de eliminación
```

---

## 🔌 API / DataSource

### Métodos Disponibles

#### `EspecialidadDataSource` (Supabase)

```dart
/// Obtiene todas las especialidades ordenadas por nombre
Future<List<EspecialidadModel>> getAll()

/// Obtiene una especialidad por ID
Future<EspecialidadModel?> getById(String id)

/// Crea una nueva especialidad
Future<void> create(EspecialidadModel especialidad)

/// Actualiza una especialidad existente
Future<void> update(EspecialidadModel especialidad)

/// Elimina una especialidad por ID
Future<void> delete(String id)

/// Busca especialidades por texto (nombre, código, descripción)
Future<List<EspecialidadModel>> search(String query)

/// Filtra especialidades por tipo
Future<List<EspecialidadModel>> filterByTipo(String tipo)

/// Obtiene solo especialidades activas
Future<List<EspecialidadModel>> getActivas()
```

---

## 🧪 Testing

### Casos de Prueba Recomendados

#### Unitarios
- [ ] Validación de campos requeridos en formulario
- [ ] Conversión Entity ↔ Model
- [ ] Estados del BLoC
- [ ] Filtrado por tipo
- [ ] Búsqueda con diferentes queries

#### Integración
- [ ] CRUD completo con Supabase
- [ ] Navegación entre estados
- [ ] Manejo de errores de red
- [ ] Validación de unicidad de código

#### E2E
- [ ] Flujo completo de creación
- [ ] Flujo completo de edición
- [ ] Flujo completo de eliminación
- [ ] Búsqueda y filtrado

---

## 📝 Migraciones SQL

### Script: `supabase/migrations/005_crear_tabla_especialidades.sql`

```sql
CREATE TABLE IF NOT EXISTS tespecialidades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo TEXT NOT NULL UNIQUE,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    requiere_certificacion BOOLEAN NOT NULL DEFAULT true,
    tipo_especialidad TEXT NOT NULL DEFAULT 'medica',
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_tipo_especialidad CHECK (
        tipo_especialidad IN ('medica', 'quirurgica', 'diagnostica', 'apoyo', 'enfermeria', 'tecnica')
    )
);
```

### Índices Creados

```sql
CREATE INDEX idx_tespecialidades_codigo ON tespecialidades(codigo);
CREATE INDEX idx_tespecialidades_nombre ON tespecialidades(nombre);
CREATE INDEX idx_tespecialidades_tipo ON tespecialidades(tipo_especialidad);
CREATE INDEX idx_tespecialidades_activo ON tespecialidades(activo);
```

### Row Level Security (RLS)

- ✅ RLS habilitado
- ✅ Políticas para usuarios autenticados:
  - SELECT (lectura)
  - INSERT (creación)
  - UPDATE (actualización)
  - DELETE (eliminación)

---

## 🔗 Relaciones

### Relaciones Actuales
- Ninguna (tabla maestra independiente)

### Relaciones Futuras (Pendientes)
- **1:N con `tfacultativos`**: Una especialidad puede tener múltiples facultativos
  - Se creará FK `especialidad_id` en `tfacultativos`
  - Reemplazará el campo TEXT actual por UUID
- **1:N con `personal`**: Personal puede tener especialidades
- **N:N con `certificaciones`**: Especialidades pueden requerir múltiples certificaciones

---

## ⚙️ Configuración Técnica

### Inyección de Dependencias

```dart
@injectable
class EspecialidadDataSource { }

@LazySingleton(as: EspecialidadRepository)
class EspecialidadRepositoryImpl implements EspecialidadRepository { }

@injectable
class EspecialidadBloc extends Bloc<EspecialidadEvent, EspecialidadState> { }
```

### Ruta Registrada

```dart
// lib/core/router/app_router.dart
GoRoute(
  path: '/tablas/especialidades',
  name: 'tablas_especialidades',
  builder: (context, state) => const EspecialidadesMedicasPage(),
),
```

---

## ✅ Checklist de Implementación

### Desarrollo
- [x] Entity creada en domain
- [x] Repository contract definido
- [x] Model con @JsonSerializable
- [x] DataSource con Supabase
- [x] Repository implementation
- [x] BLoC con eventos y estados
- [x] Página principal con SafeArea
- [x] Header con búsqueda y filtros
- [x] Tabla con acciones
- [x] Formulario crear/editar
- [x] Validaciones de campos
- [x] Manejo de errores

### Calidad
- [x] `flutter analyze` → 0 errores
- [x] Límites de líneas respetados (<350)
- [x] AppColors usado en toda la UI
- [x] Textos en español
- [x] SafeArea en página
- [x] Código limpio y comentado
- [x] debugPrint en lugar de print

### Integración
- [x] Ruta registrada en GoRouter
- [x] DI configurada con @injectable
- [x] Build runner ejecutado
- [x] Migración SQL creada
- [x] Seed data incluido
- [x] Documentación completa

---

## 🐛 Issues Conocidos

Ninguno.

---

## 🚀 Mejoras Futuras

1. **Export a CSV/Excel**: Exportar listado de especialidades
2. **Importación masiva**: Cargar especialidades desde archivo
3. **Historial de cambios**: Auditoría de modificaciones
4. **Filtros avanzados**: Múltiples filtros combinados
5. **Estadísticas**: Dashboard con métricas de uso
6. **Integración con Facultativos**: Migración del campo TEXT a FK

---

## 📚 Referencias

- **CLAUDE.md**: Reglas del proyecto
- **crud_plan.md**: Plan general de CRUDs
- **Supabase Docs**: https://supabase.com/docs
- **Flutter BLoC**: https://bloclibrary.dev

---

**Estado**: ✅ Completado
**Última actualización**: 2025-12-18
**Desarrollado por**: Claude Code Assistant
