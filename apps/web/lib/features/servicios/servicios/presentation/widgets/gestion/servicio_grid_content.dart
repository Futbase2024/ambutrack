import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/gestion/servicio_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Contenido central de servicios: carga inicial, error o rejilla
class ServicioGridContent extends StatelessWidget {
  const ServicioGridContent({
    required this.servicios,
    required this.isLoading,
    required this.errorMessage,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.hasFilters,
    required this.onSelect,
    required this.onActivate,
    required this.onSort,
    required this.onRetry,
    required this.filters,
    required this.onFiltersChanged,
    required this.filterSource,
    super.key,
  });

  /// Últimos servicios cargados (null = aún no hay datos)
  final List<ServicioEntity>? servicios;
  final bool isLoading;

  /// Mensaje de error de la última carga (null = sin error)
  final String? errorMessage;
  final List<ServicioEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<ServicioEntity> onSelect;
  final ValueChanged<ServicioEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;
  final GestionColumnFilters filters;
  final ValueChanged<GestionColumnFilters> onFiltersChanged;
  final List<ServicioEntity> filterSource;

  @override
  Widget build(BuildContext context) {
    final String? error = errorMessage;
    if (servicios == null && error != null) {
      return _ServicioLoadError(message: error, onRetry: onRetry);
    }
    if (servicios == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<ServicioEntity>(
          columns: servicioGestionColumns,
          rows: rows,
          filters: filters,
          onFiltersChanged: onFiltersChanged,
          filterSource: filterSource,
          rowId: (ServicioEntity s) => s.id ?? '',
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún servicio coincide con los filtros'
              : 'No hay servicios registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (isLoading)
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

class _ServicioLoadError extends StatelessWidget {
  const _ServicioLoadError({required this.message, required this.onRetry});

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
            'Error al cargar servicios',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: AppColors.gray600),
          ),
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
