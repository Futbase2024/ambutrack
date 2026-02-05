import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/lang/app_strings.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card individual de vehículo
class VehiculoCard extends StatelessWidget {
  const VehiculoCard({required this.vehiculo, super.key});

  final VehiculoEntity vehiculo;

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
        return AppStrings.vehiculosEstadoDisponible;
      case VehiculoEstado.mantenimiento:
        return AppStrings.vehiculosEstadoMantenimiento;
      case VehiculoEstado.reparacion:
        return AppStrings.vehiculosEstadoReparacion;
      case VehiculoEstado.baja:
        return AppStrings.vehiculosEstadoBaja;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color estadoColor = _getEstadoColor(vehiculo.estado);
    final String estadoLabel = _getEstadoLabel(vehiculo.estado);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: AppSizes.shadowSmall,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingMedium),
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Icon(
                  Icons.local_hospital,
                  color: estadoColor,
                  size: AppSizes.iconLarge,
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      vehiculo.matricula,
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontMedium,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXs),
                    Text(
                      '${vehiculo.marca} ${vehiculo.modelo}',
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingMedium,
                  vertical: AppSizes.spacingSmall - 2,
                ),
                decoration: BoxDecoration(
                  color: estadoColor,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: AppSizes.statusDot,
                      height: AppSizes.statusDot,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingSmall - 2),
                    Text(
                      estadoLabel,
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontXs,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spacingMedium),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO(team): Implementar menú de acciones
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          const Divider(),
          const SizedBox(height: AppSizes.spacing),
          Row(
            children: <Widget>[
              _InfoChip(
                icon: Icons.category,
                label: vehiculo.tipoVehiculo,
                color: AppColors.primary,
              ),
              if (vehiculo.kmActual != null) ...<Widget>[
                const SizedBox(width: AppSizes.spacingMedium),
                _InfoChip(
                  icon: Icons.speed,
                  label: '${vehiculo.kmActual!.toStringAsFixed(0)} km',
                  color: AppColors.info,
                ),
              ],
            ],
          ),
          if (vehiculo.ubicacionActual != null) ...<Widget>[
            const SizedBox(height: AppSizes.spacingMedium),
            _InfoChip(
              icon: Icons.location_on,
              label: vehiculo.ubicacionActual!,
              color: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMedium,
        vertical: AppSizes.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppSizes.iconSmall, color: color),
          const SizedBox(width: AppSizes.spacingSmall - 2),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontXs,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
