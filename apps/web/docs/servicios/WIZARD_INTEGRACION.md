# 🧙 Integración del Wizard con Arquitectura de 3 Niveles

## 📋 Problema Actual

El wizard de creación de servicios actualmente solo crea registros en `servicios_recurrentes`, pero la arquitectura correcta requiere 3 niveles:

```
servicios (padre) → servicios_recurrentes (hijo) → traslados (nietos)
```

**Estado Actual**: El wizard omite la creación de `servicios` (nivel 1)
**Impacto**: La FK `id_servicio` en `servicios_recurrentes` queda sin valor válido

---

## ✅ Solución Implementada en Código

Se ha agregado el campo `idServicio` a:
1. ✅ `ServicioRecurrenteEntity` (entity)
2. ✅ `ServicioRecurrenteSupabaseModel` (model)
3. ✅ `SupabaseServicioRecurrenteDataSource` (whitelist)

Ahora el código está preparado para recibir el `id_servicio`, pero **falta implementar la lógica del wizard**.

---

## 🔧 Cambios Requeridos en el Wizard

### PASO 1: Crear Servicio Padre (Nuevo)

Antes de crear `servicios_recurrentes`, el wizard debe:

```dart
// 1️⃣ Crear registro en tabla servicios
final servicioId = await _crearServicioPadre(wizardData);

// 2️⃣ Usar ese ID para crear servicios_recurrentes
final servicioRecurrente = ServicioRecurrenteEntity(
  id: const Uuid().v4(),
  codigo: 'SRV-${DateTime.now().millisecondsSinceEpoch}',
  idServicio: servicioId, // ⚡ CRÍTICO: FK al servicio padre
  idPaciente: wizardData.paciente.id,
  tipoRecurrencia: wizardData.tipoRecurrencia,
  // ... resto de campos
);

await _servicioRecurrenteRepository.create(servicioRecurrente);
```

### PASO 2: Implementar `_crearServicioPadre()`

```dart
Future<String> _crearServicioPadre(WizardData wizardData) async {
  // OPCIÓN A: Usar tabla servicios directamente
  final response = await _supabase
      .from('servicios')
      .insert({
        'codigo': 'SRV-${DateTime.now().millisecondsSinceEpoch}',
        'id_paciente': wizardData.paciente.id,
        'tipo_recurrencia': wizardData.tipoRecurrencia,
        'fecha_servicio_inicio': wizardData.fechaInicio.toIso8601String(),
        'fecha_servicio_fin': wizardData.fechaFin?.toIso8601String(),
        'trayectos': wizardData.trayectos,
        'created_by': currentUserId,
      })
      .select()
      .single();

  return response['id'] as String;

  // OPCIÓN B: Crear un ServicioRepository si existe
  // final servicio = ServicioEntity(/* ... */);
  // final createdServicio = await _servicioRepository.create(servicio);
  // return createdServicio.id;
}
```

---

## 📊 Diagrama de Flujo del Wizard

```
┌────────────────────────────────────────────────────────────┐
│ WIZARD: Paso 1 - Seleccionar Paciente                     │
└────────────────────────────────────────────────────────────┘
                           ↓
┌────────────────────────────────────────────────────────────┐
│ WIZARD: Paso 2 - Configurar Recurrencia                   │
└────────────────────────────────────────────────────────────┘
                           ↓
┌────────────────────────────────────────────────────────────┐
│ WIZARD: Paso 3 - Configurar Trayectos                     │
└────────────────────────────────────────────────────────────┘
                           ↓
┌────────────────────────────────────────────────────────────┐
│ WIZARD: Paso 4 - Revisar y Confirmar                      │
└────────────────────────────────────────────────────────────┘
                           ↓
┌────────────────────────────────────────────────────────────┐
│ ⚡ NUEVO: Crear Servicio Padre (tabla servicios)          │
│   - INSERT INTO servicios (...)                           │
│   - Retorna: servicio_id                                  │
└────────────────────────────────────────────────────────────┘
                           ↓
┌────────────────────────────────────────────────────────────┐
│ Crear Servicio Recurrente (tabla servicios_recurrentes)   │
│   - id_servicio = servicio_id (FK al padre)               │
│   - INSERT INTO servicios_recurrentes (...)               │
└────────────────────────────────────────────────────────────┘
                           ↓
┌────────────────────────────────────────────────────────────┐
│ TRIGGER: generar_traslados_al_crear_servicio_recurrente() │
│   - Genera traslados automáticamente                      │
│   - Para los próximos 30 días                             │
└────────────────────────────────────────────────────────────┘
                           ↓
┌────────────────────────────────────────────────────────────┐
│ ✅ Servicio creado exitosamente                           │
│    - 1 servicio (padre)                                   │
│    - 1 servicio_recurrente (hijo)                         │
│    - N traslados (nietos generados automáticamente)       │
└────────────────────────────────────────────────────────────┘
```

---

## 🗂️ Campos del Servicio Padre (tabla servicios)

```sql
CREATE TABLE servicios (
  id UUID PRIMARY KEY,
  codigo VARCHAR(50) UNIQUE,
  id_paciente UUID NOT NULL REFERENCES pacientes(id),
  tipo_recurrencia TEXT,
  fecha_servicio_inicio DATE,
  fecha_servicio_fin DATE,
  trayectos JSONB,
  created_at TIMESTAMP DEFAULT now(),
  created_by UUID REFERENCES personal(id)
);
```

**Campos mínimos requeridos**:
- `id_paciente`
- `tipo_recurrencia`
- `fecha_servicio_inicio`
- `trayectos`

**Campos opcionales**:
- `codigo` (se genera automáticamente si NULL)
- `fecha_servicio_fin`
- `created_by`

---

## 🔗 Relación con la Arquitectura

### Nivel 1: servicios
- **Propósito**: Cabecera/padre del servicio
- **Contiene**: Información general del servicio
- **Cardinalidad**: 1:N con servicios_recurrentes

### Nivel 2: servicios_recurrentes
- **Propósito**: Configuración de recurrencia
- **Contiene**: Parámetros de recurrencia (días, horarios, etc.)
- **FK**: `id_servicio` → servicios(id)
- **Cardinalidad**: 1:N con traslados

### Nivel 3: traslados
- **Propósito**: Instancias individuales de transporte
- **Contiene**: Fecha específica, estado, tracking
- **FK**: `id_servicio_recurrente` → servicios_recurrentes(id)
- **Generación**: Automática vía trigger

---

## 📝 Checklist de Implementación

- [ ] Crear método `_crearServicioPadre()` en wizard
- [ ] Modificar `_onGuardar()` para llamar a `_crearServicioPadre()` primero
- [ ] Pasar `servicioId` al crear `ServicioRecurrenteEntity`
- [ ] Verificar que `idServicio` no sea null antes de guardar
- [ ] Probar creación end-to-end del wizard
- [ ] Verificar en Supabase que se crearon los 3 niveles:
  - [ ] 1 registro en `servicios`
  - [ ] 1 registro en `servicios_recurrentes` con FK válida
  - [ ] N registros en `traslados` (generados por trigger)

---

## 🚨 Advertencias

1. **NO omitir nivel 1**: Siempre crear servicio padre primero
2. **FK obligatoria**: `id_servicio` es NOT NULL en `servicios_recurrentes`
3. **Orden de creación**: servicios → servicios_recurrentes → traslados (automático)
4. **Trigger automático**: Los traslados se generan solos al crear servicios_recurrentes
5. **Cascada**: Si se elimina servicio, se eliminan servicios_recurrentes y traslados

---

## 📚 Documentación Relacionada

- **Arquitectura completa**: `ARQUITECTURA_SERVICIOS.md`
- **Migraciones pendientes**: `../../supabase/migrations/LEER_PRIMERO_MIGRACIONES_PENDIENTES.md`
- **Contratos**: `../../packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/`
