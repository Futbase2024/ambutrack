import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/checklist_bloc.dart';
import '../bloc/checklist_event.dart';
import '../bloc/checklist_state.dart';
import '../widgets/checklist_stats_card.dart';

/// Página de detalle de checklist (solo lectura)
///
/// Muestra todos los datos de un checklist ya guardado
class DetalleChecklistPage extends StatelessWidget {
  const DetalleChecklistPage({
    super.key,
    required this.checklistId,
  });

  final String checklistId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChecklistBloc(repository: getIt())
        ..add(ChecklistEvent.verDetalle(checklistId: checklistId)),
      child: Scaffold(
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          title: const Text('Detalle de Checklist'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: BlocBuilder<ChecklistBloc, ChecklistState>(
            builder: (context, state) {
              return state.when(
                initial: () => const SizedBox.shrink(),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                historialCargado: (checklists, vehiculoId) =>
                    const SizedBox.shrink(),
                creandoChecklist: (vehiculoId, tipo, items, resultados, obs) =>
                    const SizedBox.shrink(),
                guardando: () => const SizedBox.shrink(),
                checklistGuardado: (checklist) => const SizedBox.shrink(),
                viendoDetalle: (checklist) => _DetalleContent(
                  checklist: checklist,
                ),
                error: (mensaje, vehiculoId) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mensaje,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Contenido del detalle
class _DetalleContent extends StatelessWidget {
  const _DetalleContent({required this.checklist});

  final ChecklistVehiculoEntity checklist;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Cabecera con información general
        _CabeceraCard(checklist: checklist),
        const SizedBox(height: 16),

        // Estadísticas
        ChecklistStatsCard(checklist: checklist),
        const SizedBox(height: 16),

        // Items agrupados por categoría
        _ItemsPorCategoria(items: checklist.items),
        const SizedBox(height: 16),

        // Observaciones generales
        if (checklist.observacionesGenerales != null &&
            checklist.observacionesGenerales!.isNotEmpty)
          _ObservacionesCard(
            observaciones: checklist.observacionesGenerales!,
          ),
      ],
    );
  }
}

/// Card con información general del checklist
class _CabeceraCard extends StatelessWidget {
  const _CabeceraCard({required this.checklist});

  final ChecklistVehiculoEntity checklist;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de checklist
            Row(
              children: [
                Icon(
                  _getIconoTipo(checklist.tipo),
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  checklist.tipo.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Información
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Fecha',
              value: DateFormat('dd/MM/yyyy HH:mm')
                  .format(checklist.fechaRealizacion),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.person,
              label: 'Realizado por',
              value: checklist.realizadoPorNombre,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.speed,
              label: 'Kilometraje',
              value: '${checklist.kilometraje.toStringAsFixed(0)} km',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconoTipo(TipoChecklist tipo) {
    switch (tipo) {
      case TipoChecklist.preServicio:
        return Icons.play_circle_outline;
      case TipoChecklist.postServicio:
        return Icons.stop_circle_outlined;
      case TipoChecklist.mensual:
        return Icons.calendar_month;
    }
  }
}

/// Fila de información
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.gray500),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// Items agrupados por categoría
class _ItemsPorCategoria extends StatelessWidget {
  const _ItemsPorCategoria({required this.items});

  final List<ItemChecklistEntity> items;

  @override
  Widget build(BuildContext context) {
    // Agrupar por categoría
    final itemsPorCategoria = <CategoriaChecklist, List<ItemChecklistEntity>>{};
    for (final item in items) {
      if (!itemsPorCategoria.containsKey(item.categoria)) {
        itemsPorCategoria[item.categoria] = [];
      }
      itemsPorCategoria[item.categoria]!.add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items Verificados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in itemsPorCategoria.entries) ...[
          _CategoriaCard(
            categoria: entry.key,
            items: entry.value,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Card de una categoría con sus items
class _CategoriaCard extends StatelessWidget {
  const _CategoriaCard({
    required this.categoria,
    required this.items,
  });

  final CategoriaChecklist categoria;
  final List<ItemChecklistEntity> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200, width: 1),
      ),
      child: ExpansionTile(
        title: Text(
          categoria.nombre,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('${items.length} items'),
        children: [
          for (final item in items)
            _ItemTile(item: item),
        ],
      ),
    );
  }
}

/// Tile de un item individual (read-only)
class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final ItemChecklistEntity item;

  @override
  Widget build(BuildContext context) {
    final color = _getColorResultado(item.resultado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.gray200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconoResultado(item.resultado),
                color: color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.itemNombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IntrinsicWidth(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.resultado.nombre,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (item.observaciones != null && item.observaciones!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.comment,
                    size: 16,
                    color: AppColors.gray600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.observaciones!,
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
    );
  }

  Color _getColorResultado(ResultadoItem resultado) {
    switch (resultado) {
      case ResultadoItem.presente:
        return AppColors.success;
      case ResultadoItem.ausente:
        return AppColors.error;
      case ResultadoItem.noAplica:
        return AppColors.gray400;
    }
  }

  IconData _getIconoResultado(ResultadoItem resultado) {
    switch (resultado) {
      case ResultadoItem.presente:
        return Icons.check_circle;
      case ResultadoItem.ausente:
        return Icons.cancel;
      case ResultadoItem.noAplica:
        return Icons.remove_circle_outline;
    }
  }
}

/// Card con observaciones generales
class _ObservacionesCard extends StatelessWidget {
  const _ObservacionesCard({required this.observaciones});

  final String observaciones;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.comment, color: AppColors.gray600, size: 20),
                SizedBox(width: 12),
                Text(
                  'Observaciones Generales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              observaciones,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
