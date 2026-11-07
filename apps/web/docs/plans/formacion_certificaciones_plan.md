# Plan de Implementación: Formación y Certificaciones

**Feature**: Gestión de formación, cursos y certificaciones del personal sanitario
**Módulo**: Personal
**Prioridad**: Alta
**Estado**: Planificación

---

## 📋 Descripción General

Sistema completo para gestionar la formación continua y certificaciones del personal sanitario, permitiendo:
- Control de certificaciones vigentes y vencidas
- Programación de cursos y formaciones
- Seguimiento de horas acumuladas de formación
- Alertas de renovación de certificaciones
- Historial de formaciones por empleado

## 🎯 Objetivos

1. **Catálogo de Certificaciones**: Gestionar las diferentes certificaciones sanitarias (SVA, ACLS, PHTLS, TES, SVB, DEA, etc.)
2. **Catálogo de Cursos**: Gestionar los cursos de formación disponibles
3. **Registros de Formación**: Asignar formaciones/certificaciones al personal con fechas de vigencia
4. **Dashboard Visual**: Vista de estado de formación del personal (Al día, Próxima, Vencida)
5. **Alertas**: Sistema de notificaciones para certificaciones próximas a vencer

## 📊 Entidades de Negocio

### 1. CertificacionEntity (Catálogo)
**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/formacion/entities/certificacion_entity.dart`

```dart
class CertificacionEntity {
  final String id;
  final String codigo;           // 'SVA', 'ACLS', 'PHTLS', 'TES', 'SVB', 'DEA'
  final String nombre;            // 'Soporte Vital Avanzado'
  final String descripcion;       // Descripción detallada
  final int vigenciaMeses;        // Vigencia en meses (12, 24, 36, etc.)
  final int horasRequeridas;      // Horas de formación requeridas
  final bool activa;              // Si está activa en el sistema
  final DateTime? fechaBaja;      // Fecha de baja (si aplica)
}
```

### 2. CursoEntity (Catálogo)
**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/formacion/entities/curso_entity.dart`

```dart
class CursoEntity {
  final String id;
  final String nombre;            // 'Curso TES Avanzado 2024'
  final String descripcion;       // Descripción del curso
  final String tipo;              // 'presencial', 'online', 'mixto'
  final int duracionHoras;        // Duración en horas
  final List<String> certificaciones; // IDs de certificaciones que otorga
  final bool activo;              // Si está activo
}
```

### 3. FormacionPersonalEntity (Registro)
**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/formacion/entities/formacion_personal_entity.dart`

```dart
class FormacionPersonalEntity {
  final String id;
  final String personalId;        // ID del empleado
  final String certificacionId;   // ID de la certificación (opcional si es curso)
  final String? cursoId;          // ID del curso (opcional si es solo certificación)
  final DateTime fechaInicio;     // Fecha de inicio de la formación
  final DateTime fechaFin;        // Fecha de finalización
  final DateTime fechaExpiracion; // Fecha de vencimiento de la certificación
  final int horasAcumuladas;      // Horas acumuladas
  final String estado;            // 'vigente', 'proxima_vencer', 'vencida'
  final String? observaciones;    // Observaciones
  final String? certificadoUrl;   // URL del certificado digital (Storage)
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

## 🗄️ Tablas en Supabase

### 1. certificaciones (Catálogo)
```sql
CREATE TABLE certificaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo TEXT NOT NULL UNIQUE,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  vigencia_meses INTEGER NOT NULL DEFAULT 12,
  horas_requeridas INTEGER NOT NULL DEFAULT 0,
  activa BOOLEAN NOT NULL DEFAULT true,
  fecha_baja TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_certificaciones_codigo ON certificaciones(codigo);
CREATE INDEX idx_certificaciones_activa ON certificaciones(activa);

-- RLS
ALTER TABLE certificaciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura a todos los usuarios autenticados"
  ON certificaciones FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Permitir modificacion solo a administradores y jefes de personal"
  ON certificaciones FOR ALL
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol IN ('admin', 'jefe_personal')
    )
  );
```

### 2. cursos (Catálogo)
```sql
CREATE TABLE cursos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  tipo TEXT NOT NULL CHECK (tipo IN ('presencial', 'online', 'mixto')),
  duracion_horas INTEGER NOT NULL DEFAULT 0,
  certificaciones TEXT[] DEFAULT '{}', -- Array de IDs de certificaciones
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_cursos_tipo ON cursos(tipo);
CREATE INDEX idx_cursos_activo ON cursos(activo);

-- RLS
ALTER TABLE cursos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura a todos los usuarios autenticados"
  ON cursos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Permitir modificacion solo a administradores y jefes de personal"
  ON cursos FOR ALL
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol IN ('admin', 'jefe_personal')
    )
  );
```

### 3. formacion_personal (Registros)
```sql
CREATE TABLE formacion_personal (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  personal_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  certificacion_id UUID REFERENCES certificaciones(id) ON DELETE SET NULL,
  curso_id UUID REFERENCES cursos(id) ON DELETE SET NULL,
  fecha_inicio TIMESTAMPTZ NOT NULL,
  fecha_fin TIMESTAMPTZ NOT NULL,
  fecha_expiracion TIMESTAMPTZ NOT NULL,
  horas_acumuladas INTEGER NOT NULL DEFAULT 0,
  estado TEXT NOT NULL CHECK (estado IN ('vigente', 'proxima_vencer', 'vencida')),
  observaciones TEXT,
  certificado_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT certificacion_or_curso_required CHECK (
    (certificacion_id IS NOT NULL) OR (curso_id IS NOT NULL)
  )
);

-- Índices
CREATE INDEX idx_formacion_personal_id ON formacion_personal(personal_id);
CREATE INDEX idx_formacion_certificacion ON formacion_personal(certificacion_id);
CREATE INDEX idx_formacion_curso ON formacion_personal(curso_id);
CREATE INDEX idx_formacion_estado ON formacion_personal(estado);
CREATE INDEX idx_formacion_expiracion ON formacion_personal(fecha_expiracion);

-- RLS
ALTER TABLE formacion_personal ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura a todos los usuarios autenticados"
  ON formacion_personal FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Permitir modificacion solo a administradores y jefes de personal"
  ON formacion_personal FOR ALL
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol IN ('admin', 'jefe_personal')
    )
  );
```

## 🏗️ Estructura de Archivos

### Paquete ambutrack_core_datasource
```
packages/ambutrack_core_datasource/lib/src/datasources/formacion/
├── entities/
│   ├── certificacion_entity.dart
│   ├── curso_entity.dart
│   └── formacion_personal_entity.dart
├── models/
│   ├── certificacion_supabase_model.dart
│   ├── curso_supabase_model.dart
│   └── formacion_personal_supabase_model.dart
├── implementations/
│   └── supabase_formacion_datasource.dart
├── certificacion_datasource_contract.dart
├── curso_datasource_contract.dart
├── formacion_personal_datasource_contract.dart
├── formacion_datasource_factory.dart
└── formacion_datasources.dart  # Barrel file
```

### App Web
```
lib/features/personal/formacion/
├── data/
│   └── repositories/
│       ├── certificacion_repository_impl.dart
│       ├── curso_repository_impl.dart
│       └── formacion_personal_repository_impl.dart
├── domain/
│   └── repositories/
│       ├── certificacion_repository.dart
│       ├── curso_repository.dart
│       └── formacion_personal_repository.dart
├── presentation/
│   ├── bloc/
│   │   ├── formacion_bloc.dart
│   │   ├── formacion_event.dart
│   │   └── formacion_state.dart
│   ├── pages/
│   │   ├── formacion_page.dart (actualizar existente)
│   │   ├── certificaciones_catalogo_page.dart
│   │   └── cursos_catalogo_page.dart
│   └── widgets/
│       ├── formacion_stats_widget.dart
│       └── formacion_filtro_widget.dart
└── formacion_feature.dart  # Barrel file
```

## 🎨 UI Components

### Página Principal (FormacionPage)
- **Header** con gradiente (AppColors.secondary → AppColors.formacion)
- **Tarjetas de estadísticas**: Total, Al Día, Próximas, Vencidas
- **Filtros**: Búsqueda por nombre/cargo, filtro por estado
- **Tabla AppDataGridV5** con:
  - Nombre del empleado
  - Cargo
  - Certificaciones (badges)
  - Última formación
  - Próxima formación
  - Horas acumuladas
  - Estado (badge con color)
  - Acciones (ver detalles, programar formación)

### Catálogo de Certificaciones
- CRUD completo de certificaciones
- Lista de todas las certificaciones del sistema
- Edición de vigencia y horas requeridas

### Catálogo de Cursos
- CRUD completo de cursos
- Tipos: Presencial, Online, Mixto
- Asociación con certificaciones

## 🔄 Flujo de Trabajo

### 1. Crear Datasource (AmbuTrackDatasourceAgent)
- Crear entities en `ambutrack_core_datasource`
- Crear models con @JsonSerializable
- Crear contracts
- Crear factory pattern
- Ejecutar `build_runner`

### 2. Crear Tablas Supabase (SupabaseSpecialist)
- Crear las 3 tablas con el SQL especificado
- Configurar RLS policies
- Verificar creación

### 3. Crear Repositorios (AmbuTrackFeatureBuilderAgent)
- Interfaces en domain
- Implementaciones en data (pass-through)
- Registrar en DI

### 4. Crear BLoC (AmbuTrackFeatureBuilderAgent)
- Estados con Freezed (Initial, Loading, Loaded, Error)
- Eventos con Freezed
- Lógica de negocio con permisos por rol

### 5. Actualizar UI (AmbuTrackUIDesignerAgent)
- Refactorizar [formacion_page.dart](lib/features/personal/formacion_page.dart) existente
- Conectar con BLoC
- Usar AppDataGridV5
- Implementar diálogos CRUD

## ✅ Criterios de Aceptación

- [x] Datasource creado en `ambutrack_core_datasource` con todas las entidades
- [x] Tablas creadas en Supabase con RLS configurado
- [x] Repository pass-through implementado
- [x] BLoC con estados y eventos
- [x] Página principal conectada a BLoC con datos reales
- [x] CRUD funcional para certificaciones (diálogo creado)
- [x] CRUD funcional para cursos (diálogo creado)
- [x] CRUD funcional para registros de formación (diálogo + integración UI)
- [x] Estadísticas calculadas correctamente
- [x] Filtros funcionales (búsqueda, estado)
- [x] Estados de certificación calculados:
  - **Vigente**: fecha_expiracion > hoy + 30 días
  - **Próxima a vencer**: hoy + 30 días >= fecha_expiracion > hoy
  - **Vencida**: fecha_expiracion <= hoy
- [x] `flutter analyze` → 0 warnings (código nuevo)
- [x] SafeArea en todas las páginas
- [x] AppColors para todos los colores
- [x] Diálogos profesionales para acciones CRUD (formación, certificaciones, cursos)
- [x] Rutas agregadas al router para catálogos (certificaciones, cursos)
- [x] Nombres de empleados mostrados en lugar de IDs
- [x] Diálogo de detalles para ver información completa de formación

## 📅 Tareas Estimadas

| Tarea | Agente | Prioridad |
|-------|--------|-----------|
| Crear datasource | 🟣 Datasource | Alta |
| Crear tablas Supabase | 🗄️ Supabase | Alta |
| Crear repositories | 🟠 FeatureBuilder | Alta |
| Crear BLoC | 🟠 FeatureBuilder | Alta |
| Actualizar UI | 🔵 UIDesigner | Alta |
| Validar | 🔴 QA | Media |

---

**Plan creado**: 2025-02-15
**Última actualización**: 2025-02-15
