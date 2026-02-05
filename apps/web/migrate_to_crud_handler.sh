#!/bin/bash

# Script para migrar automáticamente archivos a usar CrudOperationHandler
# Uso: ./migrate_to_crud_handler.sh <archivo>

set -e

FILE="$1"

if [ -z "$FILE" ]; then
  echo "❌ Error: Debes proporcionar un archivo"
  echo "Uso: ./migrate_to_crud_handler.sh <archivo>"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "❌ Error: Archivo no encontrado: $FILE"
  exit 1
fi

echo "🔄 Migrando: $FILE"

# Backup
cp "$FILE" "${FILE}.backup"
echo "✅ Backup creado: ${FILE}.backup"

# 1. Agregar import de CrudOperationHandler si no existe
if ! grep -q "crud_operation_handler" "$FILE"; then
  echo "📝 Agregando import de CrudOperationHandler..."
  # Buscar la última línea de imports y agregar después
  sed -i '' "/^import.*widgets/a\\
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
" "$FILE"
fi

# 2. Agregar import de AppLoadingIndicator si no existe (para forms)
if echo "$FILE" | grep -q "form_dialog.dart"; then
  if ! grep -q "app_loading_indicator" "$FILE"; then
    echo "📝 Agregando import de AppLoadingIndicator..."
    sed -i '' "/^import.*widgets/a\\
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
" "$FILE"
  fi
fi

# 3. Reemplazar SnackBar de éxito con CrudOperationHandler en BlocListener
echo "📝 Reemplazando SnackBars con CrudOperationHandler..."

# Este script es un punto de partida - la migración real requiere análisis manual
# debido a las diferencias en estructura de cada archivo

echo "⚠️  IMPORTANTE: Este script solo agrega imports."
echo "⚠️  La migración completa requiere edición manual siguiendo el patrón:"
echo ""
echo "FORMS:"
echo "  1. Agregar variable: bool _isSaving = false;"
echo "  2. En build(): Envolver con BlocListener"
echo "  3. En listener: usar CrudOperationHandler.handleSuccess/Error"
echo "  4. En _handleSave: setState(() => _isSaving = true) + showDialog(AppLoadingOverlay)"
echo ""
echo "TABLES:"
echo "  1. Agregar variables: _isDeleting, _loadingDialogContext, _deleteStartTime"
echo "  2. Agregar BlocListener con CrudOperationHandler.handleDeleteSuccess/Error"
echo "  3. Modificar _confirmDelete para mostrar AppLoadingOverlay"
echo ""
echo "✅ Imports agregados. Ahora edita manualmente siguiendo el patrón de:"
echo "   - lib/features/personal/presentation/widgets/personal_form_dialog.dart"
echo "   - lib/features/personal/presentation/widgets/personal_table.dart"

exit 0
