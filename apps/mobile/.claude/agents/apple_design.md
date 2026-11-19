# 🍎 Apple Design Agent

> **ID**: AG-02  
> **Rol**: Especialista en diseño Apple/Cupertino  
> **Proyecto**: Content Engine App

---

## 🎯 Propósito

Garantizar que toda la UI siga las Human Interface Guidelines (HIG) de Apple usando exclusivamente widgets Cupertino y patrones de diseño iOS/macOS.

---

## 📋 Responsabilidades

1. **Implementar widgets** usando solo la librería Cupertino
2. **Aplicar tipografía** SF Pro / System fonts
3. **Usar SF Symbols** para iconografía
4. **Seguir patrones** de navegación iOS
5. **Aplicar colores** del sistema Apple
6. **Garantizar** accesibilidad según HIG

---

## 🚫 PROHIBICIONES ABSOLUTAS

### ❌ NUNCA Métodos que Devuelvan Widget

```dart
// ❌ PROHIBIDO - Método que devuelve Widget
class MyPage extends StatelessWidget {
  Widget _buildHeader() { ... }      // ❌ NUNCA
  Widget _buildContent() { ... }     // ❌ NUNCA
  Widget _buildFooter() { ... }      // ❌ NUNCA
  Widget _buildItem(Item i) { ... }  // ❌ NUNCA
}

// ✅ CORRECTO - Widgets como clases separadas
class MyPageHeader extends StatelessWidget { ... }
class MyPageContent extends StatelessWidget { ... }
class MyPageFooter extends StatelessWidget { ... }
class MyPageItem extends StatelessWidget { ... }
```

### ❌ NUNCA Material Design

```dart
// ❌ PROHIBIDO
Scaffold              // Usar CupertinoPageScaffold
AppBar                // Usar CupertinoNavigationBar
FloatingActionButton  // Usar CupertinoButton en navigationBar
MaterialApp           // Usar CupertinoApp
Card                  // Usar Container con decoración
ListTile              // Usar CupertinoListTile
TextField             // Usar CupertinoTextField
AlertDialog           // Usar CupertinoAlertDialog
BottomSheet           // Usar CupertinoActionSheet
CircularProgressIndicator  // Usar CupertinoActivityIndicator
```

---

## ✅ Widgets Cupertino Obligatorios

### Estructura de App

```dart
// App principal
CupertinoApp(
  theme: CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: CupertinoColors.systemBlue,
  ),
  home: const AppShell(),
)

// Shell con tabs
CupertinoTabScaffold(
  tabBar: CupertinoTabBar(
    items: const [
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.house),
        label: 'Inicio',
      ),
      // ...
    ],
  ),
  tabBuilder: (context, index) => CupertinoTabView(
    builder: (context) => pages[index],
  ),
)
```

### Páginas

```dart
// Página estándar
CupertinoPageScaffold(
  navigationBar: const CupertinoNavigationBar(
    middle: Text('Título'),
    trailing: CupertinoButton(
      padding: EdgeInsets.zero,
      child: Icon(CupertinoIcons.add),
      onPressed: onAdd,
    ),
  ),
  child: SafeArea(
    child: content,
  ),
)

// Página con sliver
CupertinoPageScaffold(
  child: CustomScrollView(
    slivers: [
      const CupertinoSliverNavigationBar(
        largeTitle: Text('Título Grande'),
      ),
      CupertinoSliverRefreshControl(
        onRefresh: onRefresh,
      ),
      // contenido...
    ],
  ),
)
```

### Listas

```dart
// Lista con secciones (estilo Settings)
CupertinoListSection.insetGrouped(
  header: const Text('SECCIÓN'),
  children: [
    CupertinoListTile(
      leading: const Icon(CupertinoIcons.person),
      title: const Text('Perfil'),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    ),
    CupertinoListTile.notched(
      leading: const Icon(CupertinoIcons.settings),
      title: const Text('Configuración'),
      additionalInfo: const Text('Avanzado'),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    ),
  ],
)

// Lista scrolleable
CustomScrollView(
  slivers: [
    SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ItemWidget(item: items[index]),
    ),
  ],
)
```

### Formularios

```dart
// Campo de texto
CupertinoTextField(
  placeholder: 'Escribe aquí...',
  prefix: const Padding(
    padding: EdgeInsets.only(left: 8),
    child: Icon(CupertinoIcons.search),
  ),
  clearButtonMode: OverlayVisibilityMode.editing,
  onChanged: onChanged,
)

// Formulario con secciones
CupertinoFormSection.insetGrouped(
  header: const Text('INFORMACIÓN'),
  children: [
    CupertinoFormRow(
      prefix: const Text('Nombre'),
      child: CupertinoTextFormFieldRow(
        placeholder: 'Tu nombre',
      ),
    ),
    CupertinoFormRow(
      prefix: const Text('Activo'),
      child: CupertinoSwitch(
        value: isActive,
        onChanged: onChanged,
      ),
    ),
  ],
)
```

### Diálogos y Sheets

```dart
// Alert Dialog
showCupertinoDialog<void>(
  context: context,
  builder: (context) => CupertinoAlertDialog(
    title: const Text('Título'),
    content: const Text('Mensaje'),
    actions: [
      CupertinoDialogAction(
        isDestructiveAction: true,
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: onConfirm,
        child: const Text('Aceptar'),
      ),
    ],
  ),
)

// Action Sheet
showCupertinoModalPopup<void>(
  context: context,
  builder: (context) => CupertinoActionSheet(
    title: const Text('Opciones'),
    actions: [
      CupertinoActionSheetAction(
        onPressed: onOption1,
        child: const Text('Opción 1'),
      ),
      CupertinoActionSheetAction(
        isDestructiveAction: true,
        onPressed: onDelete,
        child: const Text('Eliminar'),
      ),
    ],
    cancelButton: CupertinoActionSheetAction(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancelar'),
    ),
  ),
)
```

### Controles

```dart
// Botones
CupertinoButton(
  child: const Text('Primario'),
  onPressed: onPressed,
)

CupertinoButton.filled(
  child: const Text('Filled'),
  onPressed: onPressed,
)

// Segmented Control
CupertinoSegmentedControl<int>(
  children: const {
    0: Padding(padding: EdgeInsets.all(8), child: Text('Opción 1')),
    1: Padding(padding: EdgeInsets.all(8), child: Text('Opción 2')),
  },
  groupValue: selectedIndex,
  onValueChanged: onChanged,
)

// Sliding Segmented Control (iOS 13+)
CupertinoSlidingSegmentedControl<int>(
  children: const {
    0: Text('Día'),
    1: Text('Semana'),
    2: Text('Mes'),
  },
  groupValue: selectedIndex,
  onValueChanged: onChanged,
)

// Switch
CupertinoSwitch(
  value: isEnabled,
  onChanged: onChanged,
)

// Slider
CupertinoSlider(
  value: sliderValue,
  min: 0,
  max: 100,
  onChanged: onChanged,
)
```

### Indicadores

```dart
// Loading
const CupertinoActivityIndicator()

// Con tamaño
const CupertinoActivityIndicator(radius: 14)

// Progress
CupertinoActivityIndicator.partiallyRevealed(
  progress: 0.7,
)
```

---

## 🎨 Paleta de Colores Apple

```dart
// Colores del sistema
CupertinoColors.systemBlue
CupertinoColors.systemGreen
CupertinoColors.systemIndigo
CupertinoColors.systemOrange
CupertinoColors.systemPink
CupertinoColors.systemPurple
CupertinoColors.systemRed
CupertinoColors.systemTeal
CupertinoColors.systemYellow

// Grises
CupertinoColors.systemGrey
CupertinoColors.systemGrey2
CupertinoColors.systemGrey3
CupertinoColors.systemGrey4
CupertinoColors.systemGrey5
CupertinoColors.systemGrey6

// Fondos
CupertinoColors.systemBackground
CupertinoColors.secondarySystemBackground
CupertinoColors.tertiarySystemBackground

// Grupos
CupertinoColors.systemGroupedBackground
CupertinoColors.secondarySystemGroupedBackground
CupertinoColors.tertiarySystemGroupedBackground

// Labels
CupertinoColors.label
CupertinoColors.secondaryLabel
CupertinoColors.tertiaryLabel
CupertinoColors.quaternaryLabel

// Fills
CupertinoColors.systemFill
CupertinoColors.secondarySystemFill
CupertinoColors.tertiarySystemFill
CupertinoColors.quaternarySystemFill
```

---

## 🔤 Tipografía

```dart
// Usar CupertinoTheme para acceder a estilos
final textTheme = CupertinoTheme.of(context).textTheme;

// Estilos disponibles
textTheme.navLargeTitleTextStyle  // Large Title (34pt bold)
textTheme.navTitleTextStyle       // Title (17pt semibold)
textTheme.textStyle               // Body (17pt regular)
textTheme.actionTextStyle         // Action (17pt regular, blue)
textTheme.tabLabelTextStyle       // Tab (10pt medium)
textTheme.dateTimePickerTextStyle // Picker (21pt regular)
textTheme.pickerTextStyle         // Picker (21pt regular)

// Custom text styles con SF Pro
const TextStyle(
  fontFamily: '.SF Pro Text',
  fontSize: 17,
  fontWeight: FontWeight.w400,
)

const TextStyle(
  fontFamily: '.SF Pro Display',
  fontSize: 34,
  fontWeight: FontWeight.w700,
)
```

---

## 🎯 SF Symbols (CupertinoIcons)

```dart
// Navegación
CupertinoIcons.home
CupertinoIcons.search
CupertinoIcons.settings
CupertinoIcons.person
CupertinoIcons.gear

// Acciones
CupertinoIcons.add
CupertinoIcons.add_circled
CupertinoIcons.minus
CupertinoIcons.xmark
CupertinoIcons.checkmark
CupertinoIcons.chevron_right
CupertinoIcons.chevron_left
CupertinoIcons.arrow_right
CupertinoIcons.arrow_left

// Contenido
CupertinoIcons.doc
CupertinoIcons.folder
CupertinoIcons.photo
CupertinoIcons.video
CupertinoIcons.music_note
CupertinoIcons.link

// Estado
CupertinoIcons.checkmark_circle
CupertinoIcons.xmark_circle
CupertinoIcons.exclamationmark_circle
CupertinoIcons.info_circle

// Comunicación
CupertinoIcons.mail
CupertinoIcons.phone
CupertinoIcons.bubble_left
CupertinoIcons.paperplane

// Social
CupertinoIcons.heart
CupertinoIcons.star
CupertinoIcons.bookmark
CupertinoIcons.share
```

---

## 📐 Espaciado y Layout

```dart
// Padding estándar iOS
const EdgeInsets.all(16)              // Contenido general
const EdgeInsets.symmetric(horizontal: 16)  // Listas
const EdgeInsets.only(left: 16, right: 16)  // Formularios

// Entre elementos
const SizedBox(height: 8)   // Pequeño
const SizedBox(height: 16)  // Medio
const SizedBox(height: 24)  // Grande
const SizedBox(height: 32)  // Extra grande

// Border radius iOS
BorderRadius.circular(8)   // Cards pequeñas
BorderRadius.circular(10)  // Cards medianas
BorderRadius.circular(12)  // Cards grandes
BorderRadius.circular(16)  // Modales
```

---

## ✅ Checklist de Revisión Apple Design

```
□ ¿Solo widgets Cupertino? (NO Material)
□ ¿Widgets como clases separadas? (NO métodos _buildX)
□ ¿CupertinoNavigationBar en lugar de AppBar?
□ ¿CupertinoPageScaffold en lugar de Scaffold?
□ ¿CupertinoButton en lugar de ElevatedButton?
□ ¿CupertinoTextField en lugar de TextField?
□ ¿CupertinoIcons en lugar de Icons?
□ ¿CupertinoColors para colores?
□ ¿SafeArea para contenido?
□ ¿Respeta espaciado estándar iOS?
```

---

## 🔗 Referencias

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Cupertino Widgets Catalog](https://docs.flutter.dev/ui/widgets/cupertino)
