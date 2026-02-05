import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Botón estándar de la aplicación con estilos consistentes
///
/// Variantes disponibles:
/// - Primary: Botón principal (azul sólido)
/// - Secondary: Botón secundario (verde sólido)
/// - Outline: Botón con borde
/// - Text: Botón solo texto
/// - Danger: Botón de acción peligrosa (rojo)
class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPressed,
    required this.label,
    super.key,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = false,
  });

  /// Callback cuando se presiona el botón
  final VoidCallback? onPressed;

  /// Texto del botón
  final String label;

  /// Icono opcional (se muestra a la izquierda del texto)
  final IconData? icon;

  /// Variante del botón (primary, secondary, outline, etc.)
  final AppButtonVariant variant;

  /// Tamaño del botón (small, medium, large)
  final AppButtonSize size;

  /// Si está en estado de carga (muestra spinner)
  final bool isLoading;

  /// Si el botón debe ocupar todo el ancho disponible
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: _getButtonStyle(),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getForegroundColor()),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: _getIconSize()),
          SizedBox(width: _getSpacing()),
          Text(label),
        ],
      );
    }

    return Text(label);
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: _getForegroundColor(),
      disabledBackgroundColor: AppColors.gray300,
      disabledForegroundColor: AppColors.gray500,
      elevation: _getElevation(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        side: _getBorderSide(),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(),
        vertical: _getVerticalPadding(),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return AppColors.secondary;
      case AppButtonVariant.outline:
        return Colors.transparent;
      case AppButtonVariant.text:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return AppColors.error;
      case AppButtonVariant.success:
        return AppColors.success;
      case AppButtonVariant.warning:
        return AppColors.warning;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.danger:
      case AppButtonVariant.success:
        return Colors.white;
      case AppButtonVariant.outline:
        return AppColors.primary;
      case AppButtonVariant.text:
        return AppColors.primary;
      case AppButtonVariant.warning:
        return AppColors.textPrimaryLight;
    }
  }

  BorderSide _getBorderSide() {
    if (variant == AppButtonVariant.outline) {
      return const BorderSide(color: AppColors.primary, width: 2);
    }
    return BorderSide.none;
  }

  double _getElevation() {
    if (variant == AppButtonVariant.text || variant == AppButtonVariant.outline) {
      return 0;
    }
    return 2;
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.large:
        return 52;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.paddingMedium;
      case AppButtonSize.medium:
        return AppSizes.paddingLarge;
      case AppButtonSize.large:
        return AppSizes.paddingXl;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.paddingSmall;
      case AppButtonSize.medium:
        return AppSizes.paddingMedium;
      case AppButtonSize.large:
        return AppSizes.padding;
    }
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.fontSmall;
      case AppButtonSize.medium:
        return AppSizes.fontMedium;
      case AppButtonSize.large:
        return AppSizes.fontLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }

  double _getSpacing() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 10;
    }
  }
}

/// Variantes de estilo del botón
enum AppButtonVariant {
  /// Botón principal (azul)
  primary,

  /// Botón secundario (verde)
  secondary,

  /// Botón con borde sin fondo
  outline,

  /// Botón solo texto sin fondo
  text,

  /// Botón de acción peligrosa (rojo)
  danger,

  /// Botón de éxito (verde)
  success,

  /// Botón de advertencia (amarillo)
  warning,
}

/// Tamaños disponibles para el botón
enum AppButtonSize {
  /// Pequeño (36px altura)
  small,

  /// Mediano (44px altura)
  medium,

  /// Grande (52px altura)
  large,
}

/// Botón de icono cuadrado con bordes redondeados
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
    this.color,
    this.size = 40,
    this.borderRadius = 10,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: IconButton(
        icon: Icon(icon, size: size * 0.5),
        color: Colors.white,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: size, minHeight: size),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
