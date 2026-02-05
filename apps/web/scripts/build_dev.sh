#!/bin/bash

echo "🔨 Compilando ambutrack-web para DESARROLLO..."

# Build para Android
echo "📱 Compilando APK de desarrollo..."
flutter build apk --flavor dev -t lib/main_dev.dart

echo "✅ APK de desarrollo generado en: build/app/outputs/flutter-apk/"
