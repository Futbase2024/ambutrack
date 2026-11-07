import 'package:flutter/material.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';

/// Tile para verificar un item del checklist
///
/// Permite:
/// - Seleccionar resultado (Presente/Ausente/No Aplica)
/// - Añadir observaciones (obligatorio si ausente)
class ItemChecklistTile extends StatelessWidget {
  const ItemChecklistTile({
    super.key,
    required this.item,
    required this.index,
    this.resultado,
    this.observaciones,
    required this.onResultadoChanged,
    required this.onObservacionesChanged,
  });

  /// Item del checklist (plantilla)
  final ItemChecklistEntity item;

  /// Índice del item en la lista
  final int index;

  /// Resultado actual del item (puede ser null si no se ha verificado)
  final ResultadoItem? resultado;

  /// Observaciones actuales del item
  final String? observaciones;

  /// Callback cuando cambia el resultado
  final ValueChanged<ResultadoItem> onResultadoChanged;

  /// Callback cuando cambian las observaciones
  final ValueChanged<String> onObservacionesChanged;

  @override
  Widget build(BuildContext context) {
    final tieneResultado = resultado != null;
    final esAusente = resultado == ResultadoItem.ausente;
    final color = _getColorResultado(resultado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: tieneResultado ? color : AppColors.gray200,
          width: tieneResultado ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Nombre + Cantidad
            Row(
              children: [
                // Número de orden
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: tieneResultado
                        ? color.withValues(alpha: 0.1)
                        : AppColors.gray100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: tieneResultado ? color : AppColors.gray600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Nombre del item
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemNombre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                      if (item.cantidadRequerida != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Cantidad: ${item.cantidadRequerida}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Icono de resultado
                if (tieneResultado)
                  Icon(
                    _getIconoResultado(resultado!),
                    color: color,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Botones de resultado
            Row(
              children: [
                Expanded(
                  child: _ResultadoButton(
                    label: 'Presente',
                    icon: Icons.check_circle,
                    isSelected: resultado == ResultadoItem.presente,
                    color: AppColors.success,
                    onTap: () => onResultadoChanged(ResultadoItem.presente),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ResultadoButton(
                    label: 'Ausente',
                    icon: Icons.cancel,
                    isSelected: resultado == ResultadoItem.ausente,
                    color: AppColors.error,
                    onTap: () => onResultadoChanged(ResultadoItem.ausente),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ResultadoButton(
                    label: 'No Aplica',
                    icon: Icons.remove_circle_outline,
                    isSelected: resultado == ResultadoItem.noAplica,
                    color: AppColors.gray400,
                    onTap: () => onResultadoChanged(ResultadoItem.noAplica),
                  ),
                ),
              ],
            ),

            // Campo de observaciones (obligatorio si ausente)
            if (esAusente) ...[
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: observaciones),
                decoration: InputDecoration(
                  labelText: 'Observaciones *',
                  hintText: 'Describe por qué está ausente...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.error.withValues(alpha: 0.05),
                  prefixIcon: const Icon(
                    Icons.edit_note,
                    color: AppColors.error,
                  ),
                ),
                maxLines: 2,
                textInputAction: TextInputAction.done,
                onChanged: onObservacionesChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Obtiene el color según el resultado
  Color _getColorResultado(ResultadoItem? resultado) {
    if (resultado == null) return AppColors.gray300;
    switch (resultado) {
      case ResultadoItem.presente:
        return AppColors.success;
      case ResultadoItem.ausente:
        return AppColors.error;
      case ResultadoItem.noAplica:
        return AppColors.gray400;
    }
  }

  /// Obtiene el icono según el resultado
  IconData _getIconoResultado(ResultadoItem resultado) {
    switch (resultado) {
      case ResultadoItem.presente:
        return Icons.check_circle;
      case ResultadoItem.ausente:
        return Icons.cancel;
      case ResultadoItem.noAplica:
        return Icons.remove_circle_outline;
    }
  }
}

/// Botón para seleccionar un resultado
class _ResultadoButton extends StatelessWidget {
  const _ResultadoButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.gray50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.gray500,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
