import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Tarjetas de estadísticas con gradientes para el dashboard principal
///
/// Sigue el diseño Material Design 3 con gradientes profesionales
/// y animaciones sutiles en hover.
class DashboardStatsCards extends StatelessWidget {
  const DashboardStatsCards({
    super.key,
    required this.serviciosActivos,
    required this.disponibles,
    required this.enMantenimiento,
    required this.personalActivo,
    this.serviciosChange = '+5.2%',
    this.disponiblesChange = '+2.1%',
    this.mantenimientoChange = '+12%',
    this.personalChange = '-3%',
  });

  final int serviciosActivos;
  final int disponibles;
  final int enMantenimiento;
  final int personalActivo;

  final String serviciosChange;
  final String disponiblesChange;
  final String mantenimientoChange;
  final String personalChange;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Responsive: 4 columnas en desktop, 2 en tablet, 1 en móvil
        int crossAxisCount = 4;
        if (constraints.maxWidth < 1200) {
          crossAxisCount = 2;
        }
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: <Widget>[
            _GradientStatCard(
              title: 'Servicios Activos',
              value: _formatNumber(serviciosActivos),
              change: serviciosChange,
              icon: Icons.medical_services_outlined,
              gradient: const LinearGradient(
                colors: <Color>[AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadowColor: AppColors.primary,
            ),
            _GradientStatCard(
              title: 'Disponibles',
              value: disponibles.toString(),
              change: disponiblesChange,
              icon: Icons.check_circle_outline,
              gradient: const LinearGradient(
                colors: <Color>[AppColors.secondary, AppColors.secondaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadowColor: AppColors.secondary,
            ),
            _GradientStatCard(
              title: 'En Mantenimiento',
              value: enMantenimiento.toString(),
              change: mantenimientoChange,
              icon: Icons.build_outlined,
              gradient: const LinearGradient(
                colors: <Color>[AppColors.warning, Color(0xFFFBBF24)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadowColor: AppColors.warning,
            ),
            _GradientStatCard(
              title: 'Personal Activo',
              value: personalActivo.toString(),
              change: personalChange,
              changeIsPositive: false,
              icon: Icons.badge_outlined,
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF7C3AED), Color(0xFFA78BFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadowColor: const Color(0xFF7C3AED),
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k'.replaceAll('.0', '');
    }
    return number.toString();
  }
}

/// Tarjeta individual con gradiente y efecto hover
class _GradientStatCard extends StatefulWidget {
  const _GradientStatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.gradient,
    required this.shadowColor,
    this.changeIsPositive = true,
  });

  final String title;
  final String value;
  final String change;
  final IconData icon;
  final LinearGradient gradient;
  final Color shadowColor;
  final bool changeIsPositive;

  @override
  State<_GradientStatCard> createState() => _GradientStatCardState();
}

class _GradientStatCardState extends State<_GradientStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.12, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    if (isHovered != _isHovered) {
      setState(() => _isHovered = isHovered);
      if (isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: widget.shadowColor.withValues(alpha: _isHovered ? 0.3 : 0.15),
              blurRadius: _isHovered ? 20 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            // Icono decorativo de fondo
            Positioned(
              right: -8,
              bottom: -8,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (BuildContext context, Widget? child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 3.14159,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        widget.icon,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Título con icono pequeño
                  Row(
                    children: <Widget>[
                      Icon(
                        widget.icon,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Valor y cambio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        widget.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.change,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
