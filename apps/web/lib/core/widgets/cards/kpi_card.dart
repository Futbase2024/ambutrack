import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Trend direction para KPI cards
enum TrendDirection {
  up,
  down,
  neutral,
}

/// KPI Card profesional con trend indicator
///
/// Uso:
/// ```dart
/// KpiCard(
///   title: 'Servicios Hoy',
///   value: '127',
///   trend: '+12.5%',
///   direction: TrendDirection.up,
///   icon: Icons.local_shipping,
///   color: AppColors.primary,
/// )
/// ```
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.trend,
    this.direction = TrendDirection.neutral,
    required this.icon,
    this.color,
    this.onTap,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? trend;
  final TrendDirection direction;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? AppColors.primary;

    return Material(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: AppColors.gray200,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header con icon y trend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Icon(
                      icon,
                      color: effectiveColor,
                      size: 20,
                    ),
                  ),

                  // Trend indicator
                  if (trend != null) _TrendIndicator(trend: trend!, direction: direction),
                ],
              ),

              const SizedBox(height: AppSizes.spacingMedium),

              // Value
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                  height: 1,
                ),
              ),

              const SizedBox(height: 4),

              // Title y subtitle
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                ),
              ),

              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Indicator de tendencia para KPI cards
class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({
    required this.trend,
    required this.direction,
  });

  final String trend;
  final TrendDirection direction;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (direction) {
      case TrendDirection.up:
        color = AppColors.success;
        icon = Icons.arrow_upward_rounded;
        break;
      case TrendDirection.down:
        color = AppColors.error;
        icon = Icons.arrow_downward_rounded;
        break;
      case TrendDirection.neutral:
        color = AppColors.gray500;
        icon = Icons.remove_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            trend,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// KPI Card Compact para espacios reducidos
class KpiCardCompact extends StatelessWidget {
  const KpiCardCompact({
    super.key,
    required this.title,
    required this.value,
    this.trend,
    this.direction = TrendDirection.neutral,
    required this.icon,
    this.color,
  });

  final String title;
  final String value;
  final String? trend;
  final TrendDirection direction;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(
              icon,
              color: effectiveColor,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (trend != null)
            _CompactTrendIndicator(trend: trend!, direction: direction),
        ],
      ),
    );
  }
}

/// Indicator de tendencia compacto
class _CompactTrendIndicator extends StatelessWidget {
  const _CompactTrendIndicator({
    required this.trend,
    required this.direction,
  });

  final String trend;
  final TrendDirection direction;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (direction) {
      case TrendDirection.up:
        color = AppColors.success;
        icon = Icons.arrow_upward_rounded;
        break;
      case TrendDirection.down:
        color = AppColors.error;
        icon = Icons.arrow_downward_rounded;
        break;
      case TrendDirection.neutral:
        color = AppColors.gray500;
        icon = Icons.remove_rounded;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          trend,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// KPI Card con Sparkline (mini gráfico)
class KpiCardWithSparkline extends StatelessWidget {
  const KpiCardWithSparkline({
    super.key,
    required this.title,
    required this.value,
    this.trend,
    this.direction = TrendDirection.neutral,
    required this.icon,
    this.color,
    required this.dataPoints,
    this.onTap,
  });

  final String title;
  final String value;
  final String? trend;
  final TrendDirection direction;
  final IconData icon;
  final Color? color;
  final List<double> dataPoints;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? AppColors.primary;

    return Material(
      color: AppColors.surfaceLight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Icon(
                      icon,
                      color: effectiveColor,
                      size: 20,
                    ),
                  ),
                  if (trend != null) _TrendIndicator(trend: trend!, direction: direction),
                ],
              ),

              const SizedBox(height: AppSizes.spacingMedium),

              // Value
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),

              const SizedBox(height: 4),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: AppSizes.spacingMedium),

              // Sparkline
              _Sparkline(
                dataPoints: dataPoints,
                color: effectiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mini sparkline chart
class _Sparkline extends StatelessWidget {
  const _Sparkline({
    required this.dataPoints,
    required this.color,
  });

  final List<double> dataPoints;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final double max = dataPoints.reduce((double a, double b) => a > b ? a : b);
    final double min = dataPoints.reduce((double a, double b) => a < b ? a : b);
    final double range = max - min;

    return CustomPaint(
      size: const Size(double.infinity, 40),
      painter: _SparklinePainter(
        dataPoints: dataPoints,
        min: min,
        max: max,
        range: range,
        color: color,
      ),
    );
  }
}

/// Painter para dibujar el sparkline
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.dataPoints,
    required this.min,
    required this.max,
    required this.range,
    required this.color,
  });

  final List<double> dataPoints;
  final double min;
  final double max;
  final double range;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) {
      return;
    }

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = (i / (dataPoints.length - 1)) * size.width;
      final double normalizedValue = range == 0 ? 0.5 : (dataPoints[i] - min) / range;
      final double y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw area under the line
    final Paint areaPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final Path areaPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(areaPath, areaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
