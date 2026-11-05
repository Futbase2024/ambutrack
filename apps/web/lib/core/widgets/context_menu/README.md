# Menú Contextual Personalizado

Sistema de menú contextual personalizado que bloquea el menú del navegador y muestra opciones personalizadas al hacer clic derecho.

## 📦 Componentes

### 1. ContextMenuBlocker
Bloquea el menú contextual del navegador a nivel global de la aplicación.

**Ubicación**: Ya está integrado en `lib/app/app.dart`

**Funcionalidad**:
- Bloquea el menú contextual del navegador (clic derecho)
- Previene F5 (recargar)
- Previene Ctrl+R (recargar)
- Previene Ctrl+Shift+I (DevTools)

### 2. CustomContextMenu
Widget que envuelve contenido y muestra un menú personalizado al hacer clic derecho.

**Uso básico**:

```dart
import 'package:ambutrack_web/core/widgets/context_menu/custom_context_menu.dart';

CustomContextMenu(
  menuOptions: [
    ContextMenuOption(
      label: 'Editar',
      icon: Icons.edit,
      onTap: () {
        // Acción al seleccionar
      },
    ),
    ContextMenuOption(
      label: 'Eliminar',
      icon: Icons.delete,
      onTap: () {
        // Acción al seleccionar
      },
    ),
  ],
  child: YourWidget(),
)
```

## 🎯 Uso en Tablas

### Ejemplo en AppDataGrid / ModernDataTable

```dart
import 'package:ambutrack_web/core/widgets/context_menu/custom_context_menu.dart';

// En el método que construye las filas:
Widget _buildRow(MyEntity item) {
  return CustomContextMenu(
    menuOptions: [
      ContextMenuOption(
        label: 'Ver detalles',
        icon: Icons.visibility,
        onTap: () => _showDetails(item),
      ),
      ContextMenuOption(
        label: 'Editar',
        icon: Icons.edit,
        onTap: () => _editItem(item),
      ),
      ContextMenuOption(
        label: 'Eliminar',
        icon: Icons.delete,
        onTap: () => _deleteItem(item),
      ),
    ],
    child: Row(
      children: [
        Text(item.nombre),
        Text(item.descripcion),
        // ... más celdas
      ],
    ),
  );
}
```

### Ejemplo en ListView

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];

    return CustomContextMenu(
      menuOptions: [
        ContextMenuOption(
          label: 'Acción 1',
          icon: Icons.star,
          onTap: () => _action1(item),
        ),
        ContextMenuOption(
          label: 'Acción 2',
          icon: Icons.share,
          onTap: () => _action2(item),
        ),
      ],
      child: ListTile(
        title: Text(item.title),
        subtitle: Text(item.subtitle),
      ),
    );
  },
)
```

## 🎨 Opciones de Menú

### ContextMenuOption

```dart
ContextMenuOption(
  label: 'Texto a mostrar',     // Texto de la opción
  icon: Icons.edit,             // Icono de Material Icons
  onTap: () {                   // Función al hacer clic
    // Tu código aquí
  },
  enabled: true,                // true/false - opcional, por defecto true
)
```

**Opciones deshabilitadas**: Se muestran en gris y no se pueden seleccionar

```dart
ContextMenuOption(
  label: 'No disponible',
  icon: Icons.block,
  onTap: () {},
  enabled: false,  // ⚠️ Deshabilitada
)
```

## 🔧 Personalización

### Opciones Condicionales

```dart
menuOptions: [
  // Siempre visible
  ContextMenuOption(
    label: 'Ver',
    icon: Icons.visibility,
    onTap: () => _view(item),
  ),

  // Solo si el usuario es admin
  if (isAdmin)
    ContextMenuOption(
      label: 'Eliminar',
      icon: Icons.delete,
      onTap: () => _delete(item),
    ),

  // Solo si el item está activo
  if (item.activo)
    ContextMenuOption(
      label: 'Desactivar',
      icon: Icons.toggle_off,
      onTap: () => _deactivate(item),
    ),
]
```

### Opciones Dinámicas según Estado

```dart
menuOptions: [
  ContextMenuOption(
    label: item.activo ? 'Desactivar' : 'Activar',
    icon: item.activo ? Icons.toggle_off : Icons.toggle_on,
    onTap: () => _toggleStatus(item),
  ),
]
```

## 🌐 Aplicaciones Web

El sistema está optimizado para aplicaciones Flutter Web:

1. **Bloqueo automático**: El menú del navegador se bloquea globalmente
2. **Menú personalizado**: Aparece al hacer clic derecho en cualquier widget envuelto con `CustomContextMenu`
3. **Acciones de teclado**: F5, Ctrl+R y Ctrl+Shift+I están bloqueados

## 📝 Ejemplos Completos

### Ejemplo Simple

```dart
CustomContextMenu(
  menuOptions: [
    ContextMenuOption(
      label: 'Copiar',
      icon: Icons.content_copy,
      onTap: () {
        Clipboard.setData(ClipboardData(text: 'texto a copiar'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copiado al portapapeles')),
        );
      },
    ),
  ],
  child: Text('Haz clic derecho para copiar'),
)
```

### Ejemplo con Confirmación

```dart
CustomContextMenu(
  menuOptions: [
    ContextMenuOption(
      label: 'Eliminar',
      icon: Icons.delete,
      onTap: () async {
        final confirmed = await showConfirmationDialog(
          context: context,
          title: '¿Eliminar?',
          message: '¿Estás seguro?',
        );

        if (confirmed == true) {
          _deleteItem();
        }
      },
    ),
  ],
  child: YourWidget(),
)
```

## ⚙️ Configuración Global

El bloqueo del menú contextual del navegador ya está configurado en `lib/app/app.dart`:

```dart
return BlocProvider<AuthBloc>(
  create: (context) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
  child: ContextMenuBlocker(  // ✅ Ya está integrado
    child: MaterialApp.router(
      // ...
    ),
  ),
);
```

No es necesario agregar más configuración.

## 🎯 Mejores Prácticas

1. **Opciones relevantes**: Solo incluir acciones que tengan sentido para el contexto
2. **Iconos claros**: Usar iconos de Material Icons que sean intuitivos
3. **Opciones habilitadas/deshabilitadas**: Usar `enabled: false` para mostrar opciones no disponibles en lugar de ocultarlas
4. **Feedback al usuario**: Mostrar SnackBar o diálogo de confirmación después de acciones importantes
5. **Máximo 5-7 opciones**: Evitar menús muy largos

## 🔍 Debugging

Si el menú no aparece:
1. Verificar que `CustomContextMenu` envuelve el widget correcto
2. Verificar que las opciones tienen `onTap` definido
3. Verificar en Flutter DevTools que el `GestureDetector` está presente

Si el menú del navegador sigue apareciendo:
1. Verificar que `ContextMenuBlocker` envuelve `MaterialApp` en `app.dart`
2. Limpiar y reconstruir la aplicación web
