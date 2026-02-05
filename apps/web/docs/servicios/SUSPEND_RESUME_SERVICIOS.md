# Suspender y Reanudar Servicios

## 📋 Descripción General

Este documento describe la funcionalidad de **suspender** y **reanudar** servicios en AmbuTrack, incluyendo la gestión automática de traslados futuros.

---

## 🎯 Comportamiento Esperado

### Al Suspender un Servicio

1. **Cambio de estado**: El servicio cambia de `activo` a `suspendido`
2. **Eliminación de traslados futuros**: Se eliminan todos los traslados desde la fecha actual hacia adelante
3. **Preservación de histórico**: Los traslados anteriores a la fecha actual se mantienen intactos
4. **Prevención de generación automática**: Los triggers NO crearán nuevos traslados para servicios suspendidos

### Al Reanudar un Servicio

1. **Cambio de estado**: El servicio cambia de `suspendido` a `activo`
2. **Regeneración de traslados**: Se regeneran traslados desde la fecha actual hacia adelante
3. **Respeto de configuración**: Se respeta la configuración original de recurrencia del servicio
4. **Retorno de cantidad**: Devuelve el número de traslados generados

---

## 🏗️ Arquitectura de la Solución

### 1. Base de Datos PostgreSQL

#### Trigger Modificado: `trigger_generar_traslados_recurrente`

**Ubicación**: Tabla `servicios_recurrentes`
**Evento**: `AFTER INSERT`
**Función**: `generar_traslados_recurrente()`

**Cambio Realizado**: Validación de estado antes de generar traslados

```sql
-- ✅ VALIDAR ESTADO DEL SERVICIO PADRE
SELECT estado INTO v_estado_servicio
FROM servicios
WHERE id = NEW.id_servicio;

-- Si el servicio está suspendido, NO generar traslados
IF v_estado_servicio = 'suspendido' THEN
  RAISE NOTICE 'Servicio % está SUSPENDIDO. No se generan traslados.', NEW.codigo;
  RETURN NEW;
END IF;
```

**Impacto**:
- ✅ Previene la creación automática de traslados para servicios suspendidos
- ✅ No afecta la creación de traslados para servicios activos
- ✅ Log informativo en caso de intento de creación

---

#### Función Nueva: `regenerar_traslados_servicio()`

**Propósito**: Regenerar traslados cuando un servicio suspendido se reanuda

**Firma**:
```sql
CREATE OR REPLACE FUNCTION public.regenerar_traslados_servicio(
  p_id_servicio UUID,
  p_fecha_desde DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(traslados_generados INTEGER)
```

**Parámetros**:
- `p_id_servicio`: UUID del servicio a regenerar
- `p_fecha_desde`: Fecha desde la cual generar traslados (por defecto: hoy)

**Retorno**:
- Tabla con una columna `traslados_generados` (INTEGER) indicando cuántos traslados se crearon

**Lógica**:
1. Busca el `servicio_recurrente` activo asociado al servicio
2. Calcula la fecha fin efectiva (30 días o `fecha_servicio_fin`)
3. Itera día por día desde `p_fecha_desde` hasta la fecha fin
4. Aplica la lógica de recurrencia según el tipo:
   - `diario`: Genera todos los días
   - `semanal`: Genera en días de semana especificados
   - `dias_alternos`: Genera cada N días según intervalo
   - `fechas_especificas`: Genera solo en fechas específicas
   - `mensual`: Genera en días del mes especificados
5. Crea traslados de IDA (y VUELTA si aplica) para cada fecha válida
6. Actualiza el campo `traslados_generados_hasta` del servicio recurrente
7. Retorna el contador de traslados generados

**Ejemplo de uso**:
```sql
-- Regenerar traslados desde hoy
SELECT * FROM regenerar_traslados_servicio('uuid-del-servicio');

-- Regenerar desde una fecha específica
SELECT * FROM regenerar_traslados_servicio('uuid-del-servicio', '2025-02-01');
```

---

### 2. Capa de Repositorio (Dart/Flutter)

#### Contrato: `ServicioRepository`

**Ubicación**: `lib/features/servicios/servicios/domain/repositories/servicio_repository.dart`

**Métodos Agregados**:

```dart
/// Suspende un servicio y elimina traslados futuros
///
/// Al suspender:
/// 1. Cambia el estado del servicio a 'suspendido'
/// 2. Elimina traslados desde la fecha actual en adelante
/// 3. Mantiene el histórico de traslados anteriores
Future<void> suspend(String id);

/// Reanuda un servicio suspendido y regenera traslados
///
/// Al reanudar:
/// 1. Cambia el estado del servicio a 'activo'
/// 2. Regenera traslados desde la fecha actual hacia adelante
/// 3. Respeta la configuración original de recurrencia
Future<int> reanudar(String id);
```

---

#### Implementación: `ServicioRepositoryImpl`

**Ubicación**: `lib/features/servicios/servicios/data/repositories/servicio_repository_impl.dart`

**Método `suspend()`**:

```dart
@override
Future<void> suspend(String id) async {
  debugPrint('⏸️ ServicioRepository: Suspendiendo servicio $id...');
  try {
    final String now = DateTime.now().toIso8601String().split('T').first;

    // 1. Cambiar estado del servicio a 'suspendido'
    debugPrint('⏸️ Paso 1/2: Actualizando estado a suspendido...');
    await _supabase
        .from('servicios')
        .update(<String, dynamic>{'estado': 'suspendido'})
        .eq('id', id);
    debugPrint('✅ Estado actualizado');

    // 2. Eliminar traslados desde HOY en adelante
    debugPrint('⏸️ Paso 2/2: Eliminando traslados futuros (>= $now)...');
    await _supabase
        .from('traslados')
        .delete()
        .eq('id_servicio', id)
        .gte('fecha', now);
    debugPrint('✅ Traslados futuros eliminados');

    debugPrint('📦 ServicioRepository: ✅ Servicio suspendido exitosamente');
  } catch (e) {
    debugPrint('📦 ServicioRepository: ❌ Error al suspender: $e');
    rethrow;
  }
}
```

**Pasos**:
1. Actualiza el campo `estado` a `'suspendido'` en la tabla `servicios`
2. Elimina todos los traslados con `fecha >= hoy` usando `.gte('fecha', now)`
3. Incluye logging detallado para troubleshooting

---

**Método `reanudar()`**:

```dart
@override
Future<int> reanudar(String id) async {
  debugPrint('▶️ ServicioRepository: Reanudando servicio $id...');
  try {
    final String now = DateTime.now().toIso8601String().split('T').first;

    // 1. Cambiar estado del servicio a 'activo'
    debugPrint('▶️ Paso 1/2: Actualizando estado a activo...');
    await _supabase
        .from('servicios')
        .update(<String, dynamic>{'estado': 'activo'})
        .eq('id', id);
    debugPrint('✅ Estado actualizado');

    // 2. Llamar función de PostgreSQL para regenerar traslados
    debugPrint('▶️ Paso 2/2: Regenerando traslados desde $now...');
    final List<dynamic> response = await _supabase.rpc(
      'regenerar_traslados_servicio',
      params: <String, dynamic>{
        'p_id_servicio': id,
        'p_fecha_desde': now,
      },
    );

    final int trasladosGenerados = response.first as int;
    debugPrint('✅ Traslados regenerados: $trasladosGenerados');

    debugPrint('📦 ServicioRepository: ✅ Servicio reanudado exitosamente');
    return trasladosGenerados;
  } catch (e) {
    debugPrint('📦 ServicioRepository: ❌ Error al reanudar: $e');
    rethrow;
  }
}
```

**Pasos**:
1. Actualiza el campo `estado` a `'activo'` en la tabla `servicios`
2. Llama a la función PostgreSQL `regenerar_traslados_servicio()` mediante RPC de Supabase
3. Retorna el número de traslados generados
4. Incluye logging detallado para troubleshooting

---

## 🔄 Flujo Completo

### Flujo de Suspensión

```
Usuario → Botón "Suspender"
  ↓
BLoC → ServicioBloc.add(ServicioSuspendRequested(id))
  ↓
Repository → suspend(id)
  ↓
Supabase:
  1. UPDATE servicios SET estado='suspendido' WHERE id=?
  2. DELETE FROM traslados WHERE id_servicio=? AND fecha >= CURRENT_DATE
  ↓
BLoC → emit(ServicioSuspendSuccess())
  ↓
UI → Mostrar confirmación al usuario
```

### Flujo de Reanudación

```
Usuario → Botón "Reanudar"
  ↓
BLoC → ServicioBloc.add(ServicioReanudarRequested(id))
  ↓
Repository → reanudar(id)
  ↓
Supabase:
  1. UPDATE servicios SET estado='activo' WHERE id=?
  2. SELECT * FROM regenerar_traslados_servicio(id, CURRENT_DATE)
     ↓
     PostgreSQL Function:
       - Obtiene servicio_recurrente activo
       - Calcula fecha_fin_efectiva (30 días o fecha_servicio_fin)
       - Itera día por día aplicando lógica de recurrencia
       - Crea traslados según tipo_recurrencia
       - Actualiza traslados_generados_hasta
       - Retorna count de traslados generados
  ↓
Repository → retorna número de traslados generados
  ↓
BLoC → emit(ServicioReanudarSuccess(trasladosGenerados: N))
  ↓
UI → Mostrar "Servicio reanudado. N traslados generados."
```

---

## ✅ Casos de Uso Cubiertos

### ✅ Caso 1: Servicio Suspendido NO Genera Traslados Automáticos

**Escenario**:
1. Servicio está suspendido (`estado='suspendido'`)
2. Se crea un nuevo `servicio_recurrente` manualmente (raro, pero posible)
3. Trigger `trigger_generar_traslados_recurrente` se ejecuta

**Resultado Esperado**:
- ✅ Trigger valida `estado='suspendido'`
- ✅ NO se crean traslados
- ✅ Log: "Servicio XXX está SUSPENDIDO. No se generan traslados."

---

### ✅ Caso 2: Suspender Servicio Elimina Solo Futuros

**Escenario**:
1. Servicio tiene traslados pasados (< hoy) y futuros (>= hoy)
2. Usuario suspende el servicio

**Resultado Esperado**:
- ✅ Estado cambia a `suspendido`
- ✅ Traslados futuros (>= hoy) se eliminan
- ✅ Traslados pasados (< hoy) se preservan
- ✅ Histórico intacto para reporting

---

### ✅ Caso 3: Reanudar Regenera Traslados Correctamente

**Escenario**:
1. Servicio suspendido el 2025-01-05
2. Usuario reanuda el servicio el 2025-01-10
3. Servicio tiene recurrencia `semanal` (lunes, miércoles, viernes)
4. `fecha_servicio_fin` es 2025-02-28

**Resultado Esperado**:
- ✅ Estado cambia a `activo`
- ✅ Se generan traslados desde 2025-01-10 hasta 2025-02-10 (30 días)
- ✅ Solo días lunes, miércoles, viernes
- ✅ Retorna número correcto de traslados generados

---

### ✅ Caso 4: Reanudar Respeta Fecha Fin Original

**Escenario**:
1. Servicio suspendido el 2025-01-15
2. `fecha_servicio_fin` es 2025-01-20
3. Usuario reanuda el 2025-01-18

**Resultado Esperado**:
- ✅ Se generan traslados desde 2025-01-18 hasta 2025-01-20 (no 30 días)
- ✅ Usa `LEAST(fecha_servicio_fin, fecha_desde + 30 días)`
- ✅ No genera traslados después de la fecha fin

---

## 🧪 Pruebas Recomendadas

### Test 1: Validación de Trigger

```sql
-- 1. Crear servicio suspendido
INSERT INTO servicios (id, codigo, estado, ...)
VALUES ('uuid-test', 'SRV-TEST', 'suspendido', ...);

-- 2. Crear servicio_recurrente para ese servicio
INSERT INTO servicios_recurrentes (id_servicio, tipo_recurrencia, ...)
VALUES ('uuid-test', 'diario', ...);

-- 3. Verificar que NO se crearon traslados
SELECT COUNT(*) FROM traslados WHERE id_servicio = 'uuid-test';
-- Resultado esperado: 0
```

### Test 2: Suspender Servicio

```sql
-- 1. Crear servicio activo con traslados pasados y futuros
INSERT INTO traslados (id_servicio, fecha, ...) VALUES
  ('uuid-test', '2025-01-01', ...),  -- Pasado
  ('uuid-test', '2025-01-05', ...),  -- Pasado
  ('uuid-test', '2025-01-10', ...),  -- Futuro (asumiendo hoy es 2025-01-06)
  ('uuid-test', '2025-01-15', ...);  -- Futuro

-- 2. Suspender servicio (via repository)
-- ServicioRepository.suspend('uuid-test')

-- 3. Verificar traslados futuros eliminados
SELECT COUNT(*) FROM traslados WHERE id_servicio = 'uuid-test' AND fecha >= CURRENT_DATE;
-- Resultado esperado: 0

-- 4. Verificar traslados pasados preservados
SELECT COUNT(*) FROM traslados WHERE id_servicio = 'uuid-test' AND fecha < CURRENT_DATE;
-- Resultado esperado: 2
```

### Test 3: Reanudar Servicio

```sql
-- 1. Tener servicio suspendido sin traslados futuros
UPDATE servicios SET estado = 'suspendido' WHERE id = 'uuid-test';
DELETE FROM traslados WHERE id_servicio = 'uuid-test' AND fecha >= CURRENT_DATE;

-- 2. Verificar servicio_recurrente activo con configuración
SELECT * FROM servicios_recurrentes WHERE id_servicio = 'uuid-test' AND activo = true;

-- 3. Reanudar servicio (via repository)
-- int traslados = await ServicioRepository.reanudar('uuid-test')

-- 4. Verificar estado cambiado
SELECT estado FROM servicios WHERE id = 'uuid-test';
-- Resultado esperado: 'activo'

-- 5. Verificar traslados regenerados
SELECT COUNT(*) FROM traslados WHERE id_servicio = 'uuid-test' AND fecha >= CURRENT_DATE;
-- Resultado esperado: > 0 (según configuración de recurrencia)

-- 6. Verificar retorno correcto
-- traslados == COUNT(*)
```

---

## 📊 Métricas y Logging

### Logs Generados

**Suspender**:
```
⏸️ ServicioRepository: Suspendiendo servicio {id}...
⏸️ Paso 1/2: Actualizando estado a suspendido...
✅ Estado actualizado
⏸️ Paso 2/2: Eliminando traslados futuros (>= {fecha})...
✅ Traslados futuros eliminados
📦 ServicioRepository: ✅ Servicio suspendido exitosamente
```

**Reanudar**:
```
▶️ ServicioRepository: Reanudando servicio {id}...
▶️ Paso 1/2: Actualizando estado a activo...
✅ Estado actualizado
▶️ Paso 2/2: Regenerando traslados desde {fecha}...
✅ Traslados regenerados: {N}
📦 ServicioRepository: ✅ Servicio reanudado exitosamente
```

**Trigger (cuando servicio suspendido)**:
```
NOTICE: Servicio {codigo} está SUSPENDIDO. No se generan traslados.
```

---

## ⚠️ Consideraciones Importantes

### 1. Fecha de Corte

- **Suspender**: Usa `CURRENT_DATE` para determinar qué traslados eliminar
- **Reanudar**: Usa `CURRENT_DATE` como fecha de inicio de regeneración
- **Implicación**: Si se suspende/reanuda a las 23:59, puede haber edge cases con traslados del día actual

### 2. Ventana de Regeneración

- Por defecto, regenera **30 días** hacia adelante
- Si `fecha_servicio_fin` es anterior, usa esa fecha
- **Razón**: Evitar sobrecarga de DB generando demasiados traslados de una vez

### 3. Servicio Recurrente Inactivo

- Si el `servicio_recurrente` asociado tiene `activo=false`, `reanudar()` lanzará excepción
- **Recomendación**: UI debe validar esto antes de permitir reanudar

### 4. Integridad de Datos

- Los traslados eliminados al suspender **NO se pueden recuperar**
- Si se reanuda, se regeneran desde cero (pueden tener IDs diferentes)
- **Implicación**: Cualquier asignación de personal o vehículos se pierde al suspender

---

## 🔗 Referencias

- **Trigger original**: `trigger_generar_traslados_recurrente` (modificado)
- **Función PostgreSQL**: `generar_traslados_recurrente()` (modificada)
- **Nueva función**: `regenerar_traslados_servicio()` (creada)
- **Contrato**: `lib/features/servicios/servicios/domain/repositories/servicio_repository.dart`
- **Implementación**: `lib/features/servicios/servicios/data/repositories/servicio_repository_impl.dart`

---

## 📝 Próximos Pasos (Opcional)

Para completar la funcionalidad end-to-end, se requeriría:

1. **BLoC Layer**:
   - Agregar eventos `ServicioSuspendRequested` y `ServicioReanudarRequested`
   - Manejar estados `ServicioSuspendSuccess`, `ServicioReanudarSuccess`
   - Manejo de errores con `ServicioSuspendFailure`, `ServicioReanudarFailure`

2. **UI Integration**:
   - Botón "Suspender" en tabla de servicios
   - Diálogo de confirmación "Confirmar Suspensión"
   - Botón "Reanudar" (solo visible si `estado='suspendido'`)
   - Mostrar número de traslados regenerados al reanudar

3. **Validaciones UI**:
   - Validar que `servicio_recurrente` esté activo antes de reanudar
   - Mostrar warning si servicio tiene fecha_servicio_fin muy próxima
   - Prevenir suspender servicios ya eliminados

4. **Testing**:
   - Tests unitarios para BLoC events/states
   - Tests de integración para flujo completo
   - Tests de widget para botones y diálogos

---

**Documento creado**: 2025-01-06
**Última actualización**: 2025-01-06
**Autor**: AmbuTrack Development Team
