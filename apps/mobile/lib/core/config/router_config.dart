import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/checklist_ambulancia/presentation/pages/checklist_ambulancia_page.dart';
import '../../features/home_android/presentation/pages/home_android_page.dart';
import '../../features/incidencias/presentation/pages/incidencias_page.dart';
import '../../features/partes_diarios/presentation/pages/partes_diarios_page.dart';
import '../../features/perfil/presentation/pages/perfil_page.dart';
import '../../features/registro_horario/presentation/pages/registro_horario_page.dart';
import '../../features/servicios/presentation/pages/servicios_historico_page.dart';
import '../../features/servicios/presentation/pages/servicios_page.dart';
import '../../features/servicios/presentation/pages/traslado_detalle_page.dart';
import '../../features/tramites/presentation/pages/tramite_detalle_page.dart';
import '../../features/tramites/presentation/pages/tramites_page.dart';
import '../../features/vehiculo/presentation/pages/vehiculo_page.dart';
import '../../features/vehiculo/presentation/pages/incidencias/reportar_incidencia_page.dart';
import '../../features/vehiculo/presentation/pages/checklist/checklist_mensual_page.dart';
import '../../features/vehiculo/presentation/pages/caducidades/caducidades_page.dart';
import '../../features/vehiculo/presentation/pages/historial/historial_page.dart';
import '../../features/vestuario/presentation/pages/vestuario_page.dart';
import '../../features/ambulancias/presentation/pages/ambulancias_page.dart';
import '../../features/ambulancias/presentation/pages/ambulancia_detalle_page.dart';
import '../../features/ambulancias/presentation/pages/revision_page.dart';
import '../../features/notificaciones/presentation/pages/notificaciones_page.dart';
import '../widgets/layouts/main_layout.dart';

/// Memoria de navegación para hot restart
/// Las variables estáticas se preservan durante hot restart
class _RouterMemory {
  static String? _lastLocation;
  static bool _isInitialized = false;

  /// Guardar ubicación actual
  static void save(String location) {
    if (location != '/login') {
      _lastLocation = location;
    }
  }

  /// Obtener ubicación inicial
  /// Primera vez: null (usa default de GoRouter)
  /// Hot restart: ubicación guardada
  static String? get initialLocation {
    if (!_isInitialized) {
      _isInitialized = true;
      return null; // Primera ejecución: no usar memoria
    }
    return _lastLocation; // Hot restart: usar memoria
  }
}

/// Configuración del router de AmbuTrack Mobile
///
/// Define las rutas principales con protección de autenticación:
/// 1. /login - Login (pública)
/// 2. / - Home Android (protegida)
/// 3. /registro-horario - Fichar entrada/salida (protegida)
/// 4. /checklist-ambulancia - Revisión pre-servicio (protegida)
/// 5. /partes-diarios - Informes de servicio (protegida)
/// 6. /incidencias - Reportar problemas (protegida)
/// 7. /servicios - Mis servicios/traslados del día (protegida)
/// 8. /servicios/historico - Histórico de servicios (protegida)
/// 9. /servicios/:id - Detalle de traslado (protegida)
/// 10. /perfil - Mi perfil (protegida)
GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: _RouterMemory.initialLocation,
    routes: <RouteBase>[
      // Ruta pública - Login
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const LoginPage(),
          );
        },
      ),

      // Home Android (con MainLayout)
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: MainLayout(
              isHomePage: true,
              currentLocation: '/',
              child: const HomeAndroidPage(),
            ),
          );
        },
      ),

      // Registro de Horario (página independiente con su propio AppBar)
      GoRoute(
        path: '/registro-horario',
        name: 'registro-horario',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const RegistroHorarioPage(),
          );
        },
      ),

      // Checklist de Ambulancia
      GoRoute(
        path: '/checklist-ambulancia',
        name: 'checklist-ambulancia',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const ChecklistAmbulanciaPage(),
          );
        },
      ),

      // Partes Diarios
      GoRoute(
        path: '/partes-diarios',
        name: 'partes-diarios',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const PartesDiariosPage(),
          );
        },
      ),

      // Incidencias
      GoRoute(
        path: '/incidencias',
        name: 'incidencias',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const IncidenciasPage(),
          );
        },
      ),

      // Perfil
      GoRoute(
        path: '/perfil',
        name: 'perfil',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const PerfilPage(),
          );
        },
      ),

      // Notificaciones
      GoRoute(
        path: '/notificaciones',
        name: 'notificaciones',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const NotificacionesPage(),
          );
        },
      ),

      // Servicios/Traslados
      GoRoute(
        path: '/servicios',
        name: 'servicios',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const ServiciosPage(),
          );
        },
        routes: [
          // Histórico de servicios
          GoRoute(
            path: 'historico',
            name: 'servicios-historico',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return _buildPageWithTransition(
                context: context,
                state: state,
                child: const ServiciosHistoricoPage(),
              );
            },
          ),
          // Detalle de traslado
          GoRoute(
            path: ':id',
            name: 'traslado-detalle',
            pageBuilder: (BuildContext context, GoRouterState state) {
              final idTraslado = state.pathParameters['id']!;
              return _buildPageWithTransition(
                context: context,
                state: state,
                child: TrasladoDetallePage(idTraslado: idTraslado),
              );
            },
          ),
        ],
      ),

      // Trámites (Vacaciones y Ausencias)
      GoRoute(
        path: '/tramites',
        name: 'tramites',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const TramitesPage(),
          );
        },
        routes: [
          // Detalle de vacación
          GoRoute(
            path: 'vacacion/:id',
            name: 'tramite-vacacion-detalle',
            pageBuilder: (BuildContext context, GoRouterState state) {
              final vacacion = state.extra as VacacionesEntity;
              return _buildPageWithTransition(
                context: context,
                state: state,
                child: TramiteDetallePage.vacacion(vacacion: vacacion),
              );
            },
          ),
          // Detalle de ausencia
          GoRoute(
            path: 'ausencia/:id',
            name: 'tramite-ausencia-detalle',
            pageBuilder: (BuildContext context, GoRouterState state) {
              final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
              final ausencia = extra['ausencia'] as AusenciaEntity;
              final tipoAusencia = extra['tipo'] as TipoAusenciaEntity;
              return _buildPageWithTransition(
                context: context,
                state: state,
                child: TramiteDetallePage.ausencia(
                  ausencia: ausencia,
                  tipoAusencia: tipoAusencia,
                ),
              );
            },
          ),
        ],
      ),

      // Vehículo
      GoRoute(
        path: '/vehiculo',
        name: 'vehiculo',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const VehiculoPage(),
          );
        },
        routes: [
          // Reportar incidencia
          GoRoute(
            path: 'reportar-incidencia',
            name: 'reportar-incidencia',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return _buildPageWithTransition(
                context: context,
                state: state,
                child: const ReportarIncidenciaPage(),
              );
            },
          ),
          // Checklist mensual
          GoRoute(
            path: 'checklist',
            name: 'checklist-mensual',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return _buildPageWithTransition(
                context: context,
                state: state,
                child: const ChecklistMensualPage(),
              );
            },
          ),
          // Caducidades
          GoRoute(
            path: 'caducidades',
            name: 'caducidades',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return _buildPageWithTransition(
                context: context,
                state: state,
                child: const CaducidadesPage(),
              );
            },
          ),
          // Historial
          GoRoute(
            path: 'historial',
            name: 'historial',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return _buildPageWithTransition(
                context: context,
                state: state,
                child: const HistorialPage(),
              );
            },
          ),
        ],
      ),

      // Vestuario
      GoRoute(
        path: '/vestuario',
        name: 'vestuario',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const VestuarioPage(),
          );
        },
      ),

      // Ambulancias
      GoRoute(
        path: '/ambulancias',
        name: 'ambulancias',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const AmbulanciasPage(),
          );
        },
        routes: [
          // Detalle de ambulancia
          GoRoute(
            path: ':id',
            name: 'ambulancia-detalle',
            pageBuilder: (BuildContext context, GoRouterState state) {
              final ambulanciaId = state.pathParameters['id']!;
              return _buildPageWithTransition(
                context: context,
                state: state,
                child: AmbulanciaDetallePage(ambulanciaId: ambulanciaId),
              );
            },
            routes: [
              // Detalle de revisión
              GoRoute(
                path: 'revision/:revisionId',
                name: 'revision-detalle',
                pageBuilder: (BuildContext context, GoRouterState state) {
                  final revisionId = state.pathParameters['revisionId']!;
                  return _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: RevisionPage(revisionId: revisionId),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],

    // Protección de rutas basada en AuthBloc
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      // Guardar ubicación para hot restart
      _RouterMemory.save(state.matchedLocation);

      // Si no está autenticado y no está en login, redirigir a login
      if (!isAuthenticated && !isLoginRoute) {
        debugPrint('🔒 [Router] Ruta protegida, redirigiendo a /login');
        return '/login';
      }

      // Si está autenticado y está en login, ir al home (solo primera vez)
      if (isAuthenticated && isLoginRoute) {
        debugPrint('✅ [Router] Ya autenticado, redirigiendo a /');
        return '/';
      }

      // No redirigir en ningún otro caso
      return null;
    },

    // Escuchar cambios del AuthBloc para refrescar rutas
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Error: ${state.error?.toString()}'),
        ),
      );
    },
  );
}

/// Construye una página con transición suave
CustomTransitionPage<void> _buildPageWithTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Transición de slide lateral desde la derecha con curva suave
      const begin = Offset(0.25, 0);
      const end = Offset.zero;

      final slideTween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: Curves.easeOutCubic),
      );

      final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: Curves.easeIn),
      );

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: SlideTransition(
          position: animation.drive(slideTween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
  );
}

/// Helper para convertir un Stream en un Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
