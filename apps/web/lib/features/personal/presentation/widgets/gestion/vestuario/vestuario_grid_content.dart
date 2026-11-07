import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_state.dart';
import 'package:flutter/material.dart';

/// Contenido central de vestuario: carga inicial, error o rejilla
class VestuarioGridContent extends StatelessWidget {
  const VestuarioGridContent({
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

  final VestuarioState state;
  final bool hasData;
  final List<GestionColumn<VestuarioEntity>> columns;
  final List<VestuarioEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<VestuarioEntity> onSelect;
  final ValueChanged<VestuarioEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final VestuarioState s = state;
    if (!hasData && s is VestuarioError) {
      return _VestuarioLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<VestuarioEntity>(
          columns: columns,
          rows: rows,
          rowId: (VestuarioEntity v) => v.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún registro coincide con los filtros'
              : 'No hay registros de vestuario. Pulsa "Nuevo" para crear uno.',
        ),
        if (s is VestuarioLoading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}

class _VestuarioLoadError extends StatelessWidget {
  const _VestuarioLoadError({required this.message, required this.onRetry});

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
            'Error al cargar el vestuario',
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
