# 🎯 Configuración de Flavors - AmbuTrack Mobile

## ✅ Configuración Completada

### Android ✅
- **Archivo**: `android/app/build.gradle.kts`
- **Flavors configurados**:
  - `dev`: applicationId `com.ambutrack.ambutrack_mobile.dev`
  - `prod`: applicationId `com.ambutrack.ambutrack_mobile`

### VSCode ✅
- **Archivo**: `.vscode/launch.json`
- **Configuraciones disponibles**:
  - AmbuTrack Mobile (DEV)
  - AmbuTrack Mobile (PROD)
  - AmbuTrack Mobile (Profile DEV)
  - AmbuTrack Mobile (Release PROD)

---

## 📱 iOS - Configuración Manual (Requiere Xcode)

### Pasos para configurar iOS:

1. **Abrir el proyecto en Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Duplicar el esquema Runner**:
   - En Xcode, ve a: `Product > Scheme > Manage Schemes...`
   - Selecciona `Runner` y haz clic en el botón de engranaje → `Duplicate`
   - Renombra el esquema a `Runner-dev`
   - Repite para crear `Runner-prod`

3. **Configurar Build Configuration para cada esquema**:

   **Para Runner-dev**:
   - `Product > Scheme > Edit Scheme...`
   - En la pestaña `Build`, asegúrate de que Runner esté seleccionado
   - En `Run` → `Info` → `Build Configuration`: Selecciona `Debug`
   - En `Archive` → `Build Configuration`: Selecciona `Release`

   **Para Runner-prod**:
   - Mismo proceso, pero usa `Release` para ambos

4. **Configurar Bundle Identifier**:
   - Selecciona el target `Runner` en el navegador de proyectos
   - En `Build Settings`, busca `Product Bundle Identifier`
   - Para `Debug`: `com.ambutrack.ambutrack-mobile.dev`
   - Para `Release`: `com.ambutrack.ambutrack-mobile`

5. **Configurar Display Name**:
   - En `Build Settings`, busca `Product Name`
   - Para dev: `AmbuTrack DEV`
   - Para prod: `AmbuTrack`

---

## 🚀 Cómo Ejecutar

### Desde Terminal:

```bash
# DESARROLLO (DEV)
flutter run --flavor dev -t lib/main_android_dev.dart

# PRODUCCIÓN (PROD)
flutter run --flavor prod -t lib/main_android.dart

# Profile mode (para análisis de rendimiento)
flutter run --flavor dev -t lib/main_android_dev.dart --profile

# Release mode
flutter run --flavor prod -t lib/main_android.dart --release
```

### Desde VSCode:

1. Presiona `F5` o haz clic en el botón de play
2. Selecciona la configuración deseada del dropdown:
   - **AmbuTrack Mobile (DEV)** - Para desarrollo
   - **AmbuTrack Mobile (PROD)** - Para producción
   - **AmbuTrack Mobile (Profile DEV)** - Para análisis de rendimiento
   - **AmbuTrack Mobile (Release PROD)** - Para testing de producción

---

## 🔧 Build APK/IPA

### Android:

```bash
# DEV
flutter build apk --flavor dev -t lib/main_android_dev.dart

# PROD
flutter build apk --flavor prod -t lib/main_android.dart

# App Bundle (para Play Store)
flutter build appbundle --flavor prod -t lib/main_android.dart
```

### iOS:

```bash
# DEV
flutter build ipa --flavor dev -t lib/main_android_dev.dart

# PROD
flutter build ipa --flavor prod -t lib/main_android.dart
```

---

## 📦 Diferencias entre Flavors

| Característica | DEV | PROD |
|---------------|-----|------|
| **Application ID (Android)** | `com.ambutrack.ambutrack_mobile.dev` | `com.ambutrack.ambutrack_mobile` |
| **Bundle ID (iOS)** | `com.ambutrack.ambutrack-mobile.dev` | `com.ambutrack.ambutrack-mobile` |
| **App Name** | AmbuTrack DEV | AmbuTrack |
| **Supabase URL** | `SupabaseConfig.devUrl` | `SupabaseConfig.prodUrl` |
| **Supabase Key** | `SupabaseConfig.devAnonKey` | `SupabaseConfig.prodAnonKey` |
| **Instalación** | Se puede instalar junto a PROD | Standalone |

---

## ⚠️ Notas Importantes

1. **Android está 100% configurado** - Puedes ejecutar ambos flavors inmediatamente
2. **iOS requiere configuración manual** - Sigue los pasos de la sección "iOS"
3. **Los flavors DEV y PROD pueden coexistir** en el mismo dispositivo (diferentes application IDs)
4. **Supabase Config** - Asegúrate de tener las URLs y keys correctas en `lib/core/config/supabase_config.dart`

---

## 🐛 Troubleshooting

### Error: "Flavor not found"
- Asegúrate de que el archivo `build.gradle.kts` está sincronizado
- En Android Studio: `File > Sync Project with Gradle Files`

### Error: "Scheme not found" (iOS)
- Verifica que los esquemas estén correctamente configurados en Xcode
- `Product > Scheme > Manage Schemes...`

### VSCode no muestra las configuraciones
- Reinicia VSCode
- Verifica que el archivo `.vscode/launch.json` existe y está bien formado
