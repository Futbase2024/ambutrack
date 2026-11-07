# 📱 Mejora de Notificaciones de Traslados - AmbuTrack Mobile

## ❌ Problema Identificado

Las notificaciones push en la app móvil mostraban información técnica poco profesional:

**Antes:**
```
Título: 🚑 Nuevo Traslado Asignado
Mensaje: Se te ha asignado el servicio #TRS-20260210-1AG1020H | CALLE AS DE GUÍA, 21 - H... pTO REAL
```

### Problemas:
1. ❌ Mostraba el **ID técnico del servicio** (#TRS-20260210-1AG1020H)
2. ❌ El mensaje era **truncado y poco legible**
3. ❌ **Faltaba información relevante** para el usuario (nombre del paciente, hora)
4. ❌ Emoji en el título no era apropiado para notificaciones profesionales

---

## ✅ Solución Implementada

Se actualizaron los triggers de Supabase para generar mensajes **profesionales, claros y legibles**.

**Ahora:**
```
Título: Nuevo Traslado Asignado
Mensaje: Paciente: JUAN GARCÍA LÓPEZ | Hospital Central → Domicilio Calle Mayor 123 | Hora: 09:30
```

### Mejoras:
1. ✅ **Nombre del paciente** en lugar del ID del servicio
2. ✅ **Origen → Destino** claramente visibles
3. ✅ **Hora programada** en formato HH:mm (legible)
4. ✅ Mensaje **completo y sin truncar**
5. ✅ Formato **profesional y elegante**
6. ✅ Sin emojis en el título (más profesional)

---

## 📋 Cambios Técnicos

### Funciones Actualizadas

1. **`notificar_traslado_asignado()`**
   - Usa `paciente_nombre` en lugar de `codigo`
   - Muestra origen y destino completos
   - Formatea `hora_programada` de HH:mm:ss a HH:mm
   - Guarda información detallada en `metadata` para navegación

2. **`notificar_traslado_desadjudicado()`**
   - Formato consistente con asignación
   - Mantiene información del traslado para referencia

### Estructura del Mensaje

```
Paciente: [NOMBRE_COMPLETO] | [ORIGEN] → [DESTINO] | Hora: [HH:MM]
```

**Ejemplo real:**
```
Paciente: MARÍA GONZÁLEZ PÉREZ | Hospital Universitario → Domicilio Calle Real 45 | Hora: 14:30
```

---

## 🚀 Cómo Aplicar los Cambios

### Paso 1: Ejecutar Script SQL

1. Accede al editor SQL de Supabase:
   ```
   https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr/sql
   ```

2. Copia el contenido del archivo:
   ```
   apps/mobile/docs/database/notificaciones_traslados_triggers_mejorados.sql
   ```

3. Pega en el editor SQL y haz clic en **"Run"**

4. Verifica que se ejecutó correctamente:
   ```sql
   -- Debería mostrar las funciones actualizadas
   SELECT routine_name, last_altered
   FROM information_schema.routines
   WHERE routine_name IN (
       'notificar_traslado_asignado',
       'notificar_traslado_desadjudicado'
   );
   ```

### Paso 2: Probar Notificaciones

1. En la app web de AmbuTrack, asigna un traslado a un conductor/TES

2. Verifica en la app móvil que la notificación muestre el formato nuevo:
   ```
   Paciente: [NOMBRE] | [ORIGEN] → [DESTINO] | Hora: [HH:MM]
   ```

3. Desasigna el traslado y verifica la notificación de desasignación

---

## 📊 Comparación Visual

### Notificación de Asignación

| Antes | Ahora |
|-------|-------|
| 🚑 Nuevo Traslado Asignado | Nuevo Traslado Asignado |
| Se te ha asignado el servicio #TRS-20260210-1AG1020H \| CALLE AS DE... | Paciente: JUAN GARCÍA \| Hospital Central → Domicilio \| Hora: 09:30 |

### Notificación de Desasignación

| Antes | Ahora |
|-------|-------|
| ❌ Traslado Desadjudicado | Traslado Desasignado |
| Has sido desasignado del servicio #TRS-20260210-1AG1020H | Traslado desasignado \| Paciente: JUAN GARCÍA \| Hospital Central → Domicilio \| Hora: 09:30 |

---

## 🔍 Detalles de Implementación

### Campos Usados de la Tabla `traslados`

```sql
-- Campos desnormalizados (sin joins)
paciente_nombre         -- Nombre completo del paciente
origen                  -- Dirección de origen
destino                 -- Dirección de destino
hora_programada         -- Formato HH:mm:ss (se trunca a HH:mm)
codigo                  -- Código del servicio (guardado en metadata pero no mostrado)
```

### Metadata Guardada (para navegación)

```json
{
  "servicio_id": "uuid-del-traslado",
  "numero_servicio": "TRS-20260210-1AG1020H",
  "paciente_nombre": "JUAN GARCÍA LÓPEZ",
  "origen": "Hospital Central",
  "destino": "Domicilio Calle Mayor 123",
  "hora_programada": "09:30",
  "rol": "conductor" | "tes"
}
```

---

## ✅ Verificación Post-Implementación

### Checklist

- [ ] Script SQL ejecutado correctamente en Supabase
- [ ] Funciones `notificar_traslado_asignado()` y `notificar_traslado_desadjudicado()` actualizadas
- [ ] Triggers existentes siguen activos (no necesitan recrearse)
- [ ] Notificaciones nuevas muestran formato profesional
- [ ] Notificaciones previas siguen visibles (no afectadas)
- [ ] Metadata incluye información completa para navegación

---

## 📝 Notas Importantes

1. **No afecta notificaciones existentes**: Las notificaciones antiguas mantendrán su formato original. Solo las nuevas usarán el formato mejorado.

2. **Sin cambios en el código Flutter**: El servicio de notificaciones locales (`local_notifications_service.dart`) sigue funcionando igual. Solo cambia el contenido de `titulo` y `mensaje`.

3. **Compatibilidad**: El campo `metadata` contiene toda la información del traslado, permitiendo navegación correcta desde las notificaciones.

4. **Triggers existentes**: No es necesario recrear los triggers. Las funciones actualizadas se aplican automáticamente.

---

## 🎯 Resultado Final

Las notificaciones ahora son:
- ✅ **Profesionales y elegantes**
- ✅ **Fáciles de leer de un vistazo**
- ✅ **Informativas** (nombre paciente, origen, destino, hora)
- ✅ **Sin información técnica innecesaria** (IDs)
- ✅ **Consistentes** con el diseño de AmbuTrack

---

## 📚 Archivos Relacionados

- **Script SQL**: `apps/mobile/docs/database/notificaciones_traslados_triggers_mejorados.sql`
- **Script original**: `apps/mobile/docs/database/notificaciones_traslados_triggers.sql`
- **Servicio notificaciones**: `apps/mobile/lib/features/notificaciones/services/local_notifications_service.dart`
- **BLoC notificaciones**: `apps/mobile/lib/features/notificaciones/presentation/bloc/notificaciones_bloc.dart`
- **Entidad traslado**: `packages/ambutrack_core/lib/src/datasources/traslados/entities/traslado_entity.dart`

---

**Fecha de implementación**: 2026-02-10
**Estado**: ✅ Listo para ejecutar en Supabase
