import 'package:ambutrack_desktop/app/flavors.dart';
import 'package:ambutrack_desktop/core/router/app_router_simple.dart';
import 'package:ambutrack_desktop/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// TODO(dev): Descomentar cuando AuthBloc esté disponible
// import 'package:ambutrack_desktop/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:ambutrack_desktop/features/auth/presentation/bloc/auth_event.dart';

/// Widget principal de la aplicación Desktop
///
/// Configura el tema, el enrutamiento y otros aspectos globales de la app.
/// Incluye BlocProvider para AuthBloc que gestiona la autenticación global.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(dev): Descomentar cuando AuthBloc esté disponible
    // return BlocProvider<AuthBloc>(
    //   create: (BuildContext context) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
    //   child: _buildMaterialApp(),
    // );

    return _buildMaterialApp();
  }

  Widget _buildMaterialApp() {
    return MaterialApp.router(
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

      // Configuración del router
      routerConfig: appRouter,
    );
  }
}
