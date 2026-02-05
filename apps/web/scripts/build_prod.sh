#!/bin/bash

echo "🔨 Compilando ambutrack-web para PRODUCCIÓN..."

# Build para Android
echo "📱 Compilando APK de producción..."
flutter build apk --flavor prod -t lib/main.dart

echo "✅ APK de producción generado en: build/app/outputs/flutter-apk/"
