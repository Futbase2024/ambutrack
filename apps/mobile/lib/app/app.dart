import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../core/config/router_config.dart';
import '../core/di/injection.dart';
import '../core/services/app_lock_service.dart';
import '../core/services/gps_tracking_service.dart';
import '../core/services/push_notifications_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_lock/app_lock_gate.dart';
import '../core/widgets/app_lock/oferta_biometria.dart';
import '../core/widgets/cambio_clave/cambio_clave_obligatorio_gate.dart';
import '../features/alertas_turno/presentation/cubit/alertas_turno_cubit.dart';
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
  late final GpsTrackingService _gpsService;
  final AppLockService _appLock = getIt<AppLockService>();
  final AlertasTurnoCubit _alertasTurno = getIt<AlertasTurnoCubit>();
  final PushNotificationsService _push = getIt<PushNotificationsService>();
  bool _isNotificacionesBlocInitialized = false;
  bool _sesionBloqueable = false;
  bool _loginEnCurso = false;

  @override
  void initState() {
    super.initState();

    debugPrint('🚀 [App] Inicializando App...');

    // Obtener BLoCs del service locator
    _authBloc = getIt<AuthBloc>();
    _registroHorarioBloc = getIt<RegistroHorarioBloc>();
    _notificationsService = getIt<LocalNotificationsService>();

    debugPrint('🔔 [App] LocalNotificationsService obtenido: $_notificationsService');

    // Seguimiento GPS: envía la posición mientras la jornada está fichada
    _gpsService = GpsTrackingService(registroHorarioBloc: _registroHorarioBloc)
      ..setAutenticado(value: _authBloc.state is AuthAuthenticated)
      ..iniciar();

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

    // Push tocado (app en segundo plano o cerrada) → pantalla del aviso
    _push.onAbrirNotificacion = _abrirNotificacionPush;
    // Notificación local tocada (push con la app abierta en Android) → misma pantalla
    _notificationsService.onNotificationTap =
        (String id, NotificacionTipo tipo, String? _) => _abrirNotificacionPush(id, tipo);

    // Escuchar cambios de autenticación para inicializar NotificacionesBloc
    _authBloc.stream.listen(_onAuthStateChanged);

    // Verificar si YA está autenticado (sesión guardada)
    final currentState = _authBloc.state;
    debugPrint('🔔 [App] Estado actual de AuthBloc: ${currentState.runtimeType}');
    if (currentState is AuthAuthenticated) {
      _actualizarBloqueo(currentState);
      _actualizarAlertas(currentState);
      _actualizarPush(currentState);
      debugPrint('🔔 [App] Usuario YA autenticado, inicializando NotificacionesBloc...');
      _initializeNotificacionesBloc();
    }
  }

  /// Inicializa NotificacionesBloc cuando el usuario se autentica
  void _onAuthStateChanged(AuthState state) {
    _gpsService.setAutenticado(value: state is AuthAuthenticated);
    _actualizarBloqueo(state);
    _actualizarAlertas(state);
    _actualizarPush(state);
    debugPrint('🔔 [App] Estado de AuthBloc cambiado: ${state.runtimeType}');

    if (!_isNotificacionesBlocInitialized && state is AuthAuthenticated) {
      debugPrint('🔔 [App] Usuario autenticado (stream), inicializando NotificacionesBloc...');
      _initializeNotificacionesBloc();
    }
  }

  /// Caducidades (indicador de la barra): se recalculan al entrar y se limpian al salir
  void _actualizarAlertas(AuthState state) {
    if (state is AuthAuthenticated) {
      final String? idPersonal = state.personal?.id;
      if (idPersonal != null) {
        _alertasTurno.actualizar(idPersonal);
      }
    } else if (state is AuthUnauthenticated) {
      _alertasTurno.limpiar();
    }
  }

  /// Push: registra el móvil al entrar; al salir, el próximo login lo reasigna
  void _actualizarPush(AuthState state) {
    if (state is AuthAuthenticated) {
      unawaited(_push.activarParaUsuarioActual());
    } else if (state is AuthUnauthenticated) {
      _push.marcarSesionCerrada();
    }
  }

  /// Abre la pantalla del aviso push tocado y lo marca como leído
  void _abrirNotificacionPush(String? notificacionId, NotificacionTipo tipo) {
    if (notificacionId != null) {
      _notificacionesBloc?.add(NotificacionesEvent.marcarComoLeida(notificacionId));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _router.push(_rutaNotificacion(tipo)));
  }

  /// Bloqueo por inactividad: activo solo con sesión iniciada
  void _actualizarBloqueo(AuthState state) {
    if (state is AuthLoading) {
      _loginEnCurso = true;
    } else if (state is AuthAuthenticated) {
      if (!_sesionBloqueable) {
        _sesionBloqueable = true;
        // Sesión restaurada al abrir la app (no viene del login) → pedir huella/PIN
        _appLock.setSesionActiva(value: true, sesionRestaurada: !_loginEnCurso);
        if (_loginEnCurso) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final BuildContext? ctx = _router.routerDelegate.navigatorKey.currentContext;
            if (ctx != null && ctx.mounted) {
              ofrecerBiometriaTrasLogin(ctx);
            }
          });
        }
      }
      _loginEnCurso = false;
    } else if (state is AuthUnauthenticated) {
      _loginEnCurso = false;
      _sesionBloqueable = false;
      _appLock.setSesionActiva(value: false);
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
    unawaited(_gpsService.dispose());
    _router.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Actualizar estado del servicio de notificaciones
    final isInForeground = state == AppLifecycleState.resumed;
    _notificationsService.setAppLifecycleState(isInForeground);

    // Bloqueo por inactividad
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _appLock.irASegundoPlano();
    } else if (isInForeground) {
      _appLock.volverAPrimerPlano();
      _actualizarAlertas(_authBloc.state);
      unawaited(_push.reafirmarRegistro());
    }

    // GPS: "inactive" (diálogos del sistema, p.ej. permisos) cuenta como primer plano
    _gpsService.setPrimerPlano(
      value: state == AppLifecycleState.resumed || state == AppLifecycleState.inactive,
    );

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
            final rutaDestino = _rutaNotificacion(notificacion.tipo);

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

  /// Pantalla a la que lleva el botón "Ver" del diálogo in-app
  String _rutaNotificacion(NotificacionTipo tipo) {
    switch (tipo) {
      case NotificacionTipo.alertaCaducidad:
        return '/vehiculo/caducidades';
      case NotificacionTipo.inicioTurnoPendiente:
      case NotificacionTipo.inicioTurnoAprobado:
      case NotificacionTipo.inicioTurnoRechazado:
        return '/registro-horario';
      case NotificacionTipo.vestuarioSolicitado:
      case NotificacionTipo.vestuarioAprobado:
      case NotificacionTipo.vestuarioRechazado:
      case NotificacionTipo.vestuarioEntregado:
        return '/vestuario';
      default:
        return '/servicios';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lista de providers
    final providers = <BlocProvider<dynamic>>[
      BlocProvider<AuthBloc>.value(value: _authBloc),
      BlocProvider<RegistroHorarioBloc>.value(value: _registroHorarioBloc),
      BlocProvider<AlertasTurnoCubit>.value(value: _alertasTurno),
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

        // Bloqueo por inactividad (huella / PIN) sobre toda la app y, debajo,
        // cambio obligatorio del PIN provisional
        builder: (BuildContext context, Widget? child) => AppLockGate(
          child: CambioClaveObligatorioGate(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
