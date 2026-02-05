# Sesión 2025-12-20: Implementación de Turnos Múltiples y Estilos Especiales

## 📋 Resumen Ejecutivo

Esta sesión continuó el trabajo de la sesión anterior, implementando funcionalidades clave para la gestión de múltiples turnos por día y mejorando la visualización de turnos especiales (12h y 24h) en el cuadrante.

## ✅ Funcionalidades Implementadas

### 1. Múltiples Turnos por Día (UI)

**Problema**: El usuario no podía añadir un segundo turno cuando la celda ya contenía uno.

**Solución**:
- Añadido botón "Añadir turno" al final de cada celda que contiene turnos
- El botón abre el mismo diálogo de creación de turnos
- Permite crear varios turnos no solapados para el mismo trabajador en el mismo día

**Archivos Modificados**:
- `lib/features/cuadrante/presentation/widgets/cuadrante_tabla_view.dart`

**Código Clave**:
```dart
Widget _buildTurnoChips(
  List<TurnoEntity> turnos,
  PersonalConTurnosEntity personalConTurnos,
  DateTime dia,
) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      // Chips de turnos existentes
      ...turnos.map((TurnoEntity turno) => _buildTurnoChip(turno, dia)),
      // Botón para agregar otro turno
      const SizedBox(height: 4),
      _buildAddTurnoButton(personalConTurnos, dia),
    ],
  );
}

Widget _buildAddTurnoButton(PersonalConTurnosEntity personalConTurnos, DateTime dia) {
  return Builder(
    builder: (BuildContext context) {
      return InkWell(
        onTap: () => _showAsignarTurnoDialog(context, personalConTurnos, dia),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.add_circle_outline, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Añadir turno',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
```

### 2. Validación Mejorada de Descanso entre Turnos

**Problema**: `validateDescansoEntreTurnos()` comparaba solo fechas, no fecha+hora, causando falsos positivos para turnos consecutivos el mismo día.

**Solución**:
- Modificado para usar `_combinarFechaHora()` que crea objetos `DateTime` precisos
- Calcula la diferencia real entre fin de un turno e inicio del siguiente
- Funciona en ambas direcciones (turno1 antes de turno2 y viceversa)

**Archivos Modificados**:
- `lib/features/turnos/data/services/turno_validation_service_impl.dart`

**Código Clave**:
```dart
@override
ValidationResult validateDescansoEntreTurnos({
  required TurnoEntity turnoNuevo,
  required List<TurnoEntity> turnosExistentes,
  required double horasMinimasDescanso,
}) {
  for (final TurnoEntity turnoExistente in turnosExistentes) {
    // Combinar fecha+hora para comparación precisa
    final DateTime finTurnoExistente = _combinarFechaHora(
      turnoExistente.fechaFin,
      turnoExistente.horaFin,
    );
    final DateTime inicioTurnoNuevo = _combinarFechaHora(
      turnoNuevo.fechaInicio,
      turnoNuevo.horaInicio,
    );

    // Calcular tiempo entre fin de un turno e inicio del siguiente
    if (inicioTurnoNuevo.isAfter(finTurnoExistente)) {
      final Duration diferencia = inicioTurnoNuevo.difference(finTurnoExistente);

      if (diferencia.inMinutes < (horasMinimasDescanso * 60)) {
        return ValidationResult.error(
          ValidationIssue(
            ruleType: ValidationRuleType.descansoInsuficiente,
            severity: ValidationSeverity.error,
            message:
                'Descanso insuficiente entre turnos (${(diferencia.inMinutes / 60).toStringAsFixed(1)}h)',
            details:
                'Se requiere un mínimo de $horasMinimasDescanso horas de descanso entre turnos',
            suggestedAction:
                'Ajusta la fecha/hora del turno para garantizar el descanso',
          ),
        );
      }
    }

    // También verificar en sentido inverso
    final DateTime finTurnoNuevo = _combinarFechaHora(
      turnoNuevo.fechaFin,
      turnoNuevo.horaFin,
    );
    final DateTime inicioTurnoExistente = _combinarFechaHora(
      turnoExistente.fechaInicio,
      turnoExistente.horaInicio,
    );

    if (finTurnoNuevo.isBefore(inicioTurnoExistente)) {
      final Duration diferencia = inicioTurnoExistente.difference(finTurnoNuevo);

      if (diferencia.inMinutes < (horasMinimasDescanso * 60)) {
        return ValidationResult.error(
          ValidationIssue(
            ruleType: ValidationRuleType.descansoInsuficiente,
            severity: ValidationSeverity.error,
            message:
                'Descanso insuficiente entre turnos (${(diferencia.inMinutes / 60).toStringAsFixed(1)}h)',
            details:
                'Se requiere un mínimo de $horasMinimasDescanso horas de descanso entre turnos',
            suggestedAction:
                'Ajusta la fecha/hora del turno para garantizar el descanso',
          ),
        );
      }
    }
  }

  return ValidationResult.empty();
}
```

### 3. Plantillas Disponibles al Editar

**Problema**: El selector de plantillas solo aparecía al crear turnos nuevos, no al editarlos.

**Solución**:
- Eliminada la condición `if (!isEditing)` que ocultaba el selector
- Ahora las plantillas están disponibles tanto en modo creación como edición

**Archivos Modificados**:
- `lib/features/turnos/presentation/widgets/turno_form_dialog.dart`

**Cambio**:
```dart
// ANTES (línea ~140)
if (!isEditing)
  _buildPlantillaSelector(),

// DESPUÉS
_buildPlantillaSelector(),
```

### 4. Auto-detección de Turnos que Cruzan Medianoche

**Problema**: Los turnos personalizados como 22:00-06:00 no detectaban automáticamente que debían abarcar 2 días.

**Solución**:
- Añadida detección en el listener `_onHoraFocusChanged()`
- Si `horaFin <= horaInicio` en turno personalizado, ajusta automáticamente `fechaFin` al día siguiente
- Se activa al perder foco del campo (Tab, Enter, o clic fuera)

**Archivos Modificados**:
- `lib/features/turnos/presentation/widgets/turno_form_dialog.dart`

**Código Clave**:
```dart
void _onHoraFocusChanged() {
  // Solo procesar cuando el campo pierde el foco
  if (_horaInicioFocusNode.hasFocus || _horaFinFocusNode.hasFocus) {
    return;
  }

  // Autoformatear las horas cuando pierden el foco
  final String horaInicioFormatted = _formatTimeInput(_horaInicioController.text);
  final String horaFinFormatted = _formatTimeInput(_horaFinController.text);

  if (horaInicioFormatted != _horaInicioController.text) {
    _horaInicioController.value = TextEditingValue(
      text: horaInicioFormatted,
      selection: TextSelection.collapsed(offset: horaInicioFormatted.length),
    );
  }

  if (horaFinFormatted != _horaFinController.text) {
    _horaFinController.value = TextEditingValue(
      text: horaFinFormatted,
      selection: TextSelection.collapsed(offset: horaFinFormatted.length),
    );
  }

  // Solo procesar si es turno personalizado y ambos campos tienen valores válidos
  if (!_isCustomTime) {
    return;
  }

  final String horaInicio = _horaInicioController.text;
  final String horaFin = _horaFinController.text;

  // Validar formato básico HH:mm antes de procesar
  final RegExp regex = RegExp(r'^\d{2}:\d{2}$');
  if (!regex.hasMatch(horaInicio) || !regex.hasMatch(horaFin)) {
    return;
  }

  // Detectar si cruza medianoche
  if (_cruzaMedianoche(horaInicio, horaFin)) {
    if (_fechaFin == _fechaInicio || _fechaFin.isBefore(_fechaInicio.add(const Duration(days: 1)))) {
      setState(() {
        _fechaFin = _fechaInicio.add(const Duration(days: 1));
        debugPrint('🌙 Turno personalizado cruza medianoche: $horaInicio-$horaFin | Ajustando fechaFin');
      });
    }
  } else {
    if (_fechaFin != _fechaInicio) {
      setState(() {
        _fechaFin = _fechaInicio;
        debugPrint('☀️ Turno personalizado mismo día: $horaInicio-$horaFin');
      });
    }
  }
}
```

### 5. Auto-formateo con Tab

**Problema**: El auto-formateo de horas solo funcionaba con Enter, no con Tab.

**Solución**:
- Reemplazado `onEditingComplete` (solo Enter) con `FocusNode` listeners
- Los listeners se disparan cuando el campo pierde foco (Tab, Enter, o clic fuera)
- Formatea automáticamente: "8" → "08:00", "830" → "08:30", "1430" → "14:30"

**Archivos Modificados**:
- `lib/features/turnos/presentation/widgets/turno_form_dialog.dart`

**Código Clave**:
```dart
// En initState()
_horaInicioFocusNode = FocusNode();
_horaFinFocusNode = FocusNode();

_horaInicioFocusNode.addListener(_onHoraFocusChanged);
_horaFinFocusNode.addListener(_onHoraFocusChanged);

// En dispose()
@override
void dispose() {
  // Remover listeners
  _horaInicioFocusNode.removeListener(_onHoraFocusChanged);
  _horaFinFocusNode.removeListener(_onHoraFocusChanged);

  // Disponer FocusNodes
  _horaInicioFocusNode.dispose();
  _horaFinFocusNode.dispose();

  // Disponer controllers
  _nombrePersonalController.dispose();
  _observacionesController.dispose();
  _horaInicioController.dispose();
  _horaFinController.dispose();

  super.dispose();
}

// En _buildTimeField()
Widget _buildTimeField({
  required String label,
  required TextEditingController controller,
  required bool enabled,
  FocusNode? focusNode, // NUEVO parámetro
}) {
  return TextFormField(
    controller: controller,
    focusNode: focusNode, // ASIGNADO
    enabled: enabled,
    // ... resto del código
  );
}
```

### 6. Estilos Especiales para Turnos de 12 Horas ⭐

**Problema**: Los turnos de 12 horas (día y noche) necesitaban representación visual distintiva como los de 24 horas.

**Solución**:
- Creados métodos de detección algorítmica:
  - `_esTurno12Horas()`: Detecta cualquier turno de 11.5-12.5 horas
  - `_esTurno12HorasDia()`: 12 horas que NO cruzan medianoche
  - `_esTurno12HorasNoche()`: 12 horas que SÍ cruzan medianoche
- Mejorado `_buildTurnoChip()` para aplicar estilos especiales

**Archivos Modificados**:
- `lib/features/cuadrante/presentation/widgets/cuadrante_tabla_view.dart`

**Código Clave**:

```dart
/// Detecta si un turno es de 12 horas (11.5h - 12.5h)
bool _esTurno12Horas(TurnoEntity turno) {
  final List<String> partesInicio = turno.horaInicio.split(':');
  final List<String> partesFin = turno.horaFin.split(':');

  if (partesInicio.length != 2 || partesFin.length != 2) {
    return false;
  }

  final int minutosInicio = (int.tryParse(partesInicio[0]) ?? 0) * 60 + (int.tryParse(partesInicio[1]) ?? 0);
  int minutosFin = (int.tryParse(partesFin[0]) ?? 0) * 60 + (int.tryParse(partesFin[1]) ?? 0);

  // Si cruza medianoche, sumar 24 horas al fin
  if (_cruzaMedianoche(turno)) {
    minutosFin += 24 * 60;
  }

  final int duracionMinutos = minutosFin - minutosInicio;
  final double duracionHoras = duracionMinutos / 60.0;

  // Considerar 12 horas si la duración está entre 11.5 y 12.5 horas
  return duracionHoras >= 11.5 && duracionHoras <= 12.5;
}

/// Detecta turno de 12 horas diurno (no cruza medianoche)
bool _esTurno12HorasDia(TurnoEntity turno) {
  return _esTurno12Horas(turno) && !_cruzaMedianoche(turno);
}

/// Detecta turno de 12 horas nocturno (cruza medianoche)
bool _esTurno12HorasNoche(TurnoEntity turno) {
  return _esTurno12Horas(turno) && _cruzaMedianoche(turno);
}

// En _buildTurnoChip()
Widget _buildTurnoChip(TurnoEntity turno, DateTime dia) {
  // Detectar tipo especial de turno
  final bool cruzaMedianoche = _cruzaMedianoche(turno);
  final bool esTurno24h = _esTurno24Horas(turno);
  final bool esTurno12hDia = _esTurno12HorasDia(turno);
  final bool esTurno12hNoche = _esTurno12HorasNoche(turno);

  // Determinar color, emoji y texto según tipo especial
  late Color color;
  late String emoji;
  late String tipoTurnoText;

  if (esTurno24h) {
    color = AppColors.emergency; // Rojo
    emoji = '🚨';
    tipoTurnoText = 'Turno 24 Horas';
  } else if (esTurno12hDia) {
    color = AppColors.primary; // Azul principal
    emoji = '☀️';
    tipoTurnoText = 'Turno 12h Día';
  } else if (esTurno12hNoche) {
    color = AppColors.secondaryDark; // Verde oscuro
    emoji = '🌛';
    tipoTurnoText = 'Turno 12h Noche';
  } else {
    color = _getTurnoColor(turno.tipoTurno);
    emoji = _getTurnoEmoji(turno.tipoTurno);
    tipoTurnoText = turno.tipoTurno.nombre;
  }

  // ... resto del rendering
}
```

**Estilos Aplicados**:
| Tipo Turno | Color | Emoji | Texto | Días |
|-----------|-------|-------|-------|------|
| 24 Horas | Rojo (`AppColors.emergency`) | 🚨 | "Turno 24 Horas" | 2 |
| 12h Día | Azul (`AppColors.primary`) | ☀️ | "Turno 12h Día" | 1 |
| 12h Noche | Verde oscuro (`AppColors.secondaryDark`) | 🌛 | "Turno 12h Noche" | 2 |
| Otros | Color del tipo de turno | Emoji del tipo | Nombre del tipo | Variable |

## 🐛 Errores Corregidos

### Error 1: Undefined 'widget' identifier
**Ubicación**: `cuadrante_tabla_view.dart:398`

**Causa**: Intenté acceder a `widget.personalList` dentro de un método privado sin contexto de widget.

**Solución**: Modifiqué `_buildTurnoChips()` para aceptar `personalConTurnos` como parámetro.

### Error 2: Duplicate dispose() method
**Ubicación**: `turno_form_dialog.dart:251`

**Causa**: Creé un nuevo método `dispose()` con limpieza de FocusNode, pero el antiguo seguía existiendo.

**Solución**: Eliminé el método `dispose()` antiguo, mantuve solo el nuevo con limpieza completa.

## 📊 Estado del Proyecto

### Flutter Analyze
```bash
flutter analyze
# Resultado: 18 issues found (todos informativos pre-existentes)
# Ningún error nuevo introducido por esta sesión
```

**Warnings Informativos**:
- `close_sinks`: 2 instancias (realtime_datasource.dart)
- `avoid_positional_boolean_parameters`: 3 instancias (widgets core)
- `deprecated_member_use`: 1 instancia (withOpacity)
- `cascade_invocations`: 8 instancias (varios archivos)
- `always_put_control_body_on_new_line`: 4 instancias (varios archivos)

**Ninguno de estos warnings está relacionado con el trabajo de esta sesión.**

## 🎯 Próximos Pasos Sugeridos

### Para Probar
1. **Crear múltiples turnos en el mismo día**
   - Crear un turno 07:00-15:00
   - Añadir segundo turno 15:00-23:00 usando botón "Añadir turno"
   - Verificar que no hay error de validación (0h de descanso es permitido si son consecutivos)

2. **Probar turnos de 12 horas día**
   - Crear turno 08:00-20:00
   - Verificar que aparece con color azul, emoji ☀️, y texto "Turno 12h Día"
   - Verificar que solo ocupa 1 celda (mismo día)

3. **Probar turnos de 12 horas noche**
   - Crear turno 20:00-08:00
   - Verificar que aparece con color verde oscuro, emoji 🌛, y texto "Turno 12h Noche"
   - Verificar que ocupa 2 celdas (día actual 20:00-00:00, día siguiente 00:00-08:00)

4. **Probar auto-formateo con Tab**
   - En turno personalizado, escribir "8" en Hora Inicio
   - Presionar Tab
   - Verificar que se formatea a "08:00"
   - Escribir "2030" en Hora Fin
   - Presionar Tab
   - Verificar que se formatea a "20:30"

5. **Probar auto-detección de medianoche**
   - Crear turno personalizado
   - Hora Inicio: "22:00"
   - Hora Fin: "06:00"
   - Presionar Tab para salir del campo
   - Verificar que Fecha Fin se ajusta automáticamente al día siguiente

6. **Probar plantillas al editar**
   - Editar un turno existente
   - Verificar que aparece el selector de plantillas
   - Cambiar a plantilla "24 Horas"
   - Guardar y verificar que se aplicó correctamente

### Posibles Mejoras Futuras

1. **Validaciones Adicionales**
   - Límite de turnos consecutivos por semana
   - Alertas de fatiga por acumulación de turnos nocturnos
   - Detección de patrones irregulares

2. **Visualización**
   - Tooltip con detalles completos del turno al hacer hover
   - Indicador visual de conflictos potenciales
   - Leyenda de colores en el cuadrante

3. **UX**
   - Atajos de teclado para crear turnos rápidamente
   - Drag & drop para mover turnos entre días
   - Copiar/pegar turnos entre trabajadores

4. **Reportes**
   - Informe de horas trabajadas por tipo de turno
   - Distribución de turnos nocturnos vs diurnos
   - Cumplimiento de descansos mínimos

## 📚 Referencias Técnicas

### Archivos Principales Modificados
1. `lib/features/cuadrante/presentation/widgets/cuadrante_tabla_view.dart`
   - `_buildTurnoChips()` - Añadido botón "Añadir turno"
   - `_buildAddTurnoButton()` - Nuevo widget para botón
   - `_esTurno12Horas()` - Detección de turnos 12h
   - `_esTurno12HorasDia()` - Detección turnos 12h día
   - `_esTurno12HorasNoche()` - Detección turnos 12h noche
   - `_buildTurnoChip()` - Estilos especiales por tipo

2. `lib/features/turnos/presentation/widgets/turno_form_dialog.dart`
   - Eliminada condición `if (!isEditing)` en plantillas
   - Añadidos `FocusNode` para campos de hora
   - `_onHoraFocusChanged()` - Listener para auto-formateo y detección medianoche
   - `dispose()` - Limpieza de FocusNodes

3. `lib/features/turnos/data/services/turno_validation_service_impl.dart`
   - `validateDescansoEntreTurnos()` - Comparación precisa con fecha+hora

### Conceptos Clave

**Detección de Medianoche**:
```dart
bool _cruzaMedianoche(String horaInicio, String horaFin) {
  return horaFin.compareTo(horaInicio) <= 0;
}
```

**Cálculo de Duración con Medianoche**:
```dart
int duracionMinutos = minutosFin - minutosInicio;
if (_cruzaMedianoche(turno)) {
  minutosFin += 24 * 60; // Añadir 24 horas
  duracionMinutos = minutosFin - minutosInicio;
}
```

**Formateo de Horas**:
```dart
String _formatTimeInput(String input) {
  // "8" → "08:00"
  // "830" → "08:30"
  // "1430" → "14:30"
  // "08:00:00" → "08:00"
}
```

## ✅ Completado

- [x] Implementar botón "Añadir turno" en celdas con turnos existentes
- [x] Corregir validación de descanso entre turnos (fecha+hora precisa)
- [x] Habilitar plantillas en modo edición
- [x] Auto-detectar turnos que cruzan medianoche
- [x] Auto-formateo con Tab (no solo Enter)
- [x] Detección y estilo especial para turnos 12h día
- [x] Detección y estilo especial para turnos 12h noche
- [x] Verificar con flutter analyze (0 errores nuevos)
- [x] Documentar todo el trabajo realizado

## 📝 Notas Finales

El sistema de turnos ahora es mucho más robusto y visualmente intuitivo:
- Los usuarios pueden crear múltiples turnos por día sin restricciones artificiales
- La validación de descanso entre turnos funciona correctamente con fecha+hora precisa
- Los turnos especiales (24h, 12h día, 12h noche) son fácilmente identificables por color
- El UX es más fluido con auto-formateo y auto-detección de medianoche
- El código está limpio y sin nuevos warnings

**Estado**: ✅ Listo para testing y feedback del usuario.
