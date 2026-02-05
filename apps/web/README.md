# ambutrack-web

Gestion ambulancias

Proyecto Flutter generado con la arquitectura **IAutomat** usando Mason.

## 🏗️ Arquitectura

Este proyecto implementa **Clean Architecture** con las siguientes capas:

- **Domain**: Entidades y casos de uso de negocio
- **Data**: Repositorios e implementaciones
- **Presentation**: UI, BLoC y pantallas

### Tecnologías incluidas

- ✅ **Flutter BLoC** - Gestión de estado
- ✅ **GetIt** - Inyección de dependencias
- ✅ **GoRouter** - Navegación declarativa
- ✅ **Freezed** - Inmutabilidad y generación de código
- ✅ **Firebase Suite** - Backend completo
- ✅ **Dio + Retrofit** - Cliente HTTP
- ✅ **Easy Localization** - Internacionalización

## 🚀 Ejecución

### Flavors disponibles

El proyecto está configurado con dos flavors:

#### Desarrollo (Dev)
```bash
flutter run --flavor dev -t lib/main_dev.dart
# o usar el script:
./scripts/run_dev.sh
```

#### Producción (Prod)
```bash
flutter run --flavor prod -t lib/main.dart  
# o usar el script:
./scripts/run_prod.sh
```

## 📱 Configuración específica por plataforma

### Web
- El proyecto está configurado para web
- Los flavors se manejan a través de variables de entorno
- Usar `./scripts/build_web.sh dev|prod` para compilar


## 🔨 Scripts disponibles

### Ejecución
- `./scripts/run_dev.sh` - Ejecutar en modo desarrollo
- `./scripts/run_prod.sh` - Ejecutar en modo producción

### Compilación
- `./scripts/build_dev.sh` - Compilar APK de desarrollo
- `./scripts/build_prod.sh` - Compilar APK de producción
- `./scripts/build_web.sh` - Compilar para web

## 🧱 Generación de código

### Build Runner
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Generar nueva feature
```bash
mason make iaut_feature
```

## 🔥 Firebase (incluido)

El proyecto incluye la suite completa de Firebase:
- **Core** - Configuración base
- **Auth** - Autenticación
- **Firestore** - Base de datos
- **Storage** - Almacenamiento
- **Messaging** - Notificaciones push
- **Crashlytics** - Reporte de errores
- **Remote Config** - Configuración remota
- **Analytics** - Analíticas

### Configuración de Firebase
1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com)
2. Configura las aplicaciones para cada flavor:
   - Android Dev: `com.ambutrack.web.dev`
   - Android Prod: `com.ambutrack.web`
3. Descarga los archivos de configuración:
   - `android/app/src/dev/google-services.json`
   - `android/app/src/prod/google-services.json`

## 📁 Estructura del proyecto

```
lib/
├── main.dart                 # Entry point producción
├── main_dev.dart            # Entry point desarrollo
└── lib/
    ├── app/
    │   └── router.dart      # Configuración GoRouter
    ├── core/
    │   ├── config/          # Configuraciones
    │   └── di/              # Inyección dependencias
    ├── common/              # Código compartido
    └── features/            # Features por dominio
        └── home/
            ├── data/        # Repositorios
            ├── domain/      # Entidades y casos de uso
            └── presentation/ # UI y BLoC
```

## 🚀 Próximos pasos

1. Configura Firebase para tu proyecto
2. Personaliza el tema y colores en `lib/main.dart`
3. Añade nuevas features con `mason make iaut_feature`
4. Configura CI/CD para deployments automáticos

---

**Generado con [Mason](https://pub.dev/packages/mason) + IAutomat Architecture**
