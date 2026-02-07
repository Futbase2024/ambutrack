import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import 'estado_tramite_badge.dart';

/// Card para mostrar información de un trámite (vacación o ausencia).
class TramiteCard extends StatefulWidget {
  const TramiteCard({
    required this.titulo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.dias,
    required this.estado,
    required this.icono,
    required this.colorIcono,
    this.subtitulo,
    this.observaciones,
    this.fechaSolicitud,
    this.solicitadoPor,
    this.aprobadoPor,
    this.fechaAprobacion,
    this.onTap,
    this.onLongPress,
    this.isAusencia = false,
    super.key,
  });

  final String titulo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int dias;
  final String estado;
  final IconData icono;
  final Color colorIcono;
  final String? subtitulo;
  final String? observaciones;
  final DateTime? fechaSolicitud;
  final String? solicitadoPor;
  final String? aprobadoPor;
  final DateTime? fechaAprobacion;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isAusencia;

  @override
  State<TramiteCard> createState() => _TramiteCardState();
}

class _TramiteCardState extends State<TramiteCard> {
  final _personalDataSource = PersonalDataSourceFactory.createSupabase();
  String? _nombreSolicitante;
  String? _nombreAprobador;
  bool _cargandoNombres = false;

  @override
  void initState() {
    super.initState();
    _cargarNombres();
  }

  Future<void> _cargarNombres() async {
    // Solo cargar si hay IDs para buscar
    if (widget.solicitadoPor == null && widget.aprobadoPor == null) return;

    setState(() => _cargandoNombres = true);

    try {
      // Cargar nombre del solicitante
      if (widget.solicitadoPor != null) {
        final solicitante =
            await _personalDataSource.getById(widget.solicitadoPor!);
        if (mounted && solicitante != null) {
          _nombreSolicitante = solicitante.nombreCompleto;
        }
      }

      // Cargar nombre del aprobador
      if (widget.aprobadoPor != null) {
        final aprobador =
            await _personalDataSource.getById(widget.aprobadoPor!);
        if (mounted && aprobador != null) {
          _nombreAprobador = aprobador.nombreCompleto;
        }
      }

      if (mounted) {
        setState(() => _cargandoNombres = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _nombreSolicitante ??= 'Usuario desconocido';
          _nombreAprobador ??= 'Usuario desconocido';
          _cargandoNombres = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: AppColors.gray200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icono + Título + Badge Estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.colorIcono.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Icon(
                      widget.icono,
                      color: widget.colorIcono,
                      size: AppSizes.iconMedium,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                        ),
                        if (widget.subtitulo != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitulo!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  EstadoTramiteBadge(
                    estado: widget.estado,
                    isAusencia: widget.isAusencia,
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacingMedium),

              // Fechas y días
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppColors.gray600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${dateFormat.format(widget.fechaInicio)} - ${dateFormat.format(widget.fechaFin)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Text(
                        '${widget.dias} ${widget.dias == 1 ? 'día' : 'días'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Observaciones
              if (widget.observaciones != null &&
                  widget.observaciones!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacingSmall),
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.observaciones!,
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

              // Footer: Fecha solicitud y aprobación/rechazo
              const SizedBox(height: AppSizes.spacingSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Línea 1: Solicitado por
                  if (widget.fechaSolicitud != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Solicitado: ${dateFormat.format(widget.fechaSolicitud!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                    if (_nombreSolicitante != null) ...[
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: Text(
                          'Por: $_nombreSolicitante',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                    ],
                  ],
                  // Línea 2: Aprobado/Rechazado por
                  if (widget.aprobadoPor != null &&
                      widget.fechaAprobacion != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getIconoAccion(widget.estado),
                          size: 14,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_getTextoAccion(widget.estado)}: ${dateFormat.format(widget.fechaAprobacion!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                    if (_cargandoNombres) ...[
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: Text(
                          'Por: Cargando...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ] else if (_nombreAprobador != null) ...[
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: Text(
                          'Por: $_nombreAprobador',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconoAccion(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        return Icons.check_circle_outline_rounded;
      case 'rechazada':
      case 'rechazado':
        return Icons.cancel_outlined;
      case 'cancelada':
      case 'cancelado':
        return Icons.block_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getTextoAccion(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        return 'Aprobado';
      case 'rechazada':
      case 'rechazado':
        return 'Rechazado';
      case 'cancelada':
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Actualizado';
    }
  }
}
