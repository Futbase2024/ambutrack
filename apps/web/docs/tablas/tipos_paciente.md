# Tipos de Paciente

## 📋 Descripción

Módulo para la gestión de **Tipos de Paciente** en AmbuTrack. Permite clasificar los diferentes tipos de pacientes según sus necesidades específicas y características médicas.

## 🎯 Funcionalidades

### CRUD Completo
- ✅ **Crear** nuevo tipo de paciente
- ✅ **Leer** listado de tipos con búsqueda y ordenamiento
- ✅ **Actualizar** tipos existentes
- ✅ **Eliminar** tipos (con confirmación)

### Características
- 🔍 Búsqueda en tiempo real por nombre y descripción
- 📊 Ordenamiento por columnas (nombre, descripción, estado)
- 🎨 Diseño moderno con `ModernDataTable`
- ⚡ Indicador de carga durante eliminación
- 🔔 Notificaciones de éxito/error con SnackBar
- 📱 Responsive y optimizado para web

## 🗂️ Estructura del Módulo

```
lib/features/tablas/tipos_paciente/
├── domain/
│   ├── entities/
│   │   └── tipo_paciente_entity.dart          # Entidad de dominio
│   └── repositories/
│       └── tipo_paciente_repository.dart       # Contrato del repositorio
├── data/
│   ├── models/
│   │   ├── tipo_paciente_model.dart            # Modelo con JSON serialization
│   │   └── tipo_paciente_model.g.dart          # Código generado
│   ├── datasources/
│   │   └── tipo_paciente_datasource.dart       # DataSource con Supabase
│   └── repositories/
│       └── tipo_paciente_repository_impl.dart  # Implementación del repositorio
└── presentation/
    ├── bloc/
    │   ├── tipo_paciente_event.dart            # Eventos del BLoC
    │   ├── tipo_paciente_state.dart            # Estados del BLoC
    │   └── tipo_paciente_bloc.dart             # Lógica de negocio
    ├── pages/
    │   └── tipos_paciente_page.dart            # Página principal
    └── widgets/
        ├── tipo_paciente_header.dart           # Header con botón "Agregar"
        ├── tipo_paciente_table.dart            # Tabla con datos
        └── tipo_paciente_form_dialog.dart      # Formulario crear/editar
```

## 🗄️ Modelo de Datos

### Entidad: `TipoPacienteEntity`

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | `String?` | No | Identificador único (UUID) |
| `nombre` | `String` | ✅ Sí | Nombre del tipo (mín. 3 caracteres) |
| `descripcion` | `String?` | No | Descripción detallada |
| `activo` | `bool` | ✅ Sí | Estado activo/inactivo |
| `createdAt` | `DateTime?` | No | Fecha de creación |
| `updatedAt` | `DateTime?` | No | Fecha de última actualización |

### Tabla Supabase: `ttipos_paciente`

```sql
CREATE TABLE ttipos_paciente (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL UNIQUE,
  descripcion TEXT,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🔌 Integración con Supabase

### DataSource
- **Tabla**: `ttipos_paciente`
- **Operaciones**: `select()`, `insert()`, `update()`, `delete()`
- **Ordenamiento**: Por nombre ascendente
- **Mapeo**: snake_case (Supabase) ↔ camelCase (Dart)

### Configuración JSON Serialization
```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class TipoPacienteModel extends TipoPacienteEntity {
  // Mapeo automático: createdAt → created_at
}
```

## 🧩 Componentes de UI

### 1. TiposPacientePage
- Página principal con layout SafeArea
- Provee `TipoPacienteBloc` con `BlocProvider`
- Dispara evento `TipoPacienteLoadRequested` al cargar

### 2. TipoPacienteHeader
- Título "Tipos de Paciente"
- Botón "Agregar Tipo de Paciente"
- Abre `TipoPacienteFormDialog` al hacer clic

### 3. TipoPacienteTable
- **BlocListener** + **BlocBuilder** para estados reactivos
- **SearchField** con búsqueda en tiempo real
- **ModernDataTable** con columnas:
  - Nombre (sortable)
  - Descripción (sortable)
  - Estado (sortable)
- Acciones por fila:
  - 👁️ Ver (futuro)
  - ✏️ Editar
  - 🗑️ Eliminar (con confirmación)

### 4. TipoPacienteFormDialog
- Formulario modal para crear/editar
- Validaciones:
  - Nombre: requerido, mín. 3 caracteres
  - Descripción: opcional, si se proporciona mín. 5 caracteres
- Switch para estado Activo/Inactivo
- Botones: Cancelar / Guardar

## 📊 Gestión de Estado (BLoC)

### Eventos
```dart
TipoPacienteLoadRequested()         // Cargar todos
TipoPacienteCreateRequested(entity) // Crear nuevo
TipoPacienteUpdateRequested(entity) // Actualizar
TipoPacienteDeleteRequested(id)     // Eliminar
```

### Estados
```dart
TipoPacienteInitial()               // Estado inicial
TipoPacienteLoading()               // Cargando datos
TipoPacienteLoaded(list)            // Datos cargados
TipoPacienteError(message)          // Error
```

## 🎨 Diseño y Estilos

### Colores
- Primario: `AppColors.primary` (#1E40AF - Azul médico)
- Éxito: `AppColors.success` (Verde)
- Error: `AppColors.error` (Rojo)
- Texto: `AppColors.textPrimaryLight` / `AppColors.textSecondaryLight`

### Tipografía
- Fuente: **Google Fonts Inter**
- Tamaños: 14px (cuerpo), 18px (subtítulos), 24px (títulos)

### Componentes Reutilizables
- `AppButton` (botones estandarizados)
- `AppDialog` (diálogos modales)
- `ModernDataTable` (tablas de datos)
- `AppLoadingIndicator` (indicadores de carga)
- `AppLoadingOverlay` (overlay de carga)

## 🔒 Validaciones

### Formulario
- **Nombre**:
  - ✅ Requerido
  - ✅ Mínimo 3 caracteres
- **Descripción**:
  - ⏳ Opcional
  - ✅ Si se proporciona, mínimo 5 caracteres
- **Estado**:
  - ✅ Booleano (Activo/Inactivo)

## 🚀 Rutas

### Ruta Principal
```dart
GoRoute(
  path: '/tablas/tipos-paciente',
  name: 'tablas_tipos_paciente',
  builder: (context, state) => const TiposPacientePage(),
)
```

## 💾 Datos Iniciales (Seed Data)

El sistema incluye 15 tipos de paciente predefinidos:

1. Paciente Geriátrico
2. Paciente Pediátrico
3. Paciente Crítico
4. Paciente Estable
5. Paciente Psiquiátrico
6. Paciente con Movilidad Reducida
7. Paciente Oncológico
8. Paciente Dializado
9. Paciente Traumatológico
10. Paciente Respiratorio
11. Paciente Cardiológico
12. Paciente Infeccioso
13. Paciente Obstétrico
14. Paciente Neonatal
15. Paciente con Obesidad Mórbida

## 🔗 Relaciones

### Salientes (1:N)
- `servicios.tipo_paciente_id` → `ttipos_paciente.id`
  - Un tipo de paciente puede estar asociado a múltiples servicios

## ✅ Checklist de Implementación

- [x] Entidad de dominio
- [x] Repositorio (contrato)
- [x] Modelo con JSON serialization
- [x] DataSource con Supabase
- [x] Implementación del repositorio
- [x] BLoC (eventos, estados, bloc)
- [x] Página principal
- [x] Header con botón agregar
- [x] Tabla con búsqueda y ordenamiento
- [x] Formulario crear/editar
- [x] Migración SQL (`014_crear_tabla_tipos_paciente.sql`)
- [x] Ruta registrada en GoRouter
- [x] Documentación completa

## 📝 Notas Técnicas

- **Clean Architecture**: Separación estricta domain/data/presentation
- **Inyección de Dependencias**: Injectable + GetIt
- **Inmutabilidad**: Equatable en entidades y estados
- **Row Level Security**: Habilitado en Supabase
- **Triggers**: Actualización automática de `updated_at`
- **Índices**: En `nombre` y `activo` para optimización

---

**Fecha de Creación**: 2025-12-18
**Última Actualización**: 2025-12-18
**Versión**: 1.0
**Estado**: ✅ Completado
