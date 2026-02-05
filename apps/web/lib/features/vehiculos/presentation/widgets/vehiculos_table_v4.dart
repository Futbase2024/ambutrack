import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/lang/app_strings.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/vehiculo_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/vehiculos_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Tabla de vehículos optimizada con ModernDataTableV3
class VehiculosTableV4 extends StatefulWidget {
  const VehiculosTableV4({required this.onFilterChanged, super.key});

  final void Function(VehiculosFilterData) onFilterChanged;

  @override
  State<VehiculosTableV4> createState() => _VehiculosTableV4State();
}

class _VehiculosTableV4State extends State<VehiculosTableV4> {
  VehiculosFilterData _filterData = const VehiculosFilterData();
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // Paginación para mejorar rendimiento
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  void _onFilterChanged(VehiculosFilterData filterData) {
    setState(() {
      _filterData = filterData;
      _currentPage = 0; // Resetear a primera página cuando cambian filtros
    });
    widget.onFilterChanged(filterData);
  }

  List<VehiculoEntity> _applySorting(List<VehiculoEntity> data) {
    if (_sortColumnIndex == null) {
      return data;
    }
    final int Function(VehiculoEntity, VehiculoEntity)? comparator =
        _getSortComparator(_sortColumnIndex!);
    if (comparator == null) {
      return data;
    }

    final List<VehiculoEntity> sorted = List<VehiculoEntity>.from(data)
      ..sort((VehiculoEntity a, VehiculoEntity b) {
        final int result = comparator(a, b);
        return _sortAscending ? result : -result;
      });
    return sorted;
  }

  int Function(VehiculoEntity, VehiculoEntity)? _getSortComparator(int columnIndex) {
    switch (columnIndex) {
      case 0:
        return (VehiculoEntity a, VehiculoEntity b) => a.matricula.compareTo(b.matricula);
      case 1:
        return (VehiculoEntity a, VehiculoEntity b) => a.marca.compareTo(b.marca);
      case 2:
        return (VehiculoEntity a, VehiculoEntity b) => a.tipoVehiculo.compareTo(b.tipoVehiculo);
      case 3:
        return (VehiculoEntity a, VehiculoEntity b) => a.estado.index.compareTo(b.estado.index);
      case 4:
        return (VehiculoEntity a, VehiculoEntity b) {
          if (a.kmActual == null && b.kmActual == null) {
            return 0;
          } else if (a.kmActual == null) {
            return 1;
          } else if (b.kmActual == null) {
            return -1;
          } else {
            return a.kmActual!.compareTo(b.kmActual!);
          }
        };
      case 5:
        return (VehiculoEntity a, VehiculoEntity b) =>
            (a.ubicacionActual ?? '').compareTo(b.ubicacionActual ?? '');
    }
    return null;
  }

  String _getEstadoLabel(VehiculoEstado estado) {
    switch (estado) {
      case VehiculoEstado.activo:
        return AppStrings.vehiculosEstadoDisponible;
      case VehiculoEstado.mantenimiento:
        return AppStrings.vehiculosEstadoMantenimiento;
      case VehiculoEstado.reparacion:
        return AppStrings.vehiculosEstadoReparacion;
      case VehiculoEstado.baja:
        return AppStrings.vehiculosEstadoBaja;
    }
  }

  void _onSort(int columnIndex, {required bool ascending}) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  StatusBadgeType _getStatusBadgeType(VehiculoEstado estado) {
    switch (estado) {
      case VehiculoEstado.activo:
        return StatusBadgeType.disponible;
      case VehiculoEstado.mantenimiento:
        return StatusBadgeType.mantenimiento;
      case VehiculoEstado.reparacion:
        return StatusBadgeType.error;
      case VehiculoEstado.baja:
        return StatusBadgeType.inactivo;
    }
  }

  /// Navega a la página de stock del vehículo
  void _showVehiculoDetails(BuildContext context, VehiculoEntity vehiculo) {
    context.goNamed(
      'flota_stock_vehiculo',
      pathParameters: <String, String>{'vehiculoId': vehiculo.id},
    );
  }

  Future<void> _editVehiculo(BuildContext context, VehiculoEntity vehiculo) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<VehiculosBloc>.value(
          value: context.read<VehiculosBloc>(),
          child: VehiculoFormDialog(vehiculo: vehiculo),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, VehiculoEntity vehiculo) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar este vehículo? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Matrícula': vehiculo.matricula,
        'Marca': vehiculo.marca,
        'Modelo': vehiculo.modelo,
        if (vehiculo.numeroBastidor.isNotEmpty) 'Bastidor': vehiculo.numeroBastidor,
        'Estado': _getEstadoLabel(vehiculo.estado),
        'Tipo': vehiculo.tipoVehiculo,
      },
    );

    if (confirmed == true && context.mounted) {
      BuildContext? loadingContext;

      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            loadingContext = dialogContext;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && loadingContext != null) {
                setState(() {
                  _isDeleting = true;
                  _loadingDialogContext = loadingContext;
                  _deleteStartTime = DateTime.now();
                });
              }
            });

            return const AppLoadingOverlay(
              message: 'Eliminando vehículo...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<VehiculosBloc>().add(VehiculoDeleteRequested(vehiculoId: vehiculo.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiculosBloc, VehiculosState>(
      listener: (BuildContext context, VehiculosState state) {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is VehiculosLoaded || state is VehiculosError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);
            final int durationMs = elapsed.inMilliseconds;

            setState(() {
              _isDeleting = false;
              _loadingDialogContext = null;
              _deleteStartTime = null;
            });

            if (state is VehiculosError) {
              CrudOperationHandler.handleDeleteError(
                context: context,
                isDeleting: true,
                entityName: 'Vehículo',
                errorMessage: state.message,
              );
            } else if (state is VehiculosLoaded) {
              CrudOperationHandler.handleDeleteSuccess(
                context: context,
                isDeleting: true,
                entityName: 'Vehículo',
                durationMs: durationMs,
              );
            }
          }
        }
      },
      child: BlocBuilder<VehiculosBloc, VehiculosState>(
        builder: (BuildContext context, VehiculosState state) {
          if (state is VehiculosLoading) {
            return const _LoadingView();
          }

          if (state is VehiculosError) {
            return _ErrorView(message: state.message);
          }

          if (state is VehiculosLoaded) {
            List<VehiculoEntity> vehiculosFiltrados = _filterData.apply(state.vehiculos);
            vehiculosFiltrados = _applySorting(vehiculosFiltrados);

            // Aplicar paginación para mejorar rendimiento (25 items por página)
            final int totalPages = (vehiculosFiltrados.length / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, vehiculosFiltrados.length);
            final List<VehiculoEntity> vehiculosPaginados = vehiculosFiltrados.sublist(
              startIndex,
              endIndex,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      AppStrings.vehiculosListaTitulo,
                      style: AppTextStyles.h4,
                    ),
                    VehiculosFilters(onFilterChanged: _onFilterChanged),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing),
                if (state.vehiculos.length != vehiculosFiltrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${vehiculosFiltrados.length} de ${state.vehiculos.length} vehículos',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ),
                Expanded(
                  child: AppDataGridV5<VehiculoEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'MATRÍCULA', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'MARCA / MODELO', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'TIPO', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'ESTADO', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'KM', sortable: true),
                      DataGridColumn(label: 'UBICACIÓN', flexWidth: 2, sortable: true),
                    ],
                    rows: vehiculosPaginados,
                    buildCells: _buildCells,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: _onSort,
                    rowHeight: 72,
                    outerBorderColor: AppColors.gray300,
                    emptyMessage: _filterData.hasActiveFilters
                        ? 'No se encontraron vehículos con los filtros aplicados'
                        : AppStrings.vehiculosListaVacia,
                    onView: (VehiculoEntity vehiculo) => _showVehiculoDetails(context, vehiculo),
                    onEdit: (VehiculoEntity vehiculo) => _editVehiculo(context, vehiculo),
                    onDelete: (VehiculoEntity vehiculo) => _confirmDelete(context, vehiculo),
                  ),
                ),

                // Controles de paginación (siempre visible)
                _buildPaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  totalItems: vehiculosFiltrados.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Construye controles de paginación
  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required void Function(int) onPageChanged,
  }) {
    final int startItem = currentPage * _itemsPerPage + 1;
    final int endItem = ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

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
          // Info de elementos mostrados
          Text(
            'Mostrando $startItem-$endItem de $totalItems vehículos',
            style: AppTextStyles.bodySmallSecondary,
          ),

          // Botones de navegación
          Row(
            children: <Widget>[
              // Primera página
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: currentPage > 0
                    ? () => onPageChanged(0)
                    : null,
                tooltip: 'Primera página',
              ),

              // Página anterior
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                tooltip: 'Página anterior',
              ),

              // Indicador de página
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  'Página ${currentPage + 1} de $totalPages',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Página siguiente
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                tooltip: 'Página siguiente',
              ),

              // Última página
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(totalPages - 1)
                    : null,
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye las celdas de cada fila
  List<DataGridCell> _buildCells(VehiculoEntity vehiculo) {
    final String estadoLabel = _getEstadoLabel(vehiculo.estado);
    final StatusBadgeType badgeType = _getStatusBadgeType(vehiculo.estado);

    return <DataGridCell>[
      // Matrícula + Año
      DataGridCell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              vehiculo.matricula,
              style: AppTextStyles.tableCellBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Año ${vehiculo.anioFabricacion}',
              style: AppTextStyles.tableCellSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),

      // Marca / Modelo
      DataGridCell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              vehiculo.marca,
              style: AppTextStyles.tableCellBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              vehiculo.modelo,
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
          vehiculo.tipoVehiculo,
          style: AppTextStyles.tableCell,
        ),
      ),

      // Estado con badge profesional suave
      DataGridCell(
        child: Align(
          alignment: Alignment.centerLeft,
          child: StatusBadge(
            label: estadoLabel,
            type: badgeType,
          ),
        ),
      ),

      // Kilómetros
      DataGridCell(
        child: Text(
          vehiculo.kmActual != null ? '${vehiculo.kmActual!.toStringAsFixed(0)} km' : '-',
          style: AppTextStyles.tableCell,
        ),
      ),

      // Ubicación
      DataGridCell(
        child: Text(
          vehiculo.ubicacionActual ?? '-',
          style: AppTextStyles.tableCell,
        ),
      ),
    ];
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
        child: AppLoadingIndicator(
          message: 'Cargando vehículos...',
        ),
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: AppSizes.iconMassive,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              AppStrings.vehiculosErrorCarga,
              style: AppTextStyles.errorTextLarge,
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              message,
              style: AppTextStyles.bodySmallSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing),
            ElevatedButton(
              onPressed: () {
                context.read<VehiculosBloc>().add(const VehiculosLoadRequested());
              },
              child: const Text(AppStrings.reintentar),
            ),
          ],
        ),
      ),
    );
  }
}
