# Tipos de Traslado

## 📋 Descripción

Módulo para la gestión de **Tipos de Traslado** en AmbuTrack. Permite clasificar los diferentes tipos de servicios de ambulancia según su naturaleza (urgente, programado, inter-hospitalario, etc.).

## 🎯 Funcionalidades

### CRUD Completo
- ✅ **Crear** nuevo tipo de traslado
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
lib/features/tablas/tipos_traslado/
├── domain/
│   ├── entities/
│   │   └── tipo_traslado_entity.dart          # Entidad de dominio
│   └── repositories/
│       └── tipo_traslado_repository.dart       # Contrato del repositorio
├── data/
│   ├── models/
│   │   ├── tipo_traslado_model.dart            # Modelo con JSON serialization
│   │   └── tipo_traslado_model.g.dart          # Código generado
│   ├── datasources/
│   │   └── tipo_traslado_datasource.dart       # DataSource con Supabase
│   └── repositories/
│       └── tipo_traslado_repository_impl.dart  # Implementación del repositorio
└── presentation/
    ├── bloc/
    │   ├── tipo_traslado_event.dart            # Eventos del BLoC
    │   ├── tipo_traslado_state.dart            # Estados del BLoC
    │   └── tipo_traslado_bloc.dart             # Lógica de negocio
    ├── pages/
    │   └── tipos_traslado_page.dart            # Página principal
    └── widgets/
        ├── tipo_traslado_header.dart           # Header con botón "Agregar"
        ├── tipo_traslado_table.dart            # Tabla con datos
        └── tipo_traslado_form_dialog.dart      # Formulario crear/editar
```

## 🗄️ Modelo de Datos

### Entidad: `TipoTrasladoEntity`

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | `String?` | No | Identificador único (UUID) |
| `nombre` | `String` | ✅ Sí | Nombre del tipo (mín. 3 caracteres) |
| `descripcion` | `String?` | No | Descripción detallada |
| `activo` | `bool` | ✅ Sí | Estado activo/inactivo |
| `createdAt` | `DateTime?` | No | Fecha de creación |
| `updatedAt` | `DateTime?` | No | Fecha de última actualización |

### Tabla Supabase: `ttipos_traslado`

```sql
CREATE TABLE ttipos_traslado (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## 🔌 Integración con Supabase

### DataSource
- **Tabla**: `ttipos_traslado`
- **Operaciones**: `select()`, `insert()`, `update()`, `delete()`
- **Ordenamiento**: Por nombre ascendente
- **Mapeo**: snake_case (Supabase) ↔ camelCase (Dart)

### Configuración JSON Serialization
```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class TipoTrasladoModel extends TipoTrasladoEntity {
  // Mapeo automático: createdAt → created_at
}
```

## 🧩 Componentes de UI

### 1. TiposTrasladoPage
- Página principal con layout SafeArea
- Provee `TipoTrasladoBloc` con `BlocProvider`
- Dispara evento `TipoTrasladoLoadRequested` al cargar

### 2. TipoTrasladoHeader
- Título "Tipos de Traslado"
- Botón "Agregar Tipo" que abre el diálogo de creación

### 3. TipoTrasladoTable
- Tabla con 3 columnas: Nombre, Descripción, Estado
- Búsqueda en tiempo real
- Ordenamiento por columnas
- Acciones: Editar y Eliminar
- Estados: Loading, Error, Loaded
- **SingleChildScrollView** para evitar overflow

### 4. TipoTrasladoFormDialog
- Modo crear/editar según parámetro `tipo`
- Validaciones:
  - Nombre obligatorio (mín. 3 caracteres)
  - Descripción opcional
- Switch para activar/desactivar
- Navegación por teclado con Tab/Enter

## 🔄 Flujo de Datos (BLoC)

### Eventos
- `TipoTrasladoLoadRequested` → Cargar todos los tipos
- `TipoTrasladoCreateRequested` → Crear nuevo tipo
- `TipoTrasladoUpdateRequested` → Actualizar tipo existente
- `TipoTrasladoDeleteRequested` → Eliminar tipo

### Estados
- `TipoTrasladoInitial` → Estado inicial
- `TipoTrasladoLoading` → Cargando datos
- `TipoTrasladoLoaded` → Datos cargados exitosamente
- `TipoTrasladoError` → Error al cargar/procesar

### Flujo de Eliminación
1. Usuario confirma eliminación (diálogo de confirmación)
2. Se muestra overlay de carga con `AppLoadingOverlay`
3. Se dispara `TipoTrasladoDeleteRequested`
4. BLoC procesa eliminación
5. `BlocListener` cierra overlay automáticamente
6. Se muestra SnackBar de éxito/error

## 🎨 Diseño

### Colores
- **Primario**: `AppColors.primary` (#1E40AF)
- **Éxito**: `AppColors.success` (verde)
- **Error**: `AppColors.error` (rojo)
- **Texto**: `AppColors.textPrimaryLight`, `AppColors.textSecondaryLight`

### Tipografía
- **Google Fonts**: Inter
- Tamaños: 24px (título), 18px (subtítulo), 14px (formulario), 13px (tabla)

## 🛣️ Navegación

### Ruta
- **Path**: `/tablas/tipos-traslado`
- **Name**: `tablas_tipos_traslado`
- **Widget**: `TiposTrasladoPage`

### Acceso desde Menú
- Menú lateral → **Tablas** → **Tipos de Traslado**

## ✅ Testing

### Unit Tests (Pendiente)
```dart
test('debe cargar tipos de traslado exitosamente', () async {
  // Arrange
  when(() => repository.getAll()).thenAnswer((_) async => mockTipos);

  // Act
  bloc.add(const TipoTrasladoLoadRequested());

  // Assert
  await expectLater(
    bloc.stream,
    emitsInOrder([
      const TipoTrasladoLoading(),
      TipoTrasladoLoaded(mockTipos),
    ]),
  );
});
```

## 📝 Ejemplos de Uso

### Datos de Ejemplo
```dart
// Tipos comunes de traslado
- Urgente
- Programado
- Inter-hospitalario
- Domicilio a Hospital
- Hospital a Domicilio
- Traslado a Centro Especializado
- Traslado a Rehabilitación
- Alta Voluntaria
```

## 🔧 Mantenimiento

### Regenerar Código
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Análisis de Código
```bash
flutter analyze
```

## 🚀 Próximas Mejoras

- [ ] Tests unitarios y de integración
- [ ] Paginación para grandes volúmenes de datos
- [ ] Exportar a CSV/Excel
- [ ] Filtros avanzados
- [ ] Historial de cambios (auditoría)
- [ ] Iconos personalizados por tipo

## 📚 Referencias

- [CLAUDE.md](../../CLAUDE.md) - Reglas del proyecto
- [crud_plan.md](crud_plan.md) - Plan de implementación de CRUDs
- [ModernDataTable](../../lib/core/widgets/tables/modern_data_table.dart) - Widget de tabla
- [AppDialog](../../lib/core/widgets/dialogs/app_dialog.dart) - Widget de diálogo

---

**Fecha de Creación**: 2025-12-18
**Última Actualización**: 2025-12-18
**Versión**: 1.0.0
