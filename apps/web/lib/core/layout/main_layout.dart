import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/menu/presentation/widgets/app_bar_with_menu.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_bloc.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_event.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Layout principal de la aplicación
///
/// Proporciona una estructura consistente con:
/// - AppBar superior fija con menú de navegación
/// - Área de contenido dinámico que cambia según la ruta
/// - Proveedor del NotificacionBloc para toda la aplicación
class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.child,
    this.title,
  });

  /// Widget hijo que se renderiza en el área de contenido
  final Widget child;

  /// Título opcional para mostrar en el AppBar
  final String? title;

  @override
  Widget build(BuildContext context) {
    final bool isDev = F.appFlavor == Flavor.dev;

    // Debug: Verificar flavor en consola
    debugPrint('MainLayout - Flavor actual: ${F.appFlavor} (isDev: $isDev)');

    // Obtener el estado de autenticación para inicializar notificaciones
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState authState) {
        // Solo proveer NotificacionBloc si el usuario está autenticado
        if (authState is! AuthAuthenticated) {
          return _buildScaffold(context, isDev);
        }

        final String userId = authState.user.uid;

        // Proveer NotificacionBloc a nivel de layout para compartir en toda la app
        return BlocProvider<NotificacionBloc>(
          create: (BuildContext context) {
            // Suscribir inmediatamente al usuario actual
            return getIt<NotificacionBloc>()
              ..add(NotificacionEvent.subscribeNotificaciones(userId));
          },
          child: _buildScaffold(context, isDev),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, bool isDev) {
    return BlocListener<NotificacionBloc, NotificacionState>(
      listenWhen: (NotificacionState previous, NotificacionState current) {
        // Obtener conteo anterior
        final int prevConteo = previous.whenOrNull(
          loaded: (List<NotificacionEntity> notificaciones, int conteo) => conteo,
        ) ?? 0;

        // Obtener conteo actual
        final int currentConteo = current.whenOrNull(
          loaded: (List<NotificacionEntity> notificaciones, int conteo) => conteo,
        ) ?? 0;

        // Verificar si el conteo de no leídas aumentó
        final bool conteoAumento = currentConteo > prevConteo;
        debugPrint('🔔 MainLayout: Conteo cambió de $prevConteo a $currentConteo, aumentó: $conteoAumento');
        return conteoAumento;
      },
      listener: (BuildContext context, NotificacionState state) {
        state.whenOrNull(
          loaded: (List<NotificacionEntity> notificaciones, int conteo) {
            if (notificaciones.isNotEmpty) {
              // Obtener la notificación más reciente
              final NotificacionEntity ultimaNotificacion = notificaciones.first;

              debugPrint('🔔 MainLayout: Mostrando diálogo para notificación: ${ultimaNotificacion.titulo}');

              // Mostrar diálogo de notificación
              _mostrarDialogoNotificacion(context, ultimaNotificacion);
            }
          },
        );
      },
      child: Scaffold(
        appBar: AppBarWithMenu(
          title: title,
        ),
        body: Stack(
          children: <Widget>[
            child,
            // Banner DEBUG siempre visible en DEV
            if (isDev)
              Positioned(
                top: 0,
                right: 0,
                child: CustomPaint(
                  painter: _DebugBannerPainter(),
                  child: const SizedBox(
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Muestra un diálogo de notificación cuando llega una nueva notificación
  void _mostrarDialogoNotificacion(BuildContext context, NotificacionEntity notificacion) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Icono según tipo de notificación
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getColorByTipo(notificacion.tipo).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconByTipo(notificacion.tipo),
                  size: 48,
                  color: _getColorByTipo(notificacion.tipo),
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                notificacion.titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Mensaje
              Text(
                notificacion.mensaje,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.gray700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Botón de cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Marcar como leída si no lo está
                    if (!notificacion.leida) {
                      context.read<NotificacionBloc>().add(
                        NotificacionEvent.marcarComoLeida(notificacion.id),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getColorByTipo(notificacion.tipo),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene el color según el tipo de notificación
  Color _getColorByTipo(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.ausenciaSolicitada:
      case NotificacionTipo.vacacionSolicitada:
        return AppColors.info;
      case NotificacionTipo.ausenciaAprobada:
      case NotificacionTipo.vacacionAprobada:
        return AppColors.success;
      case NotificacionTipo.ausenciaRechazada:
      case NotificacionTipo.vacacionRechazada:
        return AppColors.error;
      case NotificacionTipo.cambioTurno:
      case NotificacionTipo.trasladoAsignado:
      case NotificacionTipo.trasladoIniciado:
      case NotificacionTipo.trasladoFinalizado:
        return AppColors.success;
      case NotificacionTipo.trasladoDesadjudicado:
      case NotificacionTipo.trasladoCancelado:
        return AppColors.warning;
      case NotificacionTipo.checklistPendiente:
        return AppColors.warning;
      case NotificacionTipo.alerta:
        return AppColors.emergency;
      case NotificacionTipo.info:
        return AppColors.info;
    }
  }

  /// Obtiene el icono según el tipo de notificación
  IconData _getIconByTipo(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.ausenciaSolicitada:
      case NotificacionTipo.vacacionSolicitada:
        return Icons.calendar_today_outlined;
      case NotificacionTipo.ausenciaAprobada:
      case NotificacionTipo.vacacionAprobada:
        return Icons.check_circle_outline;
      case NotificacionTipo.ausenciaRechazada:
      case NotificacionTipo.vacacionRechazada:
        return Icons.cancel_outlined;
      case NotificacionTipo.cambioTurno:
        return Icons.swap_horiz_outlined;
      case NotificacionTipo.trasladoAsignado:
        return Icons.local_shipping_outlined;
      case NotificacionTipo.trasladoDesadjudicado:
        return Icons.remove_circle_outline;
      case NotificacionTipo.trasladoIniciado:
        return Icons.play_arrow_outlined;
      case NotificacionTipo.trasladoFinalizado:
        return Icons.done_all_outlined;
      case NotificacionTipo.trasladoCancelado:
        return Icons.block_outlined;
      case NotificacionTipo.checklistPendiente:
        return Icons.checklist_outlined;
      case NotificacionTipo.alerta:
        return Icons.warning_amber_outlined;
      case NotificacionTipo.info:
        return Icons.info_outlined;
    }
  }
}

/// Painter personalizado para el banner DEBUG
class _DebugBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double bannerWidth = 120.0;
    const double bannerHeight = 24.0;

    // Rotar el canvas para el efecto diagonal
    canvas
      ..save()
      ..translate(size.width, 0)
      ..rotate(0.785398); // 45 grados en radianes

    // Dibujar el fondo amarillo del banner
    final Paint bgPaint = Paint()
      ..color = AppColors.warning
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, bannerWidth, bannerHeight),
      bgPaint,
    );

    // Dibujar el texto "DEBUG"
    final TextPainter textPainter = TextPainter(
      text: const TextSpan(
        text: 'DEBUG',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter
      ..layout()
      ..paint(
        canvas,
        Offset(
          (bannerWidth - textPainter.width) / 2,
          (bannerHeight - textPainter.height) / 2,
        ),
      );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}