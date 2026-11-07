import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// Widget que muestra el historial de un trámite en formato timeline.
class HistorialTimelineWidget extends StatefulWidget {
  const HistorialTimelineWidget({
    required this.fechaSolicitud,
    required this.solicitadoPor,
    required this.estado,
    this.fechaAprobacion,
    this.aprobadoPor,
    this.observaciones,
    super.key,
  });

  final DateTime fechaSolicitud;
  final String solicitadoPor;
  final String estado;
  final DateTime? fechaAprobacion;
  final String? aprobadoPor;
  final String? observaciones;

  @override
  State<HistorialTimelineWidget> createState() =>
      _HistorialTimelineWidgetState();
}

class _HistorialTimelineWidgetState extends State<HistorialTimelineWidget> {
  final _personalDataSource = UsuarioDataSourceFactory.createSupabase();
  String? _nombreAprobador;
  bool _cargandoNombre = false;

  @override
  void initState() {
    super.initState();
    if (widget.aprobadoPor != null) {
      _cargarNombreAprobador();
    }
  }

  Future<void> _cargarNombreAprobador() async {
    if (widget.aprobadoPor == null) return;

    setState(() => _cargandoNombre = true);

    try {
      final personal = await _personalDataSource.getById(widget.aprobadoPor!);
      if (mounted && personal != null) {
        setState(() {
          _nombreAprobador = personal.nombreCompleto;
          _cargandoNombre = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _nombreAprobador = 'Usuario desconocido';
          _cargandoNombre = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Historial del Trámite',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingMedium),

          // Timeline de eventos
          Column(
            children: [
              // Evento 1: Solicitud creada
              _TimelineItem(
                icon: Icons.add_circle_rounded,
                iconColor: AppColors.info,
                titulo: 'Solicitud creada',
                descripcion: 'Por: ${widget.solicitadoPor}',
                fecha: dateFormat.format(widget.fechaSolicitud),
                isLast: widget.fechaAprobacion == null,
              ),

              // Evento 2: Aprobación/Rechazo (si existe)
              if (widget.fechaAprobacion != null) ...[
                _TimelineItem(
                  icon: _getIconoEstado(widget.estado),
                  iconColor: _getColorEstado(widget.estado),
                  titulo: _getTituloEstado(widget.estado),
                  descripcion: _cargandoNombre
                      ? 'Cargando...'
                      : 'Por: ${_nombreAprobador ?? widget.aprobadoPor ?? 'Sistema'}',
                  fecha: dateFormat.format(widget.fechaAprobacion!),
                  observaciones: widget.observaciones,
                  isLast: true,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        return Icons.check_circle_rounded;
      case 'rechazada':
      case 'rechazado':
        return Icons.cancel_rounded;
      case 'cancelada':
      case 'cancelado':
        return Icons.block_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        return AppColors.success;
      case 'rechazada':
      case 'rechazado':
        return AppColors.error;
      case 'cancelada':
      case 'cancelado':
        return AppColors.gray500;
      default:
        return AppColors.warning;
    }
  }

  String _getTituloEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        return 'Solicitud aprobada';
      case 'rechazada':
      case 'rechazado':
        return 'Solicitud rechazada';
      case 'cancelada':
      case 'cancelado':
        return 'Solicitud cancelada';
      default:
        return 'Estado actualizado';
    }
  }
}

/// Item individual del timeline.
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.iconColor,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.isLast,
    this.observaciones,
  });

  final IconData icon;
  final Color iconColor;
  final String titulo;
  final String descripcion;
  final String fecha;
  final String? observaciones;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea vertical y punto
          Column(
            children: [
              // Punto con icono
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),

              // Línea vertical (si no es el último)
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Contenido del evento
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSizes.spacingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Descripción
                  Text(
                    descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),

                  // Fecha
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fecha,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),

                  // Observaciones (si existen)
                  if (observaciones != null && observaciones!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.05),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.note_rounded,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              observaciones!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.gray700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
