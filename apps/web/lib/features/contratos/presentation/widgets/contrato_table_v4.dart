import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/contratos/presentation/bloc/bloc.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/contrato_form_dialog.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/contratos_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tabla de contratos con patrón estándar (V4)
class ContratoTableV4 extends StatefulWidget {
  const ContratoTableV4({required this.filterData, super.key});

  final ContratosFilterData filterData;

  @override
  State<ContratoTableV4> createState() => _ContratoTableV4State();
}

class _ContratoTableV4State extends State<ContratoTableV4> {
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(ContratoTableV4 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterData != oldWidget.filterData) {
      _currentPage = 0;
    }
  }

  // ==================== SORTING ====================

  List<ContratoEntity> _applySorting(
    List<ContratoEntity> data,
    Map<String, String> hospitalNames,
  ) {
    if (_sortColumnIndex == null) {
      return data;
    }

    final int Function(ContratoEntity, ContratoEntity)? comparator =
        _getSortComparator(_sortColumnIndex!, hospitalNames);
    if (comparator == null) {
      return data;
    }

    final List<ContratoEntity> sorted = List<ContratoEntity>.from(data)
      ..sort((ContratoEntity a, ContratoEntity b) {
        final int result = comparator(a, b);
        return _sortAscending ? result : -result;
      });
    return sorted;
  }

  int Function(ContratoEntity, ContratoEntity)? _getSortComparator(
    int columnIndex,
    Map<String, String> hospitalNames,
  ) {
    switch (columnIndex) {
      case 0: // CÓDIGO
        return (ContratoEntity a, ContratoEntity b) =>
            a.codigo.compareTo(b.codigo);
      case 1: // CENTRO HOSPITALARIO
        return (ContratoEntity a, ContratoEntity b) =>
            (hospitalNames[a.hospitalId] ?? '')
                .compareTo(hospitalNames[b.hospitalId] ?? '');
      case 2: // TIPO
        return (ContratoEntity a, ContratoEntity b) =>
            (a.tipoContrato ?? '').compareTo(b.tipoContrato ?? '');
      case 3: // VIGENCIA
        return (ContratoEntity a, ContratoEntity b) =>
            a.fechaInicio.compareTo(b.fechaInicio);
      case 4: // IMPORTE
        return (ContratoEntity a, ContratoEntity b) =>
            (a.importeMensual ?? 0).compareTo(b.importeMensual ?? 0);
      case 5: // ESTADO
        return (ContratoEntity a, ContratoEntity b) =>
            a.activo == b.activo ? 0 : (a.activo ? -1 : 1);
    }
    return null;
  }

  void _onSort(int columnIndex, {required bool ascending}) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  // ==================== ACCIONES ====================

  Future<void> _editContrato(
    BuildContext context,
    ContratoEntity contrato,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => BlocProvider<ContratoBloc>.value(
        value: context.read<ContratoBloc>(),
        child: ContratoFormDialog(contrato: contrato),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ContratoEntity contrato,
    Map<String, String> hospitalNames,
  ) async {
    final String hospitalName = hospitalNames[contrato.hospitalId] ?? 'N/A';

    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar este contrato? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Código': contrato.codigo,
        'Centro Hospitalario': hospitalName,
        if (contrato.tipoContrato != null && contrato.tipoContrato!.isNotEmpty)
          'Tipo': contrato.tipoContrato!,
        'Vigencia': contrato.periodoVigencia,
        if (contrato.importeMensual != null)
          'Importe Mensual': '€${contrato.importeMensual!.toStringAsFixed(2)}',
        'Estado': contrato.activo ? 'Activo' : 'Inactivo',
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
              message: 'Eliminando contrato...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        context.read<ContratoBloc>().add(ContratoDeleteRequested(contrato.id));
      }
    }
  }

  // ==================== CELLS ====================

  List<DataGridCell> _buildCells(
    ContratoEntity contrato,
    Map<String, String> hospitalNames,
  ) {
    final String hospitalName = hospitalNames[contrato.hospitalId] ?? 'N/A';

    return <DataGridCell>[
      // CÓDIGO
      DataGridCell(
        child: Text(
          contrato.codigo,
          style: AppTextStyles.tableCellBold.copyWith(
            color: AppColors.primary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // CENTRO HOSPITALARIO
      DataGridCell(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.local_hospital,
              size: 16,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                hospitalName,
                style: AppTextStyles.tableCell,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // TIPO
      DataGridCell(
        child: Text(
          contrato.tipoContrato ?? 'No especificado',
          style: AppTextStyles.tableCell,
        ),
      ),

      // VIGENCIA
      DataGridCell(
        child: _VigenciaCell(contrato: contrato),
      ),

      // IMPORTE
      DataGridCell(
        child: contrato.importeMensual != null
            ? Text(
                '€${contrato.importeMensual!.toStringAsFixed(2)}/mes',
                style: AppTextStyles.tableCellBold.copyWith(
                  color: AppColors.success,
                ),
              )
            : Text(
                '-',
                style: AppTextStyles.tableCell.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
      ),

      // ESTADO
      DataGridCell(
        child: Align(
          alignment: Alignment.centerLeft,
          child: StatusBadge(
            label: contrato.activo ? 'ACTIVO' : 'INACTIVO',
            type:
                contrato.activo ? StatusBadgeType.success : StatusBadgeType.error,
          ),
        ),
      ),
    ];
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContratoBloc, ContratoState>(
      listener: (BuildContext context, ContratoState state) {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is ContratoLoaded ||
              state is ContratoError ||
              state is ContratoOperationSuccess) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            setState(() {
              _isDeleting = false;
              _loadingDialogContext = null;
              _deleteStartTime = null;
            });

            if (state is ContratoError) {
              CrudOperationHandler.handleDeleteError(
                context: context,
                isDeleting: true,
                entityName: 'Contrato',
                errorMessage: state.message,
              );
            } else {
              CrudOperationHandler.handleDeleteSuccess(
                context: context,
                isDeleting: true,
                entityName: 'Contrato',
                durationMs: elapsed.inMilliseconds,
              );
            }
          }
        }
      },
      child: BlocBuilder<ContratoBloc, ContratoState>(
        builder: (BuildContext context, ContratoState state) {
          if (state is ContratoLoading) {
            return const _LoadingView();
          }

          if (state is ContratoError) {
            return _ErrorView(message: state.message);
          }

          if (state is ContratoLoaded || state is ContratoOperationSuccess) {
            final List<ContratoEntity> contratos =
                state is ContratoLoaded
                    ? state.contratos
                    : (state as ContratoOperationSuccess).contratos;
            final Map<String, String> hospitalNames =
                state is ContratoLoaded
                    ? state.hospitalNames
                    : (state as ContratoOperationSuccess).hospitalNames;

            // Filtrado y ordenamiento
            List<ContratoEntity> filtrados =
                widget.filterData.apply(contratos, hospitalNames);
            filtrados = _applySorting(filtrados, hospitalNames);

            // Paginación
            final int totalPages = (filtrados.length / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex =
                (startIndex + _itemsPerPage).clamp(0, filtrados.length);
            final List<ContratoEntity> paginados = filtrados.isNotEmpty
                ? filtrados.sublist(startIndex, endIndex)
                : <ContratoEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (contratos.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${contratos.length} contratos',
                      style: AppTextStyles.bodySmallSecondary,
                    ),
                  ),
                Expanded(
                  child: AppDataGridV5<ContratoEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'CÓDIGO', sortable: true),
                      DataGridColumn(
                        label: 'CENTRO HOSPITALARIO',
                        flexWidth: 4,
                        sortable: true,
                      ),
                      DataGridColumn(label: 'TIPO', flexWidth: 2, sortable: true),
                      DataGridColumn(
                        label: 'VIGENCIA',
                        flexWidth: 3,
                        sortable: true,
                      ),
                      DataGridColumn(label: 'IMPORTE', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'ESTADO', flexWidth: 2, sortable: true),
                    ],
                    rows: paginados,
                    buildCells: (ContratoEntity contrato) =>
                        _buildCells(contrato, hospitalNames),
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: _onSort,
                    headerHeight: 44,
                    rowHeight: 56,
                    outerBorderColor: AppColors.gray300,
                    emptyMessage: widget.filterData.hasActiveFilters
                        ? 'No se encontraron contratos con los filtros aplicados'
                        : 'No hay contratos registrados',
                    onEdit: (ContratoEntity contrato) =>
                        _editContrato(context, contrato),
                    onDelete: (ContratoEntity contrato) =>
                        _confirmDelete(context, contrato, hospitalNames),
                  ),
                ),

                // Paginación
                _buildPaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages.clamp(1, 999),
                  totalItems: filtrados.length,
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

  // ==================== PAGINACIÓN ====================

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required void Function(int) onPageChanged,
  }) {
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
            'Mostrando $startItem-$endItem de $totalItems contratos',
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

// ==================== WIDGETS AUXILIARES ====================

/// Celda de vigencia con badge de estado
class _VigenciaCell extends StatelessWidget {
  const _VigenciaCell({required this.contrato});

  final ContratoEntity contrato;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          contrato.periodoVigencia,
          style: AppTextStyles.tableCellSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        if (contrato.haFinalizado)
          const Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge(
              label: 'FINALIZADO',
              type: StatusBadgeType.error,
            ),
          )
        else if (contrato.esVigente)
          const Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge(
              label: 'VIGENTE',
              type: StatusBadgeType.success,
            ),
          ),
      ],
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
        child: AppLoadingIndicator(
          message: 'Cargando contratos...',
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
              'Error al cargar contratos',
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
                context
                    .read<ContratoBloc>()
                    .add(const ContratoLoadRequested());
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
