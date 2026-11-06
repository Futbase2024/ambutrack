import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'equipamiento_linea_tile.dart';
import 'estado_dotacion.dart';

/// Bloque desplegable de una sección (o del grupo "Requieren atención")
class EquipamientoSeccionCard extends StatelessWidget {
  const EquipamientoSeccionCard({
    required this.titulo,
    required this.lineas,
    required this.onTapLinea,
    this.destacado = false,
    this.inicialmenteAbierta = false,
    super.key,
  });

  final String titulo;
  final List<StockVehiculoEntity> lineas;
  final ValueChanged<StockVehiculoEntity> onTapLinea;

  /// Grupo de urgentes: borde y título en naranja
  final bool destacado;
  final bool inicialmenteAbierta;

  @override
  Widget build(BuildContext context) {
    final int ok = lineas.where((StockVehiculoEntity l) => EstadoDotacion.of(l) == EstadoDotacion.ok).length;
    final Color color = destacado ? AppColors.warning : AppColors.gray900;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: destacado ? AppColors.warning : AppColors.gray200),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: inicialmenteAbierta,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: destacado ? const Icon(Icons.priority_high_rounded, color: AppColors.warning) : null,
        title: Text(titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        subtitle: Text(
          destacado ? '${lineas.length} items' : '$ok de ${lineas.length} OK',
          style: const TextStyle(fontSize: 13, color: AppColors.gray600),
        ),
        children: <Widget>[
          for (final StockVehiculoEntity l in lineas) ...<Widget>[
            const Divider(height: 1, color: AppColors.gray100),
            EquipamientoLineaTile(linea: l, onTap: () => onTapLinea(l)),
          ],
        ],
      ),
    );
  }
}
