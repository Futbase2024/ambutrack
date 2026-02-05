import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/vehiculo_drag_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de vehículo arrastrable
class DraggableVehiculoCard extends StatelessWidget {
  const DraggableVehiculoCard({
    required this.vehiculoId,
    required this.matricula,
    required this.tipo,
    this.modelo,
    this.onDragStarted,
    this.onDragEnd,
    super.key,
  });

  final String vehiculoId;
  final String matricula;
  final String tipo;
  final String? modelo;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    final VehiculoDragData dragData = VehiculoDragData(
      vehiculoId: vehiculoId,
      matricula: matricula,
      tipo: tipo,
      modelo: modelo,
    );

    return Draggable<VehiculoDragData>(
      data: dragData,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd?.call(),
      // Widget que se muestra mientras se arrastra
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Opacity(
          opacity: 0.8,
          child: _buildCardContent(isDragging: true),
        ),
      ),
      // Widget que queda en su lugar mientras se arrastra
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCardContent(isDragging: false),
      ),
      // Widget normal cuando no se arrastra
      child: _buildCardContent(isDragging: false),
    );
  }

  Widget _buildCardContent({required bool isDragging}) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: _getTipoColor().withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: isDragging
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: <Widget>[
          // Icono del vehículo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getTipoColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(
              _getTipoIcon(),
              color: _getTipoColor(),
              size: 28,
            ),
          ),
          const SizedBox(width: AppSizes.spacingSmall),

          // Datos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  matricula,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (modelo != null && modelo!.isNotEmpty)
                  Text(
                    modelo!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getTipoColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getTipoLabel(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _getTipoColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Icono de arrastre
          const Icon(
            Icons.drag_indicator,
            color: AppColors.gray400,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Obtiene el color según el tipo de vehículo
  Color _getTipoColor() {
    switch (tipo.toLowerCase()) {
      case 'ambulancia':
      case 'svb':
        return AppColors.emergency;
      case 'sva':
      case 'uvi_movil':
        return AppColors.highPriority;
      case 'vehiculo_medico':
      case 'vehiculo_rapido':
        return AppColors.primary;
      case 'soporte':
      case 'logistica':
        return AppColors.secondary;
      default:
        return AppColors.gray500;
    }
  }

  /// Obtiene el icono según el tipo de vehículo
  IconData _getTipoIcon() {
    switch (tipo.toLowerCase()) {
      case 'ambulancia':
      case 'svb':
      case 'sva':
      case 'uvi_movil':
        return Icons.local_hospital;
      case 'vehiculo_medico':
        return Icons.medical_services;
      case 'vehiculo_rapido':
        return Icons.speed;
      case 'soporte':
      case 'logistica':
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }

  /// Obtiene la etiqueta del tipo de vehículo
  String _getTipoLabel() {
    switch (tipo.toLowerCase()) {
      case 'ambulancia':
        return 'Ambulancia';
      case 'svb':
        return 'SVB';
      case 'sva':
        return 'SVA';
      case 'uvi_movil':
        return 'UVI Móvil';
      case 'vehiculo_medico':
        return 'Vehículo Médico';
      case 'vehiculo_rapido':
        return 'Vehículo Rápido';
      case 'soporte':
        return 'Soporte';
      case 'logistica':
        return 'Logística';
      default:
        return tipo;
    }
  }
}
