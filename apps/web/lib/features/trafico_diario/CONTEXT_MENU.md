# Menú Contextual en Tabla de Traslados

## 📋 Descripción

La tabla de traslados pendientes de asignar ahora incluye un **menú contextual personalizado** que se muestra al hacer **clic derecho** sobre cualquier fila.

## 🎯 Ubicación

El menú contextual está implementado en:
- **Archivo**: `lib/features/trafico_diario/presentation/widgets/traslado_row_builder.dart`
- **Método**: `_buildContextMenuOptions()`

## 🖱️ Uso

1. **Hacer clic derecho** en cualquier celda de la tabla (excepto el checkbox)
2. Se mostrará un menú con opciones contextuales según el estado del traslado
3. Seleccionar una opción del menú

## 📌 Opciones Disponibles

### Opciones Siempre Visibles

1. **Ver detalles**
   - Icono: 👁️ `Icons.visibility`
   - Acción: Muestra detalles completos del traslado
   - Estado: Pendiente de implementación

2. **Copiar información**
   - Icono: 📋 `Icons.content_copy`
   - Acción: Copia información del traslado al portapapeles
   - Estado: Pendiente de implementación

### Opciones Condicionales

3. **Ver servicio** (solo si tiene servicio asociado)
   - Icono: 🏥 `Icons.medical_services`
   - Acción: Navega al detalle del servicio médico
   - Condición: `servicio != null`
   - Estado: Pendiente de implementación

4. **Asignar conductor** (solo si está pendiente o asignado)
   - Icono: 👤 `Icons.person_add`
   - Acción: Abre diálogo para asignar conductor
   - Condición: `estado == 'pendiente' || estado == 'asignado'`
   - Estado: Pendiente de implementación

5. **Modificar hora** (solo si tiene hora programada)
   - Icono: ⏰ `Icons.access_time`
   - Acción: Permite cambiar la hora del traslado
   - Condición: `horaProgramada != null`
   - Estado: Pendiente de implementación

6. **Cancelar traslado** (solo si está pendiente)
   - Icono: ❌ `Icons.cancel`
   - Acción: Cancela el traslado
   - Condición: `estado == 'pendiente'`
   - Estado: Pendiente de implementación

## 🔧 Implementación Técnica

### CustomContextMenu

Cada celda de la tabla (excepto el checkbox) está envuelta en un widget `CustomContextMenu`:

```dart
CustomContextMenu(
  menuOptions: _buildContextMenuOptions(traslado, servicio),
  child: cell.child,
)
```

### Construcción de Opciones

El método `_buildContextMenuOptions()` devuelve una lista dinámica de `ContextMenuOption` según:
- Estado del traslado (pendiente, asignado, etc.)
- Existencia de servicio asociado
- Existencia de hora programada

### Exclusión del Checkbox

La primera celda (índice 0) con el checkbox NO tiene menú contextual para evitar conflictos con la interacción de selección.

## 📝 TODOs Pendientes

Todas las acciones del menú contextual tienen comentarios `TODO(dev):` que indican las implementaciones pendientes:

1. ✅ Navegación a detalles de traslado
2. ✅ Navegación a detalles de servicio
3. ✅ Asignación de conductor
4. ✅ Modificación de hora programada
5. ✅ Copia de información al portapapeles
6. ✅ Cancelación de traslado

## 🎨 Diseño

El menú contextual sigue el diseño de AmbuTrack:
- Colores: `AppColors`
- Bordes redondeados: `AppSizes.radiusSmall`
- Sombras profesionales
- Iconos Material Icons

## 🔄 Cómo Extender

Para agregar nuevas opciones al menú:

```dart
List<ContextMenuOption> _buildContextMenuOptions(...) {
  return <ContextMenuOption>[
    // ... opciones existentes ...

    // Nueva opción
    ContextMenuOption(
      label: 'Nueva acción',
      icon: Icons.new_icon,
      onTap: () {
        debugPrint('🎯 Nueva acción');
        // Implementar acción
      },
      enabled: condicion, // opcional
    ),
  ];
}
```

## 🌐 Bloqueo de Menú del Navegador

El menú contextual del navegador está bloqueado globalmente en `lib/app/app.dart` mediante el widget `ContextMenuBlocker`, por lo que solo se mostrará el menú personalizado.

## 📚 Documentación Adicional

Ver documentación completa del sistema de menú contextual en:
- `lib/core/widgets/context_menu/README.md`
- `lib/core/widgets/context_menu/context_menu_example.dart`
