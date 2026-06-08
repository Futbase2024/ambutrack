import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/menu/presentation/widgets/app_bar_with_menu.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_bloc.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_event.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_state.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/widgets/notificacion_tipo_config.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/widgets/notificaciones_pendientes_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/incidencias/incidencia_notificacion_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final bool isDev = F.appFlavor == Flavor.dev;

    debugPrint('MainLayout - Flavor actual: ${F.appFlavor} (isDev: $isDev)');

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState authState) {
        if (authState is! AuthAuthenticated) {
          return _buildScaffold(context, isDev, isAuthenticated: false);
        }

        final String userId = authState.user.uid;

        return BlocProvider<NotificacionBloc>(
          create: (BuildContext context) {
            return getIt<NotificacionBloc>()
              ..add(NotificacionEvent.subscribeNotificaciones(userId));
          },
          child: _buildScaffold(context, isDev, isAuthenticated: true),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, bool isDev, {required bool isAuthenticated}) {
    final Widget scaffold = Scaffold(
      appBar: AppBarWithMenu(title: title),
      body: Stack(
        children: <Widget>[
          child,
          if (isDev)
            Positioned(
              top: 0,
              right: 0,
              child: CustomPaint(
                painter: _DebugBannerPainter(),
                child: const SizedBox(width: 100, height: 100),
              ),
            ),
        ],
      ),
    );

    if (!isAuthenticated) {
      return scaffold;
    }

    return _NotificacionesListenerWrapper(child: scaffold);
  }
}

/// Wrapper StatefulWidget que escucha notificaciones pendientes y nuevas.
///
/// Soluciona el timing issue: el BlocListener se monta ANTES de que
/// el BLoC emita el primer estado loaded, y usa addPostFrameCallback
/// para asegurar que el Navigator esté listo antes de mostrar el diálogo.
class _NotificacionesListenerWrapper extends StatefulWidget {
  const _NotificacionesListenerWrapper({required this.child});

  final Widget child;

  @override
  State<_NotificacionesListenerWrapper> createState() =>
      _NotificacionesListenerWrapperState();
}

class _NotificacionesListenerWrapperState
    extends State<_NotificacionesListenerWrapper> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificacionBloc, NotificacionState>(
      listenWhen: (NotificacionState previous, NotificacionState current) {
        final int currentConteo = current.whenOrNull(
          loaded: (List<NotificacionEntity> _, int conteo) => conteo,
        ) ?? 0;

        // Solo proceder si hay notificaciones pendientes
        if (currentConteo == 0) {
          return false;
        }

        // Detectar si el estado actual tiene notificaciones reales (no vacías)
        final bool currentHasNotificaciones = current.whenOrNull(
          loaded: (List<NotificacionEntity> notifs, _) => notifs.isNotEmpty,
        ) ?? false;

        // Si no hay notificaciones reales todavía, no mostrar diálogo
        // (esperar a que lleguen los datos del stream)
        if (!currentHasNotificaciones) {
          return false;
        }

        // Detectar primera carga: estado previo no era loaded
        final bool wasNotLoaded = previous.maybeWhen(
          loaded: (_, __) => false,
          orElse: () => true,
        );
        if (wasNotLoaded && !_dialogShown) {
          debugPrint('🔔 NotificacionesListener: Primera carga con $currentConteo pendientes');
          return true;
        }

        // Detectar transición de loaded con lista vacía → loaded con datos reales
        // (race condition: conteo llega antes que las notificaciones)
        final bool prevHasNotificaciones = previous.whenOrNull(
          loaded: (List<NotificacionEntity> notifs, _) => notifs.isNotEmpty,
        ) ?? false;
        if (!prevHasNotificaciones && currentHasNotificaciones && !_dialogShown) {
          debugPrint('🔔 NotificacionesListener: Notificaciones reales recibidas ($currentConteo pendientes)');
          return true;
        }

        // Detectar notificaciones nuevas en tiempo real (conteo aumenta)
        final int prevConteo = previous.whenOrNull(
          loaded: (List<NotificacionEntity> _, int conteo) => conteo,
        ) ?? 0;
        if (currentConteo > prevConteo && !_dialogShown) {
          debugPrint('🔔 NotificacionesListener: Nuevas notificaciones ($prevConteo → $currentConteo)');
          return true;
        }

        return false;
      },
      listener: (BuildContext context, NotificacionState state) {
        state.whenOrNull(
          loaded: (List<NotificacionEntity> notificaciones, int conteo) {
            // Filtrar solo las no leídas
            final List<NotificacionEntity> pendientes = notificaciones
                .where((NotificacionEntity n) => !n.leida)
                .toList();

            if (pendientes.isEmpty) {
              return;
            }

            _dialogShown = true;

            // Esperar a que el Navigator esté listo
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              _mostrarDialogo(context, pendientes, conteo);
            });
          },
        );
      },
      child: widget.child,
    );
  }

  void _mostrarDialogo(
    BuildContext context,
    List<NotificacionEntity> notificaciones,
    int conteo,
  ) {
    // Si hay múltiples pendientes, mostrar diálogo resumen
    if (conteo > 1) {
      debugPrint('🔔 Mostrando diálogo de $conteo notificaciones pendientes');
      showNotificacionesPendientesDialog(
        context: context,
        notificaciones: notificaciones,
      ).whenComplete(() {
        // Resetear flag al cerrar para permitir futuros diálogos si llegan nuevas
        if (mounted) {
          setState(() => _dialogShown = false);
        }
      });
      return;
    }

    // Si es una sola incidencia de vehículo, diálogo especializado
    final NotificacionEntity notif = notificaciones.first;
    if (notif.tipo == NotificacionTipo.incidenciaVehiculoReportada) {
      debugPrint('🔔 Mostrando diálogo incidencia vehículo: ${notif.titulo}');
      showIncidenciaVehiculoDialog(context: context, notificacion: notif);
      // Resetear flag tras un frame para permitir futuras notificaciones
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _dialogShown = false);
        }
      });
      return;
    }

    // Diálogo genérico para otros tipos
    debugPrint('🔔 Mostrando diálogo genérico: ${notif.titulo}');
    _mostrarDialogoGenerico(context, notif);
  }

  void _mostrarDialogoGenerico(BuildContext context, NotificacionEntity notif) {
    final NotificacionTipoConfig config = getNotificacionTipoConfig(notif.tipo);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: config.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(config.icon, size: 48, color: config.color),
              ),
              const SizedBox(height: 20),
              Text(
                notif.titulo,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                notif.mensaje,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.gray700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    if (!notif.leida) {
                      context.read<NotificacionBloc>().add(
                            NotificacionEvent.marcarComoLeida(notif.id),
                          );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: config.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      // Resetear flag al cerrar para permitir futuros diálogos si llegan nuevas
      if (mounted) {
        setState(() => _dialogShown = false);
      }
    });
  }
}

/// Painter personalizado para el banner DEBUG
class _DebugBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double bannerWidth = 120.0;
    const double bannerHeight = 24.0;

    canvas
      ..save()
      ..translate(size.width, 0)
      ..rotate(0.785398);

    final Paint bgPaint = Paint()
      ..color = AppColors.warning
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, bannerWidth, bannerHeight),
      bgPaint,
    );

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
