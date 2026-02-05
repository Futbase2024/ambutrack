import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/router/app_router.dart';
import 'package:ambutrack_web/core/theme/app_theme.dart';
import 'package:ambutrack_web/core/widgets/context_menu/context_menu_blocker.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      child: ContextMenuBlocker(
        child: MaterialApp.router(
          title: F.title,
          debugShowCheckedModeBanner: false, // Deshabilitado para evitar bloqueo de botones

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
        ),
      ),
    );
  }
}