# AmbuTrack Monorepo

Repositorio unificado de AmbuTrack que contiene la aplicación web (backoffice) y la aplicación móvil (conductores).

## 📁 Estructura

```
ambutrack/
├── apps/
│   ├── mobile/          # App Android/iOS para conductores
│   └── web/             # Backoffice administrativo web
├── packages/
│   └── ambutrack_core/  # Paquete compartido (datasources, entities, models)
├── melos.yaml           # Configuración del monorepo
└── README.md
```

## 🚀 Inicio Rápido

### Requisitos previos

- Flutter SDK 3.9.2+
- Dart 3.9.2+
- Melos (para gestionar el monorepo)

### Instalación

1. **Instalar Melos globalmente:**
   ```bash
   dart pub global activate melos
   ```

2. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/tu-org/ambutrack.git
   cd ambutrack
   ```

3. **Bootstrap del monorepo:**
   ```bash
   melos bootstrap
   ```
   Esto ejecuta `flutter pub get` en todos los paquetes y vincula las dependencias locales.

## 🛠️ Comandos Útiles

### Desarrollo

```bash
# Bootstrap (ejecutar después de clonar o cambiar dependencies)
melos bootstrap

# Análisis estático
melos run analyze

# Formatear código
melos run format

# Tests
melos run test                  # Todos los tests
melos run test:mobile           # Solo mobile
melos run test:web              # Solo web
melos run test:core             # Solo core package

# Build runner (generar código)
melos run build:runner

# Limpieza profunda
melos run clean:deep
```

### Trabajar en una app específica

```bash
# Mobile
cd apps/mobile
flutter run

# Web
cd apps/web
flutter run -d chrome
```

## 📦 Paquete Core

El paquete `ambutrack_core` contiene:

- **Datasources**: Interfaces y implementaciones de acceso a datos (Supabase)
- **Entities**: Modelos de dominio puros
- **Models**: DTOs para serialización JSON
- **Utils**: Utilidades compartidas

### Agregar nueva entity al core

1. Crear la entity en `packages/ambutrack_core/lib/src/datasources/[modulo]/`
2. Exportarla en `packages/ambutrack_core/lib/ambutrack_core.dart`
3. Ejecutar `melos bootstrap` para que las apps la vean

## 🔄 Flujo de Trabajo

### Agregar feature que afecta web y mobile

```bash
# 1. Crear rama
git checkout -b feature/nueva-funcionalidad

# 2. Modificar core si es necesario
cd packages/ambutrack_core
# ... hacer cambios ...

# 3. Actualizar web
cd ../../apps/web
# ... implementar en web ...

# 4. Actualizar mobile
cd ../mobile
# ... implementar en mobile ...

# 5. Tests
melos run test

# 6. Commit (TODO en un solo commit)
git add .
git commit -m "feat: agregar nueva funcionalidad (web + mobile + core)"

# 7. Push
git push origin feature/nueva-funcionalidad
```

### Agregar feature solo en mobile

```bash
cd apps/mobile
# ... desarrollar ...
git commit -m "feat(mobile): agregar feature X"
```

## 🧪 Testing

```bash
# Unit tests de core
cd packages/ambutrack_core
flutter test

# Tests de mobile
cd apps/mobile
flutter test

# Tests de web
cd apps/web
flutter test
```

## 📱 Apps

### Mobile (Conductores)
- **Plataformas**: Android, iOS
- **Usuario**: Personal de campo (conductores, técnicos)
- **Features**: Servicios, traslados, registro horario, checklists

### Web (Backoffice)
- **Plataforma**: Web responsive
- **Usuario**: Coordinadores, administradores
- **Features**: Gestión completa (personal, vehículos, cuadrantes, etc.)

## 🤝 Contribuir

1. Crear rama desde `main`
2. Hacer cambios
3. Ejecutar `melos run analyze` y `melos run test`
4. Crear Pull Request

## 📄 Licencia

Propietario - AmbuTrack © 2024
