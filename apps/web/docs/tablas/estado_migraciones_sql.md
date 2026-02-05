# Estado de Migraciones SQL - AmbuTrack

**Fecha**: 2025-12-18
**Autor**: Claude Code
**Versión**: 1.0

---

## 📊 Resumen Ejecutivo

### Estado General de Migraciones
- **Migraciones SQL creadas**: 8 archivos
- **Tablas maestras con migración**: 3/9 (33%)
- **Tablas maestras sin migración**: 6/9 (67%)

---

## ✅ Migraciones SQL Existentes

### Archivos de Migración Creados

#### 1. `001_initial_schema.sql` (9.4 KB)
**Fecha**: Nov 19, 2023
**Contenido**:
- ✅ **tipos_vehiculo** - Tipos de vehículos (tabla maestra)
- usuarios - Gestión de usuarios
- vehiculos - Flota de vehículos
- personal - Personal sanitario
- servicios - Servicios de ambulancia
- Triggers y funciones de utilidad
- Row Level Security (RLS)
- Datos iniciales (4 tipos de vehículo)

#### 2. `001_crear_tablas_vehiculos.sql` (29 KB)
**Fecha**: Dec 15, 2025
**Contenido**:
- tvehiculos - Tabla principal de vehículos
- tmantenimientos - Mantenimientos programados
- titv_revisiones - ITV y revisiones técnicas
- tdocumentos_vehiculo - Documentación
- thistorial_ubicaciones - Tracking GPS
- tconsumo_combustible - Consumo y kilómetros
- taverias - Historial de averías
- tequipamiento_vehiculo - Stock de equipamiento

#### 3. `002_insertar_vehiculos_iniciales.sql` (20 KB)
**Fecha**: Dec 16, 2025
**Contenido**:
- Datos seed para vehículos iniciales

#### 4. `003_insertar_vehiculos_completo.sql` (17 KB)
**Fecha**: Dec 16, 2025
**Contenido**:
- Datos seed completos para vehículos

#### 5. `004_crear_tabla_facultativos.sql` (4.9 KB)
**Fecha**: Dec 18, 2025
**Contenido**:
- ✅ **tfacultativos** - Tabla de facultativos (médicos)
- Relación FK con tespecialidades
- Campos: nombre, apellidos, num_colegiado, especialidad_id, centro_id, etc.
- Row Level Security (RLS)

#### 6. `005_crear_tabla_especialidades.sql` (6.7 KB)
**Fecha**: Dec 18, 2025
**Contenido**:
- ✅ **tespecialidades** - Especialidades médicas
- Campos: nombre, descripcion, tipo_especialidad, requiere_certificacion, activo
- 20 registros seed incluidos
- Row Level Security (RLS)

#### 7. `006_migrar_facultativos_especialidad_fk.sql` (4.8 KB)
**Fecha**: Dec 18, 2025
**Contenido**:
- Migración de FK especialidad_id en tfacultativos
- Actualización de constraint

#### 8. `006_migrar_facultativos_especialidad_fk_clean.sql` (3.8 KB)
**Fecha**: Dec 18, 2025 (más reciente)
**Contenido**:
- Versión limpia de la migración FK
- Actualización final de especialidad_id

---

## ❌ Tablas Maestras SIN Migración SQL

Las siguientes **6 tablas maestras** tienen la implementación completa en Flutter (domain/data/presentation) pero **NO tienen migración SQL en Supabase**:

### 1. ⏳ Provincias (`tprovincias`)
**Estado**: Feature completo, migración SQL faltante
**Ubicación código**: `lib/features/tablas/provincias/`
**Tabla requerida**: `tprovincias`
**Campos necesarios**:
```sql
CREATE TABLE IF NOT EXISTS tprovincias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo TEXT NOT NULL UNIQUE,  -- Código INE
    nombre TEXT NOT NULL,
    comunidad_autonoma_id UUID REFERENCES tcomunidades(id),
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```
**Relaciones**:
- N:1 con `tcomunidades` (comunidades autónomas)
- 1:N con `tpoblaciones` (localidades)

---

### 2. ⏳ Comunidades Autónomas (`tcomunidades`)
**Estado**: Usado en Provincias, migración SQL faltante
**Ubicación código**: `lib/features/tablas/provincias/domain/entities/comunidad_autonoma_entity.dart`
**Tabla requerida**: `tcomunidades`
**Campos necesarios**:
```sql
CREATE TABLE IF NOT EXISTS tcomunidades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo TEXT NOT NULL UNIQUE,
    nombre TEXT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```
**Relaciones**:
- 1:N con `tprovincias`

**Datos seed requeridos**: 17 comunidades autónomas de España

---

### 3. ⏳ Localidades/Poblaciones (`tpoblaciones`)
**Estado**: Feature completo, migración SQL faltante
**Ubicación código**: `lib/features/tablas/localidades/`
**Tabla requerida**: `tpoblaciones`
**Campos necesarios**:
```sql
CREATE TABLE IF NOT EXISTS tpoblaciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provincia_id UUID NOT NULL REFERENCES tprovincias(id) ON DELETE CASCADE,
    codigo_postal TEXT NOT NULL,
    nombre TEXT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_tpoblaciones_provincia ON tpoblaciones(provincia_id);
CREATE INDEX idx_tpoblaciones_cp ON tpoblaciones(codigo_postal);
```
**Relaciones**:
- N:1 con `tprovincias`
- 1:N con `tcentros_hospitalarios`

---

### 4. ⏳ Centros Hospitalarios (`tcentros_hospitalarios`)
**Estado**: Feature completo, migración SQL faltante
**Ubicación código**: `lib/features/tablas/centros_hospitalarios/`
**Tabla requerida**: `tcentros_hospitalarios`
**Campos necesarios**:
```sql
CREATE TABLE IF NOT EXISTS tcentros_hospitalarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    direccion TEXT,
    localidad_id UUID REFERENCES tpoblaciones(id) ON DELETE SET NULL,
    telefono TEXT,
    email TEXT,
    tipo_centro TEXT CHECK (tipo_centro IN ('hospital', 'centro_salud', 'clinica')),
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_tcentros_localidad ON tcentros_hospitalarios(localidad_id);
```
**Relaciones**:
- N:1 con `tpoblaciones`
- 1:N con `tfacultativos`

---

### 5. ⏳ Motivos de Traslado (`tmotivos_traslado`)
**Estado**: Feature completo, migración SQL faltante
**Ubicación código**: `lib/features/tablas/motivos_traslado/`
**Documentación**: `docs/tablas/motivos_traslado.md`
**Tabla requerida**: `tmotivos_traslado`
**Campos necesarios**:
```sql
CREATE TABLE IF NOT EXISTS tmotivos_traslado (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```
**Relaciones**:
- 1:N con `servicios`

**Datos seed**: Ver `docs/tablas/motivos_traslado.md` para 15+ registros iniciales

---

### 6. ⏳ Motivos de Cancelación (`tmotivos_cancelacion`)
**Estado**: Feature completo, migración SQL faltante
**Ubicación código**: `lib/features/tablas/motivos_cancelacion/`
**Documentación**: `docs/tablas/motivos_cancelacion.md`
**Tabla requerida**: `tmotivos_cancelacion`
**Campos necesarios**:
```sql
CREATE TABLE IF NOT EXISTS tmotivos_cancelacion (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```
**Relaciones**:
- 1:N con `servicios` (campo motivo_cancelacion_id)

**Datos seed**: Ver `docs/tablas/motivos_cancelacion.md` para 15 registros iniciales

---

### 7. ⏳ Tipos de Traslado (`ttipos_traslado`)
**Estado**: Feature completo, migración SQL faltante
**Ubicación código**: `lib/features/tablas/tipos_traslado/`
**Documentación**: `docs/tablas/tipos_traslado.md`
**Tabla requerida**: `ttipos_traslado`
**Campos necesarios**:
```sql
CREATE TABLE IF NOT EXISTS ttipos_traslado (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```
**Relaciones**:
- 1:N con `servicios`

**Datos seed**: Ver `docs/tablas/tipos_traslado.md` para 10 registros iniciales

---

## 📊 Tabla de Resumen

| # | Tabla Maestra | Código Flutter | Migración SQL | Documentación | Estado |
|---|---------------|----------------|---------------|---------------|--------|
| 1 | Provincias | ✅ | ❌ | ⏳ | 66% |
| 2 | Comunidades Autónomas | ✅ | ❌ | ❌ | 33% |
| 3 | Localidades | ✅ | ❌ | ⏳ | 66% |
| 4 | Tipos de Vehículos | ✅ | ✅ | ⏳ | 66% |
| 5 | Centros Hospitalarios | ✅ | ❌ | ⏳ | 66% |
| 6 | Motivos de Traslado | ✅ | ❌ | ✅ | 66% |
| 7 | Motivos de Cancelación | ✅ | ❌ | ✅ | 66% |
| 8 | Tipos de Traslado | ✅ | ❌ | ✅ | 66% |
| 9 | Especialidades Médicas | ✅ | ✅ | ✅ | 100% |
| 10 | Facultativos | ✅ | ✅ | ✅ | 100% |

**Leyenda**:
- ✅ Completado
- ❌ Faltante
- ⏳ Parcial

---

## 🚀 Plan de Acción

### Prioridad 1 (Crítica)
Las siguientes tablas son **dependencias** de otras:

1. **Comunidades Autónomas** (`tcomunidades`)
   - Requerida por: Provincias
   - Migración: `007_crear_tabla_comunidades.sql`
   - Incluir: 17 registros seed

2. **Provincias** (`tprovincias`)
   - Requerida por: Localidades
   - Dependencia: tcomunidades
   - Migración: `008_crear_tabla_provincias.sql`
   - Incluir: 52 registros seed (provincias de España)

3. **Localidades** (`tpoblaciones`)
   - Requerida por: Centros Hospitalarios
   - Dependencia: tprovincias
   - Migración: `009_crear_tabla_localidades.sql`

### Prioridad 2 (Alta)

4. **Centros Hospitalarios** (`tcentros_hospitalarios`)
   - Requerida por: Servicios (indirectamente)
   - Dependencia: tpoblaciones
   - Migración: `010_crear_tabla_centros_hospitalarios.sql`

### Prioridad 3 (Media)

5. **Motivos de Traslado** (`tmotivos_traslado`)
   - Requerida por: Servicios
   - Migración: `011_crear_tabla_motivos_traslado.sql`
   - Incluir: Seed data del MD

6. **Motivos de Cancelación** (`tmotivos_cancelacion`)
   - Requerida por: Servicios
   - Migración: `012_crear_tabla_motivos_cancelacion.sql`
   - Incluir: Seed data del MD

7. **Tipos de Traslado** (`ttipos_traslado`)
   - Requerida por: Servicios
   - Migración: `013_crear_tabla_tipos_traslado.sql`
   - Incluir: Seed data del MD

---

## 📝 Plantilla para Nuevas Migraciones

```sql
-- ==============================================================================
-- [NOMBRE DE LA TABLA]
-- Descripción breve
-- ==============================================================================

-- Crear tabla
CREATE TABLE IF NOT EXISTS t[nombre] (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    -- Campos específicos
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_t[nombre]_[campo] ON t[nombre]([campo]);

-- Trigger para updated_at
CREATE TRIGGER update_t[nombre]_updated_at
    BEFORE UPDATE ON t[nombre]
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE t[nombre] ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden ver (lectura)
CREATE POLICY "Usuarios autenticados pueden ver [nombre]" ON t[nombre]
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política: Solo admins pueden modificar
CREATE POLICY "Admins pueden gestionar [nombre]" ON t[nombre]
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Datos iniciales (seed)
INSERT INTO t[nombre] (campo1, campo2) VALUES
    ('valor1', 'desc1'),
    ('valor2', 'desc2')
ON CONFLICT (campo_unico) DO NOTHING;
```

---

## ✅ Checklist para Crear Migración

- [ ] Crear archivo `XXX_crear_tabla_[nombre].sql`
- [ ] Definir estructura de tabla con UUID primary key
- [ ] Añadir campos `activo`, `created_at`, `updated_at`
- [ ] Crear índices necesarios
- [ ] Añadir trigger `update_updated_at`
- [ ] Configurar Row Level Security (RLS)
- [ ] Crear políticas de acceso (SELECT para autenticados, ALL para admins)
- [ ] Incluir datos seed si aplica
- [ ] Documentar relaciones FK en comentarios
- [ ] Probar migración en Supabase local
- [ ] Aplicar migración a Supabase producción
- [ ] Actualizar este documento

---

## 📚 Referencias

- **Documentación Supabase**: https://supabase.com/docs/guides/database
- **Ubicación migraciones**: `supabase/migrations/`
- **Documentación tablas**: `docs/tablas/`
- **Plan CRUD completo**: `docs/tablas/crud_plan.md`

---

**Última actualización**: 2025-12-18 19:45
**Próxima acción**: Crear migraciones 007-013 según prioridad
**Responsable**: Equipo AmbuTrack
