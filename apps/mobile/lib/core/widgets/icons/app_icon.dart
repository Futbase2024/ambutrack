import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Estados del icono de AmbuTrack
enum AppIconState {
  /// Estado activo (azul brand)
  active,

  /// Estado hover (azul 40% alpha)
  hover,

  /// Estado deshabilitado (gris 30% alpha)
  disabled,
}

/// Widget de icono de AmbuTrack con estados predefinidos
///
/// Facilita el uso de iconos siguiendo el Design System de AmbuTrack.
///
/// **Ejemplo:**
/// ```dart
/// AppIcon(
///   AppIcons.gearUniform,
///   state: AppIconState.active,
///   size: 24,
/// )
/// ```
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.state = AppIconState.active,
    this.size = 24.0,
    this.color,
  });

  final IconData icon;
  final AppIconState state;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color ?? _getColorForState(),
    );
  }

  Color _getColorForState() {
    switch (state) {
      case AppIconState.active:
        return AppColors.primary;
      case AppIconState.hover:
        return AppColors.primary.withValues(alpha: 0.4);
      case AppIconState.disabled:
        return const Color(0xFF475569).withValues(alpha: 0.3);
    }
  }
}

/// Widget de icono interactivo que cambia de estado automáticamente
///
/// Cambia entre estados active/hover/disabled según la interacción del usuario.
///
/// **Ejemplo:**
/// ```dart
/// AppIconButton(
///   AppIcons.gearUniform,
///   onPressed: () => print('Pressed'),
///   size: 36,
/// )
/// ```
class AppIconButton extends StatefulWidget {
  const AppIconButton(
    this.icon, {
    super.key,
    required this.onPressed,
    this.size = 36.0,
    this.padding = const EdgeInsets.all(8.0),
    this.backgroundColor,
    this.activeColor,
    this.hoverColor,
    this.disabledColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? hoverColor;
  final Color? disabledColor;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: isEnabled ? widget.onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: _getIconColor(isEnabled),
          ),
        ),
      ),
    );
  }

  Color _getIconColor(bool isEnabled) {
    if (!isEnabled) {
      return widget.disabledColor ??
          const Color(0xFF475569).withValues(alpha: 0.3);
    }

    if (_isHovered) {
      return widget.hoverColor ??
          AppColors.primary.withValues(alpha: 0.4);
    }

    return widget.activeColor ?? AppColors.primary;
  }
}
