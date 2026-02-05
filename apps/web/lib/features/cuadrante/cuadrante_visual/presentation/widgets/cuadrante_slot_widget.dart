import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/cuadrante_slot_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/personal_drag_data.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/vehiculo_drag_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget que representa un slot (casilla) del cuadrante donde se puede soltar personal y vehículo
class CuadranteSlotWidget extends StatelessWidget {
  const CuadranteSlotWidget({
    required this.slot,
    required this.onPersonalDropped,
    required this.onVehiculoDropped,
    required this.onRemovePersonal,
    required this.onRemoveVehiculo,
    super.key,
  });

  final CuadranteSlotEntity slot;
  final void Function(PersonalDragData) onPersonalDropped;
  final void Function(VehiculoDragData) onVehiculoDropped;
  final VoidCallback onRemovePersonal;
  final VoidCallback onRemoveVehiculo;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (Object? data) {
        // Aceptar PersonalDragData o VehiculoDragData
        return data is PersonalDragData || data is VehiculoDragData;
      },
      onAcceptWithDetails: (Object data) {
        if (data is PersonalDragData) {
          onPersonalDropped(data);
        } else if (data is VehiculoDragData) {
          onVehiculoDropped(data);
        }
      },
      builder: (BuildContext context, List<Object?> candidateData, List<Object?> rejectedData) {
        final bool isHovering = candidateData.isNotEmpty;

        return Container(
          width: 320,
          height: 140,
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: isHovering
                ? AppColors.primarySurface
                : (slot.estaCompleto
                    ? AppColors.secondarySurface
                    : slot.estaParcial
                        ? AppColors.warning.withValues(alpha: 0.05)
                        : Colors.white),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: isHovering
                  ? AppColors.primary
                  : (slot.estaCompleto
                      ? AppColors.secondary
                      : slot.estaParcial
                          ? AppColors.warning
                          : AppColors.gray300),
              width: isHovering ? 2 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Header: Número de unidad
              Text(
                'Unidad ${slot.numeroUnidad}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.spacingSmall),

              // Personal asignado
              if (slot.personalId != null)
                _buildPersonalSection()
              else
                _buildEmptyPersonalSection(),

              const SizedBox(height: AppSizes.spacingSmall),

              // Vehículo asignado
              if (slot.vehiculoId != null)
                _buildVehiculoSection()
              else
                _buildEmptyVehiculoSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: _getRolColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            _getRolIcon(),
            color: _getRolColor(),
            size: 18,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  slot.personalNombre ?? 'Sin nombre',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  slot.rolPersonal ?? 'Sin rol',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _getRolColor(),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: AppColors.error,
            onPressed: onRemovePersonal,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPersonalSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.gray300,
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.person_add_outlined,
            color: AppColors.gray400,
            size: 18,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Text(
            'Arrastrar personal aquí',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.emergency.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.local_hospital,
            color: AppColors.emergency,
            size: 18,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Text(
              slot.vehiculoMatricula ?? 'Sin matrícula',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: AppColors.error,
            onPressed: onRemoveVehiculo,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyVehiculoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.gray300,
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.add_road,
            color: AppColors.gray400,
            size: 18,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Text(
            'Arrastrar vehículo aquí',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRolColor() {
    switch (slot.rolPersonal?.toLowerCase()) {
      case 'conductor':
        return AppColors.primary;
      case 'tes':
        return AppColors.success;
      case 'tecnico':
        return AppColors.warning;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getRolIcon() {
    switch (slot.rolPersonal?.toLowerCase()) {
      case 'conductor':
        return Icons.drive_eta;
      case 'tes':
        return Icons.medical_services;
      case 'tecnico':
        return Icons.build;
      default:
        return Icons.person;
    }
  }
}
