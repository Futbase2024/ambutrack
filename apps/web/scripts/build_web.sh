#!/bin/bash

# Script para build de diferentes flavors para web
FLAVOR=${1:-prod}

echo "🔄 Building web app for $FLAVOR flavor..."

case $FLAVOR in
  dev)
    flutter build web --dart-define=FLAVOR=dev --web-renderer html --base-href /dev/
    ;;
  prod)
    flutter build web --dart-define=FLAVOR=prod --web-renderer html
    ;;
  *)
    echo "❌ Flavor no válido. Usa: dev o prod"
    exit 1
    ;;
esac

echo "✅ Build completado para flavor $FLAVOR"
