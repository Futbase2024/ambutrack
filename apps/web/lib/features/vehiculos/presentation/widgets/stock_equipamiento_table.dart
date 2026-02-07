import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/stock_equipamiento_header.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/stock_equipamiento_view_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/stock_manual_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla de stock de equipamiento por vehículo
class StockEquipamientoTable extends StatefulWidget {
  const StockEquipamientoTable({super.key});

  @override
  State<StockEquipamientoTable> createState() => _StockEquipamientoTableState();
}

class _StockEquipamientoTableState extends State<StockEquipamientoTable> {
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockEquipamientoBloc, StockEquipamientoState>(
      builder: (BuildContext context, StockEquipamientoState state) {
        if (state is StockEquipamientoLoading || state is StockEquipamientoInitial) {
          return const _LoadingView();
        }

        if (state is StockEquipamientoError) {
          return _ErrorView(
            message: state.message,
            onRetry: () {
              context.read<StockEquipamientoBloc>().add(
                    const StockEquipamientoLoadRequested(),
                  );
            },
          );
        }

        if (state is StockEquipamientoLoaded) {
          return _buildLoadedView(state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadedView(StockEquipamientoLoaded state) {
    // Filtrar y ordenar
    List<VehiculoStockResumenEntity> filtrados = _filterVehiculos(state.vehiculos);
    filtrados = _sortVehiculos(filtrados);

    // Paginación
    final int totalItems = filtrados.length;
    final int totalPages = (totalItems / _itemsPerPage).ceil();
    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final List<VehiculoStockResumenEntity> paginados =
        filtrados.sublist(startIndex, endIndex.clamp(startIndex, totalItems));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Barra de búsqueda
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Vehículos con Equipamiento',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            StockEquipamientoSearchBar(
              onSearchChanged: (String query) {
                setState(() {
                  _searchQuery = query;
                  _currentPage = 0;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),

        // Info de filtros
        if (state.vehiculos.length != filtrados.length)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacing),
            child: Text(
              'Mostrando ${filtrados.length} de ${state.vehiculos.length} vehículos',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),

        // Tabla
        Expanded(
          child: AppDataGridV5<VehiculoStockResumenEntity>(
            columns: const <DataGridColumn>[
              DataGridColumn(label: 'VEHÍCULO', flexWidth: 2, sortable: true),
              DataGridColumn(label: 'TIPO', sortable: true),
              DataGridColumn(label: 'ESTADO', sortable: true),
              DataGridColumn(label: 'TOTAL', sortable: true),
              DataGridColumn(label: 'OK', sortable: true),
              DataGridColumn(label: 'CADUCADOS', sortable: true),
              DataGridColumn(label: 'BAJO', sortable: true),
              DataGridColumn(label: 'PRÓXIMOS', sortable: true),
            ],
            rows: paginados,
            buildCells: _buildCells,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onSort: (int columnIndex, {required bool ascending}) {
              setState(() {
                _sortColumnIndex = columnIndex;
                _sortAscending = ascending;
              });
            },
            customActions: <CustomAction<VehiculoStockResumenEntity>>[
              CustomAction<VehiculoStockResumenEntity>(
                icon: Icons.visibility,
                tooltip: 'Ver equipamiento',
                color: AppColors.info,
                onPressed: (VehiculoStockResumenEntity item) => _verStock(context, item),
              ),
              CustomAction<VehiculoStockResumenEntity>(
                icon: Icons.add,
                tooltip: 'Añadir item',
                color: AppColors.success,
                onPressed: (VehiculoStockResumenEntity item) => _addStock(context, item),
              ),
            ],
            emptyMessage: _searchQuery.isNotEmpty
                ? 'No se encontraron vehículos con los filtros aplicados'
                : 'No hay vehículos registrados',
            rowHeight: 64,
          ),
        ),

        // Paginación
        const SizedBox(height: AppSizes.spacing),
        _buildPaginationControls(
          currentPage: _currentPage,
          totalPages: totalPages,
          totalItems: totalItems,
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
        ),
      ],
    );
  }

  List<DataGridCell> _buildCells(VehiculoStockResumenEntity item) {
    return <DataGridCell>[
      // Vehículo
      DataGridCell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.matricula,
              style: AppTextStyles.tableCellBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${item.marca} ${item.modelo}',
              style: AppTextStyles.tableCellSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),

      // Tipo
      DataGridCell(
        child: Text(
          item.tipoVehiculo,
          style: AppTextStyles.tableCell,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // Estado general
      DataGridCell(
        child: Align(
          alignment: Alignment.centerLeft,
          child: StatusBadge(
            label: _getEstadoLabel(item.estadoGeneral),
            type: _getEstadoBadgeType(item.estadoGeneral),
          ),
        ),
      ),

      // Total
      DataGridCell(
        child: Text(
          item.totalItems.toString(),
          style: AppTextStyles.tableCellBold,
        ),
      ),

      // OK
      DataGridCell(
        child: Text(
          item.itemsOk.toString(),
          style: AppTextStyles.tableCellBold.copyWith(
            color: item.itemsOk > 0 ? AppColors.success : AppColors.textSecondaryLight,
          ),
        ),
      ),

      // Caducados
      DataGridCell(
        child: Text(
          item.itemsCaducados.toString(),
          style: AppTextStyles.tableCellBold.copyWith(
            color: item.itemsCaducados > 0 ? AppColors.error : AppColors.textSecondaryLight,
          ),
        ),
      ),

      // Stock bajo
      DataGridCell(
        child: Text(
          item.itemsStockBajo.toString(),
          style: AppTextStyles.tableCellBold.copyWith(
            color: item.itemsStockBajo > 0 ? AppColors.warning : AppColors.textSecondaryLight,
          ),
        ),
      ),

      // Próximos a caducar
      DataGridCell(
        child: Text(
          item.itemsProximosCaducar.toString(),
          style: AppTextStyles.tableCellBold.copyWith(
            color: item.itemsProximosCaducar > 0
                ? AppColors.warning
                : AppColors.textSecondaryLight,
          ),
        ),
      ),
    ];
  }

  String _getEstadoLabel(EstadoStockGeneral estado) {
    switch (estado) {
      case EstadoStockGeneral.ok:
        return 'OK';
      case EstadoStockGeneral.atencion:
        return 'ATENCIÓN';
      case EstadoStockGeneral.critico:
        return 'CRÍTICO';
    }
  }

  StatusBadgeType _getEstadoBadgeType(EstadoStockGeneral estado) {
    switch (estado) {
      case EstadoStockGeneral.ok:
        return StatusBadgeType.success;
      case EstadoStockGeneral.atencion:
        return StatusBadgeType.warning;
      case EstadoStockGeneral.critico:
        return StatusBadgeType.error;
    }
  }

  List<VehiculoStockResumenEntity> _filterVehiculos(
    List<VehiculoStockResumenEntity> vehiculos,
  ) {
    if (_searchQuery.isEmpty) {
      return vehiculos;
    }
    final String query = _searchQuery.toLowerCase();
    return vehiculos.where((VehiculoStockResumenEntity v) {
      return v.matricula.toLowerCase().contains(query) ||
          v.marca.toLowerCase().contains(query) ||
          v.modelo.toLowerCase().contains(query) ||
          v.tipoVehiculo.toLowerCase().contains(query);
    }).toList();
  }

  List<VehiculoStockResumenEntity> _sortVehiculos(
    List<VehiculoStockResumenEntity> vehiculos,
  ) {
    if (_sortColumnIndex == null) {
      return vehiculos;
    }

    final List<VehiculoStockResumenEntity> sorted = List<VehiculoStockResumenEntity>.from(vehiculos)
      ..sort((VehiculoStockResumenEntity a, VehiculoStockResumenEntity b) {
      int result;
      switch (_sortColumnIndex) {
        case 0:
          result = a.matricula.compareTo(b.matricula);
        case 1:
          result = a.tipoVehiculo.compareTo(b.tipoVehiculo);
        case 2:
          result = a.estadoGeneral.index.compareTo(b.estadoGeneral.index);
        case 3:
          result = a.totalItems.compareTo(b.totalItems);
        case 4:
          result = a.itemsOk.compareTo(b.itemsOk);
        case 5:
          result = a.itemsCaducados.compareTo(b.itemsCaducados);
        case 6:
          result = a.itemsStockBajo.compareTo(b.itemsStockBajo);
        case 7:
          result = a.itemsProximosCaducar.compareTo(b.itemsProximosCaducar);
        default:
          result = 0;
      }
      return _sortAscending ? result : -result;
    });

    return sorted;
  }

  void _verStock(BuildContext context, VehiculoStockResumenEntity item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StockEquipamientoViewDialog(
          vehiculoId: item.vehiculoId,
          matricula: item.matricula,
          marca: item.marca,
          modelo: item.modelo,
        );
      },
    );
  }

  Future<void> _addStock(BuildContext context, VehiculoStockResumenEntity item) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StockManualFormDialog(vehiculoId: item.vehiculoId);
      },
    );

    if (result == true && context.mounted) {
      context.read<StockEquipamientoBloc>().add(
            StockEquipamientoVehiculoUpdated(vehiculoId: item.vehiculoId),
          );
    }
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required void Function(int) onPageChanged,
  }) {
    final int startItem = totalItems == 0 ? 0 : currentPage * _itemsPerPage + 1;
    final int endItem = totalItems == 0
        ? 0
        : ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Mostrando $startItem-$endItem de $totalItems vehículos',
            style: AppTextStyles.bodySmallSecondary,
          ),
          Row(
            children: <Widget>[
              _PaginationButton(
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
                icon: Icons.first_page,
                tooltip: 'Primera página',
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              _PaginationButton(
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
                icon: Icons.chevron_left,
                tooltip: 'Página anterior',
              ),
              const SizedBox(width: AppSizes.spacing),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  'Página ${currentPage + 1} de ${totalPages > 0 ? totalPages : 1}',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontSmall,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              _PaginationButton(
                onPressed:
                    currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
                icon: Icons.chevron_right,
                tooltip: 'Página siguiente',
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              _PaginationButton(
                onPressed:
                    currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null,
                icon: Icons.last_page,
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Vista de carga
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      constraints: const BoxConstraints(minHeight: 400),
      child: const Center(
        child: AppLoadingIndicator(message: 'Cargando stock de vehículos...'),
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Error al cargar stock',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacing),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

/// Botón de paginación
class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacingSmall),
          decoration: BoxDecoration(
            color: onPressed != null
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.gray200,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: onPressed != null
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.gray300,
            ),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconSmall,
            color: onPressed != null ? AppColors.primary : AppColors.gray400,
          ),
        ),
      ),
    );
  }
}
