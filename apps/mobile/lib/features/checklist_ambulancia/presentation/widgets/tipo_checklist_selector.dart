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
            _TipoChip(
              tipo: TipoChecklist.preServicio,
              isSelected: tipoSeleccionado == TipoChecklist.preServicio,
              onTap: () => onTipoChanged(TipoChecklist.preServicio),
            ),
            const SizedBox(width: 8),
            _TipoChip(
              tipo: TipoChecklist.postServicio,
              isSelected: tipoSeleccionado == TipoChecklist.postServicio,
              onTap: () => onTipoChanged(TipoChecklist.postServicio),
            ),
            const SizedBox(width: 8),
            _TipoChip(
              tipo: TipoChecklist.mensual,
              isSelected: tipoSeleccionado == TipoChecklist.mensual,
              onTap: () => onTipoChanged(TipoChecklist.mensual),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: 1,
          ),
        ),
        child: Text(
          tipo.nombre,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.gray700,
          ),
        ),
      ),
    );
  }
}
