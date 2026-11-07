# TrayectosTable Widget

Widget reutilizable para mostrar tablas de trayectos con diseño profesional y funcionalidades completas.

## 📋 Características

- ✅ **Diseño Profesional**: Tabla moderna con diseño consistente
- ✅ **Ordenamiento**: Ordenamiento por columnas (fecha, estado, tipo, hora, etc.)
- ✅ **Badges de Estado**: Indicadores visuales con colores según estado
- ✅ **Badges de Tipo**: IDA (verde) / VUELTA (rojo)
- ✅ **Menú de Acciones**: ActionMenu integrado con opciones contextuales
- ✅ **Selección Múltiple**: Opcional, con callback de selección
- ✅ **Estado Vacío**: Vista personalizada cuando no hay datos
- ✅ **Responsive**: Scroll horizontal automático en pantallas pequeñas
- ✅ **Iconos de Estado**: Indicadores visuales con iconos descriptivos

## 🎨 Diseño

La tabla sigue el patrón de diseño AmbuTrack:

- **Cabecera**: Fondo gris claro (`AppColors.surfaceLight`) con texto azul primario
- **Filas**: Alternancia automática con hover effect
- **Estados**: 4 estados con colores distintos
  - 🟡 **Pendiente** (Warning) - Icono: schedule
  - 🔵 **En Curso** (Info) - Icono: directions_run
  - 🟢 **Completado** (Success) - Icono: check_circle
  - 🔴 **Cancelado** (Error) - Icono: cancel
- **Tipos**:
  - 🟢 **IDA** (Success)
  - 🔴 **VUELTA** (Error)

## 📦 Ubicación

```
lib/core/widgets/tables/
├── trayectos_table.dart          # Widget principal
├── trayectos_table_example.dart  # Ejemplos de uso
└── README_TRAYECTOS_TABLE.md     # Esta documentación
```

## 🚀 Uso Básico

```dart
import 'package:ambutrack_web/core/widgets/tables/trayectos_table.dart';

// En tu widget
TrayectosTable(
  trayectos: trayectos,
  onEdit: (trayecto) => _editTrayecto(trayecto),
  onDelete: (trayecto) => _deleteTrayecto(trayecto),
)
```

## 📊 Modelo de Datos

```dart
class TrayectoTableData {
  const TrayectoTableData({
    required this.id,
    required this.fecha,
    required this.estado,
    required this.tipo,
    required this.hora,
    this.horaRecogida,
    this.horaLlegada,
    this.vehiculo,
    this.conductor,
  });

  final String id;
  final DateTime fecha;
  final String estado; // 'pendiente', 'en_curso', 'completado', 'cancelado'
  final String tipo; // 'IDA', 'VUELTA'
  final String hora;
  final String? horaRecogida;
  final String? horaLlegada;
  final String? vehiculo;
  final String? conductor;
}
```

## 🔧 Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `trayectos` | `List<TrayectoTableData>` | ✅ | Lista de trayectos a mostrar |
| `onEdit` | `Function(TrayectoTableData)?` | ❌ | Callback al editar (muestra botón si se proporciona) |
| `onDelete` | `Function(TrayectoTableData)?` | ❌ | Callback al eliminar (muestra botón si se proporciona) |
| `onView` | `Function(TrayectoTableData)?` | ❌ | Callback al ver detalles |
| `onCancel` | `Function(TrayectoTableData)?` | ❌ | Callback al cancelar (solo estados activos) |
| `onAssign` | `Function(TrayectoTableData)?` | ❌ | Callback al asignar recursos (solo pendientes) |
| `sortable` | `bool` | ❌ | Permite ordenamiento (default: true) |
| `selectable` | `bool` | ❌ | Permite selección múltiple (default: false) |
| `onSelectionChanged` | `Function(List<TrayectoTableData>)?` | ❌ | Callback cuando cambia la selección |
| `emptyMessage` | `String` | ❌ | Mensaje cuando no hay datos |

## 💡 Ejemplos

### Ejemplo 1: Tabla Completa

```dart
TrayectosTable(
  trayectos: trayectos,
  sortable: true,
  selectable: false,
  onView: (trayecto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrayectoDetailPage(trayecto: trayecto),
      ),
    );
  },
  onEdit: (trayecto) {
    showDialog(
      context: context,
      builder: (_) => TrayectoFormDialog(trayecto: trayecto),
    );
  },
  onAssign: (trayecto) {
    showDialog(
      context: context,
      builder: (_) => AsignarRecursosDialog(trayecto: trayecto),
    );
  },
  onCancel: (trayecto) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Cancelar Trayecto',
      message: '¿Estás seguro de cancelar este trayecto?',
    );
    if (confirmed == true) {
      context.read<TrayectosBloc>().add(
        TrayectosEvent.cancelRequested(trayecto.id),
      );
    }
  },
  onDelete: (trayecto) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar Trayecto',
      message: '¿Estás seguro de eliminar este trayecto?',
    );
    if (confirmed == true) {
      context.read<TrayectosBloc>().add(
        TrayectosEvent.deleteRequested(trayecto.id),
      );
    }
  },
)
```

### Ejemplo 2: Solo Vista (Sin Acciones)

```dart
TrayectosTable(
  trayectos: trayectos,
  sortable: false,
  selectable: false,
  // Sin callbacks = sin menú de acciones
)
```

### Ejemplo 3: Con Selección Múltiple

```dart
TrayectosTable(
  trayectos: trayectos,
  selectable: true,
  onSelectionChanged: (selected) {
    setState(() {
      _selectedTrayectos = selected;
    });
  },
)
```

### Ejemplo 4: Integración con BLoC

```dart
BlocBuilder<TrayectosBloc, TrayectosState>(
  builder: (context, state) {
    return state.when(
      initial: () => const CircularProgressIndicator(),
      loading: () => const CircularProgressIndicator(),
      loaded: (trayectos) => TrayectosTable(
        trayectos: trayectos.map((t) => TrayectoTableData(
          id: t.id,
          fecha: t.fecha,
          estado: t.estado,
          tipo: t.tipo,
          hora: t.hora,
          horaRecogida: t.horaRecogida,
          horaLlegada: t.horaLlegada,
          vehiculo: t.vehiculo?.matricula,
          conductor: t.conductor?.nombre,
        )).toList(),
        onEdit: (trayecto) => context.read<TrayectosBloc>().add(
          TrayectosEvent.editRequested(trayecto.id),
        ),
        onDelete: (trayecto) => context.read<TrayectosBloc>().add(
          TrayectosEvent.deleteRequested(trayecto.id),
        ),
      ),
      error: (message) => ErrorView(message: message),
    );
  },
)
```

## 🎯 Menú de Acciones

El menú de acciones (`ActionMenu`) se genera dinámicamente según:

1. **Ver Detalles**: Si `onView != null`
2. **Asignar Recursos**: Si `onAssign != null` Y `estado == 'pendiente'`
3. **Editar**: Si `onEdit != null`
4. **Cancelar Trayecto**: Si `onCancel != null` Y estado NO es completado/cancelado
5. **Eliminar**: Si `onDelete != null`

**Nota**: Si NO se proporcionan callbacks, NO se muestra el menú de acciones.

## 🎨 Personalización de Estados

Los estados se mapean automáticamente a colores e iconos:

```dart
// En TrayectoTableData
Color get estadoColor {
  switch (estado.toLowerCase()) {
    case 'pendiente': return AppColors.warning;
    case 'en_curso': return AppColors.info;
    case 'completado': return AppColors.success;
    case 'cancelado': return AppColors.error;
    default: return AppColors.textSecondaryLight;
  }
}

IconData get estadoIcon {
  switch (estado.toLowerCase()) {
    case 'pendiente': return Icons.schedule;
    case 'en_curso': return Icons.directions_run;
    case 'completado': return Icons.check_circle;
    case 'cancelado': return Icons.cancel;
    default: return Icons.help_outline;
  }
}
```

## 📏 Columnas de la Tabla

| Columna | Ancho (flex) | Ordenable | Descripción |
|---------|--------------|-----------|-------------|
| Fecha ↑ | 2 | ✅ | Fecha del trayecto |
| Estado | 2 | ✅ | Badge con estado actual |
| Ida/Vuelta | 2 | ✅ | Badge con tipo de trayecto |
| Hora | 1 | ✅ | Hora programada |
| H.Rec | 1 | ✅ | Hora de recogida (real) |
| H.Lleg | 1 | ✅ | Hora de llegada (real) |
| Vehículo | 2 | ✅ | Matrícula del vehículo |
| Conductor | 2 | ✅ | Nombre del conductor |
| Acciones | - | ❌ | Menú de acciones |

## 🔍 Estado Vacío

Cuando `trayectos` está vacío, se muestra automáticamente:

- Icono de ruta (`Icons.alt_route`)
- Mensaje personalizable (`emptyMessage`)
- Diseño centrado y profesional

## ✅ Validaciones y Seguridad

- ✅ Null-safe: Todos los campos opcionales son `String?`
- ✅ Campos vacíos se muestran como `-`
- ✅ Estados case-insensitive (`toLowerCase()`)
- ✅ Menú de acciones se adapta al estado del trayecto
- ✅ Ordenamiento seguro con null checks

## 🐛 Troubleshooting

### El menú de acciones no aparece
- Verifica que hayas proporcionado al menos un callback (`onEdit`, `onDelete`, etc.)

### Los badges no tienen colores
- Asegúrate de que `estado` sea uno de: 'pendiente', 'en_curso', 'completado', 'cancelado'
- Los estados son case-insensitive

### La tabla está muy ancha en móvil
- El scroll horizontal se activa automáticamente
- Considera reducir el número de columnas en móvil

### No puedo seleccionar filas
- Activa `selectable: true`
- Proporciona callback `onSelectionChanged`

## 📚 Dependencias

- `flutter/material.dart`
- `google_fonts` (para tipografía Inter)
- `core/theme/app_colors.dart`
- `core/theme/app_sizes.dart`
- `core/widgets/menus/action_menu.dart`

## 🔄 Versionado

- **v1.0.0** (2026-01-01): Versión inicial con todas las funcionalidades

---

**Ubicación**: `lib/core/widgets/tables/trayectos_table.dart`
**Autor**: AmbuTrack Team
**Última actualización**: 2026-01-01
