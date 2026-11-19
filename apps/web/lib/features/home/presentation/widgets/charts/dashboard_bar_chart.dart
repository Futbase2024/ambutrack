import 'dart:math' as math;

import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dato de una barra
class DashboardBarData {
  const DashboardBarData(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

/// Gráfica de barras que se adapta al tamaño disponible
class DashboardBarChart extends StatelessWidget {
  const DashboardBarChart({required this.data, super.key});

  final List<DashboardBarData> data;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _BarChartPainter(data: data)),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.data});

  final List<DashboardBarData> data;

  /// Espacio reservado arriba para el valor y abajo para la etiqueta
  static const double _kTop = 20;
  static const double _kBottom = 22;
  static const double _kSide = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= _kTop + _kBottom) {
      return;
    }

    final int maxValue = data.map((DashboardBarData d) => d.value).reduce(math.max);
    if (maxValue == 0) {
      _paintText(canvas, 'Sin datos', 14, AppColors.gray400, Offset(size.width / 2, size.height / 2), size.width);
      return;
    }

    final double chartWidth = size.width - _kSide * 2;
    final double chartHeight = size.height - _kTop - _kBottom;
    final double slot = chartWidth / data.length;
    final double barWidth = math.min(slot * 0.6, 64);
    final double yScale = chartHeight / maxValue;

    final Paint gridPaint = Paint()
      ..color = AppColors.gray100
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final double y = _kTop + (chartHeight / 4) * i;
      canvas.drawLine(Offset(_kSide, y), Offset(size.width - _kSide, y), gridPaint);
    }

    // Etiquetas más pequeñas si las columnas son estrechas
    final double labelSize = slot < 70 ? 9 : 10.5;

    for (int i = 0; i < data.length; i++) {
      final DashboardBarData item = data[i];
      final double barHeight = math.max(item.value * yScale, item.value > 0 ? 2 : 0);
      final double centerX = _kSide + slot * i + slot / 2;
      final double y = _kTop + chartHeight - barHeight;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(centerX - barWidth / 2, y, barWidth, barHeight),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        Paint()..color = item.color,
      );

      _paintText(canvas, item.value.toString(), 12, item.color, Offset(centerX, y - 10), slot, bold: true);
      _paintText(canvas, item.label, labelSize, AppColors.gray600, Offset(centerX, size.height - 9), slot - 4);
    }
  }

  /// Pinta un texto centrado en [center], recortado con elipsis a [maxWidth]
  void _paintText(
    Canvas canvas,
    String text,
    double fontSize,
    Color color,
    Offset center,
    double maxWidth, {
    bool bold = false,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: math.max(maxWidth, 0));
    painter.paint(canvas, Offset(center.dx - painter.width / 2, center.dy - painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => oldDelegate.data != data;
}
