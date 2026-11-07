import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';
import '../../models/traslado_con_ruta_info.dart';

/// Widget que muestra la lista de traslados con información de ruta
class ListaTrasladosRutaWidget extends StatelessWidget {
  const ListaTrasladosRutaWidget({
    required this.traslados,
    super.key,
  });

  final List<TrasladoConRutaInfo> traslados;

  @override
  Widget build(BuildContext context) {
    if (traslados.isEmpty) {
      return const Center(
        child: Text('No hay traslados en esta ruta'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: traslados.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSizes.spacingMedium),
      itemBuilder: (BuildContext context, int index) {
        final TrasladoConRutaInfo trasladoInfo = traslados[index];
        return _TrasladoRutaCard(trasladoInfo: trasladoInfo);
      },
    );
  }
}

/// Card que muestra información de un traslado en la ruta
class _TrasladoRutaCard extends StatelessWidget {
  const _TrasladoRutaCard({
    required this.trasladoInfo,
  });

  final TrasladoConRutaInfo trasladoInfo;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: const BorderSide(color: AppColors.gray300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Número de orden
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${trasladoInfo.orden}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacingMedium),

            // Información del traslado
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Código del traslado y hora
                  Row(
                    children: <Widget>[
                      Text(
                        trasladoInfo.traslado.codigo ?? 'Sin código',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                      ),
                      if (trasladoInfo.traslado.horaProgramada != null) ...<Widget>[
                        const SizedBox(width: AppSizes.spacingSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Text(
                            _formatHora(trasladoInfo.traslado.horaProgramada!),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),

                  // Ruta: Origen → Destino
                  _buildRutaInfo(context),

                  const SizedBox(height: AppSizes.spacingSmall),

                  // Métricas del traslado
                  _buildMetricas(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRutaInfo(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.trip_origin,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      trasladoInfo.origen.nombre,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      trasladoInfo.destino.nombre,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricas(BuildContext context) {
    final List<Widget> metricas = <Widget>[];

    // Distancia desde punto anterior
    if (trasladoInfo.distanciaDesdeAnteriorKm != null && trasladoInfo.orden > 1) {
      metricas.add(
        _buildMetricChip(
          context,
          icon: Icons.trending_flat,
          label: 'Desde anterior: ${trasladoInfo.distanciaDesdeAnteriorKm!.toStringAsFixed(1)} km',
          color: AppColors.secondary,
        ),
      );
    }

    // Distancia del traslado
    if (trasladoInfo.distanciaTotalTrasladoKm != null) {
      metricas.add(
        _buildMetricChip(
          context,
          icon: Icons.straighten,
          label: '${trasladoInfo.distanciaTotalTrasladoKm!.toStringAsFixed(1)} km',
          color: AppColors.primary,
        ),
      );
    }

    // Tiempo del traslado
    if (trasladoInfo.tiempoTotalTrasladoMinutos != null) {
      metricas.add(
        _buildMetricChip(
          context,
          icon: Icons.access_time,
          label: '${trasladoInfo.tiempoTotalTrasladoMinutos} min',
          color: AppColors.info,
        ),
      );
    }

    // Hora estimada de llegada
    if (trasladoInfo.horaEstimadaLlegada != null) {
      metricas.add(
        _buildMetricChip(
          context,
          icon: Icons.schedule,
          label: 'Llegada: ${_formatHora(trasladoInfo.horaEstimadaLlegada!)}',
          color: AppColors.success,
        ),
      );
    }

    return Wrap(
      spacing: AppSizes.spacingSmall,
      runSpacing: AppSizes.spacingSmall,
      children: metricas,
    );
  }

  Widget _buildMetricChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  String _formatHora(DateTime hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }
}
