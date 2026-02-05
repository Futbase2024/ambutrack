#!/bin/bash

echo "🚀 Ejecutando ambutrack-web en modo PRODUCCIÓN..."

# Ejecutar la app en modo producción usando main.dart principal
# Nota: --flavor solo funciona en Android/iOS/macOS, no en Web
flutter run -t lib/main.dart
