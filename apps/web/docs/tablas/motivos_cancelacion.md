# Motivos de Cancelación

## 📋 Descripción
Gestión de los diferentes motivos por los cuales se puede cancelar un servicio o traslado en AmbuTrack. Esta tabla maestra permite categorizar las razones de cancelación para análisis y reportes.

## 🗄️ Tabla en Supabase
**Nombre**: `tmotivos_cancelacion`

## 📊 Estructura de la Tabla

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| `id` | uuid | PK, NOT NULL, DEFAULT uuid_generate_v4() | Identificador único |
| `nombre` | varchar(100) | NOT NULL, UNIQUE | Nombre del motivo |
| `descripcion` | text | NULL | Descripción detallada del motivo |
| `activo` | boolean | NOT NULL, DEFAULT true | Estado activo/inactivo |
| `created_at` | timestamptz | NOT NULL, DEFAULT now() | Fecha de creación |
| `updated_at` | timestamptz | NOT NULL, DEFAULT now() | Fecha de actualización |

## 🎯 Valores Típicos

Ejemplos de motivos de cancelación comunes:

1. **Paciente rechaza el servicio** - El paciente decide no utilizar el servicio
2. **Mejora del estado del paciente** - El paciente ya no requiere el traslado
3. **Duplicado** - Servicio duplicado por error
4. **Error en la solicitud** - Datos incorrectos en la solicitud inicial
5. **Falta de personal** - No hay personal disponible para el servicio
6. **Falta de vehículo** - No hay vehículos disponibles
7. **Condiciones meteorológicas** - Clima adverso impide el servicio
8. **Fallecimiento del paciente** - El paciente fallece antes del servicio
9. **Alta médica** - El paciente recibe el alta antes del traslado
10. **Cancelación del centro sanitario** - El centro destino cancela

## 🔗 Relaciones

### Salientes (1:N)
- `servicios.motivo_cancelacion_id` → `tmotivos_cancelacion.id`
  - Un motivo puede estar asociado a múltiples servicios cancelados

## 🚀 Script SQL para Supabase

```sql
-- ============================================
-- TABLA: tmotivos_cancelacion
-- Descripción: Catálogo de motivos de cancelación de servicios
-- ============================================

-- Crear tabla
CREATE TABLE IF NOT EXISTS public.tmotivos_cancelacion (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre varchar(100) NOT NULL UNIQUE,
    descripcion text,
    activo boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Comentarios
COMMENT ON TABLE public.tmotivos_cancelacion IS 'Catálogo de motivos de cancelación de servicios';
COMMENT ON COLUMN public.tmotivos_cancelacion.id IS 'Identificador único del motivo';
COMMENT ON COLUMN public.tmotivos_cancelacion.nombre IS 'Nombre del motivo de cancelación';
COMMENT ON COLUMN public.tmotivos_cancelacion.descripcion IS 'Descripción detallada del motivo';
COMMENT ON COLUMN public.tmotivos_cancelacion.activo IS 'Indica si el motivo está activo';
COMMENT ON COLUMN public.tmotivos_cancelacion.created_at IS 'Fecha de creación del registro';
COMMENT ON COLUMN public.tmotivos_cancelacion.updated_at IS 'Fecha de última actualización';

-- Índices
CREATE INDEX IF NOT EXISTS idx_tmotivos_cancelacion_activo ON public.tmotivos_cancelacion(activo);
CREATE INDEX IF NOT EXISTS idx_tmotivos_cancelacion_nombre ON public.tmotivos_cancelacion(nombre);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_tmotivos_cancelacion_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_tmotivos_cancelacion_updated_at
    BEFORE UPDATE ON public.tmotivos_cancelacion
    FOR EACH ROW
    EXECUTE FUNCTION update_tmotivos_cancelacion_updated_at();

-- RLS (Row Level Security)
ALTER TABLE public.tmotivos_cancelacion ENABLE ROW LEVEL SECURITY;

-- Política: Lectura pública
CREATE POLICY "tmotivos_cancelacion_select_policy" ON public.tmotivos_cancelacion
    FOR SELECT
    USING (true);

-- Política: Inserción autenticada
CREATE POLICY "tmotivos_cancelacion_insert_policy" ON public.tmotivos_cancelacion
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Política: Actualización autenticada
CREATE POLICY "tmotivos_cancelacion_update_policy" ON public.tmotivos_cancelacion
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Política: Eliminación autenticada
CREATE POLICY "tmotivos_cancelacion_delete_policy" ON public.tmotivos_cancelacion
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- ============================================
-- DATOS INICIALES
-- ============================================

INSERT INTO public.tmotivos_cancelacion (nombre, descripcion, activo) VALUES
('Paciente rechaza el servicio', 'El paciente decide no utilizar el servicio de ambulancia', true),
('Mejora del estado del paciente', 'El estado del paciente mejora y ya no requiere el traslado', true),
('Duplicado', 'Servicio duplicado por error en el sistema', true),
('Error en la solicitud', 'Los datos de la solicitud inicial son incorrectos', true),
('Falta de personal', 'No hay personal sanitario disponible para realizar el servicio', true),
('Falta de vehículo', 'No hay vehículos disponibles en el momento solicitado', true),
('Condiciones meteorológicas', 'Las condiciones climáticas adversas impiden realizar el servicio', true),
('Fallecimiento del paciente', 'El paciente fallece antes de que se realice el traslado', true),
('Alta médica', 'El paciente recibe el alta médica antes del traslado programado', true),
('Cancelación del centro sanitario', 'El centro sanitario de destino cancela la recepción del paciente', true),
('Cambio de prioridad', 'Se prioriza otro servicio más urgente', true),
('Problema técnico del vehículo', 'Avería o problema técnico del vehículo asignado', true),
('Paciente no localizable', 'No se puede contactar con el paciente en la dirección indicada', true),
('Familiar cancela', 'Un familiar del paciente cancela el servicio', true),
('Otro motivo', 'Motivo de cancelación no especificado en las categorías anteriores', true)
ON CONFLICT (nombre) DO NOTHING;

-- Verificación
SELECT
    COUNT(*) as total_motivos,
    COUNT(*) FILTER (WHERE activo = true) as activos,
    COUNT(*) FILTER (WHERE activo = false) as inactivos
FROM public.tmotivos_cancelacion;
```

## 📱 Ubicación del CRUD

### Frontend (Flutter)
```
lib/features/tablas/motivos_cancelacion/
├── domain/
│   ├── entities/
│   │   └── motivo_cancelacion_entity.dart
│   └── repositories/
│       └── motivo_cancelacion_repository.dart
├── data/
│   ├── models/
│   │   ├── motivo_cancelacion_model.dart
│   │   └── motivo_cancelacion_model.g.dart
│   ├── datasources/
│   │   └── motivo_cancelacion_datasource.dart
│   └── repositories/
│       └── motivo_cancelacion_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── motivo_cancelacion_event.dart
    │   ├── motivo_cancelacion_state.dart
    │   └── motivo_cancelacion_bloc.dart
    ├── pages/
    │   └── motivos_cancelacion_page.dart
    └── widgets/
        ├── motivo_cancelacion_header.dart
        ├── motivo_cancelacion_table.dart
        └── motivo_cancelacion_form_dialog.dart
```

## 🎨 Interfaz de Usuario

### Página Principal
- **Título**: "Motivos de Cancelación"
- **Ruta**: `/tablas/motivos-cancelacion`
- **Icono**: `Icons.cancel`
- **Acciones**:
  - Botón "Agregar" (esquina superior derecha)
  - Búsqueda por nombre/descripción
  - Ordenamiento por columnas

### Tabla
**Columnas**:
1. NOMBRE (sortable)
2. DESCRIPCIÓN (sortable)
3. ESTADO (sortable) - Badge con color
4. ACCIONES - Editar | Eliminar

### Formulario Crear/Editar
**Campos**:
1. **Nombre*** (obligatorio)
   - TextFormField
   - Validación: min 3 caracteres
   - Max length: 100

2. **Descripción** (opcional)
   - TextFormField multilínea (3 líneas)
   - Validación: min 5 caracteres si se proporciona

3. **Estado** (obligatorio)
   - Switch Activo/Inactivo
   - Default: Activo

**Botones**:
- Cancelar (AppButtonVariant.text)
- Guardar/Actualizar (AppButtonVariant.primary)

## ✨ Características Implementadas

### Funcionalidades
- ✅ CRUD completo (Crear, Leer, Actualizar, Eliminar)
- ✅ Búsqueda en tiempo real por nombre y descripción
- ✅ Ordenamiento por todas las columnas
- ✅ Indicador de estado visual (Activo/Inactivo)
- ✅ Validaciones de campos
- ✅ Loading states en operaciones asíncronas
- ✅ Mensajes de confirmación para eliminación
- ✅ SnackBars de éxito/error
- ✅ Navegación por teclado en formularios (Tab/Enter)

### Validaciones
- ✅ Nombre único en base de datos
- ✅ Nombre obligatorio (min 3 caracteres)
- ✅ Descripción mínima 5 caracteres (si se proporciona)
- ✅ Prevención de duplicados

### UX/UI
- ✅ Loading overlay con AppLoadingOverlay
- ✅ Confirmación de eliminación con diálogo
- ✅ Diseño responsivo
- ✅ Colores consistentes con AppColors
- ✅ Iconografía clara y comprensible
- ✅ SafeArea en toda la página

## 🔧 Uso en el Sistema

### Casos de Uso
1. **Reportes y Estadísticas**
   - Análisis de causas más frecuentes de cancelación
   - Métricas de calidad del servicio
   - Identificación de problemas operativos

2. **Auditoría**
   - Registro histórico de cancelaciones
   - Justificación documentada de servicios no realizados
   - Cumplimiento normativo

3. **Mejora Continua**
   - Detectar patrones en cancelaciones
   - Implementar acciones correctivas
   - Optimización de recursos

### Relación con Otros Módulos
- **Servicios**: Cada servicio cancelado tiene un motivo asociado
- **Informes**: Generación de reportes de cancelaciones
- **Tráfico**: Análisis de cancelaciones por problemas de tráfico
- **Personal**: Cancelaciones por falta de personal

## 📊 Consultas Útiles

```sql
-- Motivos de cancelación más usados
SELECT
    mc.nombre,
    COUNT(s.id) as total_cancelaciones
FROM tmotivos_cancelacion mc
LEFT JOIN servicios s ON s.motivo_cancelacion_id = mc.id
WHERE s.estado = 'cancelado'
GROUP BY mc.id, mc.nombre
ORDER BY total_cancelaciones DESC;

-- Motivos activos
SELECT * FROM tmotivos_cancelacion
WHERE activo = true
ORDER BY nombre;

-- Buscar por texto
SELECT * FROM tmotivos_cancelacion
WHERE nombre ILIKE '%paciente%'
   OR descripcion ILIKE '%paciente%'
ORDER BY nombre;
```

## 🔒 Seguridad

- **RLS habilitado**: Todas las operaciones verifican autenticación
- **Políticas**:
  - SELECT: Público (cualquier usuario)
  - INSERT/UPDATE/DELETE: Solo usuarios autenticados
- **Validaciones**: Tanto en frontend como backend
- **Auditoría**: Campos `created_at` y `updated_at` automáticos

## 📝 Notas de Implementación

### DataSource
- Tipo: **SimpleDataSource**
- Cache: 24-48 horas (tabla maestra estática)
- Ordenamiento por defecto: `nombre ASC`

### BLoC States
- `MotivoCancelacionInitial`
- `MotivoCancelacionLoading`
- `MotivoCancelacionLoaded`
- `MotivoCancelacionError`

### Patrón de Loading
- BlocListener escucha `MotivoCancelacionLoaded`
- Loading overlay con `showDialog` + `AppLoadingOverlay`
- Cierre automático de diálogos
- Logs con `debugPrint`

## ✅ Checklist de Implementación

- [x] Script SQL creado y probado en Supabase
- [x] Entity creada en domain
- [x] Repository contract definido
- [x] Model con @JsonSerializable
- [x] DataSource implementado
- [x] Repository implementation
- [x] BLoC (events, states, bloc)
- [x] Página principal con SafeArea
- [x] Tabla con búsqueda y ordenamiento
- [x] Formulario crear/editar
- [x] Header con botón agregar
- [x] Validaciones implementadas
- [x] Loading states
- [x] Ruta registrada en GoRouter
- [x] Menú actualizado
- [x] Build runner ejecutado
- [x] Flutter analyze sin warnings
- [x] Documentación completa

---

**Creado**: 2025-12-17
**Estado**: ✅ Implementado
**Versión**: 1.0
