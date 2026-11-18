import 'dart:math' as math;

import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dato de un segmento del donut
class DashboardDonutData {
  const DashboardDonutData(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

/// Gráfica de donut con leyenda.
///
/// Si hay ancho de sobra la leyenda va a la derecha; si no, debajo.
/// El donut siempre cabe en el lado menor del espacio disponible.
class DashboardDonutChart extends StatelessWidget {
  const DashboardDonutChart({required this.data, super.key});

  final List<DashboardDonutData> data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool horizontal = constraints.maxWidth >= constraints.maxHeight * 1.5;
        final Widget donut = SizedBox.expand(
          child: CustomPaint(painter: _DonutPainter(data: data)),
        );
        final Widget legend = _DonutLegend(data: data, horizontal: horizontal);

        if (horizontal) {
          return Row(
            children: <Widget>[
              Expanded(flex: 3, child: donut),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: legend),
            ],
          );
        }
        return Column(
          children: <Widget>[
            Expanded(child: donut),
            const SizedBox(height: 8),
            legend,
          ],
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.data});

  final List<DashboardDonutData> data;

  @override
  void paint(Canvas canvas, Size size) {
    final int total = data.fold<int>(0, (int sum, DashboardDonutData d) => sum + d.value);
    final double radius = math.min(size.width, size.height) / 2 - 2;
    if (total == 0 || radius <= 10) {
      return;
    }

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double stroke = radius * 0.32;
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    double startAngle = -math.pi / 2;
    for (final DashboardDonutData item in data) {
      if (item.value == 0) {
        continue;
      }
      final double sweep = item.value / total * 2 * math.pi;
      canvas.drawArc(
        arcRect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = item.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      startAngle += sweep;
    }

    // Texto central proporcional al tamaño del donut
    final double innerRadius = radius - stroke;
    final TextPainter painter = TextPainter(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: total.toString(),
            style: GoogleFonts.inter(
              fontSize: (innerRadius * 0.45).clamp(10, 28),
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
            ),
          ),
          TextSpan(
            text: '\nTotal',
            style: GoogleFonts.inter(fontSize: (innerRadius * 0.2).clamp(8, 12), color: AppColors.gray500),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: innerRadius * 2);
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.data != data;
}

/// Leyenda del donut: en columna (horizontal) o en línea con salto (vertical)
class _DonutLegend extends StatelessWidget {
  const _DonutLegend({required this.data, required this.horizontal});

  final List<DashboardDonutData> data;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final int total = data.fold<int>(0, (int sum, DashboardDonutData d) => sum + d.value);
    final List<Widget> items = data
        .map((DashboardDonutData d) => _LegendItem(item: d, total: total, compact: !horizontal))
        .toList();

    if (!horizontal) {
      return Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 4, children: items);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final Widget item in items) Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: item),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.item, required this.total, required this.compact});

  final DashboardDonutData item;
  final int total;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final int percentage = total > 0 ? (item.value / total * 100).round() : 0;
    final Widget swatch = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(3)),
    );
    final TextStyle labelStyle = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray700);
    final TextStyle valueStyle = GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gray900);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          swatch,
          const SizedBox(width: 6),
          Text('${item.label} ', style: labelStyle),
          Text('$percentage% (${item.value})', style: valueStyle),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        swatch,
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(item.label, style: labelStyle),
            Text('$percentage% (${item.value})', style: valueStyle),
          ],
        ),
      ],
    );
  }
}
