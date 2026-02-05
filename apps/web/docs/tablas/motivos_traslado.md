# Motivos de Traslado

## Descripción

Módulo CRUD completo para la gestión de **Motivos de Traslado** en AmbuTrack. Permite administrar los diferentes motivos por los cuales se realiza un traslado de pacientes (consulta médica, urgencia, diálisis, radioterapia, etc.).

## Ubicación

```
lib/features/tablas/motivos_traslado/
├── domain/
│   ├── entities/
│   │   └── motivo_traslado_entity.dart
│   └── repositories/
│       └── motivo_traslado_repository.dart
├── data/
│   ├── models/
│   │   ├── motivo_traslado_model.dart
│   │   └── motivo_traslado_model.g.dart (generado)
│   ├── datasources/
│   │   └── motivo_traslado_datasource.dart
│   └── repositories/
│       └── motivo_traslado_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── motivo_traslado_event.dart
    │   ├── motivo_traslado_state.dart
    │   └── motivo_traslado_bloc.dart
    ├── pages/
    │   └── motivos_traslado_page.dart
    └── widgets/
        ├── motivo_traslado_header.dart
        ├── motivo_traslado_table.dart
        └── motivo_traslado_form_dialog.dart
```

## Características

### ✅ Funcionalidades Implementadas

- **CRUD Completo**:
  - ✅ Crear nuevo motivo de traslado
  - ✅ Listar todos los motivos
  - ✅ Editar motivo existente
  - ✅ Eliminar motivo
  - ✅ Búsqueda en tiempo real
  - ✅ Ordenamiento por columnas

- **Campos del Motivo**:
  - `nombre`: Nombre del motivo (ej: "Consulta médica")
  - `descripcion`: Descripción detallada del motivo
  - `activo`: Estado activo/inactivo
  - `createdAt`: Fecha de creación
  - `updatedAt`: Fecha de última actualización

- **UI/UX**:
  - ✅ Tabla moderna con `ModernDataTable`
  - ✅ Búsqueda instantánea por nombre/descripción
  - ✅ Diálogo de confirmación para eliminar
  - ✅ Formulario validado para crear/editar
  - ✅ Indicadores de estado (Activo/Inactivo)
  - ✅ Feedback visual (SnackBars)

- **Arquitectura**:
  - ✅ Clean Architecture
  - ✅ BLoC pattern para gestión de estado
  - ✅ Inyección de dependencias con GetIt/Injectable
  - ✅ Supabase como backend
  - ✅ Serialización JSON con json_serializable

## Estructura de Datos

### Entity (Domain)

```dart
class MotivoTrasladoEntity extends Equatable {
  final String? id;
  final String nombre;
  final String descripcion;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### Model (Data)

```dart
@JsonSerializable()
class MotivoTrasladoModel {
  final String? id;
  final String nombre;
  final String descripcion;
  final bool activo;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
}
```

## Backend (Supabase)

### Tabla: `tmotivos_traslado`

```sql
-- Crear tabla tmotivos_traslado
CREATE TABLE IF NOT EXISTS public.tmotivos_traslado (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Crear índices para mejorar performance
CREATE INDEX IF NOT EXISTS idx_tmotivos_traslado_nombre ON public.tmotivos_traslado(nombre);
CREATE INDEX IF NOT EXISTS idx_tmotivos_traslado_activo ON public.tmotivos_traslado(activo);

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.tmotivos_traslado ENABLE ROW LEVEL SECURITY;

-- Política de lectura (todos los usuarios autenticados pueden leer)
CREATE POLICY "Permitir lectura a usuarios autenticados"
  ON public.tmotivos_traslado FOR SELECT
  USING (auth.role() = 'authenticated');

-- Política de inserción (usuarios autenticados pueden crear)
CREATE POLICY "Permitir inserción a usuarios autorizados"
  ON public.tmotivos_traslado FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Política de actualización (usuarios autenticados pueden actualizar)
CREATE POLICY "Permitir actualización a usuarios autorizados"
  ON public.tmotivos_traslado FOR UPDATE
  USING (auth.role() = 'authenticated');

-- Política de eliminación (usuarios autenticados pueden eliminar)
CREATE POLICY "Permitir eliminación a usuarios autorizados"
  ON public.tmotivos_traslado FOR DELETE
  USING (auth.role() = 'authenticated');

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_tmotivos_traslado_updated_at
  BEFORE UPDATE ON public.tmotivos_traslado
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insertar datos de ejemplo
INSERT INTO public.tmotivos_traslado (nombre, descripcion, activo) VALUES
  ('CONSULTA MÉDICA', 'Traslado para consulta médica de rutina', true),
  ('URGENCIA', 'Traslado de emergencia médica', true),
  ('DIÁLISIS', 'Traslado para sesión de diálisis', true),
  ('RADIOTERAPIA', 'Traslado para tratamiento de radioterapia', true),
  ('QUIMIOTERAPIA', 'Traslado para sesión de quimioterapia', true),
  ('REHABILITACIÓN', 'Traslado para sesión de rehabilitación física', true),
  ('PRUEBAS DIAGNÓSTICAS', 'Traslado para realización de pruebas diagnósticas', true),
  ('ALTA HOSPITALARIA', 'Traslado de regreso a domicilio tras alta médica', true),
  ('TRASLADO ENTRE CENTROS', 'Traslado entre diferentes centros hospitalarios', true),
  ('REVISIÓN MÉDICA', 'Traslado para revisión médica programada', true)
ON CONFLICT DO NOTHING;
```

## Navegación

- **Ruta**: `/tablas/motivos-traslado`
- **Nombre**: `tablas_motivos_traslado`
- **Acceso**: Desde el menú lateral → Tablas → Motivos de Traslado

## BLoC Pattern

### Eventos

```dart
MotivoTrasladoLoadAllRequested()      // Cargar todos
MotivoTrasladoCreateRequested(motivo) // Crear
MotivoTrasladoUpdateRequested(motivo) // Actualizar
MotivoTrasladoDeleteRequested(id)     // Eliminar
MotivoTrasladoSubscribeRequested()    // Real-time
MotivoTrasladoStreamUpdated(motivos)  // Stream update
```

### Estados

```dart
MotivoTrasladoInitial                // Estado inicial
MotivoTrasladoLoading                // Cargando
MotivoTrasladoLoaded(motivos)        // Datos cargados
MotivoTrasladoError(message)         // Error
MotivoTrasladoOperationInProgress    // Operación en curso
MotivoTrasladoOperationSuccess       // Operación exitosa
```

## Ejemplos de Uso

### Crear Motivo

```dart
final motivo = MotivoTrasladoEntity(
  id: Uuid().v4(),
  nombre: 'Consulta médica',
  descripcion: 'Traslado para consulta médica de rutina',
  activo: true,
);

context.read<MotivoTrasladoBloc>().add(
  MotivoTrasladoCreateRequested(motivo),
);
```

### Editar Motivo

```dart
final motivoEditado = motivo.copyWith(
  descripcion: 'Nueva descripción',
  updatedAt: DateTime.now(),
);

context.read<MotivoTrasladoBloc>().add(
  MotivoTrasladoUpdateRequested(motivoEditado),
);
```

### Eliminar Motivo

```dart
context.read<MotivoTrasladoBloc>().add(
  MotivoTrasladoDeleteRequested(motivoId),
);
```

## Validaciones

### Formulario

- ✅ **Nombre**: Requerido, mínimo 3 caracteres
- ✅ **Descripción**: Requerida, mínimo 5 caracteres
- ✅ **Estado**: Activo/Inactivo (switch)

### DataSource

- ✅ Validación de ID al actualizar/eliminar
- ✅ Manejo de errores con try-catch
- ✅ Logs con debugPrint para debugging

## Testing

### Datos de Prueba

```dart
final motivosPrueba = [
  MotivoTrasladoEntity(
    nombre: 'Consulta médica',
    descripcion: 'Traslado para consulta médica de rutina',
    activo: true,
  ),
  MotivoTrasladoEntity(
    nombre: 'Urgencia',
    descripcion: 'Traslado de emergencia',
    activo: true,
  ),
  MotivoTrasladoEntity(
    nombre: 'Diálisis',
    descripcion: 'Traslado para sesión de diálisis',
    activo: true,
  ),
  MotivoTrasladoEntity(
    nombre: 'Radioterapia',
    descripcion: 'Traslado para tratamiento de radioterapia',
    activo: true,
  ),
];
```

## Consideraciones Técnicas

### Performance

- ✅ Búsqueda optimizada con filtrado local
- ✅ Ordenamiento eficiente con `..sort()`
- ✅ Estado reutilizable del BLoC (no recarga innecesaria)
- ✅ Logs detallados para debugging

### Arquitectura

- ✅ Clean Architecture respetada
- ✅ Separación de responsabilidades (SRP)
- ✅ Inyección de dependencias correcta
- ✅ Sin dependencias circulares

### Código Limpio

- ✅ 0 warnings de flutter analyze
- ✅ Uso correcto de AppColors
- ✅ Uso correcto de AppSizes
- ✅ Widgets privados con prefijo `_`
- ✅ Comentarios en métodos públicos

## Mejoras Futuras

### Corto Plazo

- [ ] Paginación en tabla (si hay muchos registros)
- [ ] Exportar a CSV/Excel
- [ ] Filtros avanzados (por estado)
- [ ] Ordenamiento múltiple

### Largo Plazo

- [ ] Historial de cambios
- [ ] Auditoría de modificaciones
- [ ] Importación masiva desde CSV
- [ ] API REST para integración externa

## Relacionado

- [Centros Hospitalarios](./centros_hospitalarios.md)
- [Tipos de Traslado](./tipos_traslado.md)
- [Localidades](./localidades.md)
- [Provincias](./provincias.md)

---

**Fecha de creación**: 2025-12-17
**Última actualización**: 2025-12-17
**Estado**: ✅ Implementado y funcional
