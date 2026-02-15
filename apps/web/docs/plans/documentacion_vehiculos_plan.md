# Plan de Implementación: Documentación de Vehículos (Seguros y Licencias)

**Feature**: Gestión de documentación legal de vehículos (seguros, licencias, ITV, permisos)
**Módulo**: Vehículos
**Prioridad**: Alta
**Estado**: Planificación

---

## 📋 Descripción General

Sistema completo para gestionar la documentación legal y administrativa de los vehículos de emergencia, permitiendo:
- Control de pólizas de seguro (vigencia, coberturas, renovaciones)
- Gestión de ITV (inspecciones técnicas periódicas)
- Control de licencias y permisos municipales
- Alertas de vencimiento de documentación
- Historial completo de documentación por vehículo
- Gestión de documentos digitales (Storage)

## 🎯 Objetivos

1. **Catálogo de Tipos de Documento**: Gestionar los diferentes tipos de documentación (Seguro Responsabilidad Civil, Seguro Todo Riesgo, ITV, Permiso Municipal, Tarjeta de Transporte, etc.)
2. **Registros de Documentación**: Asignar documentos a vehículos con fechas de vigencia
3. **Dashboard Visual**: Vista de estado de documentación de la flota (Al día, Próximas, Vencidas)
4. **Alertas**: Sistema de notificaciones para documentos próximos a vencer
5. **Historial**: Registro histórico de renovaciones y cambios

## 📊 Entidades de Negocio

### 1. TipoDocumentoEntity (Catálogo)
**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/documentacion_vehiculos/entities/tipo_documento_entity.dart`

```dart
class TipoDocumentoEntity {
  final String id;
  final String codigo;           // 'SEGURO_RC', 'ITV', 'PERMISO_MUNICIPAL', 'TARJETA_TRANSPORTE'
  final String nombre;            // 'Seguro Responsabilidad Civil'
  final String descripcion;       // Descripción detallada
  final String categoria;         // 'seguro', 'itv', 'permiso', 'licencia', 'otro'
  final int vigenciaMeses;        // Vigencia recomendada en meses (12, 6, 24, etc.)
  final bool obligatorio;         // Si es obligatorio para vehículos activos
  final bool activo;              // Si está activo en el sistema
  final DateTime? fechaBaja;      // Fecha de baja (si aplica)
}
```

### 2. DocumentacionVehiculoEntity (Registro)
**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/documentacion_vehiculos/entities/documentacion_vehiculo_entity.dart`

```dart
class DocumentacionVehiculoEntity {
  final String id;
  final String vehiculoId;        // ID del vehículo
  final String tipoDocumentoId;   // ID del tipo de documento
  final String numeroPoliza;       // Número de póliza/licencia
  final String compania;           // Compañía aseguradora o entidad emisora
  final DateTime fechaEmision;    // Fecha de emisión del documento
  final DateTime fechaVencimiento; // Fecha de vencimiento
  final DateTime? fechaProximoVencimiento; // Próximo vencimiento (para renovaciones)
  final String estado;            // 'vigente', 'proxima_vencer', 'vencida'
  final double? costeAnual;       // Coste anual del seguro/permiso
  final String? observaciones;     // Observaciones
  final String? documentoUrl;     // URL del documento digital (Storage)
  final String? documentoUrl2;    // URL del documento digital adicional (Storage)
  final bool requiereRenovacion;  // Si requiere renovación automática
  final int? diasAlerta;          // Días antes del vencimiento para alertar (por defecto 30)
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

## 🗄️ Tablas en Supabase

### 1. tipos_documento_vehiculo (Catálogo)
```sql
CREATE TABLE tipos_documento_vehiculo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo TEXT NOT NULL UNIQUE,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  categoria TEXT NOT NULL CHECK (categoria IN ('seguro', 'itv', 'permiso', 'licencia', 'otro')),
  vigencia_meses INTEGER NOT NULL DEFAULT 12,
  obligatorio BOOLEAN NOT NULL DEFAULT true,
  activo BOOLEAN NOT NULL DEFAULT true,
  fecha_baja TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_tipos_doc_vehiculo_codigo ON tipos_documento_vehiculo(codigo);
CREATE INDEX idx_tipos_doc_vehiculo_categoria ON tipos_documento_vehiculo(categoria);
CREATE INDEX idx_tipos_doc_vehiculo_activo ON tipos_documento_vehiculo(activo);

-- RLS
ALTER TABLE tipos_documento_vehiculo ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura a todos los usuarios autenticados"
  ON tipos_documento_vehiculo FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Permitir modificacion solo a administradores y gestores de flota"
  ON tipos_documento_vehiculo FOR ALL
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol IN ('admin', 'jefe_flota')
    )
  );
```

### 2. documentacion_vehiculos (Registros)
```sql
CREATE TABLE documentacion_vehiculos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vehiculo_id UUID NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
  tipo_documento_id UUID NOT NULL REFERENCES tipos_documento_vehiculo(id) ON DELETE RESTRICT,
  numero_poliza TEXT NOT NULL,
  compania TEXT NOT NULL,
  fecha_emision TIMESTAMPTZ NOT NULL,
  fecha_vencimiento TIMESTAMPTZ NOT NULL,
  fecha_proximo_vencimiento TIMESTAMPTZ,
  estado TEXT NOT NULL CHECK (estado IN ('vigente', 'proxima_vencer', 'vencida')) DEFAULT 'vigente',
  coste_anual NUMERIC(10, 2),
  observaciones TEXT,
  documento_url TEXT,
  documento_url_2 TEXT,
  requiere_renovacion BOOLEAN NOT NULL DEFAULT false,
  dias_alerta INTEGER NOT NULL DEFAULT 30,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT unica_doc_por_vehiculo_tipo UNIQUE (vehiculo_id, tipo_documento_id, fecha_vencimiento)
);

-- Índices
CREATE INDEX idx_doc_vehiculo_vehiculo ON documentacion_vehiculos(vehiculo_id);
CREATE INDEX idx_doc_vehiculo_tipo ON documentacion_vehiculos(tipo_documento_id);
CREATE INDEX idx_doc_vehiculo_estado ON documentacion_vehiculos(estado);
CREATE INDEX idx_doc_vehiculo_vencimiento ON documentacion_vehiculos(fecha_vencimiento);
CREATE INDEX idx_doc_vehiculo_compania ON documentacion_vehiculos(compania);

-- RLS
ALTER TABLE documentacion_vehiculos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura a todos los usuarios autenticados"
  ON documentacion_vehiculos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Permitir modificacion solo a administradores y gestores de flota"
  ON documentacion_vehiculos FOR ALL
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol IN ('admin', 'jefe_flota', 'gestor_flota')
    )
  );

-- Trigger para actualizar estado automáticamente
CREATE OR REPLACE FUNCTION actualizar_estado_doc_vehiculo()
RETURNS TRIGGER AS $$
BEGIN
  -- Actualizar estado basado en fecha_vencimiento
  IF NEW.fecha_vencimiento <= NOW() THEN
    NEW.estado := 'vencida';
  ELSEIF NEW.fecha_vencimiento <= NOW() + (COALESCE(NEW.dias_alerta, 30) || ' days')::INTERVAL THEN
    NEW.estado := 'proxima_vencer';
  ELSE
    NEW.estado := 'vigente';
  END IF;

  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_estado_doc_vehiculo
  BEFORE INSERT OR UPDATE ON documentacion_vehiculos
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_estado_doc_vehiculo();

-- Función para alertas de vencimiento
CREATE OR REPLACE FUNCTION docs_vehiculos_proximos_vencer()
RETURNS TABLE (
  vehiculo_id UUID,
  vehiculo_matricula TEXT,
  tipo_documento TEXT,
  fecha_vencimiento TIMESTAMPTZ,
  dias_restantes INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    dv.vehiculo_id,
    v.matricula,
    td.nombre as tipo_documento,
    dv.fecha_vencimiento,
    EXTRACT(DAY FROM (dv.fecha_vencimiento - NOW()))::INTEGER as dias_restantes
  FROM documentacion_vehiculos dv
  JOIN vehiculos v ON v.id = dv.vehiculo_id
  JOIN tipos_documento_vehiculo td ON td.id = dv.tipo_documento_id
  WHERE dv.estado IN ('proxima_vencer', 'vencida')
    AND v.estado = 'activo'
  ORDER BY dv.fecha_vencimiento ASC;
END;
$$ LANGUAGE plpgsql;
```

## 🏗️ Estructura de Archivos

### Paquete ambutrack_core_datasource
```
packages/ambutrack_core_datasource/lib/src/datasources/documentacion_vehiculos/
├── entities/
│   ├── tipo_documento_entity.dart
│   └── documentacion_vehiculo_entity.dart
├── models/
│   ├── tipo_documento_supabase_model.dart
│   └── documentacion_vehiculo_supabase_model.dart
├── implementations/
│   └── supabase_documentacion_vehiculos_datasource.dart
├── tipo_documento_datasource_contract.dart
├── documentacion_vehiculo_datasource_contract.dart
├── documentacion_vehiculos_datasource_factory.dart
└── documentacion_vehiculos_datasources.dart  # Barrel file
```

### App Web
```
lib/features/vehiculos/documentacion/
├── data/
│   └── repositories/
│       ├── tipo_documento_repository_impl.dart
│       └── documentacion_vehiculo_repository_impl.dart
├── domain/
│   └── repositories/
│       ├── tipo_documento_repository.dart
│       └── documentacion_vehiculo_repository.dart
├── presentation/
│   ├── bloc/
│   │   ├── documentacion_vehiculos_bloc.dart
│   │   ├── documentacion_vehiculos_event.dart
│   │   └── documentacion_vehiculos_state.dart
│   ├── pages/
│   │   └── documentacion_page.dart (actualizar existente)
│   └── widgets/
│       ├── documentacion_stats_header.dart
│       ├── documentacion_filters.dart
│       ├── documentacion_table.dart
│       ├── documentacion_form_dialog.dart
│       ├── documentacion_estado_badge.dart
│       ├── tipo_documento_form_dialog.dart
│       └── documentos_vencidos_alert.dart
└── documentacion_feature.dart  # Barrel file
```

## 🎨 UI Components

### Página Principal (DocumentacionPage)

#### Header
- Gradiente: `AppColors.error → AppColors.turnoNaranja` (ya existe en el placeholder)
- Estadísticas: Total documentos, Vigentes, Próximos, Vencidos
- Botón "Agregar Documento" con icono `Icons.description`

#### Filtros
- Búsqueda por matrícula
- Filtro por tipo de documento (dropdown)
- Filtro por estado (chips: Todos, Vigentes, Próximos, Vencidos)
- Filtro por vencimiento (rango de fechas)

#### Tabla AppDataGridV5
Columnas:
- **Matrícula**: Clickable → navega a detalle del vehículo
- **Tipo de documento**: Badge con color según categoría
  - Seguros: `AppColors.error`
  - ITV: `AppColors.warning`
  - Permisos: `AppColors.info`
  - Otros: `AppColors.secondaryLight`
- **Número de póliza/licencia**
- **Compañía/Emisor**
- **Fecha emisión**
- **Fecha vencimiento** (resaltada si está próxima)
- **Estado**: Badge (Vigente/Próxima/Vencida)
- **Días restantes**: Número con color
- **Acciones**:
  - Ver documento (icono ojo)
  - Descargar PDF (icono download)
  - Editar (icono lápiz)
  - Renovar (icono refresh)

### Badges de Estado

| Estado | Color | Icono |
|--------|-------|-------|
| Vigente | `AppColors.success` | `Icons.check_circle` |
| Próxima a vencer | `AppColors.warning` | `Icons.warning` |
| Vencida | `AppColors.error` | `Icons.error` |

### Componentes Adicionales

#### DocumentacionStatsHeader
4 tarjetas con estadísticas:
- 📄 Total documentos
- ✅ Al día
- ⚠️ Próximos a vencer
- ❌ Vencidos

#### DocumentosVencidosAlert
Banner de alerta visible cuando hay documentos vencidos o próximos a vencer:
```dart
if (vencidos > 0 || proximosVencer > 0) {
  Banner(
    backgroundColor: AppColors.error,
    message: 'Tienes $vencidos documentos vencidos y $proximosVencer próximos a vencer',
    actions: [
      Button('Ver todos', onPressed: () => _mostrarSoloVencidos()),
    ],
  );
}
```

#### DocumentacionFormDialog
Diálogo para crear/editar documentación:
- **Campos obligatorios**:
  - Vehículo (AppSearchableDropdown si >10 vehículos)
  - Tipo de documento (AppDropdown)
  - Número de póliza/licencia (TextField)
  - Compañía/Emisor (TextField)
  - Fecha emisión (DatePicker)
  - Fecha vencimiento (DatePicker)
- **Campos opcionales**:
  - Coste anual (TextField numérico)
  - Días de alerta (TextField numérico, default 30)
  - Observaciones (TextField multiline)
  - Documento digital (FileUpload → Storage)
  - Requiere renovación (Checkbox)

## 🔄 Flujo de Trabajo

### 1. Crear DataSource (AmbuTrackDatasourceAgent)
- Crear entities en `ambutrack_core_datasource`
- Crear models con @JsonSerializable
- Crear contracts
- Crear factory pattern
- Ejecutar `build_runner`

### 2. Crear Tablas Supabase (SupabaseSpecialist)
- Crear las 2 tablas con el SQL especificado
- Configurar RLS policies
- Crear triggers para estado automático
- Crear función de alertas
- Verificar creación

### 3. Crear Repositorios (AmbuTrackFeatureBuilderAgent)
- Interfaces en domain
- Implementaciones en data (pass-through)
- Registrar en DI

### 4. Crear BLoC (AmbuTrackFeatureBuilderAgent)
- Estados con Freezed (Initial, Loading, Loaded, Error)
- Eventos con Freezed
- Lógica de negocio con permisos por rol
- Cálculo de estadísticas

### 5. Actualizar UI (AmbuTrackUIDesignerAgent)
- Reemplazar [documentacion_page.dart](lib/features/vehiculos/documentacion_page.dart) existente
- Conectar con BLoC
- Usar AppDataGridV5
- Implementar diálogos CRUD
- Implementar alertas de vencimiento

## 📅 Tareas Estimadas

| Tarea | Agente | Prioridad |
|-------|--------|-----------|
| Crear datasource | 🟣 Datasource | Alta |
| Crear tablas Supabase | 🗄️ Supabase | Alta |
| Crear repositorios | 🟠 FeatureBuilder | Alta |
| Crear BLoC | 🟠 FeatureBuilder | Alta |
| Actualizar UI | 🔵 UIDesigner | Alta |
| Validar | 🔴 QA | Media |

## ✅ Criterios de Aceptación

- [ ] DataSource creado en `ambutrack_core_datasource` con todas las entidades
- [ ] Tablas creadas en Supabase con RLS configurado
- [ ] Triggers funcionando para actualizar estado automáticamente
- [ ] Repository pass-through implementado
- [ ] BLoC con estados y eventos Freezed
- [ ] Página principal conectada a BLoC con datos reales
- [ ] CRUD funcional para tipos de documento
- [ ] CRUD funcional para registros de documentación
- [ ] Estadísticas calculadas correctamente
- [ ] Filtros funcionales (búsqueda, tipo, estado, fechas)
- [ ] Estados de documentación calculados automáticamente:
  - **Vigente**: fecha_vencimiento > hoy + días_alerta
  - **Próxima a vencer**: hoy + días_alerta >= fecha_vencimiento > hoy
  - **Vencida**: fecha_vencimiento <= hoy
- [ ] Alertas visibles para documentos vencidos/próximos
- [ ] Upload de documentos a Storage funcional
- [ ] Descarga de documentos funcional
- [ ] `flutter analyze` → 0 warnings
- [ ] SafeArea en todas las páginas
- [ ] AppColors para todos los colores
- [ ] Diálogos profesionales para acciones CRUD

## 🎨 Referencias de Diseño

### Paleta de Colores por Categoría

| Categoría | Color | Uso |
|-----------|-------|-----|
| Seguros | `AppColors.error` (rojo) | Badges, headers de seguros |
| ITV | `AppColors.warning` (naranja) | Badges, headers de ITV |
| Permisos/Licencias | `AppColors.info` (azul) | Badges, headers de permisos |
| Otros | `AppColors.secondaryLight` | Badges de otros documentos |

### Iconos por Categoría

| Categoría | Icono |
|-----------|-------|
| Seguros | `Icons.security` |
| ITV | `Icons.verified_user` |
| Permisos | `Icons.badge` |
| Licencias | `Icons.card_membership` |
| Otros | `Icons.description` |

---

**Plan creado**: 2025-02-15
**Última actualización**: 2025-02-15
