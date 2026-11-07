# 🔧 Solución Final - Notificaciones Profesionales AmbuTrack Mobile

## ❌ Problema Raíz Identificado

Las notificaciones seguían mostrando el formato técnico antiguo:
```
Se te ha asignado el servicio #TRS-20260210-1AG1020H | CALLE AS DE GUÍA, 21...
```

**Causa raíz**: Los triggers en Supabase intentaban acceder a un campo **`paciente_nombre`** que **NO EXISTE** en la tabla `traslados`.

### Investigación Realizada

1. **Estructura de la tabla `traslados`**:
   - ❌ NO tiene campo `paciente_nombre` (desnormalizado)
   - ✅ SÍ tiene campo `id_paciente` (UUID)
   - ✅ SÍ tiene campos `origen` y `destino` (TEXT)
   - ✅ SÍ tiene campo `hora_programada` (TIME)

2. **Estructura de la tabla `pacientes`**:
   - ✅ `nombre` (VARCHAR)
   - ✅ `primer_apellido` (VARCHAR)
   - ✅ `segundo_apellido` (VARCHAR)

---

## ✅ Solución Implementada

Se actualizaron las funciones de trigger para hacer **JOIN con la tabla `pacientes`** y obtener el nombre completo.

### Cambios en `notificar_traslado_asignado()`

#### Antes (INCORRECTO):
```sql
-- ❌ Intentaba acceder a campo inexistente
v_paciente_nombre := COALESCE(NEW.paciente_nombre, 'Paciente no especificado');
```

#### Ahora (CORRECTO):
```sql
-- ✅ JOIN con tabla pacientes
SELECT CONCAT_WS(' ', p.nombre, p.primer_apellido, p.segundo_apellido)
INTO v_paciente_nombre
FROM pacientes p
WHERE p.id = NEW.id_paciente;

v_paciente_nombre := COALESCE(v_paciente_nombre, 'Paciente no especificado');
```

### Formato de Hora Corregido

#### Antes (INCORRECTO):
```sql
-- ❌ SUBSTRING no funciona bien con tipo TIME
v_hora_programada := SUBSTRING(NEW.hora_programada FROM 1 FOR 5);
```

#### Ahora (CORRECTO):
```sql
-- ✅ TO_CHAR para formatear TIME correctamente
v_hora_programada := TO_CHAR(NEW.hora_programada, 'HH24:MI');
```

---

## 📊 Resultado Final

### Notificación de Asignación
```
Título: Nuevo Traslado Asignado
Mensaje: Paciente: JUAN GARCÍA LÓPEZ | Hospital Central → Domicilio Calle Mayor 123 | Hora: 09:30
```

### Notificación de Desasignación
```
Título: Traslado Desasignado
Mensaje: Traslado desasignado | Paciente: JUAN GARCÍA LÓPEZ | Hospital Central → Domicilio Calle Mayor 123 | Hora: 09:30
```

---

## 🗄️ Funciones Actualizadas en Supabase

### 1. `notificar_traslado_asignado()`

```sql
CREATE OR REPLACE FUNCTION notificar_traslado_asignado()
RETURNS TRIGGER AS $$
DECLARE
    v_paciente_nombre TEXT;
    v_origen TEXT;
    v_destino TEXT;
    v_hora_programada TEXT;
    v_mensaje_profesional TEXT;
    -- ... otros campos
BEGIN
    -- ✅ JOIN con tabla pacientes
    SELECT CONCAT_WS(' ', p.nombre, p.primer_apellido, p.segundo_apellido)
    INTO v_paciente_nombre
    FROM pacientes p
    WHERE p.id = NEW.id_paciente;

    v_paciente_nombre := COALESCE(v_paciente_nombre, 'Paciente no especificado');

    -- ✅ Origen y destino desde campos TEXT existentes
    v_origen := COALESCE(
        CASE
            WHEN NEW.origen IS NOT NULL AND LENGTH(TRIM(NEW.origen)) > 0
            THEN NEW.origen
            ELSE 'Origen no especificado'
        END
    );

    v_destino := COALESCE(
        CASE
            WHEN NEW.destino IS NOT NULL AND LENGTH(TRIM(NEW.destino)) > 0
            THEN NEW.destino
            ELSE 'Destino no especificado'
        END
    );

    -- ✅ Formatear hora con TO_CHAR
    v_hora_programada := COALESCE(
        TO_CHAR(NEW.hora_programada, 'HH24:MI'),
        'Hora no especificada'
    );

    -- ✅ Construir mensaje profesional
    v_mensaje_profesional :=
        'Paciente: ' || v_paciente_nombre ||
        ' | ' || v_origen || ' → ' || v_destino ||
        ' | Hora: ' || v_hora_programada;

    -- ... resto de la lógica de notificación
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 2. `notificar_traslado_desadjudicado()`

```sql
CREATE OR REPLACE FUNCTION notificar_traslado_desadjudicado()
RETURNS TRIGGER AS $$
DECLARE
    v_paciente_nombre TEXT;
    v_origen TEXT;
    v_destino TEXT;
    v_hora_programada TEXT;
    v_mensaje_profesional TEXT;
    -- ... otros campos
BEGIN
    -- ✅ JOIN con tabla pacientes (usando OLD)
    SELECT CONCAT_WS(' ', p.nombre, p.primer_apellido, p.segundo_apellido)
    INTO v_paciente_nombre
    FROM pacientes p
    WHERE p.id = OLD.id_paciente;

    v_paciente_nombre := COALESCE(v_paciente_nombre, 'Paciente no especificado');

    -- ✅ Origen y destino desde OLD
    v_origen := COALESCE(
        CASE
            WHEN OLD.origen IS NOT NULL AND LENGTH(TRIM(OLD.origen)) > 0
            THEN OLD.origen
            ELSE 'Origen no especificado'
        END
    );

    v_destino := COALESCE(
        CASE
            WHEN OLD.destino IS NOT NULL AND LENGTH(TRIM(OLD.destino)) > 0
            THEN OLD.destino
            ELSE 'Destino no especificado'
        END
    );

    -- ✅ Formatear hora con TO_CHAR
    v_hora_programada := COALESCE(
        TO_CHAR(OLD.hora_programada, 'HH24:MI'),
        'Hora no especificada'
    );

    -- ✅ Mensaje profesional para desasignación
    v_mensaje_profesional :=
        'Traslado desasignado | Paciente: ' || v_paciente_nombre ||
        ' | ' || v_origen || ' → ' || v_destino ||
        ' | Hora: ' || v_hora_programada;

    -- ... resto de la lógica de notificación
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 🔍 Verificación de Triggers

Los triggers están correctamente configurados en la tabla `traslados`:

```sql
-- Verificar triggers existentes
SELECT
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_table = 'traslados'
  AND trigger_name LIKE '%notificar%';
```

**Resultado:**
| Trigger | Evento | Timing | Función |
|---------|--------|--------|---------|
| `trigger_notificar_traslado_asignado_insert` | INSERT | AFTER | `notificar_traslado_asignado()` |
| `trigger_notificar_traslado_asignado_update` | UPDATE | AFTER | `notificar_traslado_asignado()` |
| `trigger_notificar_traslado_desadjudicado` | UPDATE | AFTER | `notificar_traslado_desadjudicado()` |

---

## 🧪 Cómo Probar

1. **Desde la app web**, asigna un nuevo traslado a un conductor o TES
2. **En la app móvil**, verifica que la notificación muestre:
   ```
   Nuevo Traslado Asignado
   Paciente: [NOMBRE COMPLETO] | [ORIGEN] → [DESTINO] | Hora: [HH:MM]
   ```
3. **Desasigna el traslado** desde la app web
4. **Verifica** que la notificación de desasignación muestre el mismo formato profesional

---

## 📝 Cambios Visuales (Flutter)

Los cambios visuales en el widget `NotificacionCard` se mantienen como se implementaron previamente:

- ✅ Borde rojo suave para notificaciones no leídas
- ✅ Sombra roja suave
- ✅ Punto indicador rojo
- ✅ Título en negrita para no leídas

Ver: `lib/features/notificaciones/presentation/widgets/notificacion_card.dart`

---

## ✅ Checklist Final

- [x] Identificar problema raíz (campo `paciente_nombre` no existe)
- [x] Actualizar `notificar_traslado_asignado()` con JOIN
- [x] Actualizar `notificar_traslado_desadjudicado()` con JOIN
- [x] Corregir formato de hora (SUBSTRING → TO_CHAR)
- [x] Verificar triggers existentes
- [x] Actualizar documentación
- [ ] **Probar con traslado nuevo en producción** ⚠️ Pendiente

---

## 🎯 Próximos Pasos

1. **Asignar un traslado nuevo** desde la app web
2. Verificar que la notificación aparece con el formato correcto
3. Si funciona correctamente, marcar como ✅ completado

---

**Fecha de corrección**: 2026-02-10
**Estado**: ✅ Funciones actualizadas en Supabase - Pendiente prueba en producción
**Autor**: Claude Code + User

---

## 📚 Archivos Relacionados

- **Triggers corregidos**: Ejecutados directamente en Supabase vía MCP
- **Widget visual**: `lib/features/notificaciones/presentation/widgets/notificacion_card.dart`
- **Documentación anterior**:
  - `docs/NOTIFICACIONES_MEJORADAS_RESUMEN.md` (primera versión, incorrecta)
  - `docs/NOTIFICACIONES_MEJORAS_VISUALES.md` (cambios visuales, correctos)
  - `docs/database/notificaciones_traslados_triggers_mejorados.sql` (primera versión, incorrecta)
