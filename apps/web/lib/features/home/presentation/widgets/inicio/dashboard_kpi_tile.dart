import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/stat_card.dart';
import 'package:flutter/material.dart';

/// Altura fija de las tarjetas de indicadores
const double kDashboardKpiHeight = 108;

/// Indicador compacto del dashboard (estilo programa de gestión).
///
/// Título en versalitas, valor grande, desglose opcional con puntos de color
/// y acceso directo a la pantalla (clic) y a "nuevo" (botón +).
class DashboardKpiTile extends StatefulWidget {
  const DashboardKpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.subtitle,
    this.detalles,
    this.onTap,
    this.onAdd,
    super.key,
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
  State<DashboardKpiTile> createState() => _DashboardKpiTileState();
}

class _DashboardKpiTileState extends State<DashboardKpiTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final List<StatCardDetalle> detalles = widget.detalles ?? const <StatCardDetalle>[];
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: kDashboardKpiHeight,
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _hover ? widget.accentColor.withValues(alpha: 0.5) : AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _KpiHeader(tile: widget),
              const Spacer(),
              _KpiValue(value: widget.value, subtitle: widget.subtitle),
              if (detalles.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                _KpiDetalles(detalles: detalles),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiHeader extends StatelessWidget {
  const _KpiHeader({required this.tile});

  final DashboardKpiTile tile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(tile.icon, size: 15, color: tile.accentColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            tile.title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppColors.gray500,
            ),
          ),
        ),
        if (tile.onAdd != null)
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 16,
              tooltip: 'Nuevo',
              color: AppColors.gray500,
              onPressed: tile.onAdd,
              icon: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}

class _KpiValue extends StatelessWidget {
  const _KpiValue({required this.value, required this.subtitle});

  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.gray900, height: 1),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ),
        ],
      ],
    );
  }
}

class _KpiDetalles extends StatelessWidget {
  const _KpiDetalles({required this.detalles});

  final List<StatCardDetalle> detalles;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final StatCardDetalle d in detalles) ...<Widget>[
            GestionDotLabel(label: '${d.label} ${d.count}', color: d.color, fontSize: 11.5),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}
