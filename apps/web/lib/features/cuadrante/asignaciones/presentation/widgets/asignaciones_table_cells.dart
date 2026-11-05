import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ==================== HELPERS ====================

/// Color según estado de asignación
Color getEstadoColor(String estado) {
  switch (estado.toLowerCase()) {
    case 'planificada':
      return AppColors.info;
    case 'confirmada':
      return AppColors.success;
    case 'en_curso':
      return AppColors.warning;
    case 'finalizada':
    case 'completada':
      return AppColors.textSecondaryLight;
    case 'cancelada':
      return AppColors.error;
    default:
      return AppColors.textSecondaryLight;
  }
}

/// Icono según estado de asignación
IconData getEstadoIcon(String estado) {
  switch (estado.toLowerCase()) {
    case 'planificada':
      return Icons.schedule;
    case 'confirmada':
      return Icons.check_circle;
    case 'en_curso':
      return Icons.play_circle;
    case 'finalizada':
    case 'completada':
      return Icons.done_all;
    case 'cancelada':
      return Icons.cancel;
    default:
      return Icons.help_outline;
  }
}

/// Label según estado de asignación
String getEstadoLabel(String estado) {
  switch (estado.toLowerCase()) {
    case 'planificada':
      return 'Planificada';
    case 'confirmada':
      return 'Confirmada';
    case 'en_curso':
      return 'En Curso';
    case 'finalizada':
    case 'completada':
      return 'Completada';
    case 'cancelada':
      return 'Cancelada';
    default:
      return estado;
  }
}

// ==================== CELDAS ====================

/// Celda de vehículo con icono
class AsignacionVehiculoCell extends StatelessWidget {
  const AsignacionVehiculoCell({super.key, required this.asignacion});

  final AsignacionVehiculoTurnoEntity asignacion;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.directions_car, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            asignacion.vehiculoId,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Celda de dotación
class AsignacionDotacionCell extends StatelessWidget {
  const AsignacionDotacionCell({super.key, required this.asignacion});

  final AsignacionVehiculoTurnoEntity asignacion;

  @override
  Widget build(BuildContext context) {
    return Text(
      asignacion.dotacionId,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textPrimaryLight,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Celda de turno
class AsignacionTurnoCell extends StatelessWidget {
  const AsignacionTurnoCell({super.key, required this.asignacion});

  final AsignacionVehiculoTurnoEntity asignacion;

  @override
  Widget build(BuildContext context) {
    return Text(
      asignacion.plantillaTurnoId ?? 'Sin turno',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: asignacion.plantillaTurnoId != null
            ? AppColors.textPrimaryLight
            : AppColors.textSecondaryLight,
        fontStyle:
            asignacion.plantillaTurnoId == null ? FontStyle.italic : null,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Badge de estado con icono
class AsignacionEstadoBadge extends StatelessWidget {
  const AsignacionEstadoBadge({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final Color color = getEstadoColor(estado);
    final String label = getEstadoLabel(estado);
    final IconData icon = getEstadoIcon(estado);

    return Align(
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Celda de destino (Hospital/Base)
class AsignacionDestinoCell extends StatelessWidget {
  const AsignacionDestinoCell({super.key, required this.asignacion});

  final AsignacionVehiculoTurnoEntity asignacion;

  @override
  Widget build(BuildContext context) {
    if (asignacion.hospitalId != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.local_hospital, size: 14, color: AppColors.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'H: ${asignacion.hospitalId}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (asignacion.baseId != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.home_work, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'B: ${asignacion.baseId}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      'Sin asignar',
      style: GoogleFonts.inter(
        fontSize: 12,
        color: AppColors.textSecondaryLight,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

/// Celda SI/NO compacta
class AsignacionSiNoCell extends StatelessWidget {
  const AsignacionSiNoCell({super.key, required this.valor});

  final bool valor;

  @override
  Widget build(BuildContext context) {
    final Color color = valor ? AppColors.success : AppColors.textSecondaryLight;
    final String label = valor ? 'SÍ' : 'NO';

    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

/// Botón de acción compacto con hover
class AsignacionActionButton extends StatefulWidget {
  const AsignacionActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = AppColors.secondaryLight,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  @override
  State<AsignacionActionButton> createState() =>
      _AsignacionActionButtonState();
}

class _AsignacionActionButtonState extends State<AsignacionActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.gray100 : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: 16,
              color: _isHovered ? widget.color : AppColors.gray500,
            ),
          ),
        ),
      ),
    );
  }
}
