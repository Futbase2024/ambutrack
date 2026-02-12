import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../widgets/estado_tramite_badge.dart';
import '../widgets/historial_timeline_widget.dart';

/// Página de detalle de un trámite (vacación o ausencia).
class TramiteDetallePage extends StatefulWidget {
  const TramiteDetallePage.vacacion({
    required this.vacacion,
    super.key,
  })  : ausencia = null,
        tipoAusencia = null;

  const TramiteDetallePage.ausencia({
    required this.ausencia,
    required this.tipoAusencia,
    super.key,
  }) : vacacion = null;

  final VacacionesEntity? vacacion;
  final AusenciaEntity? ausencia;
  final TipoAusenciaEntity? tipoAusencia;

  @override
  State<TramiteDetallePage> createState() => _TramiteDetallePageState();
}

class _TramiteDetallePageState extends State<TramiteDetallePage> {
  final _personalDataSource = UsuarioDataSourceFactory.createSupabase();
  String? _nombreSolicitante;
  bool _cargandoNombre = false;

  @override
  void initState() {
    super.initState();
    _cargarNombreSolicitante();
  }

  Future<void> _cargarNombreSolicitante() async {
    setState(() => _cargandoNombre = true);

    try {
      final idPersonal =
          widget.vacacion?.idPersonal ?? widget.ausencia!.idPersonal;
      final personal = await _personalDataSource.getById(idPersonal);

      if (mounted && personal != null) {
        setState(() {
          _nombreSolicitante = personal.nombreCompleto;
          _cargandoNombre = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _nombreSolicitante = 'Usuario desconocido';
          _cargandoNombre = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Datos según tipo
    final String titulo;
    final DateTime fechaInicio;
    final DateTime fechaFin;
    final int dias;
    final String estado;
    final String? observaciones;
    final DateTime fechaSolicitud;
    final String? aprobadoPor;
    final DateTime? fechaAprobacion;
    final IconData icono;
    final String? motivoODescripcion;

    if (widget.vacacion != null) {
      final v = widget.vacacion!;
      titulo = 'Vacaciones';
      fechaInicio = v.fechaInicio;
      fechaFin = v.fechaFin;
      dias = v.diasSolicitados;
      estado = v.estado;
      observaciones = v.observaciones;
      fechaSolicitud = v.fechaSolicitud ?? v.createdAt ?? DateTime.now();
      aprobadoPor = v.aprobadoPor;
      fechaAprobacion = v.fechaAprobacion;
      icono = Icons.beach_access_rounded;
      motivoODescripcion = null;
    } else {
      final a = widget.ausencia!;
      final tipo = widget.tipoAusencia!;
      titulo = tipo.nombre;
      fechaInicio = a.fechaInicio;
      fechaFin = a.fechaFin;
      dias = a.diasAusencia;
      estado = a.estado.name;
      observaciones = a.observaciones;
      fechaSolicitud = a.createdAt;
      aprobadoPor = a.aprobadoPor;
      fechaAprobacion = a.fechaAprobacion;
      icono = _getIconoTipo(tipo.nombre);
      motivoODescripcion = a.motivo;
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          title: const Text('Detalle del Trámite'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono y título
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    child: Icon(
                      icono,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        EstadoTramiteBadge(
                          estado: estado,
                          isAusencia: widget.ausencia != null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacingLarge),

              // Información general
              _buildSeccion(
                titulo: 'Información General',
                children: [
                  _buildInfoRow(
                    icono: Icons.person_outline_rounded,
                    label: 'Solicitado por',
                    valor: _cargandoNombre
                        ? 'Cargando...'
                        : (_nombreSolicitante ?? 'Desconocido'),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _buildInfoRow(
                    icono: Icons.calendar_today_rounded,
                    label: 'Fecha inicio',
                    valor: dateFormat.format(fechaInicio),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _buildInfoRow(
                    icono: Icons.calendar_today_rounded,
                    label: 'Fecha fin',
                    valor: dateFormat.format(fechaFin),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _buildInfoRow(
                    icono: Icons.event_available_rounded,
                    label: 'Total días',
                    valor: '$dias ${dias == 1 ? 'día' : 'días'}',
                  ),
                ],
              ),

              // Motivo (solo ausencias)
              if (motivoODescripcion != null) ...[
                const SizedBox(height: AppSizes.spacingMedium),
                _buildSeccion(
                  titulo: 'Motivo',
                  children: [
                    Text(
                      motivoODescripcion,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.gray700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ],

              // Observaciones
              if (observaciones != null && observaciones.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacingMedium),
                _buildSeccion(
                  titulo: 'Observaciones',
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingSmall),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.05),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        observaciones,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.gray700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSizes.spacingMedium),

              // Historial
              HistorialTimelineWidget(
                fechaSolicitud: fechaSolicitud,
                solicitadoPor: _nombreSolicitante ?? 'Cargando...',
                estado: estado,
                fechaAprobacion: fechaAprobacion,
                aprobadoPor: aprobadoPor,
                observaciones: (fechaAprobacion != null && observaciones != null)
                    ? observaciones
                    : null,
              ),

              const SizedBox(height: AppSizes.spacingXLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icono,
    required String label,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icono,
          size: 20,
          color: AppColors.gray600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconoTipo(String nombre) {
    final nombreLower = nombre.toLowerCase();
    if (nombreLower.contains('médica') || nombreLower.contains('medica')) {
      return Icons.medical_services_rounded;
    } else if (nombreLower.contains('personal')) {
      return Icons.person_outline_rounded;
    } else if (nombreLower.contains('formación') ||
        nombreLower.contains('formacion')) {
      return Icons.school_rounded;
    } else if (nombreLower.contains('compensatorio')) {
      return Icons.event_available_rounded;
    }
    return Icons.event_busy_rounded;
  }

}
