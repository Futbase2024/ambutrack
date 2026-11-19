import 'dart:math' as math;

import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/export/gestion_report.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_formatters.dart';
import 'package:excel/excel.dart' as xl;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:intl/intl.dart';

/// Renderiza [GestionReport] como libro Excel (.xlsx) y lo descarga.
///
/// - Las secciones de campos de cada informe van juntas en una hoja.
/// - Cada tabla va en su propia hoja, con cabecera de color y valores tipados
///   (números, fechas e importes se pueden ordenar y sumar en Excel).
class GestionReportExcel {
  const GestionReportExcel._();

  static const String _hojaInicial = 'Sheet1';
  static const int _maxAncho = 60;

  /// Genera el libro y lo descarga en el navegador. Devuelve los bytes del .xlsx.
  static Future<List<int>?> descargar(List<GestionReport> reports, {required String fileName}) async {
    debugPrint('📊 GestionReportExcel: generando "$fileName"');
    final xl.Excel excel = xl.Excel.createExcel();
    final _SheetNames names = _SheetNames();
    for (final GestionReport r in reports) {
      final List<GestionReportFields> fields = r.sections.whereType<GestionReportFields>().toList();
      // Ficha (campos) primero; si solo hay resumen, va en una hoja "Resumen" tras las tablas
      if (fields.isNotEmpty) {
        _writeFields(excel[names.next(reports.length == 1 ? 'Ficha' : r.title)], r, fields);
      }
      for (final GestionReportTable t in r.sections.whereType<GestionReportTable>()) {
        _writeTable(excel[names.next(t.sheetName ?? t.title)], r, t);
      }
      if (fields.isEmpty && r.summary.isNotEmpty) {
        _writeFields(excel[names.next('Resumen')], r, fields);
      }
    }
    if (names.used.isNotEmpty) {
      excel
        ..setDefaultSheet(names.used.first)
        ..delete(_hojaInicial);
    }
    return excel.save(fileName: '$fileName.xlsx');
  }

  // ---------------------------------------------------------------- estilos

  /// Color de AppColors en formato ARGB 'FFRRGGBB' (el que usa el paquete excel)
  static xl.ExcelColor _color(Color c) =>
      xl.ExcelColor.fromHexString('FF${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}');

  static final xl.CellStyle _title =
      xl.CellStyle(bold: true, fontSize: 14, fontColorHex: _color(AppColors.primary));
  static final xl.CellStyle _subtitle = xl.CellStyle(italic: true, fontColorHex: _color(AppColors.gray500));
  static final xl.CellStyle _header = xl.CellStyle(
    bold: true,
    fontColorHex: _color(AppColors.surfaceLight),
    backgroundColorHex: _color(AppColors.primary),
    verticalAlign: xl.VerticalAlign.Center,
  );
  static final xl.CellStyle _section = xl.CellStyle(
    bold: true,
    fontColorHex: _color(AppColors.primary),
    backgroundColorHex: _color(AppColors.primarySurface),
  );
  static final xl.CellStyle _label = xl.CellStyle(bold: true, fontColorHex: _color(AppColors.gray600));
  static const xl.NumFormat _moneyFormat = xl.CustomNumericNumFormat(formatCode: '#,##0.00 "€"');

  // ---------------------------------------------------------------- escritura

  /// Escribe título, subtítulo y fecha de generación. Devuelve la siguiente fila libre.
  static int _writeHeader(xl.Sheet sheet, GestionReport r, {String? extra}) {
    final String generado = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    _set(sheet, 0, 0, r.title, _title);
    final String sub = <String?>[r.subtitle, extra, 'Generado el $generado']
        .whereType<String>()
        .join(' · ');
    _set(sheet, 0, 1, sub, _subtitle);
    return 3;
  }

  static void _writeFields(xl.Sheet sheet, GestionReport r, List<GestionReportFields> sections) {
    int row = _writeHeader(sheet, r);
    if (r.summary.isNotEmpty) {
      row = _writeFieldList(sheet, row, 'Resumen', r.summary);
    }
    for (final GestionReportFields s in sections) {
      row = _writeFieldList(sheet, row, s.title, s.fields);
    }
    sheet
      ..setColumnWidth(0, 26)
      ..setColumnWidth(1, 48);
  }

  static int _writeFieldList(xl.Sheet sheet, int start, String title, List<GestionReportField> fields) {
    int row = start;
    _set(sheet, 0, row, title.toUpperCase(), _section);
    _set(sheet, 1, row, '', _section);
    row++;
    for (final GestionReportField f in fields) {
      _set(sheet, 0, row, f.label, _label);
      _setValue(sheet, 1, row, f.value, highlight: f.highlight);
      row++;
    }
    return row + 1;
  }

  static void _writeTable(xl.Sheet sheet, GestionReport r, GestionReportTable t) {
    final int headerRow = _writeHeader(sheet, r, extra: r.title == t.title ? null : t.title);
    final List<int> widths = t.columns.map((GestionReportColumn c) => c.label.length + 2).toList();
    for (int c = 0; c < t.columns.length; c++) {
      _set(sheet, c, headerRow, t.columns[c].label, _header);
    }
    for (int i = 0; i < t.rows.length; i++) {
      final List<Object?> data = t.rows[i];
      for (int c = 0; c < t.columns.length && c < data.length; c++) {
        _setValue(sheet, c, headerRow + 1 + i, data[c], zebra: i.isOdd, align: t.columns[c].align);
        widths[c] = math.max(widths[c], GestionReportFormat.text(data[c]).length + 2);
      }
    }
    if (t.rows.isEmpty) {
      _set(sheet, 0, headerRow + 1, t.emptyMessage, _subtitle);
    }
    if (t.footer != null) {
      _set(sheet, 0, headerRow + t.rows.length + 2, t.footer!, _label);
    }
    for (int c = 0; c < t.columns.length; c++) {
      final double ancho = t.columns[c].excelWidth ?? math.min(widths[c], _maxAncho).toDouble();
      sheet.setColumnWidth(c, ancho);
    }
  }

  static void _set(xl.Sheet sheet, int col, int row, String text, xl.CellStyle style) {
    sheet.updateCell(
      xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
      xl.TextCellValue(text),
      cellStyle: style,
    );
  }

  /// Escribe un valor con su tipo nativo de Excel y el estilo de la rejilla
  static void _setValue(
    xl.Sheet sheet,
    int col,
    int row,
    Object? value, {
    bool zebra = false,
    bool highlight = false,
    GestionReportAlign align = GestionReportAlign.left,
  }) {
    sheet.updateCell(
      xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
      _cellValue(value),
      cellStyle: _style(value, zebra: zebra, highlight: highlight, align: align),
    );
  }

  static xl.CellValue _cellValue(Object? value) {
    return switch (value) {
      // Nunca null: el paquete excel desplaza las celdas siguientes de la fila
      null => xl.TextCellValue(GestionFormatters.vacio),
      final int i => xl.IntCellValue(i),
      final double d => xl.DoubleCellValue(d),
      final DateTime f => xl.DateCellValue.fromDateTime(f.toLocal()),
      final GestionMoney m => xl.DoubleCellValue(m.value),
      final String s when s.trim().isEmpty => xl.TextCellValue(GestionFormatters.vacio),
      GestionCell(kind: GestionCellKind.dot, value: final Object? v) =>
        xl.TextCellValue('● ${GestionReportFormat.text(v)}'),
      GestionCell(kind: GestionCellKind.text, value: final Object? v) => _cellValue(v),
      _ => xl.TextCellValue(GestionReportFormat.text(value)),
    };
  }

  static xl.CellStyle? _style(
    Object? value, {
    required bool zebra,
    required bool highlight,
    required GestionReportAlign align,
  }) {
    final GestionCell? c = value is GestionCell ? value : null;
    final bool vacio = GestionReportFormat.text(value) == GestionFormatters.vacio;
    final Color? font = switch (c?.kind) {
      _ when highlight => AppColors.error,
      _ when vacio => AppColors.gray400,
      GestionCellKind.check => c!.checked ? AppColors.success : AppColors.gray400,
      _ => c?.color,
    };
    final bool bold = highlight || (c?.bold ?? false) || (c?.kind == GestionCellKind.check && c!.checked);
    final bool money = value is GestionMoney;
    final GestionReportAlign efectiva = c?.kind == GestionCellKind.check ? GestionReportAlign.center : align;
    if (font == null && !bold && !zebra && !money && efectiva == GestionReportAlign.left) {
      return null;
    }
    return xl.CellStyle(
      fontColorHex: font == null ? xl.ExcelColor.black : _color(font),
      backgroundColorHex: zebra ? _color(AppColors.gray50) : xl.ExcelColor.none,
      bold: bold,
      horizontalAlign: switch (efectiva) {
        GestionReportAlign.left => xl.HorizontalAlign.Left,
        GestionReportAlign.center => xl.HorizontalAlign.Center,
        GestionReportAlign.right => xl.HorizontalAlign.Right,
      },
      numberFormat: money ? _moneyFormat : xl.NumFormat.standard_0,
    );
  }
}

/// Genera nombres de hoja válidos y únicos (máx. 31 caracteres, sin : \ / ? * [ ])
class _SheetNames {
  final List<String> used = <String>[];

  String next(String base) {
    final String limpio = base.replaceAll(RegExp(r'[:\\/?*\[\]]'), ' ').trim();
    String nombre = limpio.length > 31 ? limpio.substring(0, 31) : limpio;
    int n = 2;
    while (used.contains(nombre)) {
      final String sufijo = ' ($n)';
      nombre = '${limpio.substring(0, math.min(limpio.length, 31 - sufijo.length))}$sufijo';
      n++;
    }
    used.add(nombre);
    return nombre;
  }
}
