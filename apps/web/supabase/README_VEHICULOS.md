# 📋 DOCUMENTACIÓN: Tablas de Vehículos - AmbuTrack

## 📚 Índice
1. [Descripción General](#descripción-general)
2. [Estructura de Tablas](#estructura-de-tablas)
3. [Relaciones](#relaciones)
4. [Funciones Auxiliares](#funciones-auxiliares)
5. [Índices y Rendimiento](#índices-y-rendimiento)
6. [Seguridad (RLS)](#seguridad-rls)
7. [Uso y Ejemplos](#uso-y-ejemplos)
8. [Mantenimiento](#mantenimiento)

---

## 🎯 Descripción General

Este conjunto de tablas proporciona una gestión completa del módulo de **Vehículos** de AmbuTrack, incluyendo:

- ✅ Gestión principal de vehículos (129 campos)
- ✅ Mantenimientos preventivos y correctivos
- ✅ Registro de averías e incidencias
- ✅ ITVs y revisiones técnicas
- ✅ Consumo de combustible
- ✅ Inventario de equipamiento médico
- ✅ Historial de ubicaciones GPS
- ✅ Documentación digital

---

## 📊 Estructura de Tablas

### 1. `tvehiculos` (Tabla Principal)

**Descripción**: Tabla maestra de vehículos con 129 campos organizados en 17 secciones.

**Campos Críticos**:
- `id` (PK)
- `matricula` (UNIQUE)
- `estado` (activo, mantenimiento, reparacion, baja)
- `km_actual`
- `proxima_itv`
- `fecha_vencimiento_seguro`
- `homologacion_sanitaria`
- `empresa_id` (Multi-tenant)

**Campos de Auditoría**:
```sql
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ
created_by UUID
updated_by UUID
```

**Índices**:
- `idx_tvehiculos_matricula` (búsqueda rápida por matrícula)
- `idx_tvehiculos_estado` (filtrado por estado)
- `idx_tvehiculos_empresa_id` (multi-tenant)
- `idx_tvehiculos_ubicacion` (GiST para búsquedas geoespaciales)

---

### 2. `tmantenimientos`

**Descripción**: Registro histórico de mantenimientos preventivos y correctivos.

**Campos Principales**:
- `vehiculo_id` (FK → tvehiculos)
- `fecha`, `km_vehiculo`
- `tipo_mantenimiento` (basico, completo, especial, urgente)
- `estado` (programado, en_proceso, completado, cancelado)
- `costo_total`
- `taller`, `mecanico_responsable`

**Casos de uso**:
- Historial completo de mantenimientos
- Planificación de próximos servicios
- Control de costos por vehículo
- Análisis de talleres y proveedores

---

### 3. `taverias`

**Descripción**: Registro de averías e incidencias técnicas.

**Campos Principales**:
- `vehiculo_id` (FK → tvehiculos)
- `fecha_averia`, `km_vehiculo`
- `gravedad` (leve, moderada, grave, critica)
- `estado` (reportada, en_diagnostico, en_reparacion, reparada, no_reparable)
- `costo_reparacion`
- `tiempo_reparacion_horas`

**Casos de uso**:
- Seguimiento de averías
- Análisis de fiabilidad por vehículo
- Detección de problemas recurrentes
- Control de costos de reparación

---

### 4. `titv_revisiones`

**Descripción**: Control de ITVs, revisiones técnicas y homologaciones.

**Campos Principales**:
- `vehiculo_id` (FK → tvehiculos)
- `tipo` (itv, revision_tecnica, tacografo, homologacion)
- `resultado` (favorable, favorable_defectos_leves, desfavorable, negativa)
- `proxima_fecha`
- `defectos_leves`, `defectos_graves`, `defectos_muy_graves` (JSONB)

**Casos de uso**:
- Historial de ITVs
- Alertas de vencimiento
- Análisis de defectos recurrentes

---

### 5. `tconsumo_combustible`

**Descripción**: Registro de repostajes y consumo.

**Campos Principales**:
- `vehiculo_id` (FK → tvehiculos)
- `fecha`, `km_vehiculo`
- `tipo_combustible`, `litros`, `costo_total`
- `consumo_l100km` (calculado)
- `conductor_id`, `conductor_nombre`

**Casos de uso**:
- Análisis de consumo por vehículo
- Control de gastos de combustible
- Detección de anomalías en consumo
- Seguimiento de tarjetas de combustible

---

### 6. `tequipamiento_vehiculo`

**Descripción**: Inventario de equipamiento médico por vehículo.

**Campos Principales**:
- `vehiculo_id` (FK → tvehiculos)
- `nombre_equipo`, `tipo_equipo`
- `cantidad`, `estado`
- `fecha_caducidad`, `proxima_revision`
- `certificaciones` (JSONB)

**Casos de uso**:
- Inventario de equipamiento
- Control de caducidades
- Planificación de revisiones
- Cumplimiento normativo

---

### 7. `thistorial_ubicaciones`

**Descripción**: Tracking GPS de vehículos.

**Campos Principales**:
- `vehiculo_id` (FK → tvehiculos)
- `timestamp`, `latitud`, `longitud`
- `velocidad_kmh`, `direccion_grados`
- `en_servicio`, `servicio_id`

**Casos de uso**:
- Tracking en tiempo real
- Análisis de rutas
- Estadísticas de movimiento
- Optimización de flotas

**Nota**: Esta tabla NO tiene `updated_at/updated_by` porque es solo INSERT (append-only).

---

### 8. `tdocumentos_vehiculo`

**Descripción**: Gestión documental digital.

**Campos Principales**:
- `vehiculo_id` (FK → tvehiculos)
- `tipo_documento` (permiso_circulacion, seguro, itv, etc.)
- `url`, `tipo_archivo`
- `fecha_vencimiento`, `estado`
- `notificar_vencimiento`

**Casos de uso**:
- Repositorio centralizado de documentos
- Alertas de vencimiento
- Acceso rápido a documentación
- Auditoría documental

---

## 🔗 Relaciones Entre Tablas

```
tvehiculos (1) ──┬── (N) tmantenimientos
                 ├── (N) taverias
                 ├── (N) titv_revisiones
                 ├── (N) tconsumo_combustible
                 ├── (N) tequipamiento_vehiculo
                 ├── (N) thistorial_ubicaciones
                 └── (N) tdocumentos_vehiculo
```

**Foreign Keys**:
- Todas las tablas tienen `vehiculo_id` con `ON DELETE CASCADE`
- Todas tienen `empresa_id` para multi-tenancy

---

## 🛠️ Funciones Auxiliares

### 1. `update_updated_at_column()`

**Descripción**: Trigger automático para actualizar `updated_at` en cada UPDATE.

**Uso**: Se ejecuta automáticamente en todas las tablas (excepto `thistorial_ubicaciones`).

---

### 2. `calcular_consumo_promedio(p_vehiculo_id UUID)`

**Descripción**: Calcula el consumo promedio de los últimos 6 meses.

**Retorna**: `NUMERIC` - Consumo en L/100km

**Ejemplo**:
```sql
SELECT calcular_consumo_promedio('uuid-del-vehiculo');
```

---

### 3. `calcular_km_promedio_mensual(p_vehiculo_id UUID)`

**Descripción**: Calcula el promedio de km mensuales desde la puesta en servicio.

**Retorna**: `NUMERIC` - Km promedio por mes

**Ejemplo**:
```sql
SELECT calcular_km_promedio_mensual('uuid-del-vehiculo');
```

---

### 4. `verificar_alertas_vehiculo(p_vehiculo_id UUID)`

**Descripción**: Devuelve alertas de vencimientos (ITV, seguro, homologación).

**Retorna**: Tabla con columnas:
- `tipo_alerta` (ITV, SEGURO, HOMOLOGACION)
- `descripcion`
- `fecha_vencimiento`
- `dias_restantes`
- `criticidad` (baja, media, alta, critica)

**Ejemplo**:
```sql
SELECT * FROM verificar_alertas_vehiculo('uuid-del-vehiculo');
```

**Resultado**:
| tipo_alerta | descripcion | fecha_vencimiento | dias_restantes | criticidad |
|-------------|-------------|-------------------|----------------|------------|
| ITV | Vencimiento de ITV | 2025-03-15 | 90 | media |
| SEGURO | Vencimiento de seguro | 2025-01-30 | 45 | media |
| HOMOLOGACION | Vencimiento de homologación | 2027-01-15 | 761 | baja |

---

## ⚡ Índices y Rendimiento

### Índices GiST (Geoespaciales)

**tvehiculos**:
```sql
CREATE INDEX idx_tvehiculos_ubicacion
    ON public.tvehiculos USING GIST (ll_to_earth(latitud::float8, longitud::float8));
```

**thistorial_ubicaciones**:
```sql
CREATE INDEX idx_thistorial_ubicaciones_coords
    ON public.thistorial_ubicaciones USING GIST (ll_to_earth(latitud::float8, longitud::float8));
```

**Uso**: Búsquedas por proximidad geográfica (ej: vehículos a menos de 5km).

### Índices de Fechas

Para optimizar consultas con rangos de fechas:
- `idx_tmantenimientos_fecha`
- `idx_taverias_fecha_averia`
- `idx_titv_revisiones_fecha`
- `idx_tconsumo_combustible_fecha`
- `idx_thistorial_ubicaciones_timestamp`

### Índices de Estado

Para filtrados frecuentes:
- `idx_tvehiculos_estado`
- `idx_tmantenimientos_estado`
- `idx_taverias_estado`
- `idx_tdocumentos_vehiculo_estado`

---

## 🔒 Seguridad (RLS)

### Row Level Security Habilitado

Todas las tablas tienen RLS activado con políticas basadas en `empresa_id`:

```sql
ALTER TABLE public.tvehiculos ENABLE ROW LEVEL SECURITY;
```

### Políticas Principales

#### SELECT (Lectura)
```sql
CREATE POLICY "Los usuarios pueden ver vehículos de su empresa"
    ON public.tvehiculos FOR SELECT
    USING (empresa_id IN (
        SELECT empresa_id FROM public.usuarios WHERE id = auth.uid()
    ));
```

#### INSERT (Inserción)
```sql
CREATE POLICY "Los usuarios pueden insertar vehículos en su empresa"
    ON public.tvehiculos FOR INSERT
    WITH CHECK (empresa_id IN (
        SELECT empresa_id FROM public.usuarios WHERE id = auth.uid()
    ));
```

#### UPDATE (Actualización)
```sql
CREATE POLICY "Los usuarios pueden actualizar vehículos de su empresa"
    ON public.tvehiculos FOR UPDATE
    USING (empresa_id IN (
        SELECT empresa_id FROM public.usuarios WHERE id = auth.uid()
    ));
```

**Importante**: Las políticas asumen la existencia de una tabla `usuarios` con campo `empresa_id`.

---

## 💻 Uso y Ejemplos

### Insertar un Vehículo

```sql
INSERT INTO public.tvehiculos (
    matricula,
    tipo_vehiculo,
    categoria,
    marca,
    modelo,
    anio_fabricacion,
    numero_bastidor,
    estado,
    km_actual,
    proxima_itv,
    fecha_vencimiento_seguro,
    homologacion_sanitaria,
    fecha_vencimiento_homologacion,
    empresa_id,
    created_by
) VALUES (
    'AMB-001-XY',
    'Ambulancia Soporte Vital',
    'Tipo C',
    'Mercedes-Benz',
    'Sprinter',
    2022,
    'WDB9063451234567',
    'activo',
    45000,
    '2026-03-15',
    '2025-06-30',
    'HOM-SAN-2022-001',
    '2027-01-15',
    'uuid-de-empresa',
    auth.uid()
);
```

### Registrar un Mantenimiento

```sql
INSERT INTO public.tmantenimientos (
    vehiculo_id,
    fecha,
    km_vehiculo,
    tipo_mantenimiento,
    descripcion,
    taller,
    costo_total,
    estado,
    empresa_id,
    created_by
) VALUES (
    'uuid-del-vehiculo',
    '2024-12-15',
    45000,
    'completo',
    'Mantenimiento de 45.000 km - Cambio de aceite, filtros, revisión de frenos',
    'Taller Central',
    450.00,
    'completado',
    'uuid-de-empresa',
    auth.uid()
);
```

### Registrar Repostaje

```sql
INSERT INTO public.tconsumo_combustible (
    vehiculo_id,
    fecha,
    km_vehiculo,
    tipo_combustible,
    litros,
    precio_litro,
    costo_total,
    estacion,
    conductor_nombre,
    empresa_id,
    created_by
) VALUES (
    'uuid-del-vehiculo',
    NOW(),
    45234,
    'Diésel',
    60.5,
    1.45,
    87.73,
    'Repsol - Av. Principal 123',
    'Juan Pérez',
    'uuid-de-empresa',
    auth.uid()
);
```

### Consultar Vehículos Disponibles

```sql
SELECT
    id,
    matricula,
    tipo_vehiculo,
    marca,
    modelo,
    km_actual,
    ubicacion_actual
FROM public.tvehiculos
WHERE disponible = true
  AND operativo = true
  AND estado = 'activo'
ORDER BY prioridad_asignacion ASC;
```

### Obtener Vehículos con Alertas

```sql
SELECT
    v.matricula,
    v.marca,
    v.modelo,
    a.*
FROM public.tvehiculos v
CROSS JOIN LATERAL verificar_alertas_vehiculo(v.id) a
WHERE a.criticidad IN ('alta', 'critica')
ORDER BY a.dias_restantes ASC;
```

### Estadísticas de Consumo por Vehículo

```sql
SELECT
    v.matricula,
    COUNT(c.id) as total_repostajes,
    SUM(c.litros) as litros_totales,
    SUM(c.costo_total) as costo_total,
    AVG(c.consumo_l100km) as consumo_promedio
FROM public.tvehiculos v
LEFT JOIN public.tconsumo_combustible c ON v.id = c.vehiculo_id
WHERE c.fecha >= NOW() - INTERVAL '6 months'
GROUP BY v.id, v.matricula
ORDER BY consumo_promedio DESC;
```

### Vehículos Cerca de una Ubicación

```sql
SELECT
    matricula,
    marca,
    modelo,
    ubicacion_actual,
    earth_distance(
        ll_to_earth(latitud::float8, longitud::float8),
        ll_to_earth(40.4168, -3.7038)  -- Ejemplo: Madrid
    ) / 1000 AS distancia_km
FROM public.tvehiculos
WHERE latitud IS NOT NULL
  AND longitud IS NOT NULL
ORDER BY distancia_km ASC
LIMIT 10;
```

---

## 🔧 Mantenimiento

### Actualización de Estadísticas

**Recomendación**: Ejecutar `ANALYZE` periódicamente en tablas con alto volumen:

```sql
ANALYZE public.tvehiculos;
ANALYZE public.thistorial_ubicaciones;
ANALYZE public.tconsumo_combustible;
```

### Limpieza de Datos Antiguos

**Historial de ubicaciones** (conservar últimos 6 meses):

```sql
DELETE FROM public.thistorial_ubicaciones
WHERE timestamp < NOW() - INTERVAL '6 months';
```

### Backup y Restauración

**Backup de todas las tablas de vehículos**:

```bash
pg_dump -h localhost -U postgres -t tvehiculos -t tmantenimientos -t taverias -t titv_revisiones -t tconsumo_combustible -t tequipamiento_vehiculo -t thistorial_ubicaciones -t tdocumentos_vehiculo ambutrack_db > backup_vehiculos.sql
```

---

## 📝 Notas Importantes

1. **Multi-Tenancy**: Todas las consultas deben filtrar por `empresa_id`
2. **Auditoría**: Los campos `created_by` y `updated_by` deben poblarse con `auth.uid()`
3. **Geolocalización**: Requiere extensión PostGIS o `cube` + `earthdistance`
4. **JSONB**: Los campos JSON permiten flexibilidad para datos no estructurados
5. **Cascada**: El borrado de un vehículo elimina automáticamente todos sus registros relacionados

---

## 🚀 Extensiones Requeridas

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;
```

---

## 📞 Contacto y Soporte

Para dudas o issues relacionados con la estructura de datos:
- Revisar CLAUDE.md en el proyecto
- Consultar SUPABASE_GUIDE.md

---

**Última actualización**: 2024-12-15
**Versión**: 1.0.0
