# 📱 Formato Final de Notificaciones - AmbuTrack Mobile

## ✅ Formato Implementado (Febrero 2026)

### Estructura del Mensaje

Las notificaciones de traslados ahora utilizan un formato de **dos líneas** para mejor legibilidad:

```
Línea 1: Paciente: [NOMBRE COMPLETO] | Hora: [HH:MM]
Línea 2: [ORIGEN] → [DESTINO] | [Ida/Vuelta]
```

---

## 📊 Ejemplos Reales

### Notificación de Asignación (Ida)

```
Título: Nuevo Traslado Asignado

Mensaje:
Paciente: JUAN GARCÍA LÓPEZ | Hora: 09:30
Hospital Central → Domicilio Calle Mayor 123 | Ida
```

### Notificación de Asignación (Vuelta)

```
Título: Nuevo Traslado Asignado

Mensaje:
Paciente: MARÍA GONZÁLEZ PÉREZ | Hora: 14:30
Domicilio Calle Real 45 → Hospital Universitario | Vuelta
```

### Notificación de Desasignación

```
Título: Traslado Desasignado

Mensaje:
Paciente: JUAN GARCÍA LÓPEZ | Hora: 09:30
Hospital Central → Domicilio Calle Mayor 123 | Ida
```

---

## 🔧 Implementación Técnica

### Campo `tipo_traslado`

- **Tabla**: `traslados`
- **Tipo**: `VARCHAR`
- **Valores posibles**: `'ida'`, `'vuelta'`
- **Formato en mensaje**: Capitalizado (`'Ida'`, `'Vuelta'`)

### Lógica de Formateo (SQL)

```sql
-- Capitalizar tipo de traslado
v_tipo_traslado := CASE
    WHEN LOWER(NEW.tipo_traslado) = 'ida' THEN 'Ida'
    WHEN LOWER(NEW.tipo_traslado) = 'vuelta' THEN 'Vuelta'
    ELSE INITCAP(NEW.tipo_traslado)
END;

-- Construir mensaje en dos líneas (con E'\n')
v_mensaje_profesional :=
    'Paciente: ' || v_paciente_nombre || ' | Hora: ' || v_hora_programada || E'\n' ||
    v_origen || ' → ' || v_destino || ' | ' || v_tipo_traslado;
```

---

## 📋 Ventajas del Nuevo Formato

### ✅ Mejor Legibilidad

- **Línea 1**: Información del paciente y hora (datos clave)
- **Línea 2**: Ruta y tipo de traslado (contexto del servicio)

### ✅ Información Completa

- Nombre del paciente (completo)
- Hora programada (HH:MM)
- Origen y destino (direcciones completas)
- **Tipo de traslado** (Ida/Vuelta) - **NUEVO**

### ✅ Diseño Visual

El widget `NotificacionCard` muestra el mensaje con:
- Máximo 3 líneas (`maxLines: 3`)
- Overflow con elipsis (`overflow: TextOverflow.ellipsis`)
- Fondo limpio (sin color de fondo especial)
- **Borde rojo suave** para no leídas
- **Punto rojo** en la esquina superior derecha para no leídas

---

## 🗄️ Funciones de Supabase Actualizadas

### 1. `notificar_traslado_asignado()`

```sql
CREATE OR REPLACE FUNCTION notificar_traslado_asignado()
RETURNS TRIGGER AS $$
DECLARE
    v_paciente_nombre TEXT;
    v_origen TEXT;
    v_destino TEXT;
    v_hora_programada TEXT;
    v_tipo_traslado TEXT;
    v_mensaje_profesional TEXT;
BEGIN
    -- JOIN con tabla pacientes
    SELECT CONCAT_WS(' ', p.nombre, p.primer_apellido, p.segundo_apellido)
    INTO v_paciente_nombre
    FROM pacientes p
    WHERE p.id = NEW.id_paciente;

    -- Formatear hora
    v_hora_programada := TO_CHAR(NEW.hora_programada, 'HH24:MI');

    -- Capitalizar tipo
    v_tipo_traslado := CASE
        WHEN LOWER(NEW.tipo_traslado) = 'ida' THEN 'Ida'
        WHEN LOWER(NEW.tipo_traslado) = 'vuelta' THEN 'Vuelta'
        ELSE INITCAP(NEW.tipo_traslado)
    END;

    -- ⬇️ FORMATO EN DOS LÍNEAS
    v_mensaje_profesional :=
        'Paciente: ' || v_paciente_nombre || ' | Hora: ' || v_hora_programada || E'\n' ||
        NEW.origen || ' → ' || NEW.destino || ' | ' || v_tipo_traslado;

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
    v_tipo_traslado TEXT;
    v_mensaje_profesional TEXT;
BEGIN
    -- Mismo formato que asignación (usando OLD en lugar de NEW)
    v_mensaje_profesional :=
        'Paciente: ' || v_paciente_nombre || ' | Hora: ' || v_hora_programada || E'\n' ||
        OLD.origen || ' → ' || OLD.destino || ' | ' || v_tipo_traslado;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 🎨 Diseño Visual (Flutter)

### Widget `NotificacionCard`

```dart
// Mensaje con salto de línea (\n)
Text(
  notificacion.mensaje,
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: 0.7),
  ),
  maxLines: 3,  // Permite mostrar las dos líneas completas
  overflow: TextOverflow.ellipsis,
),

// Borde adaptativo (rojo si no leída, verde si leída)
border: Border.all(
  color: notificacion.leida
      ? AppColors.success.withValues(alpha: 0.3)
      : AppColors.error.withValues(alpha: 0.4),
  width: 2,
),
```

### Notificaciones No Leídas ❌

- **Borde**: Rojo suave (`AppColors.error.withValues(alpha: 0.4)`, width: 2)
- **Sombra**: Roja suave (`AppColors.error.withValues(alpha: 0.1)`)
- **Punto indicador**: Rojo (`AppColors.error.withValues(alpha: 0.7)`)
- **Título**: Negrita (`FontWeight.bold`)
- **Visibilidad**: Alta (borde rojo destaca)

### Notificaciones Leídas ✅

- **Borde**: Verde suave (`AppColors.success.withValues(alpha: 0.3)`, width: 2)
- **Sombra**: Verde suave (`AppColors.success.withValues(alpha: 0.08)`)
- **Punto indicador**: No se muestra
- **Título**: Peso normal (`FontWeight.normal`)
- **Visibilidad**: Media (borde verde indica completado)

---

## 📊 Metadata Guardada (JSON)

Cada notificación guarda la siguiente información en el campo `metadata`:

```json
{
  "servicio_id": "uuid-del-traslado",
  "numero_servicio": "TRS-20260210-1AG1020H",
  "paciente_nombre": "JUAN GARCÍA LÓPEZ",
  "origen": "Hospital Central",
  "destino": "Domicilio Calle Mayor 123",
  "hora_programada": "09:30",
  "tipo_traslado": "Ida",
  "rol": "conductor"
}
```

Esto permite:
- Navegación directa al traslado desde la notificación
- Filtrado y búsqueda de notificaciones
- Analytics y reportes

---

## 🧪 Cómo Probar

### Prueba de Asignación

1. **Asignar un traslado de IDA** desde la app web
2. Verificar en la app móvil que la notificación muestre:
   ```
   Paciente: [NOMBRE] | Hora: [HH:MM]
   [ORIGEN] → [DESTINO] | Ida
   ```
3. **Tocar la notificación**:
   - Se marca como leída (borde cambia de rojo a verde)
   - Navega al detalle del traslado

### Prueba de Tipo Vuelta

4. **Asignar un traslado de VUELTA** desde la app web
5. Verificar que muestre "Vuelta" al final del mensaje

### Prueba de Desasignación

6. **Desasignar un traslado** desde la app web
7. Verificar que la notificación de desasignación muestre el mismo formato
8. **Tocar la notificación de desasignación**:
   - Se marca como leída (borde cambia de rojo a verde)
   - **NO navega** al detalle (el traslado ya no está asignado al usuario)

---

## ✅ Checklist de Implementación

- [x] Función `notificar_traslado_asignado()` actualizada
- [x] Función `notificar_traslado_desadjudicado()` actualizada
- [x] Formato de dos líneas implementado
- [x] Campo `tipo_traslado` incluido en mensaje
- [x] Capitalización de "Ida" / "Vuelta"
- [x] Widget `NotificacionCard` con `maxLines: 3`
- [x] Metadata actualizada con `tipo_traslado`
- [ ] **Prueba con traslado nuevo** ⚠️ Pendiente

---

## 📝 Historial de Cambios

| Fecha | Cambio | Versión |
|-------|--------|---------|
| 2026-02-10 (v1) | Primera versión con ID técnico | ❌ Incorrecto |
| 2026-02-10 (v2) | JOIN con pacientes, formato una línea | ✅ Funcionaba |
| 2026-02-10 (v3) | **Formato dos líneas + Tipo traslado** | ✅ **Actual** |

**Formato v1 (incorrecto):**
```
Se te ha asignado el servicio #TRS-20260210-1AG1020H | CALLE AS DE GUÍA, 21...
```

**Formato v2 (funcional pero denso):**
```
Paciente: JUAN GARCÍA LÓPEZ | Hospital Central → Domicilio | Hora: 09:30
```

**Formato v3 (actual - óptimo):**
```
Paciente: JUAN GARCÍA LÓPEZ | Hora: 09:30
Hospital Central → Domicilio Calle Mayor 123 | Ida
```

---

**Fecha de implementación**: 2026-02-10
**Estado**: ✅ Implementado y funcionando
**Autor**: Claude Code + User

---

## 📚 Archivos Relacionados

- **Triggers en Supabase**: Ejecutados vía MCP (actualizados)
- **Widget**: `lib/features/notificaciones/presentation/widgets/notificacion_card.dart`
- **Documentación anterior**:
  - `docs/NOTIFICACIONES_SOLUCION_FINAL.md`
  - `docs/NOTIFICACIONES_MEJORAS_VISUALES.md`
  - `docs/database/notificaciones_traslados_triggers_corregidos.sql`
