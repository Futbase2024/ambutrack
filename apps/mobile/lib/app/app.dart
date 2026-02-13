import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../core/config/router_config.dart';
import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/notificaciones/presentation/bloc/notificaciones_bloc.dart';
import '../features/notificaciones/presentation/bloc/notificaciones_event.dart';
import '../features/notificaciones/presentation/widgets/notificacion_in_app_dialog.dart';
import '../features/notificaciones/services/local_notifications_service.dart';
import '../features/registro_horario/presentation/bloc/registro_horario_bloc.dart';
import 'flavors.dart';

/// Widget principal de AmbuTrack Mobile
///
/// Configura el tema, router, localización y estado global de autenticación.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final AuthBloc _authBloc;
  late final RegistroHorarioBloc _registroHorarioBloc;
  late final NotificacionesBloc _notificacionesBloc;
  late final LocalNotificationsService _notificationsService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // Obtener BLoCs del service locator
    _authBloc = getIt<AuthBloc>();
    _registroHorarioBloc = getIt<RegistroHorarioBloc>();
    _notificacionesBloc = getIt<NotificacionesBloc>();
    _notificationsService = getIt<LocalNotificationsService>();

    // Crear router
    _router = createAppRouter(_authBloc);

    // Verificar sesión existente al iniciar
    _authBloc.add(const AuthCheckRequested());

    // Observar el ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);

    // Configurar callback para notificaciones in-app
    _notificationsService.onShowInAppNotification = _mostrarNotificacionInApp;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Actualizar estado del servicio de notificaciones
    final isInForeground = state == AppLifecycleState.resumed;
    _notificationsService.setAppLifecycleState(isInForeground);

    debugPrint('📱 [App] Ciclo de vida: $state (${isInForeground ? "primer plano" : "segundo plano"})');
  }

  /// Muestra la notificación in-app (diálogo en medio de la pantalla)
  void _mostrarNotificacionInApp(NotificacionEntity notificacion) {
    // Reproducir sonido de notificación usando el servicio
    _notificationsService.reproducirSonido();

    // Obtener contexto del router
    final context = _router.routerDelegate.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => NotificacionInAppDialog(
          notificacion: notificacion,
          onAbrirNotificaciones: () {
            // Marcar notificación como leída
            _notificacionesBloc.add(
              NotificacionesEvent.marcarComoLeida(notificacion.id),
            );

            // Navegar según el tipo de notificación
            final rutaDestino = notificacion.tipo == NotificacionTipo.alertaCaducidad
                ? '/caducidades'
                : '/servicios';

            _router.push(rutaDestino);

            debugPrint('📍 [App] Notificación marcada como leída y navegando a $rutaDestino');
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<RegistroHorarioBloc>.value(value: _registroHorarioBloc),
      ],
      child: MaterialApp.router(
        title: F.title,
        debugShowCheckedModeBanner: F.isDev,

        // Configuración de localización (español)
        locale: const Locale('es', 'ES'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],

        // Tema personalizado AmbuTrack
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,

        // Router con GoRouter y protección de rutas
        routerConfig: _router,
      ),
    );
  }
}
