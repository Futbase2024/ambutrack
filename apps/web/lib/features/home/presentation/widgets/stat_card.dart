import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Un detalle secundario que se muestra bajo el valor de la tarjeta.
///
/// Ej: contadores agrupados (Programados / En proceso / Completados).
class StatCardDetalle {
  const StatCardDetalle({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}

/// Tarjeta de estadística unificada para el dashboard.
///
/// Fondo blanco con borde de color temático, icono decorativo de fondo,
/// valor grande, botón "Añadir" opcional y una fila opcional de detalles
/// secundarios ([detalles]).
class StatCard extends StatefulWidget {
  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    super.key,
    this.subtitle,
    this.detalles,
    this.onTap,
    this.onAdd,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;
  final List<StatCardDetalle>? detalles;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  void _onHoverChanged(bool isHovered) {
    if (isHovered != _isHovered) {
      setState(() => _isHovered = isHovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => _onHoverChanged(true),
        onExit: (_) => _onHoverChanged(false),
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.accentColor
                  .withValues(alpha: _isHovered ? 0.6 : 0.35),
              width: 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: widget.accentColor
                    .withValues(alpha: _isHovered ? 0.15 : 0.06),
                blurRadius: _isHovered ? 16 : 8,
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
                child: Opacity(
                  opacity: 0.06,
                  child: Icon(
                    widget.icon,
                    size: 80,
                    color: widget.accentColor,
                  ),
                ),
              ),
              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _StatCardTitle(
                      icon: widget.icon,
                      title: widget.title,
                      color: widget.accentColor,
                    ),
                    if (widget.detalles != null &&
                        widget.detalles!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      _StatCardDetallesRow(detalles: widget.detalles!),
                    ],
                    const Spacer(),
                    _StatCardValueRow(
                      value: widget.value,
                      subtitle: widget.subtitle,
                      onAdd: widget.onAdd,
                      accentColor: widget.accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Título con icono de la tarjeta.
class _StatCardTitle extends StatelessWidget {
  const _StatCardTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: color.withValues(alpha: 0.9)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: color.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fila de detalles secundarios (contadores agrupados).
class _StatCardDetallesRow extends StatelessWidget {
  const _StatCardDetallesRow({required this.detalles});

  final List<StatCardDetalle> detalles;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < detalles.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _StatDetalleMini(detalle: detalles[i])),
        ],
      ],
    );
  }
}

/// Mini contador: número grande coloreado + label pequeño.
class _StatDetalleMini extends StatelessWidget {
  const _StatDetalleMini({required this.detalle});

  final StatCardDetalle detalle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          detalle.count.toString(),
          style: GoogleFonts.inter(
            color: detalle.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          detalle.label,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: AppColors.gray500,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Fila inferior: valor principal + botón "Añadir" opcional.
class _StatCardValueRow extends StatelessWidget {
  const _StatCardValueRow({
    required this.value,
    required this.subtitle,
    required this.onAdd,
    required this.accentColor,
  });

  final String value;
  final String? subtitle;
  final VoidCallback? onAdd;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                value,
                style: GoogleFonts.inter(
                  color: AppColors.gray900,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      color: AppColors.gray500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onAdd != null)
          SizedBox(
            height: 32,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                'Añadir',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
      ],
    );
  }
}
