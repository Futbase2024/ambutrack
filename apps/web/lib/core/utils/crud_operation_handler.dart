import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:flutter/material.dart';

/// Utilidad centralizada para manejar operaciones CRUD (Create, Read, Update, Delete)
///
/// Proporciona métodos estáticos para:
/// - Mostrar overlays de carga durante operaciones
/// - Manejar respuestas exitosas con feedback visual
/// - Manejar errores con mensajes descriptivos
class CrudOperationHandler {
  /// Muestra un overlay de carga mientras se ejecuta una operación CRUD
  ///
  /// [context] - Contexto de Flutter para mostrar el diálogo
  /// [isEditing] - true para operaciones de edición, false para creación
  /// [entityName] - Nombre de la entidad siendo procesada (ej: "Provincia", "Motivo")
  static void showLoadingOverlay({
    required BuildContext context,
    required bool isEditing,
    required String entityName,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: isEditing ? 'Actualizando $entityName...' : 'Creando $entityName...',
          color: isEditing ? AppColors.secondary : AppColors.primary,
          icon: isEditing ? Icons.edit : Icons.add,
        );
      },
    );
  }

  /// Maneja el resultado exitoso de una operación CRUD
  ///
  /// Cierra el overlay de carga y el formulario, luego muestra un SnackBar de éxito
  ///
  /// [context] - Contexto de Flutter
  /// [isSaving] - Estado de guardado para determinar si cerrar el overlay
  /// [isEditing] - true para actualización, false para creación
  /// [entityName] - Nombre de la entidad procesada
  /// [onComplete] - Callback opcional para ejecutar después de cerrar
  static void handleSuccess({
    required BuildContext context,
    required bool isSaving,
    required bool isEditing,
    required String entityName,
    VoidCallback? onComplete,
  }) {
    debugPrint('✅ $entityName guardada exitosamente, cerrando diálogo');

    // Cerrar loading overlay si está abierto
    if (isSaving) {
      Navigator.of(context).pop(); // Cierra loading overlay
    }

    Navigator.of(context).pop(); // Cierra el formulario

    // Ejecutar callback si existe
    onComplete?.call();

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? '✅ $entityName actualizada exitosamente' : '✅ $entityName creada exitosamente',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Maneja errores durante operaciones CRUD
  ///
  /// Cierra el overlay de carga y muestra un SnackBar con el mensaje de error
  ///
  /// [context] - Contexto de Flutter
  /// [isSaving] - Estado de guardado para determinar si cerrar el overlay
  /// [errorMessage] - Mensaje de error a mostrar
  /// [onComplete] - Callback opcional para ejecutar después de manejar el error
  static void handleError({
    required BuildContext context,
    required bool isSaving,
    required String errorMessage,
    VoidCallback? onComplete,
  }) {
    debugPrint('❌ Error al guardar - $errorMessage');

    // Cerrar loading overlay si está abierto
    if (isSaving) {
      Navigator.of(context).pop(); // Cierra loading overlay
    }

    // Ejecutar callback si existe
    onComplete?.call();

    // Mostrar mensaje de error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Error: $errorMessage'),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
