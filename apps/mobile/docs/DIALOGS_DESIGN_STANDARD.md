# Estándar de Diseño de Diálogos - AmbuTrack Mobile

> **Fecha de creación**: 2026-02-13
> **Última actualización**: 2026-02-13
> **Versión**: 1.0.0

## 📐 BorderRadius Estandarizado

Todos los diálogos en AmbuTrack Mobile deben seguir este estándar de `borderRadius` para mantener consistencia visual y una apariencia profesional.

### Reglas Obligatorias

| Elemento | BorderRadius | Justificación |
|----------|--------------|---------------|
| **Dialog principal** | `16` | Menos redondeado, más profesional. Consistente con Material Design 3 |
| **Botones (todos)** | `10` | Apariencia cuadrada (no ovalada). Profesional y moderna |
| **Elementos internos** | `8` (AppSizes.radiusSmall) | Sutilmente redondeados para contraste visual |

---

## 🎨 Estructura de Dialog Estándar

### Template Base

```dart
Dialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16), // ✅ OBLIGATORIO
  ),
  child: Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16), // ✅ Coincide con Dialog
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Contenido del diálogo
      ],
    ),
  ),
)
```

### Botones de Acción

#### OutlinedButton (Cancelar/Cerrar)

```dart
OutlinedButton(
  onPressed: () => Navigator.of(context).pop(),
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14),
    side: const BorderSide(color: AppColors.gray300),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // ✅ OBLIGATORIO
    ),
  ),
  child: const Text('Cancelar'),
)
```

#### ElevatedButton (Confirmar/Aceptar)

```dart
ElevatedButton(
  onPressed: _onConfirm,
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // ✅ OBLIGATORIO
    ),
  ),
  child: const Text('Confirmar'),
)
```

---

## 📋 Ejemplos de Referencia

### ✅ Diálogos Profesionales (Core)

Archivos base que ya cumplen el estándar:

- [`lib/core/widgets/dialogs/professional_confirm_dialog.dart`](../lib/core/widgets/dialogs/professional_confirm_dialog.dart)
- [`lib/core/widgets/dialogs/professional_result_dialog.dart`](../lib/core/widgets/dialogs/professional_result_dialog.dart)

### ✅ Diálogos Específicos (Features)

Archivos actualizados que cumplen el estándar:

1. **Notificaciones**
   - [`notificacion_in_app_dialog.dart`](../lib/features/notificaciones/presentation/widgets/notificacion_in_app_dialog.dart)

2. **Registro Horario**
   - [`cambiar_vehiculo_dialog.dart`](../lib/features/registro_horario/presentation/widgets/cambiar_vehiculo_dialog.dart)
   - [`ubicacion_fichaje_dialog.dart`](../lib/features/registro_horario/presentation/widgets/ubicacion_fichaje_dialog.dart)

3. **Caducidades**
   - [`editar_caducidad_dialog.dart`](../lib/features/caducidades/presentation/widgets/dialogs/editar_caducidad_dialog.dart)
   - [`registrar_incidencia_dialog.dart`](../lib/features/caducidades/presentation/widgets/dialogs/registrar_incidencia_dialog.dart)
   - [`solicitud_reposicion_dialog.dart`](../lib/features/caducidades/presentation/widgets/dialogs/solicitud_reposicion_dialog.dart)

---

## 🚫 Anti-Patrones (Evitar)

### ❌ BorderRadius Inconsistente

```dart
// ❌ NO HACER: borderRadius 20 (demasiado redondeado)
Dialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20), // ❌ INCORRECTO
  ),
)

// ❌ NO HACER: borderRadius 12 en botones (ovalados)
OutlinedButton(
  style: OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // ❌ INCORRECTO
    ),
  ),
)
```

### ❌ Sin BorderRadius Explícito

```dart
// ❌ NO HACER: Omitir shape en botones
OutlinedButton(
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14),
    // ❌ Falta shape con borderRadius: 10
  ),
  child: const Text('Cancelar'),
)
```

---

## 🔍 Checklist de Validación

Antes de marcar un diálogo como completo, verificar:

- [ ] Dialog principal tiene `borderRadius: BorderRadius.circular(16)`
- [ ] Container interno (si existe) tiene `borderRadius: BorderRadius.circular(16)`
- [ ] **TODOS** los OutlinedButton tienen `shape` con `borderRadius: 10`
- [ ] **TODOS** los ElevatedButton tienen `shape` con `borderRadius: 10`
- [ ] Elementos internos (Cards, Containers decorativos) usan `AppSizes.radiusSmall (8)`
- [ ] Ejecutar `flutter analyze` → 0 warnings relacionados

---

## 📊 Métricas de Consistencia

### Auditoría 2026-02-13

| Tipo de Dialog | Total | Cumple Estándar | Progreso |
|----------------|-------|-----------------|----------|
| Core (professional) | 2 | 2 | ✅ 100% |
| Notificaciones | 1 | 1 | ✅ 100% |
| Registro Horario | 2 | 2 | ✅ 100% |
| Caducidades | 3 | 3 | ✅ 100% |
| **TOTAL** | **8** | **8** | **✅ 100%** |

---

## 🎯 Principios de Diseño

### Por qué estos valores

1. **BorderRadius 16 (Dialog)**
   - Alineado con Material Design 3
   - No demasiado redondeado (profesional)
   - No demasiado cuadrado (moderno)

2. **BorderRadius 10 (Botones)**
   - Apariencia cuadrada pero no rígida
   - Evita look "ovalado" de valores mayores
   - Consistente con botones de acción principales

3. **BorderRadius 8 (Internos)**
   - Contraste sutil con elementos principales
   - Mantiene jerarquía visual
   - Reutiliza `AppSizes.radiusSmall`

---

## 🛠️ Comando de Verificación

Para buscar diálogos que NO cumplen el estándar:

```bash
# Buscar Dialog con borderRadius != 16
grep -r "Dialog(" lib/ | xargs grep -l "borderRadius.*circular" | \
  xargs grep "borderRadius.*circular" | grep -v "circular(16)"

# Buscar botones con borderRadius != 10
grep -r "OutlinedButton\|ElevatedButton" lib/ | \
  xargs grep -l "borderRadius" | \
  xargs grep "borderRadius.*circular" | grep -v "circular(10)\|circular(8)"
```

---

## 📚 Referencias

- Material Design 3: [Dialogs](https://m3.material.io/components/dialogs/overview)
- AppSizes: [`lib/core/theme/app_sizes.dart`](../lib/core/theme/app_sizes.dart)
- AppColors: [`lib/core/theme/app_colors.dart`](../lib/core/theme/app_colors.dart)

---

## 🔄 Historial de Cambios

### v1.0.0 - 2026-02-13

- ✅ Estandarización inicial de 8 diálogos
- ✅ Dialog: 20 → 16
- ✅ Botones: 12/sin shape → 10
- ✅ Documentación creada
- ✅ Agente UIDesigner actualizado
