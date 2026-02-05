import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/features/menu/presentation/widgets/app_bar_with_menu.dart';
import 'package:flutter/material.dart';

/// Layout principal de la aplicación
///
/// Proporciona una estructura consistente con:
/// - AppBar superior fija con menú de navegación
/// - Área de contenido dinámico que cambia según la ruta
class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.child,
    this.title,
  });

  /// Widget hijo que se renderiza en el área de contenido
  final Widget child;

  /// Título opcional para mostrar en el AppBar
  final String? title;

  @override
  Widget build(BuildContext context) {
    final bool isDev = F.appFlavor == Flavor.dev;

    // Debug: Verificar flavor en consola
    debugPrint('MainLayout - Flavor actual: ${F.appFlavor} (isDev: $isDev)');

    return Scaffold(
      appBar: AppBarWithMenu(
        title: title,
      ),
      body: Stack(
        children: <Widget>[
          child,
          // Banner DEBUG siempre visible en DEV
          if (isDev)
            Positioned(
              top: 0,
              right: 0,
              child: CustomPaint(
                painter: _DebugBannerPainter(),
                child: const SizedBox(
                  width: 100,
                  height: 100,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Painter personalizado para el banner DEBUG
class _DebugBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double bannerWidth = 120.0;
    const double bannerHeight = 24.0;

    // Rotar el canvas para el efecto diagonal
    canvas
      ..save()
      ..translate(size.width, 0)
      ..rotate(0.785398); // 45 grados en radianes

    // Dibujar el fondo amarillo del banner
    final Paint bgPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, bannerWidth, bannerHeight),
      bgPaint,
    );

    // Dibujar el texto "DEBUG"
    final TextPainter textPainter = TextPainter(
      text: const TextSpan(
        text: 'DEBUG',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter
      ..layout()
      ..paint(
        canvas,
        Offset(
          (bannerWidth - textPainter.width) / 2,
          (bannerHeight - textPainter.height) / 2,
        ),
      );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}