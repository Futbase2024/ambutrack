import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/contratos/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';

/// Contenido central de contratos: carga inicial, error o rejilla
class ContratosGridContent extends StatelessWidget {
  const ContratosGridContent({
    required this.state,
    required this.hasData,
    required this.columns,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.hasFilters,
    required this.onSelect,
    required this.onActivate,
    required this.onSort,
    required this.onRetry,
    super.key,
  });

  final ContratoState state;
  final bool hasData;
  final List<GestionColumn<ContratoEntity>> columns;
  final List<ContratoEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<ContratoEntity> onSelect;
  final ValueChanged<ContratoEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ContratoState s = state;
    if (!hasData && s is ContratoError) {
      return _ContratosLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<ContratoEntity>(
          columns: columns,
          rows: rows,
          rowId: (ContratoEntity c) => c.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún contrato coincide con los filtros'
              : 'No hay contratos registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (s is ContratoLoading)
          const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

class _ContratosLoadError extends StatelessWidget {
  const _ContratosLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 40, color: AppColors.error),
          const SizedBox(height: 8),
          const Text(
            'Error al cargar contratos',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
          ),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(fontSize: 12.5, color: AppColors.gray600)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
