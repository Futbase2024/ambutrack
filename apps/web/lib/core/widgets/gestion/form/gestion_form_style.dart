import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Estilo y utilidades comunes de los formularios de gestión
class GestionFormStyle {
  const GestionFormStyle._();

  static const double fieldHeight = 34;
  static const double fontSize = 13;
  static const TextStyle text = TextStyle(fontSize: fontSize, color: AppColors.gray900);
  static const TextStyle hint = TextStyle(fontSize: fontSize, color: AppColors.gray400);

  static OutlineInputBorder _border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: color, width: width),
      );

  /// Decoración compacta y uniforme para todos los campos
  static InputDecoration decoration({
    String? hint,
    Widget? suffix,
    String? suffixText,
    bool enabled = true,
  }) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: enabled ? Colors.white : AppColors.gray50,
      hintText: hint,
      hintStyle: GestionFormStyle.hint,
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      suffixText: suffixText,
      suffixStyle: const TextStyle(fontSize: 12.5, color: AppColors.gray500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      enabledBorder: _border(AppColors.gray300),
      disabledBorder: _border(AppColors.gray200),
      focusedBorder: _border(AppColors.primary, 1.5),
      errorBorder: _border(AppColors.error),
      focusedErrorBorder: _border(AppColors.error, 1.5),
      errorStyle: const TextStyle(fontSize: 11, height: 1.1, color: AppColors.error),
      errorMaxLines: 2,
    );
  }

  /// Validador de obligatorio estándar
  static String? requerido(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;
}

/// Conversión de valores en formato español
class GestionFormParse {
  const GestionFormParse._();

  static final NumberFormat _decimal = NumberFormat('#,##0.00', 'es_ES');
  static final NumberFormat _entero = NumberFormat('#,##0', 'es_ES');

  /// "1.234,56" / "1234.56" / "1234,5" → 1234.56
  static double? decimal(String text) {
    String t = text.trim().replaceAll(' ', '');
    if (t.isEmpty) {
      return null;
    }
    if (t.contains(',')) {
      t = t.replaceAll('.', '').replaceAll(',', '.');
    }
    return double.tryParse(t);
  }

  /// "12.500" → 12500
  static int? entero(String text) {
    final String t = text.replaceAll(RegExp(r'[^\d-]'), '');
    return t.isEmpty ? null : int.tryParse(t);
  }

  /// 1234.5 → "1.234,50"
  static String formatDecimal(double? v) => v == null ? '' : _decimal.format(v);

  /// 12500 → "12.500"
  static String formatEntero(num? v) => v == null ? '' : _entero.format(v.round());
}
