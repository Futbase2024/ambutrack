import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Tipo de notificación toast
enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Overlay para notificaciones toast profesionales
class ToastNotificationOverlay extends StatefulWidget {
  const ToastNotificationOverlay({super.key});

  static OverlayEntry of(BuildContext context) {
    return OverlayEntry(
      builder: (BuildContext context) => const ToastNotificationOverlay(),
    );
  }

  @override
  State<ToastNotificationOverlay> createState() => _ToastNotificationOverlayState();

  /// Muestra una notificación toast
  static void show(
    BuildContext context, {
    required ToastType type,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final OverlayState overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => _ToastNotificationWidget(
        type: type,
        title: title,
        message: message,
        duration: duration,
        onAction: onAction,
        actionLabel: actionLabel,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  /// Atajo para notificación de éxito
  static void success(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      type: ToastType.success,
      title: title,
      message: message,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Atajo para notificación de error
  static void error(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      type: ToastType.error,
      title: title,
      message: message,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Atajo para notificación de advertencia
  static void warning(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      type: ToastType.warning,
      title: title,
      message: message,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Atajo para notificación informativa
  static void info(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      type: ToastType.info,
      title: title,
      message: message,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
}

class _ToastNotificationOverlayState extends State<ToastNotificationOverlay> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Widget de notificación toast individual
class _ToastNotificationWidget extends StatefulWidget {
  const _ToastNotificationWidget({
    required this.type,
    required this.title,
    this.message,
    required this.duration,
    this.onAction,
    this.actionLabel,
    required this.onDismiss,
  });

  final ToastType type;
  final String title;
  final String? message;
  final Duration duration;
  final VoidCallback? onAction;
  final String? actionLabel;
  final VoidCallback onDismiss;

  @override
  State<_ToastNotificationWidget> createState() => _ToastNotificationWidgetState();
}

class _ToastNotificationWidgetState extends State<_ToastNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto-dismiss después de la duración
    Future<void>.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ToastConfig config = _getConfig();

    return Positioned(
      top: 16,
      right: 16,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: config.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(
                    color: config.borderColor,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Progress indicator
                    LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        config.progressColor,
                      ),
                      minHeight: 3,
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: config.iconBackgroundColor,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSmall,
                              ),
                            ),
                            child: Icon(
                              config.icon,
                              color: config.iconColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingMedium),

                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: config.titleColor,
                                  ),
                                ),
                                if (widget.message != null) ...<Widget>[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.message!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: config.messageColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Close button
                          GestureDetector(
                            onTap: _dismiss,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: config.closeButtonColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action button
                    if (widget.onAction != null && widget.actionLabel != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.paddingMedium,
                          0,
                          AppSizes.paddingMedium,
                          AppSizes.paddingMedium,
                        ),
                        child: TextButton(
                          onPressed: () {
                            widget.onAction!();
                            _dismiss();
                          },
                          child: Text(
                            widget.actionLabel!,
                            style: TextStyle(
                              color: config.actionButtonColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ToastConfig _getConfig() {
    switch (widget.type) {
      case ToastType.success:
        return const ToastConfig(
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          iconBackgroundColor: AppColors.badgeDisponibleBg,
          backgroundColor: AppColors.surfaceLight,
          borderColor: AppColors.badgeDisponibleBorder,
          progressColor: AppColors.success,
          titleColor: AppColors.textPrimaryLight,
          messageColor: AppColors.textSecondaryLight,
          closeButtonColor: AppColors.gray500,
          actionButtonColor: AppColors.success,
        );

      case ToastType.error:
        return const ToastConfig(
          icon: Icons.error_outline,
          iconColor: AppColors.error,
          iconBackgroundColor: Color(0xFFFEE2E2),
          backgroundColor: AppColors.surfaceLight,
          borderColor: Color(0xFFFECACA),
          progressColor: AppColors.error,
          titleColor: AppColors.textPrimaryLight,
          messageColor: AppColors.textSecondaryLight,
          closeButtonColor: AppColors.gray500,
          actionButtonColor: AppColors.error,
        );

      case ToastType.warning:
        return const ToastConfig(
          icon: Icons.warning_amber_outlined,
          iconColor: AppColors.warning,
          iconBackgroundColor: Color(0xFFFEF3C7),
          backgroundColor: AppColors.surfaceLight,
          borderColor: Color(0xFFFDE68A),
          progressColor: AppColors.warning,
          titleColor: AppColors.textPrimaryLight,
          messageColor: AppColors.textSecondaryLight,
          closeButtonColor: AppColors.gray500,
          actionButtonColor: AppColors.warning,
        );

      case ToastType.info:
        return const ToastConfig(
          icon: Icons.info_outline,
          iconColor: AppColors.info,
          iconBackgroundColor: Color(0xFFDBEAFE),
          backgroundColor: AppColors.surfaceLight,
          borderColor: Color(0xFFBFDBFE),
          progressColor: AppColors.info,
          titleColor: AppColors.textPrimaryLight,
          messageColor: AppColors.textSecondaryLight,
          closeButtonColor: AppColors.gray500,
          actionButtonColor: AppColors.info,
        );
    }
  }
}

/// Configuración de colores para cada tipo de toast
class ToastConfig {
  const ToastConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.progressColor,
    required this.titleColor,
    required this.messageColor,
    required this.closeButtonColor,
    required this.actionButtonColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color progressColor;
  final Color titleColor;
  final Color messageColor;
  final Color closeButtonColor;
  final Color actionButtonColor;
}

/// Extension para facilitar el uso de toasts
extension ToastContext on BuildContext {
  /// Muestra una notificación de éxito
  void showSuccessToast(
    String title, {
    String? message,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ToastNotificationOverlay.success(
      this,
      title: title,
      message: message,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Muestra una notificación de error
  void showErrorToast(
    String title, {
    String? message,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ToastNotificationOverlay.error(
      this,
      title: title,
      message: message,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Muestra una notificación de advertencia
  void showWarningToast(
    String title, {
    String? message,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ToastNotificationOverlay.warning(
      this,
      title: title,
      message: message,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Muestra una notificación informativa
  void showInfoToast(
    String title, {
    String? message,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ToastNotificationOverlay.info(
      this,
      title: title,
      message: message,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
}
