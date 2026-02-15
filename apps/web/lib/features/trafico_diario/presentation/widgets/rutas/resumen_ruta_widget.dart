import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';
import '../../models/traslado_con_ruta_info.dart';

/// Widget que muestra el resumen de una ruta
class ResumenRutaWidget extends StatefulWidget {
  const ResumenRutaWidget({
    required this.resumen,
    super.key,
  });

  final RutaResumen resumen;

  @override
  State<ResumenRutaWidget> createState() => _ResumenRutaWidgetState();
}

class _ResumenRutaWidgetState extends State<ResumenRutaWidget> {
  bool _mostrarDetallesRetrasos = false;

  @override
  Widget build(BuildContext context) {
    // Calcular velocidad promedio
    final double velocidadPromedio = widget.resumen.tiempoTotalMinutos > 0
        ? (widget.resumen.distanciaTotalKm / (widget.resumen.tiempoTotalMinutos / 60))
        : 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: const BorderSide(color: AppColors.gray300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Resumen de Ruta',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                ),
                const Spacer(),
                // Badge con velocidad promedio
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.speed,
                        size: 14,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${velocidadPromedio.toStringAsFixed(0)} km/h',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMedium),

            // Indicador de factibilidad
            if (!widget.resumen.esFactible)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
                child: _buildAlertaFactibilidad(context),
              ),

            _buildMetricRow(
              context,
              icon: Icons.route,
              label: 'Total traslados',
              value: '${widget.resumen.totalTraslados}',
              iconColor: AppColors.primary,
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            _buildMetricRow(
              context,
              icon: Icons.straighten,
              label: 'Distancia total',
              value: '${widget.resumen.distanciaTotalKm.toStringAsFixed(1)} km',
              iconColor: AppColors.secondary,
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            _buildMetricRow(
              context,
              icon: Icons.access_time,
              label: 'Tiempo estimado',
              value: widget.resumen.tiempoTotalFormateado,
              iconColor: AppColors.info,
            ),
            if (widget.resumen.horaInicio != null) ...<Widget>[
              const SizedBox(height: AppSizes.spacingSmall),
              _buildMetricRow(
                context,
                icon: Icons.schedule,
                label: 'Inicio estimado',
                value: _formatHora(widget.resumen.horaInicio!),
                iconColor: AppColors.success,
              ),
            ],
            if (widget.resumen.horaFin != null) ...<Widget>[
              const SizedBox(height: AppSizes.spacingSmall),
              _buildMetricRow(
                context,
                icon: Icons.schedule,
                label: 'Fin estimado',
                value: _formatHora(widget.resumen.horaFin!),
                iconColor: AppColors.warning,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: AppSizes.spacingMedium),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray700,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
        ),
      ],
    );
  }

  Widget _buildAlertaFactibilidad(BuildContext context) {
    final int cantidadRetrasos = widget.resumen.trasladosConRetraso.length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: <Widget>[
          // Header con resumen
          InkWell(
            onTap: () {
              setState(() {
                _mostrarDetallesRetrasos = !_mostrarDetallesRetrasos;
              });
            },
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: Text(
                      '$cantidadRetrasos traslado${cantidadRetrasos > 1 ? 's' : ''} con retraso estimado',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(
                    _mostrarDetallesRetrasos
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 20,
                    color: AppColors.warning,
                  ),
                ],
              ),
            ),
          ),

          // Detalles expandibles
          if (_mostrarDetallesRetrasos) ...<Widget>[
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.warning,
              indent: AppSizes.paddingSmall,
              endIndent: AppSizes.paddingSmall,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ...widget.resumen.trasladosConRetraso.map(
                    (TrasladoConRetrasoInfo retraso) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '${retraso.orden}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingSmall),
                          Expanded(
                            child: Text(
                              'Traslado ${retraso.orden}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.gray700,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${retraso.minutosRetraso} min',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatHora(DateTime hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }
}
