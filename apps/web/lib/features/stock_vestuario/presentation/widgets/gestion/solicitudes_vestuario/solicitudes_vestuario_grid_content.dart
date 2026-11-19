import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/cubit/solicitudes_vestuario_state.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitudes_vestuario_columns.dart';
import 'package:flutter/material.dart';

/// Contenido central: carga inicial, error o rejilla de solicitudes
class SolicitudesVestuarioGridContent extends StatelessWidget {
  const SolicitudesVestuarioGridContent({
    required this.state,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.emptyMessage,
    required this.onSelect,
    required this.onSort,
    required this.onRetry,
    required this.filters,
    required this.onFiltersChanged,
    required this.filterSource,
    super.key,
  });

  final SolicitudesVestuarioState state;
  final List<SolicitudVestuarioEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final String emptyMessage;
  final ValueChanged<SolicitudVestuarioEntity> onSelect;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  /// Filtros por columna estilo Excel
  final GestionColumnFilters filters;
  final ValueChanged<GestionColumnFilters> onFiltersChanged;
  final List<SolicitudVestuarioEntity> filterSource;

  @override
  Widget build(BuildContext context) {
    final String? error = state.error;
    if (state.solicitudes == null && error != null) {
      return _SolicitudesLoadError(message: error, onRetry: onRetry);
    }
    if (state.solicitudes == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<SolicitudVestuarioEntity>(
          columns: solicitudesVestuarioColumns,
          rows: rows,
          filters: filters,
          onFiltersChanged: onFiltersChanged,
          filterSource: filterSource,
          rowId: (SolicitudVestuarioEntity s) => s.id,
          selectedId: selectedId,
          onSelect: onSelect,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: emptyMessage,
        ),
        if (state.cargando || state.procesando)
          const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

class _SolicitudesLoadError extends StatelessWidget {
  const _SolicitudesLoadError({required this.message, required this.onRetry});

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
            'Error al cargar las solicitudes de vestuario',
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
