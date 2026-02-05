# AppDataTable - Widget de Tabla Común

## 📋 Descripción

`AppDataTable` es el widget estándar para todas las tablas de datos en AmbuTrack Web. Proporciona un diseño consistente, responsivo y que ocupa todo el ancho disponible.

**Ubicación**: `lib/core/widgets/tables/app_data_table.dart`

## ✨ Características

- ✅ **Responsivo**: Se adapta automáticamente al tamaño de la pantalla
- ✅ **Ancho completo**: Ocupa todo el espacio disponible
- ✅ **Scroll horizontal**: Automático cuando el contenido excede el ancho
- ✅ **Diseño consistente**: Usa AppColors y AppSizes del proyecto
- ✅ **Estado vacío**: Mensaje e icono personalizables cuando no hay datos
- ✅ **Hover effects**: Filas con efecto hover
- ✅ **Filas alternadas**: Colores alternados para mejor legibilidad

## 📦 Modelos

### AppDataColumn

Define una columna de la tabla.

```dart
AppDataColumn(
  label: 'Nombre de la columna',
  numeric: false,  // Opcional: true para números alineados a la derecha
  width: 150,      // Opcional: ancho fijo de la columna
)
```

### AppDataCell

Define una celda de la tabla.

```dart
AppDataCell(
  child: Text('Contenido'),
  onTap: () {},  // Opcional: callback al hacer clic
)
```

## 🎯 Uso Básico

```dart
import 'package:ambutrack_web/core/widgets/tables/app_data_table.dart';

AppDataTable(
  // Definir columnas
  columns: const [
    AppDataColumn(label: 'Código'),
    AppDataColumn(label: 'Nombre'),
    AppDataColumn(label: 'Estado'),
    AppDataColumn(label: 'Acciones'),
  ],

  // Definir filas (cada fila es una lista de celdas)
  rows: items.map((item) => [
    AppDataCell(
      child: Text(item.codigo ?? '-'),
    ),
    AppDataCell(
      child: Text(
        item.nombre,
        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
    ),
    AppDataCell(
      child: _buildEstadoBadge(item.estado),
    ),
    AppDataCell(
      child: _buildAcciones(item),
    ),
  ]).toList(),

  // Mensaje cuando no hay datos (opcional)
  emptyMessage: 'No hay elementos registrados',

  // Icono cuando no hay datos (opcional)
  emptyIcon: Icons.inbox_outlined,
)
```

## 🔧 Ejemplo Completo: Tabla de Provincias

```dart
import 'package:ambutrack_web/core/widgets/tables/app_data_table.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProvinciaTable extends StatelessWidget {
  const ProvinciaTable({super.key, required this.provincias});

  final List<ProvinciaEntity> provincias;

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      columns: const [
        AppDataColumn(label: 'Código'),
        AppDataColumn(label: 'Nombre'),
        AppDataColumn(label: 'Comunidad Autónoma'),
        AppDataColumn(label: 'Acciones'),
      ],
      rows: provincias.map((provincia) => [
        AppDataCell(
          child: Text(
            provincia.codigo ?? '-',
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
        AppDataCell(
          child: Text(
            provincia.nombre,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        AppDataCell(
          child: Text(
            provincia.comunidadAutonoma ?? '-',
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
        AppDataCell(
          child: _buildAcciones(context, provincia),
        ),
      ]).toList(),
      emptyMessage: 'No hay provincias registradas',
      emptyIcon: Icons.map_outlined,
    );
  }

  Widget _buildAcciones(BuildContext context, ProvinciaEntity provincia) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
          onPressed: () => _editar(context, provincia),
          tooltip: 'Editar',
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
          onPressed: () => _eliminar(context, provincia),
          tooltip: 'Eliminar',
        ),
      ],
    );
  }

  void _editar(BuildContext context, ProvinciaEntity provincia) {
    // Lógica de edición
  }

  void _eliminar(BuildContext context, ProvinciaEntity provincia) {
    // Lógica de eliminación
  }
}
```

## 🎨 Personalización de Celdas

### Celda con Badge de Estado

```dart
AppDataCell(
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: item.activo ? AppColors.success : AppColors.error,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      item.activo ? 'Activo' : 'Inactivo',
      style: GoogleFonts.inter(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
)
```

### Celda con Icono y Texto

```dart
AppDataCell(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.local_hospital, size: 16, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(item.tipo, style: GoogleFonts.inter(fontSize: 14)),
    ],
  ),
)
```

### Celda con Fecha Formateada

```dart
AppDataCell(
  child: Text(
    DateFormat('dd/MM/yyyy').format(item.fecha),
    style: GoogleFonts.inter(fontSize: 14),
  ),
)
```

### Celda Clickeable

```dart
AppDataCell(
  child: Text(
    item.nombre,
    style: GoogleFonts.inter(
      fontSize: 14,
      color: AppColors.primary,
      decoration: TextDecoration.underline,
    ),
  ),
  onTap: () {
    // Navegar a detalle
    context.goNamed('detalle', pathParameters: {'id': item.id});
  },
)
```

## 📐 Consideraciones de Diseño

### Tipografía Recomendada

- **Encabezados**: GoogleFonts.inter, fontWeight: FontWeight.w600, fontSize: 14
- **Contenido**: GoogleFonts.inter, fontSize: 14
- **Destacados**: GoogleFonts.inter, fontWeight: FontWeight.w500

### Colores

Siempre usar `AppColors`:

```dart
// Estados
AppColors.success    // Verde - Activo/Éxito
AppColors.error      // Rojo - Error/Inactivo
AppColors.warning    // Amarillo - Advertencia
AppColors.info       // Azul - Información

// Acciones
AppColors.primary    // Editar
AppColors.error      // Eliminar
AppColors.secondary  // Acciones secundarias

// Texto
AppColors.textPrimaryLight    // Texto principal
AppColors.textSecondaryLight  // Texto secundario
```

### Iconos Recomendados

```dart
// Estados vacíos
Icons.inbox_outlined        // Genérico
Icons.map_outlined          // Provincias/Localidades
Icons.person_outline        // Personal
Icons.local_shipping        // Vehículos
Icons.medical_services      // Servicios médicos

// Acciones
Icons.edit                  // Editar
Icons.delete                // Eliminar
Icons.visibility            // Ver detalles
Icons.download              // Descargar
Icons.print                 // Imprimir
```

## ⚠️ Reglas Obligatorias

1. **SIEMPRE usar `AppDataTable`** para todas las tablas de datos
2. **NO crear DataTable manualmente** - usar solo el widget común
3. **Mantener consistencia** en diseño de acciones y badges
4. **Usar AppColors** para todos los colores
5. **Mensaje vacío descriptivo** según el contexto
6. **Icono apropiado** para el tipo de datos

## 🔄 Migración de Tablas Existentes

Para migrar tablas existentes a `AppDataTable`:

1. Importar el widget:
   ```dart
   import 'package:ambutrack_web/core/widgets/tables/app_data_table.dart';
   ```

2. Reemplazar el `DataTable` por `AppDataTable`

3. Convertir `DataColumn` a `AppDataColumn`:
   ```dart
   // Antes
   DataColumn(label: Text('Nombre'))

   // Después
   AppDataColumn(label: 'Nombre')
   ```

4. Convertir filas de `DataRow` a listas de `AppDataCell`:
   ```dart
   // Antes
   DataRow(
     cells: [
       DataCell(Text(item.nombre)),
       DataCell(Text(item.codigo)),
     ],
   )

   // Después
   [
     AppDataCell(child: Text(item.nombre)),
     AppDataCell(child: Text(item.codigo)),
   ]
   ```

5. Eliminar decoraciones manuales (bordes, colores de fondo, etc.)

## 📚 Referencias

- [ProvinciaTable](../../lib/features/tablas/provincias/presentation/widgets/provincia_table.dart) - Ejemplo de implementación
- [AppColors](../../lib/core/theme/app_colors.dart) - Paleta de colores
- [AppSizes](../../lib/core/theme/app_sizes.dart) - Tamaños y espaciados

---

**Última actualización**: 2025-12-17
**Versión**: 1.0.0
