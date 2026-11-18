import 'package:flutter/material.dart';

import '../../di/injection.dart';
import '../../services/app_lock_service.dart';
import 'desbloqueo_view.dart';

/// Capa sobre toda la app que registra la actividad y muestra la
/// pantalla de desbloqueo cuando [AppLockService] bloquea la app.
///
/// Va en `MaterialApp.router(builder: ...)`, por encima del Navigator, así que
/// la vista de desbloqueo lleva su propio Navigator (Overlay para el teclado).
class AppLockGate extends StatelessWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppLockService lock = getIt<AppLockService>();
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => lock.registrarActividad(),
      child: ListenableBuilder(
        listenable: lock,
        builder: (BuildContext context, Widget? app) {
          return Stack(
            children: <Widget>[
              app!,
              if (lock.bloqueada)
                Positioned.fill(
                  child: Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => const DesbloqueoView()),
                  ),
                ),
            ],
          );
        },
        child: child,
      ),
    );
  }
}
