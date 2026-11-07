import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
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
  /// Cierra el overlay de carga y el formulario, luego muestra un diálogo de éxito
  ///
  /// [context] - Contexto de Flutter
  /// [isSaving] - Estado de guardado para determinar si cerrar el overlay
  /// [isEditing] - true para actualización, false para creación
  /// [entityName] - Nombre de la entidad procesada
  /// [onComplete] - Callback opcional para ejecutar después de cerrar
  static Future<void> handleSuccess({
    required BuildContext context,
    required bool isSaving,
    required bool isEditing,
    required String entityName,
    VoidCallback? onComplete,
  }) async {
    debugPrint('✅ $entityName guardada exitosamente, cerrando diálogo');

    if (!context.mounted) {
      return;
    }

    // Cerrar loading overlay si está abierto
    if (isSaving) {
      Navigator.of(context).pop(); // Cierra loading overlay
      // Esperar un frame para que el Navigator se desbloquee
      await Future<void>.delayed(Duration.zero);
    }

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop(); // Cierra el formulario

    // Ejecutar callback si existe
    onComplete?.call();

    if (!context.mounted) {
      return;
    }

    // Mostrar diálogo de éxito
    await showResultDialog(
      context: context,
      type: ResultType.success,
      title: isEditing ? '$entityName actualizado' : '$entityName creado',
      message: isEditing
          ? 'El registro de $entityName se ha actualizado correctamente.'
          : 'El nuevo registro de $entityName se ha creado correctamente.',
    );
  }

  /// Maneja errores durante operaciones CRUD
  ///
  /// Cierra el overlay de carga y muestra un diálogo de error (el formulario sigue abierto)
  ///
  /// [context] - Contexto de Flutter
  /// [isSaving] - Estado de guardado para determinar si cerrar el overlay
  /// [errorMessage] - Mensaje de error a mostrar
  /// [onComplete] - Callback opcional para ejecutar después de manejar el error
  static Future<void> handleError({
    required BuildContext context,
    required bool isSaving,
    required String errorMessage,
    VoidCallback? onComplete,
  }) async {
    debugPrint('❌ Error al guardar - $errorMessage');

    if (!context.mounted) {
      return;
    }

    // Cerrar loading overlay si está abierto
    if (isSaving) {
      Navigator.of(context).pop(); // Cierra loading overlay
      // Esperar un frame para que el Navigator se desbloquee
      await Future<void>.delayed(Duration.zero);
    }

    if (!context.mounted) {
      return;
    }

    // Ejecutar callback si existe
    onComplete?.call();

    // Mostrar diálogo de error (el formulario sigue abierto)
    await showResultDialog(
      context: context,
      type: ResultType.error,
      title: 'Error al guardar',
      message: 'No se pudo guardar el registro. Revisa los datos e inténtalo de nuevo.',
      details: errorMessage,
    );
  }
}
