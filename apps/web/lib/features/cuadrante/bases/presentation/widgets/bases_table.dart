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
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bloc.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/base_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/bases_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BasesTable extends StatefulWidget {
  const BasesTable({super.key, required this.filterData});
  final BasesFilterData filterData;
  @override
  State<BasesTable> createState() => _BasesTableState();
}

class _BasesTableState extends State<BasesTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true, _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  void didUpdateWidget(BasesTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterData != oldWidget.filterData) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BasesBloc, BasesState>(
      listener: (BuildContext context, BasesState state) async {
        if (!_isDeleting || _loadingDialogContext == null) {
          return;
        }
        if (state is BasesLoaded || state is BasesError) {
          final Duration elapsed = DateTime.now().difference(_deleteStartTime!);
          if (state is BasesError) {
            await CrudOperationHandler.handleDeleteError(
              context: _loadingDialogContext!,
              isDeleting: _isDeleting,
              entityName: 'Base',
              errorMessage: state.message,
              onClose: () => setState(() {
                _isDeleting = false;
                _loadingDialogContext = null;
                _deleteStartTime = null;
              }),
            );
          } else {
            await CrudOperationHandler.handleDeleteSuccess(
              context: _loadingDialogContext!,
              isDeleting: _isDeleting,
              entityName: 'Base',
              durationMs: elapsed.inMilliseconds,
              onClose: () => setState(() {
                _isDeleting = false;
                _loadingDialogContext = null;
                _deleteStartTime = null;
              }),
            );
          }
        }
      },
      child: BlocBuilder<BasesBloc, BasesState>(
        builder: (BuildContext context, BasesState state) {
          if (state is BasesLoading) {
            return const _LoadingView();
          }
          if (state is BasesError) {
            return _ErrorView(message: state.message);
          }
          if (state is BasesLoaded) {
            return _buildLoadedContent(state.bases);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadedContent(List<BaseCentroEntity> bases) {
    final List<BaseCentroEntity> filtered = widget.filterData.apply(bases);
    final List<BaseCentroEntity> sorted = _sortBases(filtered);
    final int totalItems = sorted.length;
    final int totalPages = (totalItems / _itemsPerPage).ceil();
    final int start = _currentPage * _itemsPerPage;
    final int end = (start + _itemsPerPage).clamp(0, totalItems);
    final List<BaseCentroEntity> paged = totalItems > 0 ? sorted.sublist(start, end) : <BaseCentroEntity>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.filterData.hasActiveFilters)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacing),
            child: Text('Mostrando ${filtered.length} de ${bases.length} bases', style: AppTextStyles.bodySmallSecondary),
          )
        else
          const SizedBox(height: 1),
        Expanded(
          child: AppDataGridV5<BaseCentroEntity>(
            columns: const <DataGridColumn>[
              DataGridColumn(label: 'NOMBRE', flexWidth: 2, sortable: true),
              DataGridColumn(label: 'DIRECCIÓN'),
              DataGridColumn(label: 'POBLACIÓN', sortable: true),
              DataGridColumn(label: 'TIPO', sortable: true),
              DataGridColumn(label: 'ESTADO', sortable: true),
            ],
            rows: paged,
            buildCells: (BaseCentroEntity base) => <DataGridCell>[
              DataGridCell(child: _NombreCell(nombre: base.nombre)),
              DataGridCell(child: _DireccionCell(direccion: base.direccion)),
              DataGridCell(child: _PoblacionCell(poblacion: base.poblacionNombre)),
              DataGridCell(child: _TipoCell(tipo: base.tipo)),
              DataGridCell(child: _EstadoBadge(activo: base.activo)),
            ],
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onSort: (int columnIndex, {required bool ascending}) => setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            }),
            headerHeight: 44,
            outerBorderColor: AppColors.gray300,
            emptyMessage: widget.filterData.hasActiveFilters
                ? 'No se encontraron bases con los filtros aplicados'
                : 'No hay bases registradas',
            onEdit: (BaseCentroEntity base) => _editBase(context, base),
            onDelete: (BaseCentroEntity base) => _confirmDelete(context, base),
          ),
        ),
        const SizedBox(height: AppSizes.spacing),
        _PaginationControls(
          currentPage: _currentPage,
          totalPages: totalPages.clamp(1, 999),
          totalItems: totalItems,
          onPageChanged: (int page) => setState(() => _currentPage = page),
        ),
      ],
    );
  }

  List<BaseCentroEntity> _sortBases(List<BaseCentroEntity> bases) {
    if (_sortColumnIndex == null) {
      return bases;
    }
    return List<BaseCentroEntity>.from(bases)..sort((BaseCentroEntity a, BaseCentroEntity b) {
      int comparison = 0;
      switch (_sortColumnIndex!) {
        case 0: comparison = a.nombre.compareTo(b.nombre); break;
        case 2: comparison = (a.poblacionNombre ?? '').compareTo(b.poblacionNombre ?? ''); break;
        case 3: comparison = (a.tipo ?? '').compareTo(b.tipo ?? ''); break;
        case 4: comparison = a.activo == b.activo ? 0 : (a.activo ? -1 : 1); break;
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  Future<void> _editBase(BuildContext context, BaseCentroEntity base) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<BasesBloc>.value(
        value: context.read<BasesBloc>(), child: BaseFormDialog(base: base),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, BaseCentroEntity base) async {
    final bool isActive = base.activo;
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar ${isActive ? 'Desactivación' : 'Activación'}',
      message: '¿Estás seguro de que deseas ${isActive ? "desactivar" : "activar"} esta base?',
      itemDetails: <String, String>{
        if (base.codigo != null && base.codigo!.isNotEmpty) 'Código': base.codigo!,
        'Nombre': base.nombre,
        if (base.direccion != null && base.direccion!.isNotEmpty) 'Dirección': base.direccion!,
        if (base.poblacionNombre != null && base.poblacionNombre!.isNotEmpty) 'Población': base.poblacionNombre!,
        if (base.tipo != null && base.tipo!.isNotEmpty) 'Tipo': base.tipo!,
        'Estado': isActive ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

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
          return AppLoadingOverlay(
            message: '${isActive ? "Desactivando" : "Activando"} base...',
            color: isActive ? AppColors.emergency : AppColors.success,
            icon: isActive ? Icons.block : Icons.check_circle,
          );
        },
      ),
    );
    if (context.mounted) {
      if (isActive) {
        context.read<BasesBloc>().add(BaseDeactivateRequested(base.id));
      } else {
        context.read<BasesBloc>().add(BaseUpdateRequested(base.copyWith(activo: true, updatedAt: DateTime.now())));
      }
    }
  }
}

// ==================== CELDAS ====================

class _NombreCell extends StatelessWidget {
  const _NombreCell({required this.nombre});
  final String nombre;
  @override
  Widget build(BuildContext context) => Text(nombre, style: AppTextStyles.tableCellBold, maxLines: 2, overflow: TextOverflow.ellipsis);
}

class _DireccionCell extends StatelessWidget {
  const _DireccionCell({this.direccion});
  final String? direccion;
  @override
  Widget build(BuildContext context) => Text(direccion ?? '-', style: AppTextStyles.tableCellSecondary, maxLines: 2, overflow: TextOverflow.ellipsis);
}

class _PoblacionCell extends StatelessWidget {
  const _PoblacionCell({this.poblacion});
  final String? poblacion;
  @override
  Widget build(BuildContext context) => Text(poblacion ?? '-', style: AppTextStyles.tableCellSecondary);
}

class _TipoCell extends StatelessWidget {
  const _TipoCell({this.tipo});
  final String? tipo;
  @override
  Widget build(BuildContext context) => Text(tipo ?? '-', style: AppTextStyles.tableCellSecondary);
}

class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.activo});
  final bool activo;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: StatusBadge(label: activo ? 'Activo' : 'Inactivo', type: activo ? StatusBadgeType.success : StatusBadgeType.inactivo),
  );
}

// ==================== PAGINACIÓN COMPACTA ====================

class _PaginationControls extends StatelessWidget {
  const _PaginationControls({required this.currentPage, required this.totalPages, required this.totalItems, required this.onPageChanged});
  final int currentPage, totalPages, totalItems;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final int start = totalItems == 0 ? 0 : currentPage * 25 + 1;
    final int end = totalItems == 0 ? 0 : ((currentPage + 1) * 25).clamp(0, totalItems);
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text('Mostrando $start-$end de $totalItems items', style: AppTextStyles.bodySmallSecondary),
        Row(children: <Widget>[
          IconButton(icon: const Icon(Icons.first_page), onPressed: currentPage > 0 ? () => onPageChanged(0) : null, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
            child: Text('Página ${currentPage + 1} de $totalPages', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600)),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
          IconButton(icon: const Icon(Icons.last_page), onPressed: currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
        ]),
      ]),
    );
  }
}

// ==================== ESTADOS ====================

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSizes.spacingMassive),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSizes.radius), border: Border.all(color: AppColors.gray200)),
    constraints: const BoxConstraints(minHeight: 400),
    child: const Center(child: AppLoadingIndicator(message: 'Cargando bases...')),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSizes.paddingXl),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSizes.radius), border: Border.all(color: AppColors.error)),
    child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
      const SizedBox(height: AppSizes.spacing),
      Text('Error al cargar bases', style: AppTextStyles.errorTextLarge),
      const SizedBox(height: AppSizes.spacingSmall),
      Text(message, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
    ]),
  );
}
