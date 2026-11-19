import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Resumen compacto del stock de la prenda/talla seleccionada
class VestuarioStockInfo extends StatelessWidget {
  const VestuarioStockInfo({required this.stock, super.key});

  final StockVestuarioEntity stock;

  Color get _color => stock.sinStock
      ? AppColors.error
      : stock.tieneStockBajo
          ? AppColors.warning
          : AppColors.success;

  IconData get _icon => stock.sinStock
      ? Icons.error_outline
      : stock.tieneStockBajo
          ? Icons.warning_amber
          : Icons.check_circle_outline;

  @override
  Widget build(BuildContext context) {
    final List<String> detalles = <String>[
      'Disponible: ${stock.cantidadDisponible} / ${stock.cantidadTotal}',
      if (stock.marca != null) 'Marca: ${stock.marca}',
      if (stock.color != null) 'Color: ${stock.color}',
    ];
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: <Widget>[
          Icon(_icon, size: 16, color: _color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              detalles.join('  ·  '),
              style: const TextStyle(fontSize: 12.5, color: AppColors.gray700, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
