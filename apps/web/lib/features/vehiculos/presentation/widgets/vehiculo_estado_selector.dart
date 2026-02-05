import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Selector de estado del vehículo con opciones visuales
class VehiculoEstadoSelector extends StatelessWidget {
  const VehiculoEstadoSelector({
    super.key,
    required this.estadoSeleccionado,
    required this.onChanged,
  });

  final VehiculoEstado estadoSeleccionado;
  final void Function(VehiculoEstado?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: VehiculoEstado.values.map((VehiculoEstado estado) {
        final bool isSelected = estado == estadoSeleccionado;
        final Color color = _getEstadoColor(estado);

        return InkWell(
          onTap: () => onChanged(estado),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : AppColors.gray300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getEstadoLabel(estado),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? color : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getEstadoColor(VehiculoEstado estado) {
    switch (estado) {
      case VehiculoEstado.activo:
        return AppColors.success;
      case VehiculoEstado.mantenimiento:
        return AppColors.warning;
      case VehiculoEstado.reparacion:
        return AppColors.error;
      case VehiculoEstado.baja:
        return AppColors.gray500;
    }
  }

  String _getEstadoLabel(VehiculoEstado estado) {
    switch (estado) {
      case VehiculoEstado.activo:
        return 'Activo/Disponible';
      case VehiculoEstado.mantenimiento:
        return 'En Mantenimiento';
      case VehiculoEstado.reparacion:
        return 'En Reparación';
      case VehiculoEstado.baja:
        return 'Dado de Baja';
    }
  }
}
