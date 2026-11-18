import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_edit_cells.dart';
import 'package:flutter/material.dart';

/// Barra del modo edición: aviso y acciones en bloque sobre los vehículos marcados
class VehiculoBulkEditBar extends StatelessWidget {
  const VehiculoBulkEditBar({
    required this.count,
    required this.onEstado,
    required this.onCap,
    required this.onSilla,
    required this.onCarros,
    required this.onSoporte,
    required this.onClear,
    super.key,
  });

  /// Vehículos marcados
  final int count;
  final ValueChanged<VehiculoEstado> onEstado;
  final ValueChanged<bool> onCap;
  final ValueChanged<bool> onSilla;
  final ValueChanged<int> onCarros;
  final ValueChanged<bool> onSoporte;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool hay = count > 0;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        border: const Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            const Icon(Icons.edit_note, size: 18, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(
              hay
                  ? '$count ${count == 1 ? 'vehículo marcado' : 'vehículos marcados'}'
                  : 'Modo edición: los cambios se guardan al momento. '
                      'Marca varios vehículos con las casillas para cambiarlos a la vez.',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.gray800),
            ),
            if (hay) ...<Widget>[
              const SizedBox(width: 16),
              VehiculoEstadoMenu(
                onSelected: onEstado,
                child: const _BulkButton(icon: Icons.swap_horiz, label: 'Cambiar estado'),
              ),
              _BulkSiNoMenu(label: 'CAP', icon: Icons.badge_outlined, onSelected: onCap),
              _BulkSiNoMenu(label: 'Silla eléctrica', icon: Icons.stairs_outlined, onSelected: onSilla),
              _BulkSiNoMenu(label: 'Soporte silla eléc.', icon: Icons.chair_alt_outlined, onSelected: onSoporte),
              VehiculoCarrosMenu(
                onSelected: onCarros,
                child: const _BulkButton(icon: Icons.accessible_forward, label: 'Carros'),
              ),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.deselect, size: 16),
                label: const Text('Desmarcar'),
                style: TextButton.styleFrom(foregroundColor: AppColors.gray600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Menú Sí / No para una característica en bloque
class _BulkSiNoMenu extends StatelessWidget {
  const _BulkSiNoMenu({required this.label, required this.icon, required this.onSelected});

  final String label;
  final IconData icon;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      itemBuilder: (BuildContext _) => <PopupMenuEntry<bool>>[
        PopupMenuItem<bool>(value: true, height: 36, child: Text('Marcar $label')),
        PopupMenuItem<bool>(value: false, height: 36, child: Text('Quitar $label')),
      ],
      child: _BulkButton(icon: icon, label: label),
    );
  }
}

class _BulkButton extends StatelessWidget {
  const _BulkButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: AppColors.gray700),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.gray800)),
          const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.gray500),
        ],
      ),
    );
  }
}
