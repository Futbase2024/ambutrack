# Validaciones Configurables por Trabajador

## 📋 Resumen

Sistema que permite configurar reglas de validación de turnos personalizadas para cada trabajador, adaptándose a diferentes tipos de jornadas laborales y convenios.

## 🎯 Características

### 1. Configuración Individual
Cada trabajador puede tener su propia configuración de validaciones almacenada en `PersonalEntity.configuracionValidaciones`.

### 2. Parámetros Configurables

| Parámetro | Tipo | Descripción | Valor por Defecto |
|-----------|------|-------------|-------------------|
| `permitirDobleTurno` | `bool` | Permite asignar más de un turno por día | `false` |
| `horasMinimasDescanso` | `double` | Horas mínimas de descanso entre turnos | `12` |
| `horasMaximasSemanales` | `double?` | Horas máximas por semana (null = sin límite) | `40` |
| `horasMaximasMensuales` | `double?` | Horas máximas por mes (null = sin límite) | `160` |
| `diasDescansoSemanalMinimo` | `int` | Días de descanso obligatorios por semana | `1` |
| `horasMaximasContinuas` | `double?` | Horas máximas sin descanso prolongado (null = sin límite) | `72` |
| `validacionesActivas` | `bool` | Switch maestro para activar/desactivar validaciones | `true` |
| `motivoExencion` | `String?` | Motivo de exención si las validaciones están desactivadas | `null` |

### 3. Presets Predefinidos

#### 📊 Estándar
```dart
ConfiguracionValidacionEntity.estandar()
```
- **Uso**: Personal de jornada completa estándar
- Horas semanales: 40h
- Descanso entre turnos: 12h
- Descanso semanal: 1 día
- NO permite doble turno

#### 🔥 Guardia 24h
```dart
ConfiguracionValidacionEntity.guardia24h()
```
- **Uso**: Personal de guardias médicas
- SIN límites horarios
- Permite doble turno
- Permite turnos consecutivos sin descanso

#### ⏰ Media Jornada
```dart
ConfiguracionValidacionEntity.mediaJornada()
```
- **Uso**: Personal part-time
- Horas semanales: 20h
- Horas mensuales: 80h
- Descanso entre turnos: 10h

#### ⛔ Sin Validaciones
```dart
ConfiguracionValidacionEntity.sinValidaciones(motivo: "Personal administrativo")
```
- **Uso**: Personal exento de restricciones
- Todas las validaciones desactivadas
- Requiere motivo de exención

## 🖥️ Interfaz de Usuario

### Selector de Preset
Dropdown con 5 opciones predefinidas:
1. 📊 **Estándar** (40h/semana, descanso 12h)
2. 🔥 **Guardia 24h** (sin límites)
3. ⏰ **Media Jornada** (20h/semana)
4. ⛔ **Sin Validaciones**
5. ⚙️ **Personalizado**

### Configuración Detallada
Al seleccionar "Personalizado" o expandir detalles:

- **Switch**: Permitir Doble Turno
- **Campo numérico**: Horas Mínimas de Descanso (0-24h)
- **Campo numérico + Checkbox "Sin límite"**: Horas Máximas Semanales (0-168h)
- **Campo numérico + Checkbox "Sin límite"**: Horas Máximas Mensuales (0-744h)
- **Campo numérico**: Días de Descanso Semanal Mínimo (0-7 días)
- **Campo numérico + Checkbox "Sin límite"**: Horas Máximas Continuas (0-168h)

## 🔄 Flujo de Validación

### 1. Al Crear/Editar Turno

```dart
// Obtener configuración del trabajador
final personal = await personalRepository.getById(idPersonal);
final turnos = await turnosRepository.getByPersonal(idPersonal);

// Validar con configuración personal
final validationResult = await validationService.validateTurno(
  turnoNuevo: nuevoTurno,
  idPersonal: personal.id,
  turnosExistentes: turnos,
  configuracion: personal.configuracionValidaciones, // ← Configuración
);

// Verificar resultado
if (validationResult.hasErrors) {
  // Mostrar errores
  showValidationDialog(validationResult);
} else {
  // Permitir guardar turno
  await turnosRepository.create(nuevoTurno);
}
```

### 2. Lógica de Validación

```dart
// TurnoValidationServiceImpl

// Si validaciones desactivadas → OK inmediato
if (!config.validacionesActivas) {
  return ValidationResult.empty();
}

// Validar doble turno
if (config.permitirDobleTurno) {
  // ✅ Permitir → No validar
} else {
  // ❌ Validar → Error si tiene otro turno el mismo día
}

// Validar horas semanales
if (config.horasMaximasSemanales == null) {
  // ✅ Sin límite → No validar
} else if (horasTrabajadas > config.horasMaximasSemanales) {
  // ❌ Error → Excede límite semanal
}

// ... resto de validaciones
```

## 📊 Ejemplos de Uso

### Ejemplo 1: Enfermera de Urgencias (Estándar)

```dart
// Configuración
ConfiguracionValidacionEntity.estandar()

// Intentos de asignación:
✅ Turno de 8h (lunes) → OK
✅ Turno de 8h (miércoles) con 48h de descanso → OK
❌ 2 turnos el mismo día → ERROR: "No se permite doble turno"
❌ 50h en una semana → ERROR: "Exceso de horas semanales (50h / 40h)"
❌ Turno con solo 8h de descanso → ERROR: "Descanso insuficiente (8h < 12h)"
```

### Ejemplo 2: Médico de Guardia (Guardia 24h)

```dart
// Configuración
ConfiguracionValidacionEntity.guardia24h()

// Intentos de asignación:
✅ Turno de 24h → OK
✅ 2 turnos de 24h el mismo día → OK (permite doble turno)
✅ 80h en una semana → OK (sin límite semanal)
✅ Turno inmediatamente después de otro → OK (sin descanso mínimo)
```

### Ejemplo 3: Administrativo (Sin Validaciones)

```dart
// Configuración
ConfiguracionValidacionEntity.sinValidaciones(
  motivo: "Personal administrativo, no sujeto a convenio sanitario"
)

// Intentos de asignación:
✅ Cualquier turno → OK (sin validaciones)
```

### Ejemplo 4: Técnico Part-Time (Personalizado)

```dart
// Configuración personalizada
ConfiguracionValidacionEntity(
  permitirDobleTurno: false,
  horasMinimasDescanso: 10,
  horasMaximasSemanales: 20,
  horasMaximasMensuales: 80,
  diasDescansoSemanalMinimo: 2,
  horasMaximasContinuas: 24,
  validacionesActivas: true,
)

// Intentos de asignación:
✅ 15h distribuidas en 3 días con 2 días libres → OK
❌ 25h en una semana → ERROR: "Exceso de horas semanales (25h / 20h)"
❌ Turno dejando solo 1 día libre → ERROR: "Faltan días de descanso semanal"
```

## 🗄️ Base de Datos

### Tabla `personal`
Columna añadida:
- `configuracion_validaciones` (JSONB, nullable)

### Estructura JSON
```json
{
  "permitirDobleTurno": false,
  "horasMinimasDescanso": 12.0,
  "horasMaximasSemanales": 40.0,
  "horasMaximasMensuales": 160.0,
  "diasDescansoSemanalMinimo": 1,
  "horasMaximasContinuas": 72.0,
  "validacionesActivas": true,
  "motivoExencion": null
}
```

### Valores Null
- `horasMaximasSemanales: null` → Sin límite semanal
- `horasMaximasMensuales: null` → Sin límite mensual
- `horasMaximasContinuas: null` → Sin límite continuo
- `configuracionValidaciones: null` → Usa configuración estándar por defecto

## 🔧 Archivos Modificados/Creados

### Creados
1. `lib/features/personal/domain/entities/configuracion_validacion_entity.dart`
2. `lib/features/personal/presentation/widgets/configuracion_validaciones_widget.dart`
3. `docs/turnos/validaciones_configurables.md` (este archivo)

### Modificados
1. `lib/features/personal/domain/entities/personal_entity.dart`
   - Campo `configuracionValidaciones` añadido
   - Serialización/deserialización completa

2. `lib/features/turnos/domain/services/turno_validation_service.dart`
   - Método `validateTurno()` acepta `ConfiguracionValidacionEntity?`
   - Métodos individuales con parámetros opcionales

3. `lib/features/turnos/data/services/turno_validation_service_impl.dart`
   - Implementación de validaciones configurables
   - Respeta valores null como "sin límite"
   - Skip de validaciones si `validacionesActivas = false`

4. `lib/features/personal/presentation/widgets/personal_form_dialog.dart`
   - Integración de `ConfiguracionValidacionesWidget`
   - Nueva sección "Configuración de Turnos"

## ✅ Estado de Implementación

- ✅ Entidad de configuración creada con presets
- ✅ Integración en PersonalEntity
- ✅ Servicio de validación actualizado
- ✅ UI widget completo con selector de presets
- ✅ Integración en formulario de Personal
- ✅ Serialización JSON completa
- ✅ 0 errores de compilación
- ⏳ **Pendiente**: Migración de base de datos (añadir columna JSONB)

## 🚀 Próximos Pasos

1. **Migración de Base de Datos**
   ```sql
   ALTER TABLE personal
   ADD COLUMN configuracion_validaciones JSONB;
   ```

2. **Testing**
   - Crear tests unitarios para ConfiguracionValidacionEntity
   - Crear tests para TurnoValidationService con diferentes configuraciones
   - Tests de integración del formulario

3. **Mejoras Opcionales**
   - Historial de cambios en configuración
   - Plantillas de configuración a nivel de empresa
   - Validaciones por tipo de contrato
   - Alertas preventivas antes de exceder límites

---

**Fecha**: 2025-01-20
**Versión**: 1.0
**Feature**: Validaciones Configurables por Trabajador
