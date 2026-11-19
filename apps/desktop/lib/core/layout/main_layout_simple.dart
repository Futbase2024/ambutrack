import 'package:ambutrack_desktop/features/menu/presentation/widgets/app_menu.dart';
import 'package:flutter/material.dart';

/// Layout principal simplificado para Desktop
/// Sin dependencias de notificaciones u otras features complejas
class MainLayoutSimple extends StatelessWidget {
  const MainLayoutSimple({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          // Menú lateral
          const AppMenu(),

          // Contenido principal
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
