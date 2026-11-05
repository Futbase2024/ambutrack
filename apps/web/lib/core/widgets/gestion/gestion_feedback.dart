import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:flutter/material.dart';

/// Diálogos de resultado estándar para las pantallas de gestión
class GestionFeedback {
  const GestionFeedback._();

  /// Diálogo profesional de éxito tras eliminar un registro.
  ///
  /// [entidad]: tipo de registro ("Taller", "Vehículo"...).
  /// [nombre]: identificador visible del registro eliminado (nombre, matrícula, código...).
  static Future<void> eliminado(
    BuildContext context, {
    required String entidad,
    String? nombre,
  }) {
    final String detalle = nombre == null || nombre.trim().isEmpty ? '' : ' "${nombre.trim()}"';
    return showResultDialog(
      context: context,
      type: ResultType.success,
      title: 'Eliminación completada',
      message: 'Registro de $entidad$detalle eliminado correctamente.',
    );
  }
}
