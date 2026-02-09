# Plan de Implementación - Wizard Modalidad (Paso 2)

## Objetivo
Implementar el Paso 2 "Modalidad" del wizard de creación de servicios, permitiendo configurar recurrencia y programación de horarios.

## Alcance
- Selector de 6 tipos de recurrencia
- Configuraciones dinámicas según tipo seleccionado
- Grid de horarios (modo plantilla vs expandido)
- Auto-cálculo de tiempos basado en motivo de traslado
- Validaciones completas
- Integración con estado del wizard

## Análisis de Archivos Existentes

### Archivos a Crear (Nuevos)
1. **Widgets de Configuración de Recurrencia**
   - `lib/features/servicios/presentation/widgets/wizard/recurrence_selector.dart`
   - `lib/features/servicios/presentation/widgets/wizard/recurrence_configs/unico_config.dart`
   - `lib/features/servicios/presentation/widgets/wizard/recurrence_configs/diario_config.dart`
   - `lib/features/servicios/presentation/widgets/wizard/recurrence_configs/semanal_config.dart`
   - `lib/features/servicios/presentation/widgets/wizard/recurrence_configs/dias_alternos_config.dart`
   - `lib/features/servicios/presentation/widgets/wizard/recurrence_configs/fechas_especificas_config.dart`
   - `lib/features/servicios/presentation/widgets/wizard/recurrence_configs/mensual_config.dart`

2. **Grid de Horarios**
   - `lib/features/servicios/presentation/widgets/wizard/schedule_grid.dart`
   - `lib/features/servicios/presentation/widgets/wizard/schedule_grid_plantilla.dart`
   - `lib/features/servicios/presentation/widgets/wizard/schedule_grid_expandido.dart`

3. **Utilidades**
   - `lib/features/servicios/utils/time_calculator.dart`
   - `lib/features/servicios/utils/recurrence_utils.dart`

4. **Modelos/Entities**
   - `lib/features/servicios/domain/entities/configuracion_modalidad.dart`
   - `lib/features/servicios/domain/entities/plantilla_horario.dart`
   - `lib/features/servicios/domain/entities/dia_programado.dart`

### Archivos a Modificar (Existentes)
1. `lib/features/servicios/presentation/widgets/wizard/step_modalidad.dart`
   - Agregar lógica de recurrencia
   - Integrar selector y configuraciones
   - Integrar grid de horarios

2. **BLoC del Wizard** (si existe)
   - Agregar eventos para configuración de modalidad
   - Agregar estados para plantilla vs expandido
   - Validaciones

## Estructura de Archivos

```
lib/features/servicios/
├── domain/
│   └── entities/
│       ├── configuracion_modalidad.dart         [NUEVO]
│       ├── plantilla_horario.dart               [NUEVO]
│       └── dia_programado.dart                  [NUEVO]
│
├── utils/
│   ├── time_calculator.dart                     [NUEVO]
│   └── recurrence_utils.dart                    [NUEVO]
│
└── presentation/
    └── widgets/
        └── wizard/
            ├── step_modalidad.dart              [MODIFICAR]
            ├── recurrence_selector.dart         [NUEVO]
            ├── schedule_grid.dart               [NUEVO]
            ├── schedule_grid_plantilla.dart     [NUEVO]
            ├── schedule_grid_expandido.dart     [NUEVO]
            └── recurrence_configs/
                ├── unico_config.dart            [NUEVO]
                ├── diario_config.dart           [NUEVO]
                ├── semanal_config.dart          [NUEVO]
                ├── dias_alternos_config.dart    [NUEVO]
                ├── fechas_especificas_config.dart [NUEVO]
                └── mensual_config.dart          [NUEVO]
```

## Estimación de Líneas de Código

- **Entities**: ~200 líneas (3 archivos)
- **Utils**: ~300 líneas (2 archivos)
- **Recurrence Selector**: ~150 líneas (1 archivo)
- **Recurrence Configs**: ~600 líneas (6 archivos × ~100 líneas c/u)
- **Schedule Grids**: ~600 líneas (3 archivos)
- **Step Modalidad**: ~400 líneas (modificación)

**Total estimado**: ~2,250 líneas

## Fases de Implementación

### Fase 1: Fundamentos (Entities + Utils)
1. Crear entities para configuración de modalidad
2. Crear utilidades de cálculo de tiempos
3. Crear utilidades de generación de fechas por recurrencia

### Fase 2: Selector de Recurrencia
1. Crear widget selector de 6 tipos
2. Implementar diseño de cards con iconos
3. Agregar feedback visual

### Fase 3: Configuraciones por Tipo
1. Implementar UnicoConfig (fecha única)
2. Implementar DiarioConfig (fecha inicio/fin)
3. Implementar SemanalConfig (días de semana)
4. Implementar DiasAlternosConfig (intervalo)
5. Implementar FechasEspecificasConfig (calendario multi-select)
6. Implementar MensualConfig (días del mes)

### Fase 4: Grid de Horarios
1. Crear ScheduleGrid base
2. Implementar modo PLANTILLA (sin fecha fin)
3. Implementar modo EXPANDIDO (con fecha fin)
4. Agregar funcionalidad "Aplicar a todos"
5. Agregar eliminación de días específicos

### Fase 5: Integración
1. Integrar en step_modalidad.dart
2. Conectar con BLoC (si existe) o estado local
3. Validaciones completas
4. Testing manual

## Decisiones Técnicas

### 1. Manejo de Estado
- **Opción A**: Estado local con StatefulWidget (más simple)
- **Opción B**: BLoC dedicado para wizard (más escalable)
- **Decisión**: Comenzar con estado local, migrar a BLoC si crece

### 2. Widgets de Formulario
- Usar `AppDatePicker` existente
- Usar `AppTimePicker` existente
- Crear widget custom para selector de días de semana

### 3. Validaciones
- Zod no existe en Flutter → usar validaciones manuales
- Validar en cada cambio de configuración
- Validar antes de permitir "Siguiente"

### 4. Persistencia Temporal
- Guardar configuración en memoria durante wizard
- Solo persistir en Supabase al finalizar wizard completo

## Dependencias Requeridas

```yaml
# Verificar si ya existen en pubspec.yaml:
dependencies:
  intl: ^0.19.0  # Para formateo de fechas en español
  collection: ^1.18.0  # Para utilidades de listas
```

## Validaciones Críticas

1. ✅ Al menos un día debe estar programado
2. ✅ Hora de cita es obligatoria para cada día
3. ✅ Fecha fin >= Fecha inicio
4. ✅ Para semanal: al menos un día seleccionado
5. ✅ Hora de cita entre 06:00 y 22:00

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Mitigación |
|--------|-------------|------------|
| Complejidad de grid expandido con muchas fechas | Media | Implementar paginación si > 100 días |
| Performance en cálculos de fechas | Baja | Usar Future/isolates si es necesario |
| Validaciones complejas | Media | Crear clase validadora dedicada |
| Integración con paso anterior | Media | Verificar estructura de datos del Paso 1 |

## Criterios de Éxito

- ✅ Selector de 6 tipos funcional
- ✅ Configuraciones dinámicas funcionan correctamente
- ✅ Grid modo plantilla funciona
- ✅ Grid modo expandido funciona
- ✅ Auto-cálculo de tiempos correcto
- ✅ "Aplicar a todos" funciona
- ✅ Eliminación de días funciona
- ✅ Todas las validaciones implementadas
- ✅ 0 warnings en `flutter analyze`
- ✅ UI responsive y consistente con el resto de la app

## Próximos Pasos

1. ✅ Crear este plan
2. ⏳ Implementar Fase 1 (Entities + Utils)
3. ⏳ Implementar Fase 2 (Selector)
4. ⏳ Implementar Fase 3 (Configuraciones)
5. ⏳ Implementar Fase 4 (Grids)
6. ⏳ Implementar Fase 5 (Integración)
7. ⏳ Testing y refinamiento
8. ⏳ Ejecutar `flutter analyze` y corregir warnings

---

**Fecha de creación**: 2025-01-03
**Última actualización**: 2025-01-03
**Estado**: Planificado
