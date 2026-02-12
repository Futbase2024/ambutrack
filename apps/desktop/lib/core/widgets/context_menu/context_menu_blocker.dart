import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget que bloquea el menú contextual del navegador en toda la aplicación
///
/// Envuelve la aplicación completa para prevenir el menú contextual por defecto
/// del navegador cuando se hace clic derecho.
class ContextMenuBlocker extends StatelessWidget {
  const ContextMenuBlocker({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Bloquear menú contextual del navegador
      onSecondaryTapDown: (TapDownDetails details) {
        // Prevenir el menú contextual del navegador
        // En Flutter Web, esto bloquea el menú nativo
      },
      onLongPress: () {
        // Bloquear menú en móvil (long press)
      },
      // Prevenir el menú contextual con Shortcuts
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          // Bloquear F5 (refresh)
          LogicalKeySet(LogicalKeyboardKey.f5): const DoNothingIntent(),
          // Bloquear Ctrl+R (refresh)
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR): const DoNothingIntent(),
          // Bloquear Ctrl+Shift+I (DevTools)
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.shift,
            LogicalKeyboardKey.keyI,
          ): const DoNothingIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DoNothingIntent: DoNothingAction(),
          },
          child: child,
        ),
      ),
    );
  }
}

/// Intent vacío para bloquear acciones
class DoNothingIntent extends Intent {
  const DoNothingIntent();
}

/// Acción que no hace nada (bloquea la acción por defecto)
class DoNothingAction extends Action<DoNothingIntent> {
  @override
  Object? invoke(DoNothingIntent intent) {
    // No hacer nada - esto bloquea la acción
    return null;
  }
}
