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
import '../features/auth/presentation/bloc/auth_state.dart';
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
  NotificacionesBloc? _notificacionesBloc;
  late final LocalNotificationsService _notificationsService;
  late final GoRouter _router;
  bool _isNotificacionesBlocInitialized = false;

  @override
  void initState() {
    super.initState();

    debugPrint('🚀 [App] Inicializando App...');

    // Obtener BLoCs del service locator
    _authBloc = getIt<AuthBloc>();
    _registroHorarioBloc = getIt<RegistroHorarioBloc>();
    _notificationsService = getIt<LocalNotificationsService>();

    debugPrint('🔔 [App] LocalNotificationsService obtenido: $_notificationsService');

    // Crear router
    _router = createAppRouter(_authBloc);

    // Verificar sesión existente al iniciar
    _authBloc.add(const AuthCheckRequested());

    // Observar el ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);

    // Configurar callback para notificaciones in-app
    debugPrint('🔔 [App] Configurando callback onShowInAppNotification...');
    _notificationsService.onShowInAppNotification = _mostrarNotificacionInApp;
    debugPrint('✅ [App] Callback configurado');

    // Escuchar cambios de autenticación para inicializar NotificacionesBloc
    _authBloc.stream.listen(_onAuthStateChanged);

    // Verificar si YA está autenticado (sesión guardada)
    final currentState = _authBloc.state;
    debugPrint('🔔 [App] Estado actual de AuthBloc: ${currentState.runtimeType}');
    if (currentState is AuthAuthenticated) {
      debugPrint('🔔 [App] Usuario YA autenticado, inicializando NotificacionesBloc...');
      _initializeNotificacionesBloc();
    }
  }

  /// Inicializa NotificacionesBloc cuando el usuario se autentica
  void _onAuthStateChanged(AuthState state) {
    debugPrint('🔔 [App] Estado de AuthBloc cambiado: ${state.runtimeType}');

    if (!_isNotificacionesBlocInitialized && state is AuthAuthenticated) {
      debugPrint('🔔 [App] Usuario autenticado (stream), inicializando NotificacionesBloc...');
      _initializeNotificacionesBloc();
    }
  }

  /// Inicializa el NotificacionesBloc
  void _initializeNotificacionesBloc() {
    _notificacionesBloc = getIt<NotificacionesBloc>();
    _notificacionesBloc!.add(const NotificacionesEvent.started());

    _isNotificacionesBlocInitialized = true;

    debugPrint('✅ [App] NotificacionesBloc inicializado: $_notificacionesBloc');
    setState(() {}); // Rebuild para proporcionar el BLoC
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
    debugPrint('🔔 [App] Notificación recibida: ${notificacion.titulo}');
    debugPrint('   Tipo: ${notificacion.tipo.value}');

    // ✅ VERIFICACIÓN: Si estamos en /servicios y es una notificación de traslado asignado/desasignado,
    // NO mostrar la notificación in-app porque el TrasladosBloc ya maneja el evento con su propio diálogo
    final routerState = _router.routerDelegate.currentConfiguration;
    final ubicacionActual = routerState.last.matchedLocation;
    final enServicios = ubicacionActual == '/servicios' || ubicacionActual.startsWith('/servicios/');
    final esNotificacionTraslado = notificacion.tipo == NotificacionTipo.trasladoAsignado ||
        notificacion.tipo == NotificacionTipo.trasladoDesadjudicado;

    if (enServicios && esNotificacionTraslado) {
      debugPrint('⚠️ [App] Usuario en /servicios con notificación de traslado - NO mostrar diálogo in-app');
      debugPrint('   (El TrasladosBloc ya maneja este evento con su propio diálogo)');
      return;
    }

    // Reproducir sonido de notificación usando el servicio
    _notificationsService.reproducirSonido();

    // Obtener contexto del router
    final context = _router.routerDelegate.navigatorKey.currentContext;
    debugPrint('📍 [App] Contexto del router: ${context != null ? "✅ disponible" : "❌ null"}');
    debugPrint('📍 [App] Contexto mounted: ${context?.mounted ?? false}');

    if (context != null && context.mounted) {
      debugPrint('✅ [App] Mostrando diálogo de notificación in-app');
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => NotificacionInAppDialog(
          notificacion: notificacion,
          onAbrirNotificaciones: () {
            debugPrint('👆 [App] Botón Ver presionado');

            // Marcar notificación como leída
            _notificacionesBloc!.add(
              NotificacionesEvent.marcarComoLeida(notificacion.id),
            );

            // Navegar según el tipo de notificación
            final rutaDestino = notificacion.tipo == NotificacionTipo.alertaCaducidad
                ? '/caducidades'
                : '/servicios';

            debugPrint('📍 [App] Ruta destino: $rutaDestino');

            // Verificar si ya estamos en la ruta destino para no duplicar la navegación
            final routerState = _router.routerDelegate.currentConfiguration;
            final ubicacionActual = routerState.last.matchedLocation;
            final yaEnRutaDestino = ubicacionActual == rutaDestino ||
                ubicacionActual.startsWith('$rutaDestino/');

            debugPrint('📍 [App] Ubicación actual: $ubicacionActual');
            debugPrint('📍 [App] ¿Ya en ruta destino?: $yaEnRutaDestino');

            if (yaEnRutaDestino) {
              debugPrint('📍 [App] Ya estamos en $rutaDestino, no se navega de nuevo');
            } else {
              // Usar context.push() en lugar de _router.go() para agregar al stack de navegación
              // Esto asegura que el botón de back aparezca correctamente
              context.push(rutaDestino);
              debugPrint('📍 [App] Notificación marcada como leída y navegando a $rutaDestino');
            }
          },
        ),
      );
    } else {
      debugPrint('❌ [App] No se puede mostrar diálogo: contexto no disponible');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lista de providers
    final providers = <BlocProvider<dynamic>>[
      BlocProvider<AuthBloc>.value(value: _authBloc),
      BlocProvider<RegistroHorarioBloc>.value(value: _registroHorarioBloc),
    ];

    // Añadir NotificacionesBloc solo si está inicializado
    if (_notificacionesBloc != null) {
      providers.add(BlocProvider<NotificacionesBloc>.value(value: _notificacionesBloc!));
    }

    return MultiBlocProvider(
      providers: providers,
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
