# Sistema de Generación Automática de Traslados

## 📋 Resumen

Sistema completo para generar traslados automáticamente para servicios únicos y recurrentes en AmbuTrack.

---

## 🏗️ Arquitectura de 3 Niveles

```
┌─────────────────────────────────────────────────────────┐
│ NIVEL 1: servicios                                      │
│ - Datos generales del servicio                          │
│ - tipo_recurrencia: 'unico' | 'diario' | 'semanal' ...  │
├─────────────────────────────────────────────────────────┤
│ NIVEL 2: servicios_recurrentes                          │
│ - Configuración de recurrencia                          │
│ - Solo se crea si tipo_recurrencia != 'unico'          │
│ - traslados_generados_hasta: DATE (tracking)            │
├─────────────────────────────────────────────────────────┤
│ NIVEL 3: traslados                                      │
│ - Instancias concretas de cada traslado                 │
│ - id_servicio (servicios únicos)                        │
│ - id_servicio_recurrente (servicios recurrentes)        │
│ - Mutuamente excluyentes (CHECK constraint)             │
└─────────────────────────────────────────────────────────┘
```

---

## ⚡ Triggers Automáticos

### 1. Trigger para Servicios Únicos

**Archivo**: `20250131_trigger_generar_traslados_servicio_unico.sql`

**Trigger**: `trigger_generar_traslados_unico`
**Tabla**: `servicios`
**Cuándo**: `AFTER INSERT` cuando `tipo_recurrencia = 'unico'`

**Funcionamiento**:
```sql
INSERT INTO servicios (tipo_recurrencia = 'unico', ...)
    ↓
Trigger genera automáticamente:
    - 1 traslado IDA (siempre)
    - 1 traslado VUELTA (si requiere_vuelta = true)
    ↓
Traslados vinculados a servicios.id directamente
```

**Características**:
- ✅ Se ejecuta una sola vez al crear el servicio
- ✅ NO requiere seguimiento posterior
- ✅ Usa campo `id_servicio` en traslados

---

### 2. Trigger para Servicios Recurrentes

**Archivo**: `20250131_fix_trigger_servicios_recurrentes.sql`

**Trigger**: `trigger_generar_traslados_servicio_rec`
**Tabla**: `servicios_recurrentes`
**Cuándo**: `AFTER INSERT`

**Funcionamiento**:
```sql
INSERT INTO servicios_recurrentes (tipo_recurrencia = 'diario', ...)
    ↓
Trigger genera automáticamente:
    - Primeros 14 DÍAS de traslados
    - 1 traslado IDA por día válido
    - 1 traslado VUELTA por día válido (si requiere_vuelta = true)
    ↓
Actualiza: traslados_generados_hasta = fecha_inicio + 14 días
```

**Tipos de recurrencia soportados**:
- `diario`: Todos los días
- `semanal`: Días específicos de la semana (ej: Lunes, Miércoles, Viernes)
- `semanas_alternas`: Cada N semanas en días específicos
- `dias_alternos`: Cada N días
- `mensual`: Días específicos del mes
- `especifico`: Fechas concretas listadas

**Características**:
- ✅ Solo genera **14 días** (no 30)
- ✅ Usa campo `id_servicio_recurrente` en traslados
- ✅ Actualiza `traslados_generados_hasta` para tracking

---

## 🔄 Función de Generación Continua

**Archivo**: `20250131_function_generar_proximos_lotes.sql`

**Función**: `generar_traslados_proximos_lotes()`

**Lógica**:
```sql
FOR cada servicio_recurrente activo:
    IF traslados_generados_hasta <= (HOY + 7 días) THEN
        -- Generar próximos 14 días
        fecha_desde = traslados_generados_hasta + 1 día
        fecha_hasta = fecha_desde + 13 días  -- Total: 14 días

        -- Generar traslados sin duplicar
        INSERT INTO traslados (...)
        ON CONFLICT DO NOTHING

        -- Actualizar tracking
        UPDATE servicios_recurrentes
        SET traslados_generados_hasta = fecha_hasta
```

**Características**:
- ✅ **NO duplica traslados** existentes
- ✅ Genera desde `traslados_generados_hasta + 1` día
- ✅ Genera exactamente **14 días nuevos**
- ✅ Se ejecuta solo cuando quedan menos de 7 días de traslados
- ✅ Actualiza `traslados_generados_hasta` al último día generado

**Retorna**:
```json
{
  "servicios_procesados": 5,
  "traslados_generados": 140,
  "servicios_actualizados": [
    "SRV-123 (28 traslados hasta 2025-02-14)",
    "SRV-124 (28 traslados hasta 2025-02-14)"
  ]
}
```

---

## ⏰ Cron Job Automático

**Archivo**: `20250131_setup_cron_generar_traslados.sql`

**Extensión**: `pg_cron`
**Job**: `generar-traslados-diarios`
**Schedule**: `0 1 * * *` (01:00 AM todos los días)

**Comando SQL**:
```sql
SELECT cron.schedule(
  'generar-traslados-diarios',
  '0 1 * * *',
  $$
  SELECT * FROM generar_traslados_proximos_lotes();
  $$
);
```

**Funcionamiento**:
- 🕐 Se ejecuta automáticamente cada día a la 01:00 AM
- 📋 Llama a `generar_traslados_proximos_lotes()`
- 📊 Procesa todos los servicios recurrentes que lo necesiten
- 🔄 Mantiene siempre 7-21 días de traslados generados por adelantado

---

## 🧪 Testing y Verificación

### Verificar Cron Job Activo

```sql
-- Ver el cron job configurado
SELECT * FROM cron.job
WHERE jobname = 'generar-traslados-diarios';
```

### Ver Historial de Ejecuciones

```sql
-- Últimas 10 ejecuciones
SELECT
  start_time,
  end_time,
  status,
  return_message
FROM cron.job_run_details
WHERE jobid = (
  SELECT jobid FROM cron.job
  WHERE jobname = 'generar-traslados-diarios'
)
ORDER BY start_time DESC
LIMIT 10;
```

### Ejecutar Manualmente (Testing)

```sql
-- Ejecutar función de test
SELECT * FROM test_generar_proximos_lotes();

-- Resultado esperado:
--  servicios_procesados | traslados_generados | servicios_actualizados
-- ----------------------+---------------------+------------------------
--                     5 |                 140 | {SRV-123 (28 tras...}
```

### Verificar Traslados Generados

```sql
-- Ver traslados de un servicio recurrente
SELECT
  t.codigo,
  t.tipo_traslado,
  t.fecha,
  t.hora_programada,
  t.generado_automaticamente
FROM traslados t
WHERE t.id_servicio_recurrente = 'UUID_DEL_SERVICIO'
ORDER BY t.fecha, t.tipo_traslado;
```

---

## 📊 Ejemplo de Flujo Completo

### Día 1 (2025-01-31): Crear Servicio Diario

```sql
-- Usuario crea servicio desde wizard
INSERT INTO servicios (
  tipo_recurrencia = 'diario',
  fecha_servicio_inicio = '2025-01-31',
  requiere_vuelta = true,
  ...
);
    ↓
INSERT INTO servicios_recurrentes (...);
    ↓
-- Trigger genera automáticamente:
-- 2025-01-31: IDA + VUELTA
-- 2025-02-01: IDA + VUELTA
-- 2025-02-02: IDA + VUELTA
-- ...
-- 2025-02-13: IDA + VUELTA (14 días × 2 traslados = 28 traslados)
    ↓
traslados_generados_hasta = 2025-02-13
```

### Día 7 (2025-02-06): Ejecución Automática

```sql
-- Cron job ejecuta a las 01:00 AM
SELECT * FROM generar_traslados_proximos_lotes();
    ↓
-- Detecta: traslados_generados_hasta (2025-02-13) <= HOY (2025-02-06) + 7 días
-- Quedan solo 7 días de traslados → GENERA MÁS
    ↓
-- Genera desde 2025-02-14 hasta 2025-02-27 (14 días nuevos)
-- 2025-02-14: IDA + VUELTA
-- 2025-02-15: IDA + VUELTA
-- ...
-- 2025-02-27: IDA + VUELTA (14 días × 2 traslados = 28 traslados nuevos)
    ↓
traslados_generados_hasta = 2025-02-27
```

### Día 14 (2025-02-13): Segunda Ejecución

```sql
-- Cron job ejecuta a las 01:00 AM
SELECT * FROM generar_traslados_proximos_lotes();
    ↓
-- Detecta: traslados_generados_hasta (2025-02-27) <= HOY (2025-02-13) + 7 días
-- Quedan 14 días → NO GENERA (todavía hay suficientes)
    ↓
-- No hace nada, espera hasta el día 21
```

### Día 21 (2025-02-20): Tercera Ejecución

```sql
-- Cron job ejecuta a las 01:00 AM
SELECT * FROM generar_traslados_proximos_lotes();
    ↓
-- Detecta: traslados_generados_hasta (2025-02-27) <= HOY (2025-02-20) + 7 días
-- Quedan solo 7 días → GENERA MÁS
    ↓
-- Genera desde 2025-02-28 hasta 2025-03-13 (14 días nuevos)
    ↓
traslados_generados_hasta = 2025-03-13
```

**Resultado**: El sistema mantiene automáticamente entre 7 y 21 días de traslados generados por adelantado.

---

## 🔍 Solución de Problemas

### Problema: No se generan traslados al crear servicio recurrente

**Verificar**:
1. ¿El trigger está activo?
```sql
SELECT tgname, tgenabled
FROM pg_trigger
WHERE tgrelid = 'servicios_recurrentes'::regclass;
```

2. ¿Hay errores en logs de PostgreSQL?
```sql
-- Ver logs recientes en Supabase Dashboard → Logs
```

### Problema: Cron job no se ejecuta

**Verificar**:
1. ¿La extensión pg_cron está habilitada?
```sql
SELECT * FROM pg_extension WHERE extname = 'pg_cron';
```

2. ¿El job está programado?
```sql
SELECT * FROM cron.job WHERE jobname = 'generar-traslados-diarios';
```

3. ¿Hay errores en las ejecuciones?
```sql
SELECT * FROM cron.job_run_details
WHERE status = 'failed'
ORDER BY start_time DESC;
```

### Problema: Se duplican traslados

**Causa**: Constraint `uk_traslado_unico` evita duplicados con `ON CONFLICT DO NOTHING`.

**Verificar constraint**:
```sql
SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'traslados'::regclass
  AND conname = 'uk_traslado_unico';
```

---

## 📚 Archivos Relacionados

### Migraciones SQL
- `20250131_trigger_generar_traslados_servicio_unico.sql` - Trigger servicios únicos
- `20250131_add_id_servicio_to_traslados.sql` - Schema traslados
- `20250131_fix_trigger_servicios_recurrentes.sql` - Trigger servicios recurrentes (14 días)
- `20250131_fix_trigger_14_dias.sql` - Ajuste a 14 días
- `20250131_function_generar_proximos_lotes.sql` - Función de generación continua
- `20250131_fix_generar_proximos_lotes_no_duplicar.sql` - Fix sin duplicados
- `20250131_setup_cron_generar_traslados.sql` - Configuración cron job

### Edge Functions (opcional)
- `supabase/functions/generar-traslados-diarios/index.ts` - Edge function alternativa

### Código Flutter
- `lib/features/servicios/servicios/presentation/formulario/servicio_form_wizard_dialog.dart` - Wizard creación servicios

---

## ✅ Checklist de Implementación

- [x] Trigger para servicios únicos
- [x] Trigger para servicios recurrentes (14 días)
- [x] Función `generar_traslados_proximos_lotes()`
- [x] Fix para evitar duplicados
- [x] Cron job automático (01:00 AM diaria)
- [x] Constraint `uk_traslado_unico` (4 columnas)
- [x] CHECK constraint mutually exclusive
- [x] Índices en `id_servicio` y `id_servicio_recurrente`
- [x] Documentación completa
- [x] Funciones de testing

---

## 🚀 Próximos Pasos

1. **Probar creación de servicio recurrente** desde wizard
2. **Verificar generación de 14 días** iniciales
3. **Ejecutar manualmente** `test_generar_proximos_lotes()`
4. **Monitorear ejecuciones** del cron job en producción
5. **Crear dashboard** para visualizar traslados generados por servicio

---

**Fecha de creación**: 2025-01-31
**Autor**: Sistema AmbuTrack
**Versión**: 1.0
