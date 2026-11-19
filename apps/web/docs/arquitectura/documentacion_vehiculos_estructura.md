# Estructura de Base de Datos - Documentación de Vehículos

## 📊 Diagrama Entidad-Relación

```
┌─────────────────────────────────────────────────────────────────┐
│                    ambutrack_tipos_documento_vehiculo           │
│                    (Catálogo Maestro - 16 registros)            │
├─────────────────────────────────────────────────────────────────┤
│ PK  id                 UUID                                     │
│    *codigo             TEXT    UNIQUE (seguro_rc, itv, etc)    │
│    *nombre             TEXT                                     │
│     descripcion        TEXT                                     │
│    *categoria          TEXT    CHECK (seguro|tecnica|legal|...)│
│     dias_alerta_recomendados  INTEGER (defecto: 30)            │
│     requiere_renovacion_automatica BOOLEAN                     │
│     periodicidad_renovacion_meses INTEGER                      │
│     activo             BOOLEAN (defecto: true)                  │
│     orden_visual       INTEGER (defecto: 100)                   │
│     created_at         TIMESTAMPTZ                              │
│     updated_at         TIMESTAMPTZ                              │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    │ FK: ON DELETE RESTRICT
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ambutrack_documentacion_vehiculos             │
│                    (Registros de Documentación)                  │
├─────────────────────────────────────────────────────────────────┤
│ PK  id                 UUID                                     │
│ FK  vehiculo_id        UUID → tvehiculos.id (CASCADE)           │
│ FK  tipo_documento_id  UUID → tipos_documento.id (RESTRICT)     │
│    *numero_poliza      TEXT                                     │
│    *compania           TEXT                                     │
│    *fecha_emision      DATE                                     │
│    *fecha_vencimiento  DATE                                     │
│     fecha_proximo_vencimiento DATE                              │
│    *estado             TEXT (vigente|proxima_vencer|vencida)     │
│     coste_anual        NUMERIC(10,2)                            │
│     observaciones      TEXT                                     │
│     documento_url      TEXT (Supabase Storage)                  │
│     documento_url2     TEXT (Supabase Storage - adicional)      │
│     requiere_renovacion BOOLEAN (defecto: false)                │
│     dias_alerta        INTEGER (defecto: 30)                    │
│     created_at         TIMESTAMPTZ                              │
│     updated_at         TIMESTAMPTZ                              │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Flujo de Estado Automático

```
                    INSERT/UPDATE
                         │
                         ▼
              ┌──────────────────────┐
              │  Trigger Automático  │
              │  calcular_estado()   │
              └──────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
    ┌──────────┐   ┌──────────┐   ┌──────────┐
    │ vigente  │   │ proxima_  │   │ vencida  │
    │          │   │ vencer   │   │          │
    │ dias >   │   │ dias <=  │   │ dias <   │
    │ alerta   │   │ alerta   │   │ 0        │
    └──────────┘   └──────────┘   └──────────┘
```

## 📦 Categorías de Documentos

### 1. Seguros (3 tipos)
```
┌─ seguro_rc ─────────────────────┐
│ Seguro de Responsabilidad Civil │
│ Periodicidad: 12 meses          │
│ Alerta: 30 días                 │
└─────────────────────────────────┘

┌─ seguro_todo_riesgo ────────────┐
│ Seguro a Todo Riesgo            │
│ Periodicidad: 12 meses          │
│ Alerta: 30 días                 │
└─────────────────────────────────┘

┌─ seguro_mercancia ──────────────┐
│ Seguro de Mercancías            │
│ Periodicidad: 12 meses          │
│ Alerta: 30 días                 │
└─────────────────────────────────┘
```

### 2. Documentación Técnica (3 tipos)
```
┌─ itv ───────────────────────────┐
│ Inspección Técnica de Vehículos │
│ Periodicidad: 12 meses          │
│ Alerta: 60 días                 │
└─────────────────────────────────┘

┌─ homologacion_sanitaria ────────┐
│ Homologación Sanitaria          │
│ Periodicidad: 24 meses          │
│ Alerta: 90 días                 │
└─────────────────────────────────┘

┌─ revision_tacografo ────────────┐
│ Revisión de Tacógrafo           │
│ Periodicidad: 24 meses          │
│ Alerta: 30 días                 │
└─────────────────────────────────┘
```

### 3. Documentación Legal (4 tipos)
```
┌─ permiso_circulacion ───────────┐
│ Permiso de Circulación          │
│ Periodicidad: NULL              │
│ Alerta: 60 días                 │
└─────────────────────────────────┘

┌─ tarjeta_transportes ───────────┐
│ Tarjeta de Transportes           │
│ Periodicidad: 12 meses          │
│ Alerta: 60 días                 │
└─────────────────────────────────┘

┌─ permiso_municipal ─────────────┐
│ Permiso Municipal               │
│ Periodicidad: 12 meses          │
│ Alerta: 90 días                 │
└─────────────────────────────────┘

┌─ licencia_operativa ────────────┐
│ Licencia Operativa              │
│ Periodicidad: 12 meses          │
│ Alerta: 60 días                 │
└─────────────────────────────────┘
```

### 4. Documentación Administrativa (3 tipos)
```
┌─ contrato_renting ──────────────┐
│ Contrato de Renting/Leasing     │
│ Periodicidad: NULL              │
│ Alerta: 90 días                 │
└─────────────────────────────────┘

┌─ certificado_conformidad ───────┐
│ Certificado de Conformidad       │
│ Periodicidad: NULL              │
│ Alerta: 365 días                │
└─────────────────────────────────┘

┌─ ficha_tecnica ─────────────────┐
│ Ficha Técnica del Vehículo      │
│ Periodicidad: NULL              │
│ Alerta: 365 días                │
└─────────────────────────────────┘
```

## 🎯 Índices Optimizados

### Índices Simples
```sql
-- Búsqueda por vehículo
idx_ambutrack_documentacion_vehiculos_vehiculo_id

-- Búsqueda por tipo de documento
idx_ambutrack_documentacion_vehiculos_tipo_documento_id

-- Búsqueda por estado (vigente, proxima_vencer, vencida)
idx_ambutrack_documentacion_vehiculos_estado

-- Búsqueda por fecha de vencimiento
idx_ambutrack_documentacion_vehiculos_fecha_vencimiento

-- Búsqueda por número de póliza
idx_ambutrack_documentacion_vehiculos_numero_poliza

-- Búsqueda por compañía
idx_ambutrack_documentacion_vehiculos_compania
```

### Índice Compuesto (Alertas)
```sql
-- Para alertas de vencimiento (muy eficiente)
idx_ambutrack_documentacion_vehiculos_alertas_vencimiento
WHERE estado IN ('proxima_vencer', 'vencida')
```

## 🔍 Vistas Útiles

### vw_documentacion_proxima_vencer
```sql
-- Documentos próximos a vencer o vencidos
SELECT
    vehiculo_id,
    matricula,
    tipo_documento_nombre,
    numero_poliza,
    compania,
    fecha_vencimiento,
    dias_restantes,
    estado
FROM vw_documentacion_proxima_vencer
WHERE dias_restantes <= 30
ORDER BY fecha_vencimiento ASC;
```

### vw_documentacion_por_vehiculo
```sql
-- Resumen de documentación por vehículo
SELECT
    matricula,
    marca,
    modelo,
    total_documentos,
    documentos_vigentes,
    documentos_proximos_vencer,
    documentos_vencidos,
    proximo_vencimiento
FROM vw_documentacion_por_vehiculo
WHERE estado_vehiculo = 'activo'
ORDER BY matricula;
```

## 🛡️ Restricciones y Validaciones

### CHECK Constraints
```sql
-- Estado válido
CHECK (estado IN ('vigente', 'proxima_vencer', 'vencida'))

-- Categoría válida
CHECK (categoria IN ('seguro', 'tecnica', 'legal', 'administrativa', 'otra'))

-- Fecha de vencimiento posterior a emisión
CHECK (fecha_vencimiento >= fecha_emision)

-- Fecha próximo vencimiento posterior a vencimiento actual
CHECK (fecha_proximo_vencimiento IS NULL OR
        fecha_proximo_vencimiento > fecha_vencimiento)

-- Días de alerta no negativos
CHECK (dias_alerta >= 0)
```

### Foreign Keys
```sql
-- FK hacia tvehículos con eliminación en cascada
CONSTRAINT fk_documentacion_vehiculo
    FOREIGN KEY (vehiculo_id)
    REFERENCES tvehiculos(id)
    ON DELETE CASCADE

-- FK hacia tipos_documento con restricción
CONSTRAINT fk_documentacion_tipo
    FOREIGN KEY (tipo_documento_id)
    REFERENCES ambutrack_tipos_documento_vehiculo(id)
    ON DELETE RESTRICT
```

## 🔔 Sistema de Alertas

### Cálculo de Estado
```sql
-- Función calcular_estado_documento()
-- Se ejecuta automáticamente via TRIGGER

IF dias_restantes < 0 THEN
    estado = 'vencida'
ELSIF dias_restantes <= dias_alerta THEN
    estado = 'proxima_vencer'
ELSE
    estado = 'vigente'
END IF
```

### Días de Alerta por Defecto
- Seguros: 30 días
- ITV: 60 días
- Homologación: 90 días
- Permisos: 60-90 días
- Administrativos: 90-365 días

## 📈 Estadísticas y Consultas Útiles

### Documentos por vencer en los próximos 30 días
```sql
SELECT
    v.matricula,
    tdv.nombre AS tipo_documento,
    dv.numero_poliza,
    dv.fecha_vencimiento,
    calcular_dias_restantes(dv.fecha_vencimiento) AS dias_restantes
FROM ambutrack_documentacion_vehiculos dv
INNER JOIN tvehiculos v ON dv.vehiculo_id = v.id
INNER JOIN ambutrack_tipos_documento_vehiculo tdv ON dv.tipo_documento_id = tdv.id
WHERE dv.estado = 'proxima_vencer'
  AND v.estado = 'activo'
ORDER BY dv.fecha_vencimiento ASC;
```

### Documentos vencidos (urgente renovación)
```sql
SELECT
    v.matricula,
    tdv.nombre AS tipo_documento,
    dv.numero_poliza,
    dv.fecha_vencimiento,
    CURRENT_DATE - dv.fecha_vencimiento AS dias_vencido
FROM ambutrack_documentacion_vehiculos dv
INNER JOIN tvehiculos v ON dv.vehiculo_id = v.id
INNER JOIN ambutrack_tipos_documento_vehiculo tdv ON dv.tipo_documento_id = tdv.id
WHERE dv.estado = 'vencida'
  AND v.estado = 'activo'
ORDER BY dv.fecha_vencimiento ASC;
```

### Coste anual de seguros por vehículo
```sql
SELECT
    v.matricula,
    v.marca,
    v.modelo,
    COUNT(dv.id) AS total_seguros,
    COALESCE(SUM(dv.coste_anual), 0) AS coste_total_anual
FROM tvehiculos v
LEFT JOIN ambutrack_documentacion_vehiculos dv ON (
    dv.vehiculo_id = v.id
    AND dv.tipo_documento_id IN (
        SELECT id FROM ambutrack_tipos_documento_vehiculo
        WHERE categoria = 'seguro'
    )
)
WHERE v.estado = 'activo'
GROUP BY v.id, v.matricula, v.marca, v.modelo
ORDER BY coste_total_anual DESC;
```

---

**Fecha de creación**: 2025-02-15
**Versión**: 1.0
**Estado**: Completado ✅
