# AmbuTrack Icon Library v1.5 - Guía de Uso

## 📚 Índice
- [Visión General](#visión-general)
- [Instalación](#instalación)
- [Uso Básico](#uso-básico)
- [Widgets Personalizados](#widgets-personalizados)
- [Catálogo de Iconos](#catálogo-de-iconos)
- [Estados de Iconos](#estados-de-iconos)
- [Mejores Prácticas](#mejores-prácticas)

---

## Visión General

La **AmbuTrack Icon Library** es un sistema centralizado de iconos basado en Material Icons Round y Material Symbols Outlined, diseñado específicamente para la aplicación AmbuTrack.

### Especificaciones de Color

| Estado | Color | Código |
|--------|-------|--------|
| **Active** | Brand Blue | `#137fec` |
| **Hover** | Brand Blue 40% | `#137fec66` |
| **Disabled** | Slate Gray 30% | `#4755694D` |

### Estándares de Iconos

- **Grid:** 24px Responsive Viewbox
- **Weight:** 400 (Regular) para UI del sistema
- **Variantes:** Estilo outline para acciones secundarias
- **Estados:** Heredan el color actual por defecto

---

## Instalación

Los iconos ya están disponibles en el proyecto. Solo necesitas importar:

```dart
import 'package:ambutrack/core/theme/app_icons.dart';
import 'package:ambutrack/core/widgets/icons/app_icon.dart';
```

---

## Uso Básico

### Método 1: Icon Widget Estándar

```dart
Icon(
  AppIcons.gearUniform,
  size: 24,
  color: AppColors.primary,
)
```

### Método 2: AppIcon Widget (Recomendado)

```dart
AppIcon(
  AppIcons.gearUniform,
  state: AppIconState.active,
  size: 24,
)
```

### Método 3: AppIconButton (Interactivo)

```dart
AppIconButton(
  AppIcons.facAlarm,
  onPressed: () => print('Alarm pressed'),
  size: 36,
  padding: EdgeInsets.all(8),
)
```

---

## Widgets Personalizados

### AppIcon

Widget básico que aplica automáticamente los colores del Design System según el estado.

**Propiedades:**
- `icon` (IconData): Icono de AppIcons
- `state` (AppIconState): Estado del icono (active, hover, disabled)
- `size` (double): Tamaño del icono (default: 24)
- `color` (Color?): Color personalizado (sobrescribe el estado)

**Ejemplo:**
```dart
Row(
  children: [
    AppIcon(AppIcons.gearUniform, state: AppIconState.active),
    SizedBox(width: 12),
    AppIcon(AppIcons.gearId, state: AppIconState.hover),
    SizedBox(width: 12),
    AppIcon(AppIcons.gearLog, state: AppIconState.disabled),
  ],
)
```

### AppIconButton

Widget de botón interactivo que cambia automáticamente entre estados active/hover según la interacción del usuario.

**Propiedades:**
- `icon` (IconData): Icono de AppIcons
- `onPressed` (VoidCallback?): Callback al presionar (null = disabled)
- `size` (double): Tamaño del icono (default: 36)
- `padding` (EdgeInsetsGeometry): Padding interno (default: 8)
- `backgroundColor` (Color?): Color de fondo
- `activeColor`, `hoverColor`, `disabledColor` (Color?): Colores personalizados

**Ejemplo:**
```dart
AppIconButton(
  AppIcons.facAlarm,
  onPressed: _showAlarmDialog,
  size: 36,
  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
)
```

---

## Catálogo de Iconos

### 👥 Personnel & Gear

| Icono | Constante | Uso |
|-------|-----------|-----|
| 👔 | `AppIcons.gearUniform` | Uniformes del personal |
| 🪪 | `AppIcons.gearId` | Tarjetas de identificación |
| 🕐 | `AppIcons.gearLog` | Registro de horarios |

```dart
// Ejemplo de uso
ListTile(
  leading: AppIcon(AppIcons.gearUniform),
  title: Text('Uniformes'),
)
```

### 📦 Advanced Logistics

| Icono | Constante | Uso |
|-------|-----------|-----|
| 🚐 | `AppIcons.logFurgon` | Vehículos tipo furgoneta |
| 📚 | `AppIcons.logDocs` | Documentación agrupada |
| 🛣️ | `AppIcons.logRoute` | Rutas de navegación |
| 📁 | `AppIcons.logFolder` | Carpetas de archivos |

```dart
// Ejemplo de uso
NavigationRailDestination(
  icon: AppIcon(AppIcons.logRoute),
  label: Text('Rutas'),
)
```

### 🏢 Facilities & Safety

| Icono | Constante | Uso |
|-------|-----------|-----|
| 🏭 | `AppIcons.facBase` | Instalaciones y bases |
| 🦺 | `AppIcons.facSafety` | Equipamiento de seguridad |
| 🚨 | `AppIcons.facAlarm` | Alertas y sirenas |

```dart
// Ejemplo de uso
ElevatedButton.icon(
  icon: AppIcon(AppIcons.facAlarm),
  label: Text('Activar Alarma'),
  onPressed: _activateAlarm,
)
```

### 🧭 Navigation Icons

| Icono | Constante | Uso |
|-------|-----------|-----|
| 🚚 | `AppIcons.navFleet` | Navegación - Flota |
| 🏥 | `AppIcons.navMedical` | Navegación - Médico |
| 📋 | `AppIcons.navLogistics` | Navegación - Logística |
| ⚡ | `AppIcons.navActions` | Navegación - Acciones |
| 👥 | `AppIcons.navPersonnel` | Navegación - Personal |
| 📦 | `AppIcons.navAdvLogistics` | Navegación - Logística Avanzada |
| 🏢 | `AppIcons.navFacilities` | Navegación - Instalaciones |

```dart
// Ejemplo de uso en NavigationBar
NavigationDestination(
  icon: AppIcon(AppIcons.navFleet),
  selectedIcon: AppIcon(AppIcons.navFleet, state: AppIconState.active),
  label: 'Flota',
)
```

### 🔧 Utility Icons

| Icono | Constante | Uso |
|-------|-----------|-----|
| 🚑 | `AppIcons.emergency` | Logo principal AmbuTrack |
| 🔍 | `AppIcons.search` | Búsqueda |
| 📥 | `AppIcons.download` | Descargar archivos |
| 📋 | `AppIcons.copy` | Copiar contenido |
| 🎨 | `AppIcons.palette` | Paleta de colores |
| 📏 | `AppIcons.straighten` | Regla / medidas |
| ✅ | `AppIcons.verified` | Verificado |

### 🎯 App Navigation & Actions

| Icono | Constante | Uso |
|-------|-----------|-----|
| 🚪 | `AppIcons.logout` | Cerrar sesión |
| 🏠 | `AppIcons.dashboard` | Dashboard principal |
| ⏰ | `AppIcons.schedule` | Registro horario |
| ✅ | `AppIcons.checklist` | Checklist |
| 📄 | `AppIcons.assignment` | Asignaciones / Partes |
| ⚠️ | `AppIcons.warningAmber` | Incidencias / Alertas |
| 👤 | `AppIcons.person` | Perfil de usuario |
| ⚙️ | `AppIcons.settings` | Configuración |
| 🔔 | `AppIcons.notifications` | Notificaciones |
| ➕ | `AppIcons.add` | Añadir |
| ✏️ | `AppIcons.edit` | Editar |
| 🗑️ | `AppIcons.delete` | Eliminar |
| ❌ | `AppIcons.close` | Cerrar |
| ✔️ | `AppIcons.check` | Confirmar |
| 🔽 | `AppIcons.filter` | Filtrar |
| 🔄 | `AppIcons.sort` | Ordenar |
| 🔃 | `AppIcons.refresh` | Refrescar |
| ℹ️ | `AppIcons.info` | Información |
| ❓ | `AppIcons.help` | Ayuda |

### 🚑 App Features (AmbuTrack Mobile)

| Icono | Constante | Uso |
|-------|-----------|-----|
| 🏥 | `AppIcons.servicios` | Servicios médicos / Traslados |
| 📝 | `AppIcons.tramites` | Trámites y documentación |
| 🚗 | `AppIcons.vehiculo` | Vehículo asignado |
| 👔 | `AppIcons.vestuario` | Vestuario y uniformes |
| 🚑 | `AppIcons.ambulancias` | Gestión de ambulancias |
| 🕐 | `AppIcons.turno` | Turno de trabajo |
| 👤 | `AppIcons.perfil` | Perfil del usuario |
| 🏢 | `AppIcons.base` | Base / Instalaciones |
| 🗺️ | `AppIcons.ruta` | Rutas GPS |
| 🗾 | `AppIcons.mapa` | Mapa / Localización |
| 📅 | `AppIcons.calendario` | Calendario |
| 📁 | `AppIcons.documentacion` | Documentación |
| 🕒 | `AppIcons.historial` | Historial |
| 📊 | `AppIcons.estadisticas` | Estadísticas |
| 🎛️ | `AppIcons.configuracion` | Configuración avanzada |

---

## Estados de Iconos

### AppIconState.active
Color: `#137fec` (Brand Blue)
```dart
AppIcon(AppIcons.gearUniform, state: AppIconState.active)
```

### AppIconState.hover
Color: `#137fec66` (Brand Blue 40%)
```dart
AppIcon(AppIcons.gearUniform, state: AppIconState.hover)
```

### AppIconState.disabled
Color: `#4755694D` (Slate Gray 30%)
```dart
AppIcon(AppIcons.gearUniform, state: AppIconState.disabled)
```

---

## Mejores Prácticas

### ✅ Hacer

```dart
// ✅ Usar constantes de AppIcons
Icon(AppIcons.gearUniform)

// ✅ Usar AppIcon para consistencia
AppIcon(AppIcons.logRoute, state: AppIconState.active)

// ✅ Usar AppIconButton para interactividad
AppIconButton(AppIcons.facAlarm, onPressed: _onPress)

// ✅ Usar AppColors para colores personalizados
Icon(AppIcons.emergency, color: AppColors.emergency)
```

### ❌ Evitar

```dart
// ❌ NO usar Material Icons directamente
Icon(Icons.checkroom_rounded)

// ❌ NO hardcodear colores
Icon(AppIcons.gearUniform, color: Color(0xFF137FEC))

// ❌ NO crear botones personalizados sin AppIconButton
IconButton(icon: Icon(AppIcons.facAlarm), onPressed: _onPress)
```

---

## Ejemplos Completos

### Ejemplo 1: Lista de Personal con Iconos

```dart
ListView(
  children: [
    ListTile(
      leading: AppIcon(AppIcons.gearUniform, size: 32),
      title: Text('Uniformes'),
      trailing: AppIconButton(
        AppIcons.copy,
        onPressed: () => _copyUniformInfo(),
      ),
    ),
    ListTile(
      leading: AppIcon(AppIcons.gearId, size: 32),
      title: Text('Identificaciones'),
      trailing: AppIconButton(
        AppIcons.download,
        onPressed: () => _downloadIds(),
      ),
    ),
    ListTile(
      leading: AppIcon(AppIcons.gearLog, size: 32),
      title: Text('Registro de Horarios'),
      trailing: AppIconButton(
        AppIcons.search,
        onPressed: () => _searchLogs(),
      ),
    ),
  ],
)
```

### Ejemplo 2: Grid de Instalaciones

```dart
GridView.count(
  crossAxisCount: 3,
  children: [
    _buildFacilityCard(
      icon: AppIcons.facBase,
      label: 'Base Principal',
      onTap: _goToBase,
    ),
    _buildFacilityCard(
      icon: AppIcons.facSafety,
      label: 'Seguridad',
      onTap: _goToSafety,
    ),
    _buildFacilityCard(
      icon: AppIcons.facAlarm,
      label: 'Alarmas',
      onTap: _goToAlarms,
    ),
  ],
)

Widget _buildFacilityCard({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Card(
    child: InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(icon, size: 48),
          SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
```

### Ejemplo 3: AppBar con Iconos

```dart
AppBar(
  leading: AppIcon(AppIcons.emergency),
  title: Text('AmbuTrack'),
  actions: [
    AppIconButton(
      AppIcons.search,
      onPressed: _openSearch,
    ),
    AppIconButton(
      AppIcons.facAlarm,
      onPressed: _showAlerts,
    ),
  ],
)
```

---

## Referencia Completa

Para ver la librería completa con ejemplos visuales, abre:
```
docs/stich/iconos1.html
```

Para consultas sobre implementación, consulta:
```
lib/core/theme/app_icons.dart
lib/core/widgets/icons/app_icon.dart
```

---

**Última actualización:** 2026-02-11
**Versión:** 1.5 Expanded
**Mantenedor:** AmbuTrack Dev Team
