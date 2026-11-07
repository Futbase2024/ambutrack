# Agente: Patrón de Filas Compactas y Profesionales

## Propósito
Estandarizar la altura de filas en tablas (`AppDataGridV5`) para que sean más compactas, profesionales y consistentes en todo el proyecto.

## Problema
Las tablas tenían alturas de fila grandes (60-72px) que desperdiciaban espacio vertical,
obligando al usuario a hacer scroll para ver pocos registros.

## Solución
Reducir `rowHeight` a 48px, añadir `headerHeight: 44`, footer más compacto (`paddingSmall` + IconButtons 36x36), y usar bordes más sutiles (`gray300`).

---

## Configuración Estándar

### AppDataGridV5
```dart
AppDataGridV5<MyEntity>(
  // ... columnas, rows, buildCells ...
  sortColumnIndex: _sortColumnIndex,
  sortAscending: _sortAscending,
  onSort: _onSort,
  // rowHeight: 48 ya es el valor por defecto en AppDataGridV5
  headerHeight: 44,                    // ← 44px (antes ~56px default)
  outerBorderColor: AppColors.gray300, // ← gray300 (antes gray400)
  ...
)
```

### SizedBox compacto
En los separadores verticales dentro de la tabla:
```dart
// ✅ Usar SizedBox(height: 1) en lugar de 2
SizedBox(height: 1)
```

### Celdas de texto compactas
```dart
// Estilos recomendados para celdas compactas
AppTextStyles.tableCell        // ← cuerpo compacto
AppTextStyles.tableCellBold    // ← énfasis
AppTextStyles.tableCellSmall   // ← texto muy pequeño (contacto, metadata)
```

---

## Valores Antes/Después

| Propiedad | Antes | Después |
|-----------|-------|---------|
| `rowHeight` | 60-72px | 48px (default) |
| `headerHeight` | *default* (~56px) | 44px |
| `outerBorderColor` | `gray400` | `gray300` |
| `SizedBox` separadores | 2px | 1px |
| Footer padding | `paddingMedium` (12px) | `paddingSmall` (8px) |
| IconButton footer | 48x48 (default) | 36x36 (`minWidth/minHeight`) |

---

## Migración

### 1. Ajustar AppDataGridV5
```dart
// ❌ Antes
rowHeight: 60.0,
outerBorderColor: AppColors.gray400,

// ✅ Después
headerHeight: 44,
outerBorderColor: AppColors.gray300,
// rowHeight: 48 no necesario (es el default en AppDataGridV5)
```

### 2. Ajustar SizedBox
```dart
// ❌ Antes
SizedBox(height: AppSizes.spacingSmall) // o 2

// ✅ Después
SizedBox(height: 1)
```

### 3. Paginación compacta (footer)

```dart
return Container(
  padding: const EdgeInsets.all(AppSizes.paddingSmall),  // ← paddingSmall (8px)
  decoration: BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
    border: Border.all(color: AppColors.gray200),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text(
        'Mostrando $startItem-$endItem de $totalItems items',
        style: AppTextStyles.bodySmallSecondary,
      ),
      Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.first_page),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36), // ← compacto
            ...
          ),
          // ... mismo patrón para chevron_left, badge página, chevron_right, last_page
        ],
      ),
    ],
  ),
);
```

**Cambios clave:**
- `padding: EdgeInsets.all(AppSizes.paddingSmall)` (8px en vez de 12px)
- `constraints: BoxConstraints(minWidth: 36, minHeight: 36)` en IconButtons (en vez de 48px default)
- Badge de página: `padding vertical: 4` (en vez de `paddingSmall` 8px)

---

## Checklist

- [ ] `headerHeight: 44` en AppDataGridV5
- [ ] `outerBorderColor: AppColors.gray300`
- [ ] Separadores verticales con `SizedBox(height: 1)`
- [ ] Footer paginación: `paddingSmall` + IconButton 36x36
- [ ] `flutter analyze` → 0 errores/warnings nuevos

---

## Ejemplos de Referencia

| Archivo | Estado |
|---------|--------|
| `lib/features/vehiculos/presentation/widgets/vehiculos_table_v4.dart` | ✅ Completado |
| `lib/features/personal/presentation/widgets/personal_table_v4.dart` | ✅ Completado |

---

## Reglas Críticas

1. ✅ **SIEMPRE** añadir `headerHeight: 44`
2. ✅ **SIEMPRE** usar `outerBorderColor: AppColors.gray300`
3. ✅ **CONFÍA** en el `rowHeight: 48` por defecto de `AppDataGridV5`
4. ✅ **SIEMPRE** footer con `AppSizes.paddingSmall` + IconButton 36x36

---

**Creado**: 2026-06-04
**Basado en**: Vehículos (vehiculos_table_v4.dart)
**Versión**: 1.0
