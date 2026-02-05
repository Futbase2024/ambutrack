# 🚀 Migraciones Pendientes - Sistema de Servicios

## 📋 Estado Actual

La tabla `servicios_recurrentes` **YA EXISTE** en Supabase, pero fue creada manualmente sin migración formal.

## ✅ Migraciones a Ejecutar en Orden

### 1️⃣ Verificar Estructura de `servicios_recurrentes`

**Acción:** Comprobar que la tabla existente tiene todos los campos necesarios.

**SQL de verificación:**
```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'servicios_recurrentes'
ORDER BY ordinal_position;
```

**Campos esperados:**
- `id` (uuid, PK)
- `codigo` (varchar, unique)
- `id_servicio` (uuid, FK → servicios) ⚠️ **CRÍTICO**
- `id_paciente` (uuid, FK → pacientes)
- `tipo_recurrencia` (text)
- `dias_semana` (integer[])
- `intervalo_semanas` (integer)
- `intervalo_dias` (integer)
- `dias_mes` (integer[])
- `fechas_especificas` (date[])
- `fecha_servicio_inicio` (date)
- `fecha_servicio_fin` (date)
- `hora_recogida` (time)
- `hora_vuelta` (time)
- `requiere_vuelta` (boolean)
- `trayectos` (jsonb)
- `observaciones` (text)
- `traslados_generados_hasta` (date)
- `activo` (boolean)
- `created_at` (timestamp)
- `updated_at` (timestamp)
- `created_by` (uuid, FK → personal)
- `updated_by` (uuid, FK → personal)

---

### 2️⃣ Si falta `id_servicio`, ejecutar ALTER TABLE

**Archivo:** `20250130_006_add_id_servicio_to_servicios_recurrentes.sql`

```sql
-- Agregar FK hacia servicios si no existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'servicios_recurrentes' AND column_name = 'id_servicio'
  ) THEN
    ALTER TABLE servicios_recurrentes
    ADD COLUMN id_servicio UUID REFERENCES servicios(id) ON DELETE CASCADE;

    CREATE INDEX idx_servicios_rec_servicio ON servicios_recurrentes(id_servicio);

    COMMENT ON COLUMN servicios_recurrentes.id_servicio IS 'FK hacia servicios (tabla cabecera/padre)';
  END IF;
END $$;
```

---

### 3️⃣ Actualizar FK de `traslados`

**Archivo:** `20250130_007_alter_traslados_fk_servicios_recurrentes.sql`

**⚠️ IMPORTANTE:** Esta migración cambia la FK de `traslados` para que apunte a `servicios_recurrentes` en lugar de `servicios`.

```sql
-- PASO 1: Verificar si la columna actual es id_servicio o id_servicio_recurrente
DO $$
DECLARE
  v_column_exists BOOLEAN;
BEGIN
  -- Verificar si existe id_servicio
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'traslados' AND column_name = 'id_servicio'
  ) INTO v_column_exists;

  IF v_column_exists THEN
    -- La columna se llama id_servicio, necesitamos cambiarla

    -- Eliminar constraint FK existente
    ALTER TABLE traslados DROP CONSTRAINT IF EXISTS traslados_id_servicio_fkey;

    -- Renombrar columna
    ALTER TABLE traslados RENAME COLUMN id_servicio TO id_servicio_recurrente;

    -- Crear nueva FK hacia servicios_recurrentes
    ALTER TABLE traslados
    ADD CONSTRAINT traslados_id_servicio_recurrente_fkey
    FOREIGN KEY (id_servicio_recurrente) REFERENCES servicios_recurrentes(id) ON DELETE CASCADE;

    -- Recrear índice
    DROP INDEX IF EXISTS idx_traslados_servicio;
    CREATE INDEX idx_traslados_servicio_recurrente ON traslados(id_servicio_recurrente);

    -- Actualizar constraint único
    ALTER TABLE traslados DROP CONSTRAINT IF EXISTS uk_traslado_servicio_fecha_tipo;
    ALTER TABLE traslados ADD CONSTRAINT uk_traslado_servicio_rec_fecha_tipo
      UNIQUE(id_servicio_recurrente, fecha, tipo_traslado);

    -- Comentario
    COMMENT ON COLUMN traslados.id_servicio_recurrente IS 'FK hacia servicios_recurrentes (configuración de recurrencia del servicio)';

    RAISE NOTICE 'FK actualizada: traslados.id_servicio → traslados.id_servicio_recurrente → servicios_recurrentes(id)';
  ELSE
    RAISE NOTICE 'La columna ya se llama id_servicio_recurrente, no es necesario cambiarla';
  END IF;
END $$;

-- Refrescar schema cache
NOTIFY pgrst, 'reload schema';
```

---

### 4️⃣ Crear Trigger de Generación Automática

**Archivo:** `20250130_008_update_trigger_generar_traslados.sql`

Este trigger se ejecuta al insertar en `servicios_recurrentes` y genera automáticamente los traslados.

**Ver archivo completo:** `supabase/migrations/20250130_008_update_trigger_generar_traslados.sql`

---

## 🔍 Verificaciones Post-Migración

### Verificar FK de `servicios_recurrentes`

```sql
SELECT
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'servicios_recurrentes' AND tc.constraint_type = 'FOREIGN KEY';
```

**Resultado esperado:**
```
constraint_name                              | column_name  | foreign_table_name | foreign_column_name
---------------------------------------------|--------------|--------------------|---------------------
servicios_recurrentes_id_servicio_fkey       | id_servicio  | servicios          | id
servicios_recurrentes_id_paciente_fkey       | id_paciente  | pacientes          | id
servicios_recurrentes_created_by_fkey        | created_by   | personal           | id
servicios_recurrentes_updated_by_fkey        | updated_by   | personal           | id
```

### Verificar FK de `traslados`

```sql
SELECT
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'traslados' AND tc.constraint_type = 'FOREIGN KEY'
  AND kcu.column_name LIKE '%servicio%';
```

**Resultado esperado:**
```
constraint_name                              | column_name              | foreign_table_name      | foreign_column_name
---------------------------------------------|--------------------------|------------------------|---------------------
traslados_id_servicio_recurrente_fkey        | id_servicio_recurrente   | servicios_recurrentes  | id
```

### Verificar Trigger

```sql
SELECT
  tgname AS trigger_name,
  tgenabled AS enabled,
  proname AS function_name
FROM pg_trigger
JOIN pg_proc ON pg_proc.oid = pg_trigger.tgfoid
WHERE tgrelid = 'servicios_recurrentes'::regclass
  AND tgname LIKE '%generar_traslados%';
```

**Resultado esperado:**
```
trigger_name                              | enabled | function_name
------------------------------------------|---------|------------------------------------------
trigger_generar_traslados_servicio_rec    | O       | generar_traslados_al_crear_servicio_recurrente
```

---

## 📊 Probar Generación de Traslados

```sql
-- Insertar un servicio recurrente de prueba (semanal: lunes, miércoles, viernes)
INSERT INTO servicios_recurrentes (
  id_servicio,
  id_paciente,
  tipo_recurrencia,
  dias_semana,
  fecha_servicio_inicio,
  fecha_servicio_fin,
  hora_recogida,
  hora_vuelta,
  requiere_vuelta,
  trayectos
) VALUES (
  (SELECT id FROM servicios LIMIT 1), -- Usar un servicio existente
  (SELECT id FROM pacientes LIMIT 1), -- Usar un paciente existente
  'semanal',
  ARRAY[1, 3, 5], -- Lunes, Miércoles, Viernes
  CURRENT_DATE,
  CURRENT_DATE + INTERVAL '30 days',
  '08:00',
  '12:00',
  true,
  '[{"orden": 1, "tipo": "domicilio"}]'::jsonb
);

-- Verificar traslados generados
SELECT
  codigo,
  fecha,
  tipo_traslado,
  hora_programada,
  estado
FROM traslados
WHERE id_servicio_recurrente = (
  SELECT id FROM servicios_recurrentes ORDER BY created_at DESC LIMIT 1
)
ORDER BY fecha, tipo_traslado;
```

**Resultado esperado:** Debe haber traslados para cada lunes, miércoles y viernes de los próximos 30 días, con ida (08:00) y vuelta (12:00).

---

## ⚠️ NOTAS IMPORTANTES

1. **Backup antes de migrar:** Hacer snapshot de la base de datos antes de ejecutar migraciones
2. **Migración 3️⃣ cambia FK:** La migración que cambia `traslados.id_servicio` → `id_servicio_recurrente` es **destructiva** si ya existen traslados apuntando a `servicios`
3. **Migrar datos existentes:** Si hay traslados existentes, necesitas crear registros en `servicios_recurrentes` primero y actualizar las FK manualmente
4. **Testing:** Probar en entorno de desarrollo antes de aplicar en producción

---

## 📚 Documentación Relacionada

- **Arquitectura completa:** `docs/servicios/ARQUITECTURA_SERVICIOS.md`
- **Entity:** `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/entities/`
- **DataSource:** `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/implementations/supabase/`
