# AmbuTrack Icon Library - Ejemplos de Uso

Este documento muestra ejemplos prácticos de cómo usar los iconos de AppIcons en diferentes contextos de la aplicación AmbuTrack Mobile.

## 📋 Índice
1. [MainLayout - Navegación con Drawer](#mainlayout---navegación-con-drawer)
2. [Botones de Acción](#botones-de-acción)
3. [Listas con Iconos](#listas-con-iconos)
4. [Cards con Iconos](#cards-con-iconos)
5. [App Bar Actions](#app-bar-actions)
6. [Bottom Navigation](#bottom-navigation)
7. [Iconos Interactivos](#iconos-interactivos)

---

## MainLayout - Navegación con Drawer

### Implementación Actual

El archivo [lib/core/widgets/layouts/main_layout.dart](../lib/core/widgets/layouts/main_layout.dart) ahora usa `AppIcons`:

```dart
// En el Drawer
_buildDrawerItem(
  context,
  icon: AppIcons.dashboard,  // ✅ En lugar de Icons.dashboard
  title: 'Dashboard',
  route: '/',
  isSelected: currentLocation == '/',
),

_buildDrawerItem(
  context,
  icon: AppIcons.schedule,  // ✅ En lugar de Icons.schedule
  title: 'Registro Horario',
  route: '/registro-horario',
  isSelected: currentLocation == '/registro-horario',
),

// Botón de logout en AppBar
IconButton(
  icon: const Icon(AppIcons.logout),  // ✅ En lugar de Icons.logout
  tooltip: 'Cerrar Sesión',
  onPressed: () => _showLogoutDialog(context),
),
```

### Lista Completa de Iconos del Drawer

| Sección | Icono Anterior | Icono Nuevo | Constante |
|---------|----------------|-------------|-----------|
| Dashboard | `Icons.dashboard` | ✅ | `AppIcons.dashboard` |
| Registro Horario | `Icons.schedule` | ✅ | `AppIcons.schedule` |
| Checklist | `Icons.checklist` | ✅ | `AppIcons.checklist` |
| Partes Diarios | `Icons.assignment` | ✅ | `AppIcons.assignment` |
| Incidencias | `Icons.warning_amber` | ✅ | `AppIcons.warningAmber` |
| Mi Perfil | `Icons.person` | ✅ | `AppIcons.person` |
| Cerrar Sesión | `Icons.logout` | ✅ | `AppIcons.logout` |

---

## Botones de Acción

### Ejemplo 1: Botones en AppBar

```dart
AppBar(
  title: Text('AmbuTrack'),
  actions: [
    // Búsqueda
    IconButton(
      icon: Icon(AppIcons.search),
      onPressed: () => _openSearch(),
    ),

    // Notificaciones con badge
    Stack(
      children: [
        IconButton(
          icon: Icon(AppIcons.notifications),
          onPressed: () => context.push('/notificaciones'),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('3', style: TextStyle(fontSize: 10)),
          ),
        ),
      ],
    ),

    // Configuración
    IconButton(
      icon: Icon(AppIcons.settings),
      onPressed: () => context.push('/settings'),
    ),
  ],
)
```

### Ejemplo 2: Floating Action Button

```dart
FloatingActionButton(
  onPressed: () => _addNewService(),
  child: Icon(AppIcons.add),
)
```

### Ejemplo 3: Botones con AppIconButton

```dart
Row(
  children: [
    AppIconButton(
      AppIcons.edit,
      onPressed: () => _editItem(),
      size: 36,
    ),
    SizedBox(width: 8),
    AppIconButton(
      AppIcons.delete,
      onPressed: () => _deleteItem(),
      size: 36,
      activeColor: AppColors.error,
    ),
  ],
)
```

---

## Listas con Iconos

### Ejemplo 1: ListTile Simple

```dart
ListView(
  children: [
    ListTile(
      leading: Icon(AppIcons.servicios, color: AppColors.primary),
      title: Text('Servicios Activos'),
      subtitle: Text('3 traslados en curso'),
      trailing: Icon(Icons.chevron_right),
      onTap: () => context.push('/servicios'),
    ),

    ListTile(
      leading: Icon(AppIcons.tramites, color: AppColors.secondary),
      title: Text('Trámites Pendientes'),
      subtitle: Text('2 documentos por revisar'),
      trailing: Icon(Icons.chevron_right),
      onTap: () => context.push('/tramites'),
    ),

    ListTile(
      leading: Icon(AppIcons.vehiculo, color: AppColors.info),
      title: Text('Mi Vehículo'),
      subtitle: Text('Ambulancia A-123'),
      trailing: Icon(Icons.chevron_right),
      onTap: () => context.push('/vehiculo'),
    ),
  ],
)
```

### Ejemplo 2: ListTile con AppIcon

```dart
ListTile(
  leading: AppIcon(
    AppIcons.gearUniform,
    size: 32,
    state: AppIconState.active,
  ),
  title: Text('Uniformes Asignados'),
  subtitle: Text('3 piezas en uso'),
  trailing: AppIconButton(
    AppIcons.info,
    onPressed: () => _showUniformInfo(),
  ),
)
```

---

## Cards con Iconos

### Ejemplo 1: Card de Estadísticas

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                AppIcons.estadisticas,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Servicios del Mes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '127',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
)
```

### Ejemplo 2: Card de Funcionalidad

```dart
GridView.count(
  crossAxisCount: 2,
  children: [
    _buildFeatureCard(
      icon: AppIcons.servicios,
      title: 'Servicios',
      subtitle: '3 activos',
      color: AppColors.primary,
      onTap: () => context.push('/servicios'),
    ),
    _buildFeatureCard(
      icon: AppIcons.tramites,
      title: 'Trámites',
      subtitle: '2 pendientes',
      color: AppColors.secondary,
      onTap: () => context.push('/tramites'),
    ),
  ],
)

Widget _buildFeatureCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
}) {
  return Card(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

## App Bar Actions

### Implementación Completa de AppBar

```dart
AppBar(
  title: Text('Servicios Activos'),
  leading: IconButton(
    icon: Icon(AppIcons.close),
    onPressed: () => Navigator.pop(context),
  ),
  actions: [
    // Búsqueda
    IconButton(
      icon: Icon(AppIcons.search),
      onPressed: () => _showSearchDialog(),
    ),

    // Filtros
    IconButton(
      icon: Icon(AppIcons.filter),
      onPressed: () => _showFilterBottomSheet(),
    ),

    // Ordenar
    IconButton(
      icon: Icon(AppIcons.sort),
      onPressed: () => _showSortDialog(),
    ),

    // Refrescar
    IconButton(
      icon: Icon(AppIcons.refresh),
      onPressed: () => _refreshData(),
    ),

    // Más opciones
    PopupMenuButton(
      icon: Icon(AppIcons.moreVert),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(AppIcons.download, size: 20),
              SizedBox(width: 12),
              Text('Descargar'),
            ],
          ),
          onTap: () => _downloadData(),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(AppIcons.settings, size: 20),
              SizedBox(width: 12),
              Text('Configuración'),
            ],
          ),
          onTap: () => _openSettings(),
        ),
      ],
    ),
  ],
)
```

---

## Bottom Navigation

### Ejemplo con BottomNavigationBar

```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  type: BottomNavigationBarType.fixed,
  selectedItemColor: AppColors.primary,
  items: [
    BottomNavigationBarItem(
      icon: Icon(AppIcons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(AppIcons.servicios),
      label: 'Servicios',
    ),
    BottomNavigationBarItem(
      icon: Icon(AppIcons.calendario),
      label: 'Calendario',
    ),
    BottomNavigationBarItem(
      icon: Icon(AppIcons.perfil),
      label: 'Perfil',
    ),
  ],
)
```

### Ejemplo con NavigationRail

```dart
NavigationRail(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
  labelType: NavigationRailLabelType.selected,
  destinations: [
    NavigationRailDestination(
      icon: Icon(AppIcons.dashboard),
      selectedIcon: Icon(AppIcons.dashboard),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(AppIcons.servicios),
      selectedIcon: Icon(AppIcons.servicios),
      label: Text('Servicios'),
    ),
    NavigationRailDestination(
      icon: Icon(AppIcons.historial),
      selectedIcon: Icon(AppIcons.historial),
      label: Text('Historial'),
    ),
  ],
)
```

---

## Iconos Interactivos

### Ejemplo 1: Toggle con Estado

```dart
class FavoriteButton extends StatefulWidget {
  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? AppColors.error : null,
      ),
      onPressed: () {
        setState(() => _isFavorite = !_isFavorite);
      },
    );
  }
}
```

### Ejemplo 2: Botón con Loading

```dart
class ActionButton extends StatefulWidget {
  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isLoading = false;

  Future<void> _handleAction() async {
    setState(() => _isLoading = true);

    // Simular operación
    await Future.delayed(Duration(seconds: 2));

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(AppIcons.check),
      onPressed: _isLoading ? null : _handleAction,
    );
  }
}
```

### Ejemplo 3: AppIconButton con Estados

```dart
Column(
  children: [
    // Estado activo
    AppIconButton(
      AppIcons.servicios,
      onPressed: () => _openServices(),
      size: 48,
    ),
    SizedBox(height: 16),

    // Estado deshabilitado
    AppIconButton(
      AppIcons.tramites,
      onPressed: null,  // null = disabled
      size: 48,
    ),
    SizedBox(height: 16),

    // Estado con color personalizado
    AppIconButton(
      AppIcons.facAlarm,
      onPressed: () => _triggerAlarm(),
      size: 48,
      activeColor: AppColors.error,
      backgroundColor: AppColors.error.withValues(alpha: 0.1),
    ),
  ],
)
```

---

## Migración de Código Existente

### Antes (usando Material Icons directamente)

```dart
// ❌ ANTES
ListTile(
  leading: Icon(Icons.dashboard),
  title: Text('Dashboard'),
)

IconButton(
  icon: Icon(Icons.logout),
  onPressed: _logout,
)

AppBar(
  actions: [
    IconButton(icon: Icon(Icons.search), onPressed: _search),
    IconButton(icon: Icon(Icons.settings), onPressed: _settings),
  ],
)
```

### Después (usando AppIcons)

```dart
// ✅ DESPUÉS
ListTile(
  leading: Icon(AppIcons.dashboard),
  title: Text('Dashboard'),
)

IconButton(
  icon: Icon(AppIcons.logout),
  onPressed: _logout,
)

AppBar(
  actions: [
    IconButton(icon: Icon(AppIcons.search), onPressed: _search),
    IconButton(icon: Icon(AppIcons.settings), onPressed: _settings),
  ],
)
```

---

## Checklist de Migración

- [x] MainLayout actualizado con AppIcons
- [ ] HomeAndroidPage (mantiene assets PNG)
- [ ] Formularios de servicios
- [ ] Formularios de trámites
- [ ] Páginas de vehículos
- [ ] Páginas de vestuario
- [ ] Diálogos y BottomSheets
- [ ] Cards de estadísticas

---

**Próximos Pasos:**
1. Migrar gradualmente las páginas restantes
2. Crear componentes reutilizables con AppIcon
3. Documentar nuevos patrones de uso
4. Actualizar guía de estilo del equipo

**Última actualización:** 2026-02-11
**Mantenedor:** AmbuTrack Dev Team
