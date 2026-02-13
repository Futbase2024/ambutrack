import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../data/services/alertas_caducidad_cache_service.dart';

/// Diálogo de alertas de caducidad
///
/// Muestra items próximos a caducar y críticos agrupados por categoría
class AlertasCaducidadDialog extends StatelessWidget {
  const AlertasCaducidadDialog({
    super.key,
    required this.items,
    required this.vehiculoId,
  });

  final List<StockVehiculoEntity> items;
  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    // Agrupar por categoría
    final itemsPorCategoria = <String, List<StockVehiculoEntity>>{};
    for (final item in items) {
      final categoria = item.categoriaNombre ?? 'Sin categoría';
      if (!itemsPorCategoria.containsKey(categoria)) {
        itemsPorCategoria[categoria] = [];
      }
      itemsPorCategoria[categoria]!.add(item);
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alertas de Caducidad',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${items.length} ${items.length == 1 ? 'item requiere' : 'items requieren'} tu atención',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Lista de categorías
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                children: itemsPorCategoria.entries.map((entry) {
                  return _CategoriaSection(
                    categoria: entry.key,
                    items: entry.value,
                  );
                }).toList(),
              ),
            ),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Marcar como revisadas
                        final cache = AlertasCaducidadCacheService.instance;
                        cache.marcarComoRevisadas(vehiculoId);
                        // Cerrar diálogo
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.gray400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Marcar como revisadas
                        final cache = AlertasCaducidadCacheService.instance;
                        cache.marcarComoRevisadas(vehiculoId);
                        // Cerrar diálogo
                        Navigator.of(context).pop();
                        // Navegar a caducidades
                        context.push('/vehiculo/caducidades');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Ver todas'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sección de una categoría con sus items
class _CategoriaSection extends StatelessWidget {
  const _CategoriaSection({
    required this.categoria,
    required this.items,
  });

  final String categoria;
  final List<StockVehiculoEntity> items;

  @override
  Widget build(BuildContext context) {
    // Contar críticos y próximos
    final criticos = items.where((item) {
      final estado = _calcularEstadoCaducidad(item);
      return estado == 'critico';
    }).length;
    final proximos = items.where((item) {
      final estado = _calcularEstadoCaducidad(item);
      return estado == 'proximo';
    }).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Categoría + Badges
          Row(
            children: [
              Expanded(
                child: Text(
                  categoria,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              if (criticos > 0)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '$criticos crítico${criticos > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              if (proximos > 0)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '$proximos próximo${proximos > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Lista de items
          ...items.map((item) {
            final estadoCalculado = _calcularEstadoCaducidad(item);
            final esCritico = estadoCalculado == 'critico';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    esCritico ? Icons.circle : Icons.circle_outlined,
                    size: 8,
                    color: esCritico ? AppColors.error : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.productoNombre ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _calcularDiasRestantes(item),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: esCritico ? AppColors.error : AppColors.warning,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _calcularDiasRestantes(StockVehiculoEntity item) {
    if (item.fechaCaducidad == null) return 'N/A';
    final dias = item.fechaCaducidad!.difference(DateTime.now()).inDays;
    if (dias < 0) return 'Caducado';
    if (dias == 0) return 'Hoy';
    if (dias == 1) return '1 día';
    return '$dias días';
  }

  String _calcularEstadoCaducidad(StockVehiculoEntity item) {
    if (item.estadoCaducidad != null && item.estadoCaducidad != 'null') {
      return item.estadoCaducidad!;
    }

    if (item.fechaCaducidad == null) {
      return 'sin_caducidad';
    }

    final diasRestantes = item.fechaCaducidad!.difference(DateTime.now()).inDays;

    if (diasRestantes < 0) {
      return 'caducado';
    } else if (diasRestantes <= 7) {
      return 'critico';
    } else if (diasRestantes <= 30) {
      return 'proximo';
    } else {
      return 'ok';
    }
  }
}
