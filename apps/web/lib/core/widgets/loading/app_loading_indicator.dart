import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Indicador de carga personalizado de AmbuTrack
///
/// Muestra un icono animado con progreso
class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = _defaultSize,
    this.color,
    this.icon,
  });

  /// Mensaje opcional que se muestra debajo de la animación
  final String? message;

  /// Tamaño del indicador
  final double size;

  /// Color del indicador (por defecto AppColors.primary)
  final Color? color;

  /// Icono del indicador (por defecto Icons.local_hospital)
  final IconData? icon;

  static const double _defaultSize = 120.0;

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _moveController;
  late Animation<double> _moveAnimation;

  @override
  void initState() {
    super.initState();

    // Controlador para animación de progreso
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Controlador para rotación sutil
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _moveAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _moveController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color indicatorColor = widget.color ?? AppColors.primary;
    final IconData indicatorIcon = widget.icon ?? Icons.local_hospital;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Icono con animación profesional
        AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: indicatorColor.withValues(alpha: 0.05),
              ),
              child: AnimatedBuilder(
                animation: _moveController,
                builder: (BuildContext context, Widget? child) {
                  return Transform.rotate(
                    angle: _moveAnimation.value * 0.02,
                    child: Icon(
                      indicatorIcon,
                      size: widget.size,
                      color: indicatorColor,
                    ),
                  );
                },
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Indicador de progreso lineal
        SizedBox(
          width: widget.size * 2,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return LinearProgressIndicator(
                backgroundColor: AppColors.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                minHeight: 3,
              );
            },
          ),
        ),

        if (widget.message != null) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Overlay de carga que cubre toda la pantalla
///
/// Útil para operaciones que bloquean la UI
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    this.message,
    this.color,
    this.icon,
  });

  final String? message;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.gray900.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.gray900.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AppLoadingIndicator(
            message: message,
            color: color,
            icon: icon,
          ),
        ),
      ),
    );
  }
}
