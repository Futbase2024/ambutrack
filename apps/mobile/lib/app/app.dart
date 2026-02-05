import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/config/router_config.dart';
import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import 'flavors.dart';

/// Widget principal de AmbuTrack Mobile
///
/// Configura el tema, router, localización y estado global de autenticación.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    // Obtener AuthBloc del service locator
    _authBloc = getIt<AuthBloc>();

    // Verificar sesión existente al iniciar
    _authBloc.add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    // No cerrar el AuthBloc aquí porque es singleton y se usa en toda la app
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
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
        routerConfig: createAppRouter(_authBloc),
      ),
    );
  }
}
