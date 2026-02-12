import 'package:ambutrack_desktop/core/widgets/dialogs/result_dialog.dart';
import 'package:flutter/material.dart';

/// Handler reutilizable para operaciones CRUD
///
/// Maneja el flujo completo de:
/// 1. Cerrar loading overlay
/// 2. Cerrar formulario
/// 3. Mostrar ResultDialog con resultado
///
/// Uso:
/// ```dart
/// CrudOperationHandler.handleSuccess(
///   context: context,
///   isSaving: _isSaving,
///   isEditing: _isEditing,
///   entityName: 'Personal',
///   onClose: () => setState(() => _isSaving = false),
/// );
///
/// CrudOperationHandler.handleError(
///   context: context,
///   isSaving: _isSaving,
///   isEditing: _isEditing,
///   entityName: 'Personal',
///   errorMessage: state.message,
///   onClose: () => setState(() => _isSaving = false),
/// );
/// ```
class CrudOperationHandler {
  CrudOperationHandler._();

  /// Maneja una operación exitosa (Create/Update)
  ///
  /// - Cierra loading overlay si [isSaving] es true
  /// - Cierra el formulario con resultado true
  /// - Muestra ResultDialog de éxito
  static Future<void> handleSuccess({
    required BuildContext context,
    required bool isSaving,
    required bool isEditing,
    required String entityName,
    int? durationMs,
    VoidCallback? onClose,
  }) async {
    if (!context.mounted) {
      return;
    }

    // 1. Cerrar loading overlay si está abierto
    if (isSaving) {
      Navigator.of(context).pop();
      debugPrint('✅ CrudOperationHandler: Loading overlay cerrado');

      // Esperar un frame para que el Navigator se desbloquee
      await Future<void>.delayed(Duration.zero);
    }

    // 2. Cerrar el formulario con resultado exitoso (true)
    if (context.mounted) {
      Navigator.of(context).pop(true); // Retornar true para indicar éxito
      debugPrint('✅ CrudOperationHandler: Formulario cerrado con éxito');

      // Esperar un frame para que el Navigator se desbloquee
      await Future<void>.delayed(Duration.zero);
    }

    // 3. Ejecutar callback de limpieza si existe
    if (onClose != null) {
      onClose();
    }

    // 4. Mostrar ResultDialog profesional
    if (context.mounted) {
      await showResultDialog(
        context: context,
        title: isEditing ? '$entityName Actualizado' : '$entityName Creado',
        message: isEditing
            ? 'El registro de $entityName se ha actualizado exitosamente.'
            : 'El nuevo registro de $entityName se ha creado exitosamente.',
        type: ResultType.success,
        durationMs: durationMs,
      );
    }
  }

  /// Maneja un error en la operación (Create/Update)
  ///
  /// - Cierra loading overlay si [isSaving] es true
  /// - Cierra el formulario
  /// - Muestra ResultDialog de error con detalles técnicos
  static Future<void> handleError({
    required BuildContext context,
    required bool isSaving,
    required bool isEditing,
    required String entityName,
    required String errorMessage,
    VoidCallback? onClose,
  }) async {
    if (!context.mounted) {
      return;
    }

    // 1. Cerrar loading overlay si está abierto
    if (isSaving) {
      Navigator.of(context).pop();
      debugPrint('✅ CrudOperationHandler: Loading overlay cerrado');

      // Esperar un frame para que el Navigator se desbloquee
      await Future<void>.delayed(Duration.zero);
    }

    // 2. Cerrar el formulario
    if (context.mounted) {
      Navigator.of(context).pop();
      debugPrint('✅ CrudOperationHandler: Formulario cerrado');

      // Esperar un frame para que el Navigator se desbloquee
      await Future<void>.delayed(Duration.zero);
    }

    // 3. Ejecutar callback de limpieza si existe
    if (onClose != null) {
      onClose();
    }

    // 4. Mostrar ResultDialog con error
    if (context.mounted) {
      await showResultDialog(
        context: context,
        title: 'Error al Guardar',
        message: isEditing
            ? 'No se pudo actualizar el registro de $entityName.'
            : 'No se pudo crear el registro de $entityName.',
        type: ResultType.error,
        details: errorMessage,
      );
    }
  }

  /// Maneja una eliminación exitosa
  ///
  /// - Cierra loading overlay si [isDeleting] es true
  /// - Muestra ResultDialog de éxito con métricas de tiempo
  static Future<void> handleDeleteSuccess({
    required BuildContext context,
    required bool isDeleting,
    required String entityName,
    required int durationMs,
    VoidCallback? onClose,
  }) async {
    if (!context.mounted) {
      return;
    }

    // Esperar un pequeño delay para evitar conflictos con el Navigator
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (!context.mounted) {
      return;
    }

    // 1. Cerrar loading overlay si está abierto
    if (isDeleting) {
      Navigator.of(context ).pop();
      debugPrint('✅ CrudOperationHandler: Loading overlay cerrado');
    }

    // 2. Ejecutar callback de limpieza si existe
    if (onClose != null) {
      onClose();
    }

    // Esperar otro delay antes de mostrar el ResultDialog
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // 3. Mostrar ResultDialog profesional
    if (context.mounted) {
      await showResultDialog(
        context: context,
        title: '$entityName Eliminado',
        message: 'El registro de $entityName ha sido eliminado exitosamente.',
        type: ResultType.success,
        durationMs: durationMs,
      );
    }
  }

  /// Maneja un error en la eliminación
  ///
  /// - Cierra loading overlay si [isDeleting] es true
  /// - Muestra ResultDialog de error con detalles técnicos
  static Future<void> handleDeleteError({
    required BuildContext context,
    required bool isDeleting,
    required String entityName,
    required String errorMessage,
    VoidCallback? onClose,
  }) async {
    if (!context.mounted) {
      return;
    }

    // Esperar un pequeño delay para evitar conflictos con el Navigator
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (!context.mounted) {
      return;
    }

    // 1. Cerrar loading overlay si está abierto
    if (isDeleting) {
      Navigator.of(context).pop();
      debugPrint('✅ CrudOperationHandler: Loading overlay cerrado');
    }

    // 2. Ejecutar callback de limpieza si existe
    if (onClose != null) {
      onClose();
    }

    // Esperar otro delay antes de mostrar el ResultDialog
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // 3. Mostrar ResultDialog con error
    if (context.mounted) {
      await showResultDialog(
        context: context,
        title: 'Error al Eliminar',
        message: 'No se pudo eliminar el registro de $entityName.',
        type: ResultType.error,
        details: errorMessage,
      );
    }
  }

  /// Maneja operaciones con advertencias
  ///
  /// Útil para casos como:
  /// - Duplicados encontrados
  /// - Validaciones parciales
  /// - Operaciones completadas con observaciones
  static Future<void> handleWarning({
    required BuildContext context,
    required String title,
    required String message,
    String? details,
  }) async {
    if (!context.mounted) {
      return;
    }

    await showResultDialog(
      context: context,
      title: title,
      message: message,
      type: ResultType.warning,
      details: details,
    );
  }

  /// Maneja operaciones informativas
  ///
  /// Útil para casos como:
  /// - Operaciones parciales
  /// - Información al usuario
  /// - Cambios automáticos
  static Future<void> handleInfo({
    required BuildContext context,
    required String title,
    required String message,
    String? details,
  }) async {
    if (!context.mounted) {
      return;
    }

    await showResultDialog(
      context: context,
      title: title,
      message: message,
      type: ResultType.info,
      details: details,
    );
  }
}
