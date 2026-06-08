import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotacion_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotaciones_filters.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotaciones_table_cells.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tabla de gestión de Dotaciones con patrón Vehículos
class DotacionesTable extends StatefulWidget {
  const DotacionesTable({super.key, required this.filterData});

  final DotacionesFilterData filterData;

  @override
  State<DotacionesTable> createState() => _DotacionesTableState();
}

class _DotacionesTableState extends State<DotacionesTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(covariant DotacionesTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterData != oldWidget.filterData) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DotacionesBloc, DotacionesState>(
      listener: (BuildContext context, DotacionesState state) async {
        if (!_isDeleting || _loadingDialogContext == null) {
          return;
        }

        if (state is DotacionesError) {
          await CrudOperationHandler.handleDeleteError(
            context: _loadingDialogContext!,
            isDeleting: _isDeleting,
            entityName: 'Dotación',
            errorMessage: state.message,
            onClose: () {
              setState(() {
                _isDeleting = false;
                _loadingDialogContext = null;
                _deleteStartTime = null;
              });
            },
          );
        } else if (state is DotacionesLoaded) {
          if (_deleteStartTime != null) {
            final Duration elapsed =
                DateTime.now().difference(_deleteStartTime!);
            await CrudOperationHandler.handleDeleteSuccess(
              context: _loadingDialogContext!,
              isDeleting: _isDeleting,
              entityName: 'Dotación',
              durationMs: elapsed.inMilliseconds,
              onClose: () {
                setState(() {
                  _isDeleting = false;
                  _loadingDialogContext = null;
                  _deleteStartTime = null;
                });
              },
            );
          }
        }
      },
      child: BlocBuilder<DotacionesBloc, DotacionesState>(
        builder: (BuildContext context, DotacionesState state) {
          if (state is DotacionesLoading) {
            return const _LoadingView();
          }

          if (state is DotacionesError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<DotacionesBloc>()
                  .add(const DotacionesLoadRequested()),
            );
          }

          if (state is DotacionesLoaded) {
            // Filtrado client-side
            final List<DotacionEntity> filtradas =
                widget.filterData.apply(state.dotaciones);

            // Ordenamiento
            final List<DotacionEntity> ordenadas =
                _sortDotaciones(filtradas);

            // Paginación
            final int totalItems = ordenadas.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex =
                (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<DotacionEntity> paginadas = totalItems > 0
                ? ordenadas.sublist(startIndex, endIndex)
                : <DotacionEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Info de resultados filtrados
                if (widget.filterData.hasActiveFilters)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtradas.length} de ${state.dotaciones.length} dotaciones',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ),

                // Tabla
                Expanded(
                  child: AppDataGridV5<DotacionEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(
                        label: 'NOMBRE',
                        flexWidth: 2,
                        sortable: true,
                      ),
                      DataGridColumn(label: 'DESTINO', sortable: true),
                      DataGridColumn(label: 'UNIDADES', sortable: true),
                      DataGridColumn(label: 'PRIORIDAD', sortable: true),
                      DataGridColumn(label: 'VIGENCIA'),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: paginadas,
                    buildCells: (DotacionEntity dotacion) =>
                        <DataGridCell>[
                      DataGridCell(
                        child: DotacionNombreCell(dotacion: dotacion),
                      ),
                      DataGridCell(
                        child: DotacionDestinoCell(dotacion: dotacion),
                      ),
                      DataGridCell(
                        child: DotacionUnidadesCell(dotacion: dotacion),
                      ),
                      DataGridCell(
                        child: DotacionPrioridadCell(dotacion: dotacion),
                      ),
                      DataGridCell(
                        child: DotacionVigenciaCell(dotacion: dotacion),
                      ),
                      DataGridCell(
                        child: DotacionEstadoCell(dotacion: dotacion),
                      ),
                    ],
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (int columnIndex, {required bool ascending}) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                    headerHeight: 44,
                    outerBorderColor: AppColors.gray300,
                    emptyMessage: widget.filterData.hasActiveFilters
                        ? 'No se encontraron dotaciones con los filtros aplicados'
                        : 'No hay dotaciones registradas',
                    onView: (DotacionEntity dotacion) =>
                        _showDetails(context, dotacion),
                    onEdit: (DotacionEntity dotacion) =>
                        _editDotacion(context, dotacion),
                    onDelete: (DotacionEntity dotacion) =>
                        _confirmDelete(context, dotacion),
                  ),
                ),

                // Paginación
                const SizedBox(height: AppSizes.spacing),
                _PaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages.clamp(1, 999),
                  totalItems: totalItems,
                  onPageChanged: (int page) {
                    setState(() => _currentPage = page);
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

  // ==================== ORDENAMIENTO ====================

  List<DotacionEntity> _sortDotaciones(List<DotacionEntity> dotaciones) {
    if (_sortColumnIndex == null) {
      return dotaciones;
    }

    final List<DotacionEntity> sorted = List<DotacionEntity>.from(dotaciones)
      ..sort((DotacionEntity a, DotacionEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex!) {
          case 0: // NOMBRE
            comparison = a.nombre.compareTo(b.nombre);
          case 1: // DESTINO
            comparison = a.tipoDestino.compareTo(b.tipoDestino);
          case 2: // UNIDADES
            comparison =
                a.cantidadUnidades.compareTo(b.cantidadUnidades);
          case 3: // PRIORIDAD
            comparison = a.prioridad.compareTo(b.prioridad);
          case 5: // ESTADO
            comparison =
                a.activo == b.activo ? 0 : (a.activo ? -1 : 1);
        }

        return _sortAscending ? comparison : -comparison;
      });

    return sorted;
  }

  // ==================== ACCIONES ====================

  void _showDetails(BuildContext context, DotacionEntity dotacion) {
    debugPrint('👁️ Ver detalle dotación: ${dotacion.nombre}');
  }

  Future<void> _editDotacion(
    BuildContext context,
    DotacionEntity dotacion,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<DotacionesBloc>.value(
          value: context.read<DotacionesBloc>(),
          child: DotacionFormDialog(dotacion: dotacion),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DotacionEntity dotacion,
  ) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar esta dotación? '
          'Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Código': dotacion.codigo ?? 'N/A',
        'Nombre': dotacion.nombre,
        if (dotacion.descripcion != null &&
            dotacion.descripcion!.isNotEmpty)
          'Descripción': dotacion.descripcion!,
        'Destino': dotacion.tipoDestino,
        'Unidades': '${dotacion.cantidadUnidades}',
        'Prioridad': '${dotacion.prioridad}',
        'Estado': dotacion.activo ? 'Activa' : 'Inactiva',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint(
        '🗑️ Eliminando dotación: ${dotacion.nombre} (${dotacion.id})',
      );

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
              message: 'Eliminando dotación...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context
            .read<DotacionesBloc>()
            .add(DotacionDeleteRequested(dotacion.id));
      }
    }
  }
}

// ==================== WIDGETS AUXILIARES ====================

/// Controles de paginación profesional
class _PaginationControls extends StatelessWidget {
  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final int startItem =
        totalItems == 0 ? 0 : currentPage * _itemsPerPage + 1;
    final int endItem = totalItems == 0
        ? 0
        : ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Mostrando $startItem-$endItem de $totalItems dotaciones',
            style: AppTextStyles.bodySmallSecondary,
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.first_page),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: currentPage > 0
                    ? () => onPageChanged(0)
                    : null,
                tooltip: 'Primera página',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                tooltip: 'Página anterior',
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4,
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
              IconButton(
                icon: const Icon(Icons.chevron_right),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                tooltip: 'Página siguiente',
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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

  static const int _itemsPerPage = 25;
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
          message: 'Cargando dotaciones...',
        ),
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
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Error al cargar dotaciones',
            style: AppTextStyles.h6.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacing),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
