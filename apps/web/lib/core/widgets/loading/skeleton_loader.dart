import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Skeleton loader profesional con shimmer effect
///
/// Uso:
/// ```dart
/// SkeletonLoader(
///   type: SkeletonType.card,
///   height: 100,
/// )
/// ```
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.type = SkeletonType.rectangle,
    this.width,
    this.height,
    this.borderRadius,
  });

  final SkeletonType type;
  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.gray200,
          borderRadius: BorderRadius.circular(
            borderRadius ?? _getBorderRadius(type),
          ),
        ),
      ),
    );
  }

  double _getBorderRadius(SkeletonType type) {
    switch (type) {
      case SkeletonType.circle:
        return 50;
      case SkeletonType.card:
        return 12;
      case SkeletonType.row:
        return 8;
      case SkeletonType.rectangle:
        return 8;
    }
  }
}

/// Tipos de skeleton disponibles
enum SkeletonType {
  circle,
  card,
  row,
  rectangle,
}

/// Shimmer effect animation
class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({required this.child, super.key});

  final Widget child;

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              colors: const <Color>[
                AppColors.gray200,
                AppColors.gray100,
                AppColors.gray200,
              ],
              stops: const <double>[0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Transform para animar el gradiente del shimmer
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Skeleton para una fila de tabla
class TableRowSkeleton extends StatelessWidget {
  const TableRowSkeleton({
    super.key,
    required this.columnCount,
    this.height = 56,
  });

  final int columnCount;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List<Widget>.generate(
          columnCount,
          (int index) => Expanded(
            child: index == 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildCheckbox(),
                  )
                : index == columnCount - 1
                    ? const SizedBox.shrink()
                    : const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: SkeletonLoader(
                          type: SkeletonType.row,
                          height: 16,
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return const SkeletonLoader(
      width: 20,
      height: 20,
      borderRadius: 4,
    );
  }
}

/// Skeleton para múltiples filas de tabla
class TableSkeleton extends StatelessWidget {
  const TableSkeleton({
    super.key,
    this.rowCount = 5,
    this.columnCount = 6,
  });

  final int rowCount;
  final int columnCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        rowCount,
        (int index) => TableRowSkeleton(
          columnCount: columnCount,
        ),
      ),
    );
  }
}

/// Skeleton para KPI card
class KpiCardSkeleton extends StatelessWidget {
  const KpiCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SkeletonLoader(
                type: SkeletonType.circle,
                width: 40,
                height: 40,
              ),
              SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  type: SkeletonType.row,
                  height: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SkeletonLoader(
            type: SkeletonType.row,
            height: 32,
          ),
          SizedBox(height: 8),
          SkeletonLoader(
            type: SkeletonType.row,
            height: 16,
            width: 80,
          ),
        ],
      ),
    );
  }
}

/// Skeleton para header de página
class PageHeaderSkeleton extends StatelessWidget {
  const PageHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: const Row(
        children: <Widget>[
          SkeletonLoader(
            type: SkeletonType.circle,
            width: 48,
            height: 48,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonLoader(
                  type: SkeletonType.row,
                  height: 20,
                  width: 200,
                ),
                SizedBox(height: 8),
                SkeletonLoader(
                  type: SkeletonType.row,
                  height: 14,
                  width: 300,
                ),
              ],
            ),
          ),
          SkeletonLoader(
            type: SkeletonType.row,
            height: 40,
            width: 120,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }
}
