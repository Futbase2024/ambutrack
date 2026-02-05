#!/bin/bash

echo "🚀 Ejecutando ambutrack-web en modo DESARROLLO..."

# Ejecutar la app en modo desarrollo
# Nota: --flavor solo funciona en Android/iOS/macOS, no en Web
flutter run -t lib/main_dev.dart
