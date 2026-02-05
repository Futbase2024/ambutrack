# ModernDataTableV2

Tabla de datos moderna con diseño minimalista inspirado en aplicaciones financieras.

## 📍 Ubicación
`lib/core/widgets/tables/modern_data_table_v2.dart`

## 🎨 Características

### Diseño Minimalista
- ✅ Sin bordes gruesos, solo líneas sutiles
- ✅ Hover effect suave (gris claro)
- ✅ Separadores entre filas con Divider
- ✅ Header con fondo gris claro (`AppColors.gray50`)
- ✅ Acciones alineadas a la derecha

### Funcionalidades
- ✅ Columnas sortables con indicador de dirección
- ✅ Hover state en filas
- ✅ Acciones (Ver/Editar/Eliminar) con iconos
- ✅ Estado vacío con icono y mensaje personalizable
- ✅ Flex configurable por columna

### Diferencias con ModernDataTable

| Característica | ModernDataTable | ModernDataTableV2 |
|----------------|-----------------|-------------------|
| **Diseño** | Más robusto con bordes | Minimalista, limpio |
| **Hover** | Azul primario (5% alpha) | Gris claro |
| **Separadores** | Background alternado | Divider entre filas |
| **Acciones** | Izquierda/Centro | Derecha (consistente) |
| **Header** | Gris 50 con border | Gris 50 con border bottom |
| **Estilo** | Corporativo | Financiero/Bancario |

## 🚀 Uso

### Ejemplo Básico

```dart
import 'package:ambutrack_web/core/widgets/tables/modern_data_table_v2.dart';

ModernDataTableV2<TipoPacienteEntity>(
  onEdit: (tipo) => _editTipo(context, tipo),
  onDelete: (tipo) => _confirmDelete(context, tipo),
  sortColumnIndex: _sortColumnIndex,
  sortAscending: _sortAscending,
  onSort: (columnIndex, ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  },
  columns: const [
    ModernDataColumnV2(label: 'NOMBRE', sortable: true),
    ModernDataColumnV2(label: 'DESCRIPCIÓN', sortable: true, flex: 2),
    ModernDataColumnV2(label: 'ESTADO', sortable: true),
  ],
  rows: filtrados.map((tipo) {
    return ModernDataRowV2<TipoPacienteEntity>(
      data: tipo,
      cells: [
        _buildNombreCell(tipo),
        _buildDescripcionCell(tipo),
        _buildEstadoCell(tipo),
      ],
    );
  }).toList(),
  emptyMessage: 'No hay tipos de paciente registrados',
  emptyIcon: Icons.personal_injury_outlined,
)
```

### Parámetros

#### ModernDataTableV2

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `columns` | `List<ModernDataColumnV2>` | ✅ | Columnas de la tabla |
| `rows` | `List<ModernDataRowV2<T>>` | ✅ | Filas con datos |
| `onRowTap` | `Function(T)?` | ❌ | Callback al hacer clic en fila |
| `onEdit` | `Function(T)?` | ❌ | Callback para editar |
| `onDelete` | `Function(T)?` | ❌ | Callback para eliminar |
| `onView` | `Function(T)?` | ❌ | Callback para ver |
| `showActions` | `bool` | ❌ | Mostrar columna de acciones (default: true) |
| `emptyMessage` | `String` | ❌ | Mensaje cuando no hay datos |
| `emptyIcon` | `IconData` | ❌ | Icono para estado vacío |
| `sortColumnIndex` | `int?` | ❌ | Índice de columna ordenada |
| `sortAscending` | `bool` | ❌ | Dirección del ordenamiento |
| `onSort` | `Function(int, bool)?` | ❌ | Callback al ordenar |

#### ModernDataColumnV2

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `label` | `String` | ✅ | Etiqueta de la columna |
| `sortable` | `bool` | ❌ | Si permite ordenar (default: false) |
| `flex` | `int` | ❌ | Flex para ancho de columna (default: 1) |

#### ModernDataRowV2

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `data` | `T` | ✅ | Datos de la fila |
| `cells` | `List<Widget>` | ✅ | Widgets de las celdas |

## 🎯 Cuándo Usar Cada Versión

### Usar ModernDataTable (v1)
- Aplicaciones corporativas tradicionales
- Cuando necesitas filas alternadas de color
- Diseño más robusto y con más peso visual
- Tablas con mucha información

### Usar ModernDataTableV2
- Aplicaciones financieras/bancarias
- Dashboards modernos
- Cuando quieres un diseño minimalista
- Tablas con información clara y concisa
- Aplicaciones SaaS modernas

## 🎨 Personalización de Celdas

```dart
Widget _buildNombreCell(TipoPacienteEntity tipo) {
  return Text(
    tipo.nombre,
    style: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimaryLight,
    ),
  );
}

Widget _buildEstadoCell(TipoPacienteEntity tipo) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: tipo.activo
        ? AppColors.success.withValues(alpha: 0.1)
        : AppColors.gray300,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      tipo.activo ? 'Activo' : 'Inactivo',
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: tipo.activo
          ? AppColors.success
          : AppColors.textSecondaryLight,
      ),
    ),
  );
}
```

## 📊 Estado de Prueba

**Estado**: ✅ En pruebas

**Probado en**:
- ✅ Tipos de Paciente

**Pendiente probar**:
- ⏳ Centros Hospitalarios
- ⏳ Facultativos
- ⏳ Motivos de Traslado
- ⏳ Otras tablas maestras

## 🐛 Issues Conocidos

- Ninguno por ahora

## 🚀 Próximas Mejoras

- [ ] Agregar paginación
- [ ] Agregar filtros por columna
- [ ] Agregar selección múltiple de filas
- [ ] Agregar export a CSV/Excel
- [ ] Agregar resize de columnas

## 📝 Notas

- La columna de descripción usa `flex: 2` para darle más espacio
- Los iconos de acciones usan `AppIconButton` del core
- El hover es más sutil que en la v1 para un look más moderno
- Los separadores usan `Divider` en lugar de background alternado

---

**Creado**: 2025-12-19
**Autor**: Claude + UITableStandardAgent
**Versión**: 2.0
