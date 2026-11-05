import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_bloc.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Muestra el diálogo especializado para notificaciones de incidencia de vehículo.
///
/// Incluye acciones:
/// - "Visto": marca la notificación como leída y cierra
/// - "Ver detalle": marca como leída, cierra y navega al historial de averías
void showIncidenciaVehiculoDialog({
  required BuildContext context,
  required NotificacionEntity notificacion,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => _IncidenciaDialogContent(
      notificacion: notificacion,
    ),
  );
}

/// Contenido del diálogo de incidencia de vehículo
class _IncidenciaDialogContent extends StatelessWidget {
  const _IncidenciaDialogContent({required this.notificacion});

  final NotificacionEntity notificacion;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> metadata = notificacion.metadata;

    // Extraer datos del metadata
    final String prioridadRaw = metadata['prioridad'] as String? ?? 'media';
    final String prioridad = prioridadRaw[0].toUpperCase() + prioridadRaw.substring(1);
    final String tecnico = metadata['reportado_por_nombre'] as String? ??
        metadata['reportante_nombre'] as String? ??
        'Sin especificar';
    final String averia = metadata['titulo'] as String? ??
        metadata['tipo'] as String? ??
        'Sin especificar';
    final String observaciones = metadata['descripcion'] as String? ??
        notificacion.mensaje;
    final String matricula = metadata['vehiculo_matricula'] as String? ??
        metadata['matricula'] as String? ??
        'Sin especificar';
    final String kilometraje = metadata['kilometraje_reporte']?.toString() ??
        metadata['kilometraje']?.toString() ??
        '0';

    final Color prioridadColor = _getPrioridadColor(prioridad);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header con borde lateral izquierdo
            _IncidenciaHeader(prioridadColor: prioridadColor),
            const Divider(height: 1, color: AppColors.gray200),
            // Contenido
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _IncidenciaInfoRow(
                      icon: Icons.flag_outlined,
                      label: 'Prioridad',
                      value: prioridad,
                      valueColor: prioridadColor,
                    ),
                    const SizedBox(height: AppSizes.spacing),
                    _IncidenciaInfoRow(
                      icon: Icons.person_outline,
                      label: 'Reportado por',
                      value: tecnico,
                    ),
                    const SizedBox(height: AppSizes.spacing),
                    _IncidenciaInfoRow(
                      icon: Icons.build_outlined,
                      label: 'Avería',
                      value: averia,
                    ),
                    const SizedBox(height: AppSizes.spacing),
                    _IncidenciaInfoRow(
                      icon: Icons.notes_outlined,
                      label: 'Observaciones',
                      value: observaciones,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSizes.spacingLarge),
                    // Tarjetas vehículo y kilometraje
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _IncidenciaInfoCard(
                            icon: Icons.directions_car_outlined,
                            label: 'Vehículo',
                            value: matricula,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacing),
                        Expanded(
                          child: _IncidenciaInfoCard(
                            icon: Icons.speed_outlined,
                            label: 'Kilometraje',
                            value: '$kilometraje km',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.gray200),
            // Footer con Visto y Ver
            _IncidenciaFooter(
              onVisto: () => _marcarVistoYCerrar(context),
              onVer: () => _verDetalle(context),
            ),
          ],
        ),
      ),
    );
  }

  void _marcarVistoYCerrar(BuildContext context) {
    Navigator.of(context).pop();
    if (!notificacion.leida) {
      context.read<NotificacionBloc>().add(
            NotificacionEvent.marcarComoLeida(notificacion.id),
          );
    }
  }

  void _verDetalle(BuildContext context) {
    Navigator.of(context).pop();
    if (!notificacion.leida) {
      context.read<NotificacionBloc>().add(
            NotificacionEvent.marcarComoLeida(notificacion.id),
          );
    }
    context.pushNamed('historial_averias');
  }

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
      case 'high':
      case 'critica':
      case 'critical':
        return AppColors.error;
      case 'media':
      case 'medium':
        return AppColors.warning;
      case 'baja':
      case 'low':
        return AppColors.info;
      default:
        return AppColors.gray600;
    }
  }
}

/// Header del diálogo con icono y título
class _IncidenciaHeader extends StatelessWidget {
  const _IncidenciaHeader({required this.prioridadColor});

  final Color prioridadColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.car_crash_outlined,
              size: AppSizes.iconLarge,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Nueva Incidencia de Vehículo',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMedium,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Se ha reportado una avería que requiere atención',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de información con icono, label y valor
class _IncidenciaInfoRow extends StatelessWidget {
  const _IncidenciaInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: AppSizes.iconMedium, color: AppColors.gray500),
        const SizedBox(width: AppSizes.spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.gray900,
                  height: 1.3,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta compacta de información
class _IncidenciaInfoCard extends StatelessWidget {
  const _IncidenciaInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: AppSizes.iconSmall, color: AppColors.gray600),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Footer con botones Visto y Ver detalle
class _IncidenciaFooter extends StatelessWidget {
  const _IncidenciaFooter({
    required this.onVisto,
    required this.onVer,
  });

  final VoidCallback onVisto;
  final VoidCallback onVer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onVisto,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(vertical: AppSizes.padding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.visibility_off_outlined, size: AppSizes.iconMedium),
              label: Text(
                'Visto',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: FilledButton.icon(
              onPressed: onVer,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.padding),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.open_in_new, size: AppSizes.iconMedium),
              label: Text(
                'Ver detalle',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
