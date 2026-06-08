import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/excepcion_festivo_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/excepciones_festivos_filters.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/excepciones_festivos_table_cells.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Tabla de gestión de Excepciones y Festivos
class ExcepcionesFestivosTable extends StatefulWidget {
  const ExcepcionesFestivosTable({
    super.key,
    required this.filterData,
  });

  final ExcepcionesFestivosFilterData filterData;

  @override
  State<ExcepcionesFestivosTable> createState() =>
      _ExcepcionesFestivosTableState();
}

class _ExcepcionesFestivosTableState extends State<ExcepcionesFestivosTable> {
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void didUpdateWidget(covariant ExcepcionesFestivosTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterData != oldWidget.filterData) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExcepcionesFestivosBloc, ExcepcionesFestivosState>(
      listener: (BuildContext context, ExcepcionesFestivosState state) async {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is ExcepcionesFestivosLoaded ||
              state is ExcepcionesFestivosError) {
            final Duration elapsed =
                DateTime.now().difference(_deleteStartTime!);

            if (state is ExcepcionesFestivosError) {
              await CrudOperationHandler.handleDeleteError(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Excepción/Festivo',
                errorMessage: state.message,
                onClose: () {
                  setState(() {
                    _isDeleting = false;
                    _loadingDialogContext = null;
                    _deleteStartTime = null;
                  });
                },
              );
            } else {
              await CrudOperationHandler.handleDeleteSuccess(
                context: _loadingDialogContext!,
                isDeleting: _isDeleting,
                entityName: 'Excepción/Festivo',
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
        }
      },
      child: BlocBuilder<ExcepcionesFestivosBloc, ExcepcionesFestivosState>(
        builder: (BuildContext context, ExcepcionesFestivosState state) {
          if (state is ExcepcionesFestivosLoading) {
            return const _TableLoadingView();
          }

          if (state is ExcepcionesFestivosError) {
            return _TableErrorView(message: state.message);
          }

          if (state is ExcepcionesFestivosLoaded) {
            final List<ExcepcionFestivoEntity> filtrados =
                widget.filterData.apply(state.items);
            final List<ExcepcionFestivoEntity> ordenados =
                _sortItems(filtrados);

            final int totalItems = ordenados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex =
                (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<ExcepcionFestivoEntity> itemsPaginados = totalItems > 0
                ? ordenados.sublist(startIndex, endIndex)
                : <ExcepcionFestivoEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Info de resultados filtrados
                if (widget.filterData.hasActiveFilters)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.items.length} excepciones/festivos',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ),

                // Tabla
                Expanded(
                  child: AppDataGridV5<ExcepcionFestivoEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'FECHA', sortable: true),
                      DataGridColumn(
                        label: 'NOMBRE',
                        flexWidth: 2,
                        sortable: true,
                      ),
                      DataGridColumn(label: 'TIPO', sortable: true),
                      DataGridColumn(label: 'REPETIR ANUAL', sortable: true),
                      DataGridColumn(
                        label: 'AFECTA DOTACIONES',
                        sortable: true,
                      ),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: itemsPaginados,
                    buildCells: (ExcepcionFestivoEntity item) =>
                        <DataGridCell>[
                      DataGridCell(child: ExcepcionFechaCell(item: item)),
                      DataGridCell(child: ExcepcionNombreCell(item: item)),
                      DataGridCell(child: ExcepcionTipoCell(item: item)),
                      DataGridCell(
                        child: ExcepcionBooleanBadge(
                          value: item.repetirAnualmente,
                          activeColor: AppColors.success,
                        ),
                      ),
                      DataGridCell(
                        child: ExcepcionBooleanBadge(
                          value: item.afectaDotaciones,
                          activeColor: AppColors.warning,
                        ),
                      ),
                      DataGridCell(child: ExcepcionEstadoCell(item: item)),
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
                        ? 'No se encontraron excepciones/festivos con los filtros aplicados'
                        : 'No hay excepciones/festivos registradas',
                    onEdit: (ExcepcionFestivoEntity item) =>
                        _editItem(context, item),
                    onDelete: (ExcepcionFestivoEntity item) =>
                        _confirmDelete(context, item),
                  ),
                ),

                // Paginación
                const SizedBox(height: AppSizes.spacing),
                _TablePaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages.clamp(1, 999),
                  totalItems: totalItems,
                  itemsPerPage: _itemsPerPage,
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

  List<ExcepcionFestivoEntity> _sortItems(
    List<ExcepcionFestivoEntity> items,
  ) {
    if (_sortColumnIndex == null) {
      return items;
    }

    final List<ExcepcionFestivoEntity> sorted =
        List<ExcepcionFestivoEntity>.from(items);
    final DateTime now = DateTime.now();

    return sorted
      ..sort((ExcepcionFestivoEntity a, ExcepcionFestivoEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0: // Fecha (proximidad a fecha actual)
            final Duration diffA = a.fecha.difference(now).abs();
            final Duration diffB = b.fecha.difference(now).abs();
            comparison = diffA.compareTo(diffB);
          case 1: // Nombre
            comparison = a.nombre.compareTo(b.nombre);
          case 2: // Tipo
            comparison = a.tipo.compareTo(b.tipo);
          case 3: // Repetir Anual
            comparison = a.repetirAnualmente == b.repetirAnualmente
                ? 0
                : (a.repetirAnualmente ? -1 : 1);
          case 4: // Afecta Dotaciones
            comparison = a.afectaDotaciones == b.afectaDotaciones
                ? 0
                : (a.afectaDotaciones ? -1 : 1);
          case 5: // Estado
            comparison =
                a.activo == b.activo ? 0 : (a.activo ? -1 : 1);
        }

        return _sortAscending ? comparison : -comparison;
      });
  }

  // ==================== ACCIONES ====================

  void _editItem(BuildContext context, ExcepcionFestivoEntity item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) =>
          BlocProvider<ExcepcionesFestivosBloc>.value(
            value: context.read<ExcepcionesFestivosBloc>(),
            child: ExcepcionFestivoFormDialog(item: item),
          ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ExcepcionFestivoEntity item,
  ) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar esta excepción/festivo? '
          'Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': item.nombre,
        'Fecha': _dateFormat.format(item.fecha),
        'Tipo': item.tipo,
        if (item.descripcion != null && item.descripcion!.isNotEmpty)
          'Descripción': item.descripcion!,
        'Repetir Anualmente': item.repetirAnualmente ? 'Sí' : 'No',
        'Afecta Dotaciones': item.afectaDotaciones ? 'Sí' : 'No',
        'Estado': item.activo ? 'Activo' : 'Inactivo',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint(
        '🗑️ Eliminando excepción/festivo: ${item.nombre} (${item.id})',
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
              message: 'Eliminando excepción/festivo...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<ExcepcionesFestivosBloc>().add(
              ExcepcionFestivoDeleteRequested(item.id),
            );
      }
    }
  }
}

// ==================== WIDGETS AUXILIARES ====================

/// Vista de carga
class _TableLoadingView extends StatelessWidget {
  const _TableLoadingView();

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
          message: 'Cargando excepciones/festivos...',
        ),
      ),
    );
  }
}

/// Vista de error
class _TableErrorView extends StatelessWidget {
  const _TableErrorView({required this.message});

  final String message;

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
            'Error al cargar excepciones/festivos',
            style: AppTextStyles.h6.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Controles de paginación
class _TablePaginationControls extends StatelessWidget {
  const _TablePaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final int startItem =
        totalItems == 0 ? 0 : currentPage * itemsPerPage + 1;
    final int endItem = totalItems == 0
        ? 0
        : ((currentPage + 1) * itemsPerPage).clamp(0, totalItems);

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
            'Mostrando $startItem-$endItem de $totalItems items',
            style: AppTextStyles.bodySmallSecondary,
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.first_page),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed:
                    currentPage > 0 ? () => onPageChanged(0) : null,
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
}
