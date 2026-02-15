import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/router/app_router.dart';
import 'package:ambutrack_web/core/theme/app_theme.dart';
import 'package:ambutrack_web/core/widgets/context_menu/context_menu_blocker.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_bloc.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_event.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_state.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/widgets/alertas_dialogo_inicial.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Clave global para acceder al Navigator desde cualquier lugar
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Widget principal de la aplicación
///
/// Configura el tema, el enrutamiento y otros aspectos globales de la app.
/// Incluye BlocProvider para AuthBloc que gestiona la autenticación global.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (BuildContext context) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
      child: RepositoryProvider<AlertasCaducidadBloc>.value(
        value: getIt<AlertasCaducidadBloc>(),
        child: BlocListener<AlertasCaducidadBloc, AlertasCaducidadState>(
          listener: (BuildContext context, AlertasCaducidadState state) {
            // Listener vacío para mantener suscripción activa al BLoC
          },
          child: BlocListener<AuthBloc, AuthState>(
            listener: (BuildContext context, AuthState authState) {
              // Escuchar cambios de autenticación para cargar alertas críticas
              if (authState is AuthAuthenticated) {
                final String usuarioId = authState.user.uid;
                context.read<AlertasCaducidadBloc>().add(
                  AlertasCaducidadEvent.loadAlertasCriticas(usuarioId: usuarioId),
                );
              }
            },
            child: ContextMenuBlocker(
              child: MaterialApp.router(
                title: F.title,
                debugShowCheckedModeBanner: false,

                // Configuración de localización
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

                // Configuración de tema personalizado AmbuTrack
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,

                // Builder para mostrar el diálogo de alertas críticas
                builder: (BuildContext context, Widget? child) {
                  return _AlertasDialogListener(child: child!);
                },

                // Configuración del router
                routerConfig: appRouter,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget que escucha el estado de alertas y muestra el diálogo de críticas solo una vez
class _AlertasDialogListener extends StatefulWidget {
  const _AlertasDialogListener({
    required this.child,
  });

  final Widget child;

  @override
  State<_AlertasDialogListener> createState() => _AlertasDialogListenerState();
}

class _AlertasDialogListenerState extends State<_AlertasDialogListener> {
  final List<String> _shownAlertasIds = <String>[];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlertasCaducidadBloc, AlertasCaducidadState>(
      listener: (BuildContext context, AlertasCaducidadState alertasState) {
        alertasState.maybeWhen(
          loaded: (List<AlertaCaducidadEntity> alertas, _, _, _, _) {
            final AuthState authState = context.read<AuthBloc>().state;
            if (authState is! AuthAuthenticated) {
              return;
            }

            // Filtrar alertas críticas que no se han mostrado aún
            final List<AlertaCaducidadEntity> nuevasCriticas = alertas
                .where((AlertaCaducidadEntity a) =>
                    a.esCritica == true && !_shownAlertasIds.contains(a.id))
                .toList();

            if (nuevasCriticas.isEmpty) {
              return;
            }

            // Marcar las alertas como mostradas
            for (final AlertaCaducidadEntity alerta in nuevasCriticas) {
              _shownAlertasIds.add(alerta.id);
            }

            final String usuarioId = authState.user.uid;
            debugPrint('🔔 _AlertasDialogListener: Intentando mostrar diálogo de ${nuevasCriticas.length} alertas críticas...');
            // Usar Future.delayed para asegurar que el Navigator esté completamente inicializado
            Future<void>.delayed(const Duration(milliseconds: 100), () {
              debugPrint('🔔 _AlertasDialogListener: Delay ejecutado, mounted=$mounted, appNavigatorKey.currentState=${appNavigatorKey.currentState}');
              if (mounted && appNavigatorKey.currentState != null) {
                final BuildContext? context = appNavigatorKey.currentContext;
                debugPrint('🔔 _AlertasDialogListener: Context obtenido: $context, mounted=${context?.mounted}');
                if (context != null && context.mounted) {
                  debugPrint('🔔 _AlertasDialogListener: Mostrando diálogo...');
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) => AlertasDialogoInicial(
                      usuarioId: usuarioId,
                    ),
                  );
                } else {
                  debugPrint('⚠️ _AlertasDialogListener: Context es null o no mounted');
                }
              } else {
                debugPrint('⚠️ _AlertasDialogListener: No se pudo mostrar diálogo - mounted=$mounted, navigatorKey=${appNavigatorKey.currentState}');
              }
            });
          },
          orElse: () {},
        );
      },
      child: widget.child,
    );
  }
}