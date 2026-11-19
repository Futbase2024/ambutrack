# 🎨 Estándares de Diseño - AmbuTrack Mobile

> **Versión**: 1.0
> **Fecha**: 2026-02-11
> **Basado en**: Módulo de Trámites (referencia de implementación)

## 📐 Principios Fundamentales

### 1. **Color Principal Único**
- ✅ **SIEMPRE** usar `AppColors.primary` (azul #1E40AF) para:
  - Todos los botones de acción
  - Todos los iconos interactivos
  - AppBars
  - Elementos seleccionados
  - Bordes activos
  - Fondos de elementos destacados (con alpha 0.1)

- ❌ **NUNCA** usar colores variables en elementos interactivos
- ❌ **NUNCA** usar `AppColors.success`, `AppColors.secondary`, etc. en botones o iconos

### 2. **Colores Semánticos** (Solo para Indicadores)
Usar **ÚNICAMENTE** para badges de estado y alertas:
- `AppColors.success` → Estados aprobados/correctos
- `AppColors.warning` → Estados pendientes/alertas
- `AppColors.error` → Estados rechazados/errores
- `AppColors.info` → Información contextual

### 3. **Espaciado Compacto**
```dart
// Padding de cards
padding: const EdgeInsets.all(16)

// Espaciado entre elementos
const SizedBox(height: 12)  // Entre cards
const SizedBox(height: 8)   // Entre label y campo

// Bordes redondeados
borderRadius: BorderRadius.circular(12)  // Cards
borderRadius: BorderRadius.circular(10)  // Botones y campos
borderRadius: BorderRadius.circular(8)   // Iconos pequeños
```

### 4. **Elevación Sutil**
```dart
Card(
  elevation: 1,  // ✅ Siempre 1
  shadowColor: AppColors.primary.withValues(alpha: 0.1),
)
```

---

## 🧩 Componentes Estándar

### AppBar
```dart
AppBar(
  title: const Text('Título'),
  backgroundColor: AppColors.primary,
  foregroundColor: Colors.white,
  elevation: 0,
  centerTitle: true,
)
```

### Botones Primarios
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: const Text(
    'Texto del Botón',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

### Cards de Contenido
```dart
Card(
  elevation: 1,
  shadowColor: AppColors.primary.withValues(alpha: 0.1),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con icono
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.icon_name,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Título de Sección',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.gray800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Contenido...
      ],
    ),
  ),
)
```

### Campos de Texto
```dart
TextFormField(
  decoration: InputDecoration(
    hintText: 'Placeholder',
    hintStyle: const TextStyle(
      color: AppColors.gray400,
      fontSize: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.gray300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.gray300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(12),
  ),
)
```

### Selectores de Fecha
```dart
Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: () => _seleccionarFecha(),
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: _fecha != null
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.gray300,
          width: _fecha != null ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _fecha == null
                  ? 'Seleccionar fecha'
                  : dateFormat.format(_fecha!),
              style: TextStyle(
                fontSize: 14,
                fontWeight: _fecha != null
                    ? FontWeight.w500
                    : FontWeight.w400,
                color: _fecha == null
                    ? AppColors.gray400
                    : AppColors.gray900,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.primary,
          ),
        ],
      ),
    ),
  ),
)
```

### Badges de Estado
```dart
Align(
  alignment: Alignment.centerLeft,
  child: IntrinsicWidth(
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  ),
)
```

### Contenedores de Información
```dart
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: AppColors.primary.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: AppColors.primary.withValues(alpha: 0.2),
    ),
  ),
  child: Row(
    children: [
      Icon(
        Icons.info_outline_rounded,
        color: AppColors.primary,
        size: 18,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          'Información relevante',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.gray700,
            height: 1.4,
          ),
        ),
      ),
    ],
  ),
)
```

---

## 🎯 Iconos Estándar

### Acciones en Tablas
```dart
// Ver detalles
AppIconButton(
  icon: Icons.visibility_outlined,
  color: AppColors.info,
  size: 36,
  onPressed: () {},
)

// Editar
AppIconButton(
  icon: Icons.edit_outlined,
  color: AppColors.secondaryLight,
  size: 36,
  onPressed: () {},
)

// Eliminar
AppIconButton(
  icon: Icons.delete_outline,
  color: AppColors.error,
  size: 36,
  onPressed: () {},
)
```

### Iconos en Cards
- Tamaño: 18-20px
- Color: `AppColors.primary`
- Fondo: `AppColors.primary.withValues(alpha: 0.1)`
- Padding: 8px
- Border radius: 8px

---

## 📱 Layouts

### Estructura de Página Típica
```dart
SafeArea(
  child: Scaffold(
    backgroundColor: AppColors.gray50,
    appBar: AppBar(
      title: const Text('Título'),
      backgroundColor: AppColors.primary,
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards con espaciado de 12px entre ellas
        ],
      ),
    ),
  ),
)
```

---

## ✅ Checklist de Implementación

Al crear o actualizar un módulo, verificar:

- [ ] AppBar usa `AppColors.primary`
- [ ] Todos los botones usan `AppColors.primary`
- [ ] Todos los iconos interactivos usan `AppColors.primary`
- [ ] Cards tienen `elevation: 1`
- [ ] Border radius: 12px (cards), 10px (botones/campos), 8px (iconos)
- [ ] Espaciado entre cards: 12px
- [ ] Padding de cards: 16px
- [ ] Badges de estado usan `IntrinsicWidth` para ajustarse al texto
- [ ] Background principal: `AppColors.gray50`
- [ ] Sin colores hardcoded (excepto white/black/transparent)
- [ ] SafeArea obligatorio en todas las páginas

---

## 📚 Referencia de Implementación

El módulo **`lib/features/tramites/`** es la referencia completa de estos estándares:

- **tramites_page.dart** → Página principal con grid
- **solicitar_ausencia_page.dart** → Formulario completo
- **solicitar_vacaciones_page.dart** → Formulario con validaciones
- **mis_tramites_page.dart** → Lista con tabs
- **tramite_detalle_page.dart** → Página de detalle
- **tramite_card.dart** → Card de lista
- **estado_tramite_badge.dart** → Badge con IntrinsicWidth

---

## 🚫 Anti-Patrones (NUNCA HACER)

❌ **NO** usar múltiples colores en botones de un mismo módulo
❌ **NO** usar `AppColors.success` en botones
❌ **NO** usar `elevation > 1` en cards
❌ **NO** crear badges que ocupen todo el ancho (usar IntrinsicWidth)
❌ **NO** usar spacing mayor a 20px entre elementos
❌ **NO** usar colores diferentes en AppBars dentro de la misma app
❌ **NO** hardcodear colores con `Color(0xFF...)`
❌ **NO** usar `AppSizes` (usar valores directos)

---

## 🔄 Proceso de Actualización de Módulo Existente

1. **Identificar** todos los botones y cambiar a `AppColors.primary`
2. **Actualizar** AppBar a color azul
3. **Ajustar** spacing a valores compactos (12-16px)
4. **Reducir** elevation de cards a 1
5. **Cambiar** iconos interactivos a azul
6. **Aplicar** border radius consistente
7. **Ejecutar** `flutter analyze` → 0 warnings
8. **Verificar** visualmente en dispositivo

---

**Última actualización**: 2026-02-11
**Módulo de referencia**: `lib/features/tramites/`
