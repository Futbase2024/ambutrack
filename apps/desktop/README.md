# AmbuTrack Desktop

Aplicación de escritorio de AmbuTrack para **Windows** y **macOS**.

## 🎯 Descripción

AmbuTrack Desktop es la versión nativa de escritorio de AmbuTrack, diseñada específicamente para usuarios que trabajan todo el día en la gestión de ambulancias y servicios de emergencia médica (despachadores, coordinadores, gestores de flota).

## 🏗️ Arquitectura

### Monorepo
Este proyecto forma parte del monorepo de AmbuTrack:

```
ambutrack/
├── apps/
│   ├── web/              # Aplicación web (Chrome, Firefox, Safari)
│   ├── desktop/          # ⭐ Esta aplicación (Windows + macOS)
│   └── mobile/           # Aplicación móvil (Android + iOS)
└── packages/
    └── ambutrack_core_datasource/  # Código compartido (entities, repos, datasources)
```

### Separación de Responsabilidades

**Compartido entre todas las apps (`packages/ambutrack_core_datasource`):**
- ✅ Entities (modelos de dominio)
- ✅ DataSources (lógica de datos con Supabase)
- ✅ Repositories (contratos + implementaciones)
- ✅ BLoCs (lógica de negocio)
- ✅ Models (DTOs + serialización)
- ✅ Utils

**Específico de Desktop (`apps/desktop/lib`):**
- 🎨 UI/Widgets optimizados para pantallas grandes
- 📐 Layouts para desktop (sin limitaciones responsive)
- ⌨️ Keyboard shortcuts (Ctrl/Cmd+N, Ctrl/Cmd+S, etc.)
- 🪟 Gestión de ventanas nativas (window_manager)
- 🔔 Notificaciones nativas de sistema operativo
- 📋 Menús nativos de Windows/macOS

## 🚀 Características Desktop

### Ventajas sobre Web

1. **Rendimiento nativo** - Ejecución directa sin navegador
2. **Ventanas múltiples** - Abrir varias vistas simultáneamente
3. **Keyboard shortcuts** - Atajos de teclado profesionales
4. **Menús nativos** - Menús de Windows/macOS integrados
5. **Acceso al sistema** - Integración más profunda con el OS
6. **Offline first** - Mejor soporte offline que web
7. **Instalación local** - No depende de conexión web

### Window Manager

Configuración de ventana nativa:
- **Tamaño inicial:** 1280x800
- **Tamaño mínimo:** 800x600
- **Centrada en pantalla** al iniciar
- **Título:** "AmbuTrack Desktop"

## 📦 Dependencias Principales

```yaml
# State Management
flutter_bloc: ^9.1.1
bloc: ^9.0.1

# Backend
supabase_flutter: ^2.8.3

# Routing
go_router: ^14.2.7

# DI
get_it: ^7.7.0
injectable: ^2.4.4

# Desktop específico
window_manager: ^0.4.3  # Gestión de ventanas nativas

# Paquete compartido
ambutrack_core_datasource:  # Entities, repos, blocs compartidos
  path: ../../packages/ambutrack_core_datasource
```

## 🛠️ Comandos

### Desarrollo

```bash
# Ejecutar en macOS
flutter run -d macos

# Ejecutar en Windows (desde Windows)
flutter run -d windows

# Listar dispositivos disponibles
flutter devices

# Análisis de código
flutter analyze
```

### Compilación Release

```bash
# Compilar para macOS (desde macOS)
flutter build macos --release

# Compilar para Windows (desde Windows)
flutter build windows --release
```

### Ubicación de Builds

**macOS:**
```
build/macos/Build/Products/Release/ambutrack_desktop.app
```

**Windows:**
```
build\windows\x64\runner\Release\
```

## 📁 Estructura del Proyecto

```
apps/desktop/
├── lib/
│   ├── main.dart                    # Entry point con window_manager
│   ├── app/                         # Configuración de la app
│   ├── core/
│   │   ├── config/                  # Configuraciones (Supabase, env)
│   │   ├── di/                      # Inyección de dependencias
│   │   ├── layout/                  # Layout principal
│   │   ├── router/                  # Routing (GoRouter)
│   │   ├── services/                # Servicios (Auth, etc.)
│   │   ├── theme/                   # Tema Material 3
│   │   └── widgets/                 # Widgets compartidos desktop
│   └── features/                    # Features de la app
│       ├── auth/
│       ├── home/
│       ├── vehiculos/
│       ├── personal/
│       └── [otros módulos]
│
├── macos/                           # Proyecto nativo macOS (Xcode)
├── windows/                         # Proyecto nativo Windows (Visual Studio)
├── test/                            # Tests
├── pubspec.yaml                     # Dependencias
└── README.md                        # Este archivo
```

## 🎨 UI/UX Desktop

### Material Design 3
AmbuTrack Desktop usa Material Design 3 con adaptaciones para desktop:

- **Paleta de colores:** Azul médico (#1E40AF) + Verde salud (#059669)
- **Tipografía:** Google Fonts (optimizada para legibilidad)
- **Componentes:** Material 3 widgets nativos

### Keyboard Shortcuts (Próximos)

| Acción | Windows | macOS |
|--------|---------|-------|
| Nuevo | Ctrl+N | Cmd+N |
| Guardar | Ctrl+S | Cmd+S |
| Buscar | Ctrl+F | Cmd+F |
| Cerrar ventana | Alt+F4 | Cmd+W |
| Salir | Ctrl+Q | Cmd+Q |

## 🔧 Configuración Inicial

### Requisitos

**Para compilar en Windows:**
- Windows 10/11 (64-bit)
- Visual Studio 2022
  - Workload: "Desktop development with C++"
- Flutter SDK 3.35.3+

**Para compilar en macOS:**
- macOS 10.14+ (Mojave o superior)
- Xcode 12+
- CocoaPods (`sudo gem install cocoapods`)
- Flutter SDK 3.35.3+

### Setup

1. **Clonar repositorio:**
```bash
cd ambutrack/apps/desktop
```

2. **Instalar dependencias:**
```bash
flutter pub get
```

3. **Ejecutar:**
```bash
flutter run -d macos  # o -d windows
```

## 📝 Estado de Desarrollo

### ✅ Completado
- [x] Proyecto creado
- [x] pubspec.yaml configurado
- [x] Dependencias instaladas
- [x] Window manager configurado
- [x] Placeholder UI
- [x] flutter analyze → 0 warnings

### ⏳ Pendiente
- [ ] Copiar estructura de features desde web
- [ ] Configurar DI (GetIt + Injectable)
- [ ] Configurar routing (GoRouter)
- [ ] Configurar Supabase
- [ ] Implementar shortcuts de teclado
- [ ] Implementar menús nativos
- [ ] Tests unitarios + integración
- [ ] Scripts de build para distribución

## 🎯 Próximos Pasos

1. **Copiar estructura compartida** de `apps/web`:
   - `lib/app/` → Configuración de la app
   - `lib/core/` → Servicios, providers, widgets
   - Referencias a features se importarán desde `ambutrack_core_datasource`

2. **Adaptar para desktop:**
   - Layouts optimizados para pantallas grandes
   - Keyboard shortcuts
   - Menús nativos (File, Edit, View, Help)
   - Multi-window support

3. **Configurar build & distribución:**
   - Scripts de build automatizados
   - Firma de código (Windows + macOS)
   - Instaladores (.msi para Windows, .dmg para macOS)

## 📚 Documentación Relacionada

- [CLAUDE.md](../web/CLAUDE.md) - Guía de desarrollo AmbuTrack
- [ambutrack_core_datasource](../../packages/ambutrack_core_datasource/README.md) - Paquete compartido
- [Flutter Desktop](https://docs.flutter.dev/platform-integration/desktop) - Documentación oficial

## 🤝 Contribuir

Ver guías de desarrollo en `../web/CLAUDE.md`

## 📄 Licencia

Propiedad privada - Uso interno AmbuTrack
