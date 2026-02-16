import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Estados posibles de una tarjeta de funcionalidad
enum FunctionalityCardState {
  /// Activo (ej: turno iniciado) - Verde con borde
  active,

  /// Habilitado (disponible) - Gris claro
  enabled,

  /// Deshabilitado (no disponible) - Gris con opacidad
  disabled,
}

/// Tarjeta de funcionalidad mejorada para Home Dashboard
///
/// Características:
/// - Tres estados: activo, habilitado, deshabilitado
/// - Icono grande centrado (70% del espacio)
/// - Etiqueta centrada (30% del espacio)
/// - Animación de escala al presionar
/// - Diseño Material 3
class FunctionalityCard extends StatefulWidget {
  const FunctionalityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.state = FunctionalityCardState.enabled,
    this.subtitle,
    this.badge,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final FunctionalityCardState state;
  final String? subtitle;
  final String? badge;

  @override
  State<FunctionalityCard> createState() => _FunctionalityCardState();
}

class _FunctionalityCardState extends State<FunctionalityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isEnabled) {
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isEnabled) {
      _scaleController.reverse();
    }
  }

  bool get _isEnabled => widget.state != FunctionalityCardState.disabled;

  @override
  Widget build(BuildContext context) {
    final config = _FunctionalityCardConfig.fromState(widget.state);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _isEnabled ? widget.onTap : null,
        child: Opacity(
          opacity: config.opacity,
          child: Card(
            elevation: config.elevation,
            color: config.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: config.borderColor != null
                  ? BorderSide(color: config.borderColor!, width: 2)
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Icono - 70% del espacio
                  Expanded(
                    flex: 70,
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final iconSize = constraints.maxHeight * 0.7;
                          return Icon(
                            widget.icon,
                            size: iconSize,
                            color: config.iconColor,
                          );
                        },
                      ),
                    ),
                  ),

                  // Título y badge - 30% del espacio
                  Expanded(
                    flex: 30,
                    child: _CardLabel(
                      title: widget.title,
                      subtitle: widget.subtitle,
                      badge: widget.badge,
                      labelColor: config.labelColor,
                      badgeColor: config.badgeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Configuración de estilos según el estado de la tarjeta
class _FunctionalityCardConfig {
  const _FunctionalityCardConfig({
    required this.backgroundColor,
    required this.iconColor,
    required this.labelColor,
    required this.badgeColor,
    required this.opacity,
    required this.elevation,
    this.borderColor,
  });

  factory _FunctionalityCardConfig.fromState(FunctionalityCardState state) {
    switch (state) {
      case FunctionalityCardState.active:
        return const _FunctionalityCardConfig(
          backgroundColor: Color(0xFFD1FAE5), // Verde claro
          iconColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          badgeColor: AppColors.secondary,
          opacity: 1.0,
          elevation: 2,
          borderColor: AppColors.secondary,
        );

      case FunctionalityCardState.enabled:
        return const _FunctionalityCardConfig(
          backgroundColor: AppColors.gray100,
          iconColor: AppColors.primary,
          labelColor: AppColors.gray800,
          badgeColor: AppColors.gray600,
          opacity: 1.0,
          elevation: 1,
        );

      case FunctionalityCardState.disabled:
        return const _FunctionalityCardConfig(
          backgroundColor: AppColors.gray100,
          iconColor: AppColors.gray400,
          labelColor: AppColors.gray500,
          badgeColor: AppColors.gray400,
          opacity: 0.5,
          elevation: 0,
        );
    }
  }

  final Color backgroundColor;
  final Color iconColor;
  final Color labelColor;
  final Color badgeColor;
  final double opacity;
  final double elevation;
  final Color? borderColor;
}

/// Widget con la etiqueta de la tarjeta
class _CardLabel extends StatelessWidget {
  const _CardLabel({
    required this.title,
    this.subtitle,
    this.badge,
    required this.labelColor,
    required this.badgeColor,
  });

  final String title;
  final String? subtitle;
  final String? badge;
  final Color labelColor;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge (si existe)
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
            ],

            // Subtítulo (si existe)
            if (subtitle != null) ...[
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 10,
                  color: labelColor.withValues(alpha: 0.7),
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
            ],

            // Título principal
            Text(
              title,
              style: TextStyle(
                fontSize: 18, // Reducido ligeramente desde 24
                fontWeight: FontWeight.bold,
                color: labelColor,
                height: 1.0,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
