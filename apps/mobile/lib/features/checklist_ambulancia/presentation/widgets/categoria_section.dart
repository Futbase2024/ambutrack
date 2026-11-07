import 'package:flutter/material.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';

/// Sección colapsable de items por categoría
///
/// Agrupa items del checklist por categoría y permite
/// expandir/colapsar para mejor organización visual
class CategoriaSection extends StatefulWidget {
  const CategoriaSection({
    super.key,
    required this.categoria,
    required this.children,
    this.initiallyExpanded = true,
  });

  /// Categoría de los items
  final CategoriaChecklist categoria;

  /// Widgets hijos (normalmente ItemChecklistTile)
  final List<Widget> children;

  /// Si la sección debe estar expandida inicialmente
  final bool initiallyExpanded;

  @override
  State<CategoriaSection> createState() => _CategoriaSectionState();
}

class _CategoriaSectionState extends State<CategoriaSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorCategoria(widget.categoria);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera colapsable
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icono de categoría
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconoCategoria(widget.categoria),
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),

                // Nombre de categoría
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoria.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.children.length} items',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Icono expandir/colapsar
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: color,
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        // Contenido expandible
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: widget.children,
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  /// Obtiene el color según la categoría
  Color _getColorCategoria(CategoriaChecklist categoria) {
    switch (categoria) {
      case CategoriaChecklist.equiposTraslado:
        return AppColors.primary;
      case CategoriaChecklist.equipoVentilacion:
        return AppColors.info;
      case CategoriaChecklist.equipoDiagnostico:
        return AppColors.secondary;
      case CategoriaChecklist.equipoInfusion:
        return AppColors.warning;
      case CategoriaChecklist.equipoEmergencia:
        return AppColors.emergency;
      case CategoriaChecklist.vendajesAsistencia:
        return AppColors.success;
      case CategoriaChecklist.documentacion:
        return AppColors.gray600;
    }
  }

  /// Obtiene el icono según la categoría
  IconData _getIconoCategoria(CategoriaChecklist categoria) {
    switch (categoria) {
      case CategoriaChecklist.equiposTraslado:
        return Icons.local_shipping;
      case CategoriaChecklist.equipoVentilacion:
        return Icons.air;
      case CategoriaChecklist.equipoDiagnostico:
        return Icons.monitor_heart;
      case CategoriaChecklist.equipoInfusion:
        return Icons.water_drop;
      case CategoriaChecklist.equipoEmergencia:
        return Icons.emergency;
      case CategoriaChecklist.vendajesAsistencia:
        return Icons.healing;
      case CategoriaChecklist.documentacion:
        return Icons.description;
    }
  }
}
