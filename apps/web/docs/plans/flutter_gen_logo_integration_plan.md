# Plan: Integración Flutter Gen + Logo en Auth y AppShell

> **Fecha**: 2025-12-29
> **Objetivo**: Configurar flutter_gen para gestión de assets y añadir logo en pantallas de auth y CupertinoNavigationBar del AppShell
> **Complejidad**: Media (5 archivos a modificar/crear)

---

## 1. Contexto Actual

### Assets Existentes
- `lib/core/assets/logodark.png` - Logo para modo oscuro
- `lib/core/assets/logolight.png` - Logo para modo claro

### Archivos a Modificar
- `pubspec.yaml` - Añadir flutter_gen y configuración de assets
- `lib/presentation/features/auth/widgets/auth_header.dart` - Reemplazar icono por logo
- `lib/presentation/features/app_shell/page/app_shell_page.dart` - Añadir CupertinoNavigationBar con logo

### Archivos Generados (automáticos)
- `lib/core/assets/assets.gen.dart` - Generado por flutter_gen

---

## 2. Pasos de Implementación

### Paso 1: Configurar pubspec.yaml

**Añadir dependencia flutter_gen:**
```yaml
dev_dependencies:
  # ... existentes ...
  flutter_gen_runner: ^5.7.0
```

**Añadir configuración flutter_gen:**
```yaml
flutter_gen:
  output: lib/core/assets
  line_length: 80

  integrations:
    flutter_svg: false
    flare_flutter: false
    rive: false
    lottie: false

  assets:
    enabled: true
    package_parameter_enabled: false
    style: dot-delimiter

  fonts:
    enabled: false
```

**Declarar assets en flutter:**
```yaml
flutter:
  uses-material-design: false
  generate: true
  assets:
    - lib/core/assets/
```

### Paso 2: Generar Assets

```bash
fvm flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Esto generará `lib/core/assets/assets.gen.dart` con:
```dart
class Assets {
  Assets._();

  static const AssetGenImage logodark = AssetGenImage('lib/core/assets/logodark.png');
  static const AssetGenImage logolight = AssetGenImage('lib/core/assets/logolight.png');
}
```

### Paso 3: Crear Widget AppLogo Reutilizable

**Archivo**: `lib/shared/widgets/app_logo.dart`

```dart
import 'package:flutter/cupertino.dart';
import '../../core/assets/assets.gen.dart';

/// Logo de la aplicación que cambia según el tema (claro/oscuro)
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.size,
  }) : assert(
         size == null || (width == null && height == null),
         'Use size OR width/height, not both',
       );

  /// Ancho del logo
  final double? width;

  /// Alto del logo
  final double? height;

  /// Tamaño cuadrado (sobrescribe width y height)
  final double? size;

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final logo = isDark ? Assets.logodark : Assets.logolight;

    return logo.image(
      width: size ?? width,
      height: size ?? height,
      fit: BoxFit.contain,
    );
  }
}
```

### Paso 4: Actualizar AuthHeader

**Archivo**: `lib/presentation/features/auth/widgets/auth_header.dart`

**Cambios:**
- Importar `AppLogo`
- Reemplazar el Container con Icon por `AppLogo`

```dart
import 'package:flutter/cupertino.dart';
import '../../../../shared/widgets/app_logo.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        // Logo de la app
        const AppLogo(size: 80),
        const SizedBox(height: 24),
        Text(
          title,
          style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}
```

### Paso 5: Actualizar AppShellPage con NavigationBar

**Archivo**: `lib/presentation/features/app_shell/page/app_shell_page.dart`

**Cambios:**
- Añadir `CupertinoNavigationBar` con logo en `middle`
- Mantener estructura existente

```dart
import 'package:flutter/cupertino.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../widgets/app_tab_bar.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key, required this.child});

  final Widget child;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const AppLogo(height: 32),
        // Opcional: añadir acciones si se requieren
        // trailing: CupertinoButton(...),
      ),
      child: Column(
        children: [
          Expanded(child: widget.child),
          const AppTabBar(),
        ],
      ),
    );
  }
}
```

---

## 3. Comandos de Ejecución

```bash
# 1. Instalar dependencias
fvm flutter pub get

# 2. Generar código (incluye flutter_gen)
dart run build_runner build --delete-conflicting-outputs

# 3. Aplicar fixes y analizar
dart fix --apply && dart analyze

# 4. Ejecutar tests
flutter test --coverage
```

---

## 4. Checklist de Validación

- [ ] `pubspec.yaml` actualizado con flutter_gen_runner
- [ ] `pubspec.yaml` tiene declaración de assets
- [ ] `lib/core/assets/assets.gen.dart` generado correctamente
- [ ] `lib/shared/widgets/app_logo.dart` creado
- [ ] `auth_header.dart` usa `AppLogo` en lugar de icono
- [ ] `app_shell_page.dart` tiene `CupertinoNavigationBar` con logo
- [ ] `dart analyze` sin errores ni warnings
- [ ] Tests pasan correctamente

---

## 5. Consideraciones

### Tema Claro/Oscuro
El widget `AppLogo` detecta automáticamente el brightness del tema actual y muestra:
- `logolight.png` en modo claro
- `logodark.png` en modo oscuro

### Tamaños Recomendados
- **AuthHeader**: `size: 80` (cuadrado 80x80)
- **CupertinoNavigationBar**: `height: 32` (ajustado a la barra)

### Alternativa: Logo con Texto
Si se requiere logo + texto, considerar crear widget `AppLogoWithTitle`:
```dart
class AppLogoWithTitle extends StatelessWidget {
  // Logo a la izquierda + "Content Engine" a la derecha
}
```

---

## 6. Estructura Final

```
lib/
├── core/
│   └── assets/
│       ├── logodark.png
│       ├── logolight.png
│       └── assets.gen.dart  # Generado
│
├── shared/
│   └── widgets/
│       └── app_logo.dart    # Nuevo
│
└── presentation/
    └── features/
        ├── auth/
        │   └── widgets/
        │       └── auth_header.dart  # Modificado
        │
        └── app_shell/
            └── page/
                └── app_shell_page.dart  # Modificado
```

---

## 7. Rollback

En caso de problemas:
1. Revertir cambios en `pubspec.yaml`
2. Eliminar `lib/core/assets/assets.gen.dart`
3. Revertir `auth_header.dart` y `app_shell_page.dart`
4. Ejecutar `fvm flutter pub get`
