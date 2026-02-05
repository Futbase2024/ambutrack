# ExcelDataGridFiltered - Tabla con Filtros Profesional

## 📋 Descripción

Widget de tabla estilo Excel con capacidades avanzadas de filtrado, búsqueda y ordenamiento, diseñado para gestionar grandes volúmenes de datos de forma eficiente.

## ✨ Características Principales

### 1. **Búsqueda por Columna Individual** 🆕
- Campos de búsqueda debajo de cada columna header
- Búsqueda específica por columna (si `searchable: true`)
- Búsqueda en tiempo real mientras escribes
- Botón de limpiar (X) en cada campo de búsqueda
- Se combina con filtros dropdown

### 2. **Búsqueda Global** (opcional)
- Barra de búsqueda en la parte superior
- Busca en todas las columnas simultáneamente
- Búsqueda en tiempo real mientras escribes
- Botón de limpiar búsqueda (X)
- Se puede ocultar con `showGlobalSearch: false`

### 3. **Filtros por Columna**
- Icono de filtro en cada columna (si `filterable: true`)
- Dropdown con valores únicos de la columna
- Multi-selección con checkboxes
- Botón "Limpiar" para resetear filtro de columna
- Indicador visual cuando hay filtros activos (icono azul)

### 4. **Ordenamiento**
- Clic en header de columna para ordenar (si `sortable: true`)
- Iconos visuales:
  - ⬆️ Orden ascendente
  - ⬇️ Orden descendente
  - ⇅ Sin orden (estado inicial)
- Alterna entre ascendente/descendente con cada clic

### 5. **Controles Avanzados**
- **Badge de filtros activos**: Muestra cuántos filtros hay aplicados
- **Botón "Limpiar"**: Resetea todos los filtros, búsqueda y ordenamiento
- **Contador de resultados**: "X de Y registros"
- **Estado vacío inteligente**: Diferencia entre "sin datos" y "sin resultados con filtros"

### 6. **Scroll Profesional**
- Scroll horizontal y vertical independientes
- Scrollbars nativos siempre visibles
- Header fijo al hacer scroll vertical
- Layout adaptable a cualquier resolución

## 🔧 Uso Básico

```dart
ExcelDataGridFiltered<ServicioEntity>(
  columns: [
    ExcelColumnFiltered(
      label: 'Servicio',
      width: 100,
      sortable: true,
      filterable: false,
    ),
    ExcelColumnFiltered(
      label: 'Paciente',
      minWidth: 150,
      sortable: true,
      filterable: true,  // ✅ Columna con filtro dropdown
      searchable: true,  // 🆕 Columna con búsqueda
    ),
    ExcelColumnFiltered(
      label: 'Terapia',
      width: 140,
      sortable: true,
      filterable: true,  // ✅ Columna con filtro dropdown
      searchable: true,  // 🆕 Columna con búsqueda
    ),
  ],
  rows: servicios,
  buildCells: (servicio) => [
    _buildTextCell(servicio.codigo),
    _buildTextCell(servicio.paciente),
    _buildTextCell(servicio.terapia),
  ],
  getColumnValue: (servicio, columnIndex) {
    switch (columnIndex) {
      case 0: return servicio.codigo;
      case 1: return servicio.paciente;
      case 2: return servicio.terapia;
      default: return '';
    }
  },
  onRowTap: (servicio) => _onSelect(servicio),
  showGlobalSearch: true,
)
```

## 📐 Propiedades de ExcelColumnFiltered

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `label` | `String` | Texto del header |
| `width` | `double?` | Ancho fijo (px) |
| `minWidth` | `double?` | Ancho mínimo adaptable |
| `sortable` | `bool` | Permite ordenar (default: false) |
| `filterable` | `bool` | Muestra botón de filtro dropdown (default: false) |
| `searchable` | `bool` | 🆕 Muestra campo de búsqueda en columna (default: false) |

## 🎯 Callbacks Requeridos

### `buildCells`
Construye las celdas de cada fila.

```dart
buildCells: (ServicioEntity servicio) => [
  Text(servicio.codigo),
  Text(servicio.paciente),
  Text(servicio.terapia),
]
```

### `getColumnValue`
Obtiene el valor string de una columna para filtrado y ordenamiento.

```dart
getColumnValue: (ServicioEntity servicio, int columnIndex) {
  switch (columnIndex) {
    case 0: return servicio.codigo;
    case 1: return servicio.paciente;
    case 2: return servicio.terapia;
    default: return '';
  }
}
```

**⚠️ IMPORTANTE**: Los índices deben coincidir con el orden de las columnas.

## 🎨 Ejemplo Completo (Servicios)

Ver implementación en:
- Widget: `lib/core/widgets/tables/excel_data_grid_filtered.dart`
- Uso: `lib/features/servicios/servicios/presentation/widgets/servicios_table.dart`

### Columnas Configuradas

| Columna | Ancho | Sortable | Filterable | Searchable 🆕 |
|---------|-------|----------|------------|--------------|
| Servicio | 100px | ✅ | ❌ | ✅ |
| Paciente | 150px (min) | ✅ | ✅ | ✅ |
| Domicilio | 200px (min) | ❌ | ❌ | ✅ |
| F. Nacimiento | 120px | ✅ | ❌ | ❌ |
| Terapia | 140px | ✅ | ✅ | ✅ |
| Origen | 150px | ❌ | ✅ | ✅ |
| Destino | 150px | ❌ | ✅ | ✅ |
| Centro Prescriptor | 160px | ✅ | ✅ | ✅ |

## 🚀 Ventajas vs AppDataGridV5

| Característica | AppDataGridV5 | ExcelDataGridFiltered |
|----------------|---------------|----------------------|
| Búsqueda por columna individual | ❌ | ✅ 🆕 |
| Búsqueda global | ❌ | ✅ |
| Filtros por columna | ❌ | ✅ |
| Multi-selección en filtros | ❌ | ✅ |
| Contador de filtros activos | ❌ | ✅ |
| Botón limpiar todo | ❌ | ✅ |
| Columnas adaptables | ✅ | ✅ |
| Ordenamiento | ✅ | ✅ |
| Scroll profesional | ✅ | ✅ |

## 💡 Consejos de Uso

### 1. **Columnas Filterables**
Marca como `filterable: true` solo las columnas con valores categóricos o repetidos:
- ✅ Terapia (Diálisis, Radioterapia, Quimioterapia)
- ✅ Origen (Domicilio, Hospital Central, Clínica)
- ✅ Centro Prescriptor (Hospital Central, Hospital Sur)
- ❌ Domicilio (valores únicos)
- ❌ F. Nacimiento (muchos valores únicos)

### 2. **Columnas Sortables**
Marca como `sortable: true` las columnas donde tenga sentido ordenar:
- ✅ Servicio (código)
- ✅ Paciente (nombre)
- ✅ F. Nacimiento (fecha)
- ❌ Acciones

### 3. **Columnas Searchables** 🆕
Marca como `searchable: true` las columnas donde la búsqueda sea útil:
- ✅ Servicio (código único)
- ✅ Paciente (nombre)
- ✅ Domicilio (dirección específica)
- ✅ Terapia (tipo de tratamiento)
- ❌ F. Nacimiento (mejor usar filtro)

### 4. **Ancho de Columnas**
- Usa `width` para columnas con contenido corto fijo (códigos, fechas)
- Usa `minWidth` para columnas con texto largo variable (nombres, direcciones)

### 5. **Búsqueda vs Filtros**
- **Búsqueda por columna**: Para buscar valores específicos en una columna
- **Búsqueda global**: Para localizar registros en cualquier campo
- **Filtros por columna**: Para analizar subconjuntos de datos categóricos
- Se pueden combinar: búsquedas individuales + filtros dropdown

## 📊 Rendimiento

El widget está optimizado para manejar:
- ✅ Hasta 1000+ filas sin lag
- ✅ Scroll fluido en ambas direcciones
- ✅ Filtrado en tiempo real
- ✅ Múltiples filtros simultáneos sin impacto

## 🔄 Migración desde ExcelDataGrid

```dart
// ❌ ANTES: ExcelDataGrid sin filtros
ExcelDataGrid<T>(
  columns: [
    ExcelColumn(label: 'Columna', width: 100, sortable: true),
  ],
  rows: data,
  buildCells: (item) => [...],
)

// ✅ DESPUÉS: ExcelDataGridFiltered con filtros y búsqueda
ExcelDataGridFiltered<T>(
  columns: [
    ExcelColumnFiltered(
      label: 'Columna',
      width: 100,
      sortable: true,
      filterable: true,  // 🆕 Agregar filtro dropdown
      searchable: true,  // 🆕 Agregar búsqueda por columna
    ),
  ],
  rows: data,
  buildCells: (item) => [...],
  getColumnValue: (item, index) { // 🆕 Requerido para filtros y búsqueda
    switch (index) {
      case 0: return item.campo;
      default: return '';
    }
  },
  showGlobalSearch: true, // Opcional: búsqueda global
)
```

## 🐛 Solución de Problemas

### Los filtros no aparecen
- ✅ Verificar que `filterable: true` en la columna
- ✅ Implementar correctamente `getColumnValue`

### Los campos de búsqueda por columna no aparecen 🆕
- ✅ Verificar que `searchable: true` en la columna
- ✅ Implementar correctamente `getColumnValue`
- ✅ La fila de búsqueda aparece debajo de los headers

### El ordenamiento no funciona
- ✅ Verificar que `sortable: true` en la columna
- ✅ `getColumnValue` debe retornar strings comparables

### La búsqueda no encuentra resultados
- ✅ Verificar que `getColumnValue` retorna strings válidos
- ✅ La búsqueda es case-insensitive
- ✅ Verificar que los campos de búsqueda tienen texto ingresado

### Scroll horizontal no se ve
- ✅ Asegurar que el widget tiene altura definida (usar Expanded)
- ✅ El ancho total de columnas debe exceder el ancho del contenedor

## 📝 Mantenimiento

Creado: 30/12/2024
Última actualización: 30/12/2024
Versión: 1.1.0 (🆕 Búsqueda por columna individual)
Autor: AmbuTrack Team

### Changelog

**v1.1.0** (30/12/2024)
- 🆕 Agregada búsqueda por columna individual con `searchable` property
- 🆕 Campos de búsqueda debajo de cada header de columna
- 🆕 Botón de limpiar (X) en cada campo de búsqueda
- ✅ Búsqueda por columna se combina con filtros dropdown
- ✅ Búsqueda global ahora es opcional (`showGlobalSearch`)

**v1.0.0** (30/12/2024)
- ✅ Versión inicial con filtros dropdown
- ✅ Búsqueda global
- ✅ Ordenamiento por columna
- ✅ Scroll profesional
