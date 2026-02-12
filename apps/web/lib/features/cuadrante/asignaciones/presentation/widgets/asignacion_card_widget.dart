import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget de tarjeta para mostrar una asignación de forma compacta
class AsignacionCardWidget extends StatelessWidget {
  const AsignacionCardWidget({
    required this.asignacion,
    this.onTap,
    super.key,
  });

  final CuadranteAsignacionEntity asignacion;

  /// Callback cuando se hace clic en la asignación (para editarla)
  final void Function(CuadranteAsignacionEntity)? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(asignacion),
      hoverColor: _getEstadoColor().withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _getEstadoColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: _getEstadoColor(),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildHorario(),
          const SizedBox(height: 2),
          if (asignacion.idPersonal.isNotEmpty) _buildPersonal(),
          if (asignacion.idVehiculo != null && asignacion.idVehiculo!.isNotEmpty) _buildVehiculo(),
          if (asignacion.numeroUnidad > 0) _buildUnidad(),
        ],
      ),
      ),
    );
  }

  Widget _buildHorario() {
    return Row(
      children: <Widget>[
        Icon(
          Icons.schedule,
          size: 12,
          color: _getEstadoColor(),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${asignacion.horaInicio} - ${asignacion.horaFin}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getEstadoColor(),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildEstadoBadge(),
      ],
    );
  }

  Widget _buildPersonal() {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.person,
          size: 11,
          color: AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            asignacion.idPersonal,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVehiculo() {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.local_shipping,
          size: 11,
          color: AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            asignacion.idVehiculo ?? '',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUnidad() {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.tag,
          size: 11,
          color: AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 4),
        Text(
          'Unidad ${asignacion.numeroUnidad}',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: _getEstadoColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getEstadoText(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getEstadoColor() {
    switch (asignacion.estado) {
      case EstadoAsignacion.planificada:
        return AppColors.warning;
      case EstadoAsignacion.confirmada:
        return AppColors.info;
      case EstadoAsignacion.activa:
        return AppColors.primary;
      case EstadoAsignacion.completada:
        return AppColors.success;
      case EstadoAsignacion.cancelada:
        return AppColors.error;
    }
  }

  String _getEstadoText() {
    switch (asignacion.estado) {
      case EstadoAsignacion.planificada:
        return 'P';
      case EstadoAsignacion.confirmada:
        return 'C';
      case EstadoAsignacion.activa:
        return 'A';
      case EstadoAsignacion.completada:
        return '✓';
      case EstadoAsignacion.cancelada:
        return 'X';
    }
  }
}
