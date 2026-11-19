import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/cubit/inicio_turno_validacion_state.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicios_turno_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Contenido central: carga inicial, error o rejilla de inicios de turno
class IniciosTurnoGridContent extends StatelessWidget {
  const IniciosTurnoGridContent({
    required this.state,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.emptyMessage,
    required this.onSelect,
    required this.onActivate,
    required this.onSort,
    required this.onRetry,
    required this.filters,
    required this.onFiltersChanged,
    required this.filterSource,
    super.key,
  });

  final InicioTurnoValidacionState state;
  final List<InicioTurnoEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final String emptyMessage;
  final ValueChanged<InicioTurnoEntity> onSelect;
  final ValueChanged<InicioTurnoEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  /// Filtros por columna estilo Excel
  final GestionColumnFilters filters;
  final ValueChanged<GestionColumnFilters> onFiltersChanged;
  final List<InicioTurnoEntity> filterSource;

  @override
  Widget build(BuildContext context) {
    final String? error = state.error;
    if (state.inicios == null && error != null) {
      return _IniciosLoadError(message: error, onRetry: onRetry);
    }
    if (state.inicios == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<InicioTurnoEntity>(
          columns: iniciosTurnoColumns,
          rows: rows,
          filters: filters,
          onFiltersChanged: onFiltersChanged,
          filterSource: filterSource,
          rowId: (InicioTurnoEntity i) => i.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: emptyMessage,
        ),
        if (state.cargando || state.validando)
          const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

class _IniciosLoadError extends StatelessWidget {
  const _IniciosLoadError({required this.message, required this.onRetry});

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
            'Error al cargar los inicios de turno',
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
