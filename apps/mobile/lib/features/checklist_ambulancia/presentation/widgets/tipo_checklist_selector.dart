import 'package:flutter/material.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';

/// Selector de tipo de checklist
///
/// Muestra chips horizontales para seleccionar entre:
/// - Pre-Servicio
/// - Post-Servicio
/// - Mensual
class TipoChecklistSelector extends StatelessWidget {
  const TipoChecklistSelector({
    super.key,
    required this.tipoSeleccionado,
    required this.onTipoChanged,
  });

  /// Tipo de checklist actualmente seleccionado
  final TipoChecklist tipoSeleccionado;

  /// Callback cuando cambia el tipo seleccionado
  final ValueChanged<TipoChecklist> onTipoChanged;

  /// Orden de visualización de los chips
  static const _orden = [
    TipoChecklist.preServicio,
    TipoChecklist.postServicio,
    TipoChecklist.mensual,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Checklist',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final tipo in _orden) ...[
              if (tipo != _orden.first) const SizedBox(width: 8),
              Expanded(
                child: _TipoChip(
                  tipo: tipo,
                  isSelected: tipoSeleccionado == tipo,
                  onTap: () => onTipoChanged(tipo),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Chip individual para un tipo de checklist
class _TipoChip extends StatelessWidget {
  const _TipoChip({
    required this.tipo,
    required this.isSelected,
    required this.onTap,
  });

  final TipoChecklist tipo;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            tipo.nombre,
            maxLines: 1,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.gray700,
            ),
          ),
        ),
      ),
    );
  }
}
