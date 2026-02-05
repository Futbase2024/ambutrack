# 🏗️ Arquitectura del Sistema de Servicios

## 📊 Modelo de Datos de 3 Niveles

El sistema de gestión de servicios de AmbuTrack utiliza una arquitectura de **3 niveles jerárquicos**:

```
┌─────────────────────────────────────────────────────────────┐
│ NIVEL 1: SERVICIOS (Cabecera)                              │
│ Tabla: servicios                                            │
│ - Información general del servicio                          │
│ - Datos del contrato/facturación                            │
│ - Estado global del servicio                                │
└─────────────────────────────────────────────────────────────┘
                           ↓
                          1:N
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ NIVEL 2: SERVICIOS RECURRENTES (Configuración)             │
│ Tabla: servicios_recurrentes                                │
│ - Configuración de recurrencia (único, diario, semanal...)  │
│ - Días y horarios                                           │
│ - Trayectos y paradas                                       │
│ - Período de vigencia                                       │
└─────────────────────────────────────────────────────────────┘
                           ↓
                          1:N
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ NIVEL 3: TRASLADOS (Instancias)                            │
│ Tabla: traslados                                            │
│ - Traslado concreto para una fecha específica              │
│ - Asignación de recursos (conductor, vehículo, personal)   │
│ - Tracking de estados y cronas                              │
│ - Facturación individual                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔗 Relaciones Entre Tablas

### 1️⃣ **servicios** → 2️⃣ **servicios_recurrentes** (1:N)

Un **servicio** puede tener **múltiples configuraciones de recurrencia**.

**Ejemplo real:**
```sql
-- Servicio: "Diálisis Hospital A"
INSERT INTO servicios (id, codigo, nombre) VALUES
  ('uuid-1', 'SRV-001', 'Diálisis Hospital A');

-- Configuraciones de recurrencia:
-- 1. Lunes, Miércoles, Viernes (ida y vuelta)
INSERT INTO servicios_recurrentes (id_servicio, tipo_recurrencia, dias_semana, requiere_vuelta) VALUES
  ('uuid-1', 'semanal', ARRAY[1, 3, 5], true);

-- 2. Martes (solo ida, urgente)
INSERT INTO servicios_recurrentes (id_servicio, tipo_recurrencia, dias_semana, requiere_vuelta) VALUES
  ('uuid-1', 'semanal', ARRAY[2], false);
```

**Campos FK:**
```sql
servicios_recurrentes.id_servicio → servicios.id (ON DELETE CASCADE)
```

---

### 2️⃣ **servicios_recurrentes** → 3️⃣ **traslados** (1:N)

Una **configuración de recurrencia** genera **múltiples traslados** automáticamente.

**Ejemplo real:**
```sql
-- Servicio recurrente: Lunes, Miércoles, Viernes (3 días/semana)
INSERT INTO servicios_recurrentes (
  id, codigo, tipo_recurrencia, dias_semana,
  fecha_servicio_inicio, hora_recogida, requiere_vuelta
) VALUES (
  'uuid-rec-1', 'SRV-REC-001', 'semanal', ARRAY[1, 3, 5],
  '2025-01-01', '08:00', true
);

-- ⚡ TRIGGER AUTOMÁTICO genera traslados:
--
-- Lunes 06/01/2025:
--   - TRS-20250106-0001-I (ida, 08:00)
--   - TRS-20250106-0001-V (vuelta, 12:00)
--
-- Miércoles 08/01/2025:
--   - TRS-20250108-0002-I (ida, 08:00)
--   - TRS-20250108-0002-V (vuelta, 12:00)
--
-- Viernes 10/01/2025:
--   - TRS-20250110-0003-I (ida, 08:00)
--   - TRS-20250110-0003-V (vuelta, 12:00)
```

**Campos FK:**
```sql
traslados.id_servicio_recurrente → servicios_recurrentes.id (ON DELETE CASCADE)
```

---

## 📋 Tipos de Recurrencia Soportados

| Tipo | Descripción | Parámetros Requeridos | Ejemplo |
|------|-------------|----------------------|---------|
| `unico` | Servicio de una sola vez | - | Cita médica puntual |
| `diario` | Todos los días | - | Tratamiento diario |
| `semanal` | Días específicos de la semana | `dias_semana` | Lunes, Miércoles, Viernes |
| `semanas_alternas` | Cada N semanas | `dias_semana`, `intervalo_semanas` | Cada 2 semanas los Martes |
| `dias_alternos` | Cada N días | `intervalo_dias` | Cada 3 días |
| `mensual` | Días del mes específicos | `dias_mes` | Día 1 y 15 de cada mes |
| `especifico` | Fechas exactas | `fechas_especificas` | 10/01, 15/03, 20/06 |

---

## ⚡ Generación Automática de Traslados

### Trigger: `generar_traslados_al_crear_servicio_recurrente`

**Se ejecuta:** Al insertar un registro en `servicios_recurrentes`

**Acción:**
1. Lee la configuración de recurrencia
2. Calcula las fechas que aplican (según tipo_recurrencia)
3. Genera traslados para los próximos **30 días** (o hasta `fecha_servicio_fin` si es menor)
4. Crea traslados de **ida** (siempre)
5. Crea traslados de **vuelta** (solo si `requiere_vuelta = true`)
6. Evita duplicados con `ON CONFLICT DO NOTHING`
7. Actualiza `traslados_generados_hasta`

**Job Nocturno:** Un cron job ejecuta `generar_traslados_periodo()` cada noche para mantener traslados generados con 30 días de anticipación.

---

## 🎯 Casos de Uso

### Caso 1: Servicio Único (Cita Médica Puntual)

```sql
-- Paso 1: Crear servicio
INSERT INTO servicios (codigo, nombre) VALUES ('SRV-001', 'Cita Traumatología');

-- Paso 2: Crear configuración de recurrencia (tipo único)
INSERT INTO servicios_recurrentes (
  id_servicio, id_paciente, tipo_recurrencia,
  fecha_servicio_inicio, hora_recogida, requiere_vuelta, trayectos
) VALUES (
  'uuid-srv-1', 'uuid-paciente-1', 'unico',
  '2025-02-15', '09:00', true, '[{"orden": 1, "tipo": "domicilio"...}]'::jsonb
);

-- Paso 3: El trigger genera automáticamente:
--   - TRS-20250215-0001-I (ida, 09:00)
--   - TRS-20250215-0001-V (vuelta, 12:00)
```

### Caso 2: Servicio Recurrente Semanal (Diálisis)

```sql
-- Paso 1: Crear servicio
INSERT INTO servicios (codigo, nombre) VALUES ('SRV-002', 'Diálisis Hospital Clínico');

-- Paso 2: Crear configuración de recurrencia (lunes, miércoles, viernes)
INSERT INTO servicios_recurrentes (
  id_servicio, id_paciente, tipo_recurrencia, dias_semana,
  fecha_servicio_inicio, fecha_servicio_fin,
  hora_recogida, hora_vuelta, requiere_vuelta, trayectos
) VALUES (
  'uuid-srv-2', 'uuid-paciente-2', 'semanal', ARRAY[1, 3, 5],
  '2025-01-06', '2025-12-31',
  '07:30', '12:00', true, '[{...}]'::jsonb
);

-- Paso 3: El trigger genera automáticamente traslados para:
--   - Todos los lunes, miércoles y viernes entre 06/01/2025 y 05/02/2025 (30 días)
--   - Cada traslado tiene ida (07:30) y vuelta (12:00)
```

### Caso 3: Servicio Cada 2 Semanas

```sql
-- Paso 1: Crear servicio
INSERT INTO servicios (codigo, nombre) VALUES ('SRV-003', 'Rehabilitación');

-- Paso 2: Crear configuración de recurrencia (cada 2 semanas, martes y jueves)
INSERT INTO servicios_recurrentes (
  id_servicio, id_paciente, tipo_recurrencia,
  dias_semana, intervalo_semanas,
  fecha_servicio_inicio, hora_recogida, requiere_vuelta, trayectos
) VALUES (
  'uuid-srv-3', 'uuid-paciente-3', 'semanas_alternas',
  ARRAY[2, 4], 2,
  '2025-01-07', '10:00', false, '[{...}]'::jsonb
);

-- Paso 3: El trigger genera traslados para:
--   - Semana 1: Martes 07/01 y Jueves 09/01
--   - Semana 2: (nada)
--   - Semana 3: Martes 21/01 y Jueves 23/01
--   - Semana 4: (nada)
--   - ...
```

---

## 🗂️ Migraciones SQL

Las migraciones se encuentran en `supabase/migrations/`:

| Archivo | Descripción |
|---------|-------------|
| `20250130_001_create_servicios_table.sql` | Crea tabla `servicios` (cabecera) |
| `20250130_006_create_servicios_recurrentes_table.sql` | Crea tabla `servicios_recurrentes` (configuración) |
| `20250130_002_create_traslados_table.sql` | Crea tabla `traslados` (instancias) |
| `20250130_007_alter_traslados_fk_servicios_recurrentes.sql` | Cambia FK de traslados a servicios_recurrentes |
| `20250130_008_update_trigger_generar_traslados.sql` | Trigger de generación automática |
| `20250130_003_function_generar_traslados.sql` | Función para job nocturno |
| `20250130_004_function_cambiar_estado_traslado.sql` | Función para cambio de estados |
| `20250130_005_setup_cron_jobs.sql` | Configuración de jobs automáticos |

---

## 🔍 Consultas Útiles

### Ver servicios con sus configuraciones de recurrencia

```sql
SELECT
  s.codigo AS servicio,
  sr.codigo AS configuracion,
  sr.tipo_recurrencia,
  sr.fecha_servicio_inicio,
  sr.fecha_servicio_fin,
  COUNT(t.id) AS traslados_generados
FROM servicios s
JOIN servicios_recurrentes sr ON sr.id_servicio = s.id
LEFT JOIN traslados t ON t.id_servicio_recurrente = sr.id
GROUP BY s.codigo, sr.codigo, sr.tipo_recurrencia, sr.fecha_servicio_inicio, sr.fecha_servicio_fin
ORDER BY s.codigo;
```

### Ver traslados pendientes de asignación

```sql
SELECT
  t.codigo,
  t.fecha,
  t.hora_programada,
  t.tipo_traslado,
  p.nombre AS paciente,
  sr.tipo_recurrencia
FROM traslados t
JOIN servicios_recurrentes sr ON sr.id = t.id_servicio_recurrente
JOIN pacientes p ON p.id = t.id_paciente
WHERE t.estado = 'pendiente'
  AND t.id_vehiculo IS NULL
ORDER BY t.fecha, t.hora_programada;
```

### Verificar traslados generados hoy

```sql
SELECT
  sr.codigo AS servicio_recurrente,
  t.codigo AS traslado,
  t.fecha,
  t.tipo_traslado,
  t.estado
FROM traslados t
JOIN servicios_recurrentes sr ON sr.id = t.id_servicio_recurrente
WHERE t.created_at::date = CURRENT_DATE
ORDER BY t.created_at DESC;
```

---

## 📚 Referencias

- **Entidades del Core:** `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/entities/`
- **DataSource Supabase:** `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/implementations/supabase/`
- **Wizard de Creación:** `lib/features/servicios/servicios/presentation/widgets/servicio_form_wizard_dialog.dart`

---

## ✅ Checklist de Implementación

- [x] Migración SQL: `servicios`
- [x] Migración SQL: `servicios_recurrentes`
- [x] Migración SQL: `traslados`
- [x] Migración SQL: FK correctas
- [x] Migración SQL: Trigger generación automática
- [x] Entity: `ServicioRecurrenteEntity`
- [x] Model: `ServicioRecurrenteSupabaseModel`
- [x] DataSource: `SupabaseServicioRecurrenteDataSource`
- [x] Repository: `ServicioRecurrenteRepository`
- [ ] Wizard: Crear servicio completo (servicios + servicios_recurrentes)
- [ ] Dashboard: Vista de traslados generados
- [ ] Testing: Generación de traslados para todos los tipos de recurrencia
