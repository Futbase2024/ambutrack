import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_state.dart';
import 'package:flutter/material.dart';

/// Contenido central del listado de vacaciones: carga inicial, error o rejilla
class VacacionGridContent extends StatelessWidget {
  const VacacionGridContent({
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

  final VacacionesState state;
  final bool hasData;
  final List<GestionColumn<VacacionesEntity>> columns;
  final List<VacacionesEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<VacacionesEntity> onSelect;
  final ValueChanged<VacacionesEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final VacacionesState s = state;
    if (!hasData && s is VacacionesError) {
      return VacacionLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<VacacionesEntity>(
          columns: columns,
          rows: rows,
          rowId: (VacacionesEntity v) => v.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ninguna solicitud coincide con los filtros'
              : 'No hay vacaciones registradas este año. Pulsa "Nuevo" para crear una.',
        ),
        if (s is VacacionesLoading)
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

/// Mensaje de error en la carga inicial
class VacacionLoadError extends StatelessWidget {
  const VacacionLoadError({required this.message, required this.onRetry, super.key});

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
            'Error al cargar vacaciones',
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
