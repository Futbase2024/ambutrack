# Agente: Patrón Filtros en PageHeader

## Propósito
Mover los filtros de búsqueda de una tabla hacia el `PageHeader` para ganar espacio vertical en la pantalla,
eliminando la fila separadora que contenía título + filtros dentro de la tabla.

## Problema
Las tablas mostraban un `Row` con el título de la lista y los filtros, ocupando ~60px de altura innecesaria.
Esto forzaba a usar alturas de fila más pequeñas para compensar.

## Solución
Incustrar los filtros dentro del `PageHeader` mediante el slot `extra` de `PageHeaderConfig`, y que la página
gestione el estado de filtros, pasándolo como prop a la tabla.

---

## Arquitectura

```
Page (StatefulWidget)
  ├── PageHeader
  │     └── extra: VehiculosFilters(onFilterChanged: _onFilterChanged)
  │
  ├── _filterData ← estado manejado por la página
  │
  └── Expanded
        └── Tabla(filterData: _filterData)  ← recibe filtros como prop
```

## Flujo de Datos

1. **Página** declara `VehiculosFilterData _filterData` como estado
2. **PageHeader** renderiza `VehiculosFilters` en su slot `extra`
3. Usuario interactúa con filtros → callback `_onFilterChanged(filters)` en página
4. Página hace `setState(() => _filterData = filters)`
5. **Tabla** recibe `widget.filterData` y filtra los items internamente

---

## Cambios Necesarios en PageHeader

### `lib/core/widgets/headers/page_header.dart`

El `PageHeaderConfig` y los layouts ya tienen el slot `extra`. Si no existe, añadirlo:

```dart
class PageHeaderConfig {
  // ... campos existentes ...
  final Widget? extra;  // ← Nuevo campo

  const PageHeaderConfig({
    // ... campos existentes ...
    this.extra,
  });
}
```

En el layout desktop renderizarlo:

```dart
// En PageHeader.build:
Column(
  children: [
    _TitleSection(config),
    const SizedBox(height: AppSizes.spacing),
    _StatsSection(config.stats),
    const SizedBox(height: AppSizes.spacing),
    _AddButton(config),
    if (config.extra != null) ...[
      const SizedBox(height: AppSizes.spacing),
      config.extra!,
    ],
  ],
)
```

---

## Migración de Página (StatefulWidget)

### Antes (filtros en tabla)
```dart
class _MyViewState extends State<MyView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(config: PageHeaderConfig(/* ... */)),
        const SizedBox(height: AppSizes.spacing),
        Expanded(child: MyTable(onFilterChanged: _onFilterChanged)),
      ],
    );
  }

  void _onFilterChanged(FilterData data) {
    debugPrint('Filter changed: $data');
  }
}
```

### Después (filtros en header)
```dart
class _MyViewState extends State<MyView> {
  FilterData _filterData = const FilterData();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          config: PageHeaderConfig(
            // ... args existentes ...
            extra: MyFilters(onFilterChanged: _onFilterChanged),
          ),
        ),
        const SizedBox(height: AppSizes.spacing),
        Expanded(child: MyTable(filterData: _filterData)),
      ],
    );
  }

  void _onFilterChanged(FilterData data) {
    setState(() => _filterData = data);
  }
}
```

---

## Migración de Tabla

### Antes (StatefulWidget con filtros internos)
```dart
class MyTable extends StatefulWidget {
  const MyTable({required this.onFilterChanged, super.key});
  final void Function(FilterData) onFilterChanged;
}

class _MyTableState extends State<MyTable> {
  FilterData _filterData = const FilterData();

  void _onFilterChanged(FilterData data) {
    setState(() {
      _filterData = data;
      _currentPage = 0;
    });
    widget.onFilterChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [Text('Título'), MyFilters(onFilterChanged: _onFilterChanged)]),
        // ... tabla ...
      ],
    );
  }
}
```

### Después (solo recibe prop)
```dart
class MyTable extends StatefulWidget {
  const MyTable({required this.filterData, super.key});
  final FilterData filterData;
}

class _MyTableState extends State<MyTable> {
  int _currentPage = 0;

  @override
  void didUpdateWidget(MyTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterData != oldWidget.filterData) {
      _currentPage = 0;  // Resetear página cuando cambian filtros
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar widget.filterData directamente
    final items = widget.filterData.apply(allItems);
    // ... tabla con items filtrados ...
  }
}
```

---

## Checklist de Migración

### Página
- [ ] Convertir a `StatefulWidget` (si no lo es)
- [ ] Añadir `FilterData _filterData` como estado
- [ ] Crear método `_onFilterChanged(FilterData data)` con `setState`
- [ ] Pasar `extra: MyFilters(onFilterChanged: _onFilterChanged)` al `PageHeaderConfig`
- [ ] Pasar `filterData: _filterData` a la tabla
- [ ] Eliminar el `SizedBox` de separación entre header y tabla si se duplica

### Tabla
- [ ] Quitar `onFilterChanged` del constructor
- [ ] Añadir `filterData` como prop requerida
- [ ] Eliminar `_filterData` interno y `_onFilterChanged`
- [ ] Añadir `didUpdateWidget` para resetear `_currentPage`
- [ ] Cambiar referencias de `_filterData` a `widget.filterData`
- [ ] Eliminar el `Row` con título + filtros del `build`
- [ ] Eliminar import de `MyFilters` (ya no se usa aquí)
- [ ] Mantener texto informativo de "Mostrando X de Y items" con filtros activos

### Verificación
- [ ] `flutter analyze` → 0 errores/warnings nuevos
- [ ] `_currentPage` se resetea al cambiar filtros
- [ ] El `hasActiveFilters` sigue funcionando en el `emptyMessage` de `AppDataGridV5`

---

## Ejemplo de Referencia (Completado ✅)

| Archivo | Rol |
|---------|-----|
| `lib/features/vehiculos/vehiculos_page.dart` | Página que gestiona `_filterData` y pasa filtros como `extra` |
| `lib/features/vehiculos/presentation/widgets/vehiculos_table_v4.dart` | Tabla que recibe `filterData` como prop |

---

## Reglas Críticas

1. ✅ **NUNCA** mantener `_filterData` duplicado (página + tabla)
2. ✅ **SIEMPRE** resetear `_currentPage = 0` cuando cambian filtros
3. ✅ **SIEMPRE** usar `didUpdateWidget` en la tabla para detectar cambios
4. ✅ **MANTENER** `hasActiveFilters` en el `emptyMessage` condicional
5. ✅ **CONSERVAR** el texto "Mostrando X de Y" con filtros activos

---

**Creado**: 2026-06-04
**Basado en**: Vehículos (vehiculos_page.dart + vehiculos_table_v4.dart)
**Versión**: 1.0
