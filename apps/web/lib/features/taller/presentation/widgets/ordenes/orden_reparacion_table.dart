import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_dialogs.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_filters_bar.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_table_cells.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_table_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_table_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tabla de Órdenes de Reparación con búsqueda, filtro de estado y paginación
class OrdenReparacionTable extends StatefulWidget {
  const OrdenReparacionTable({super.key});

  @override
  State<OrdenReparacionTable> createState() => _OrdenReparacionTableState();
}

class _OrdenReparacionTableState extends State<OrdenReparacionTable> {
  static const int _itemsPerPage = 25;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _estado = filtroOrdenesTodas;
  int _currentPage = 0;
  bool _isDeleting = false;
  final Stopwatch _deleteWatch = Stopwatch();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(OrdenReparacionEntity orden) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar Orden de Reparación',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{'Nº Orden': orden.numeroOrden, 'Matrícula': orden.vehiculoMatricula ?? '-'},
      warningMessage: 'Se eliminarán también todos los repuestos de la orden.',
      icon: Icons.delete_forever,
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _isDeleting = true);
    _deleteWatch
      ..reset()
      ..start();
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => const AppLoadingOverlay(
          message: 'Eliminando orden...',
          color: AppColors.emergency,
          icon: Icons.delete_forever,
        ),
      ),
    );
    context.read<OrdenReparacionBloc>().add(OrdenReparacionDeleteRequested(id: orden.id));
  }

  void _onDeleteResult(BuildContext context, OrdenReparacionState state) {
    if (!_isDeleting) {
      return;
    }
    void reset() => setState(() => _isDeleting = false);
    if (state is OrdenReparacionOperationSuccess && state.operacion == OrdenOperacion.eliminar) {
      CrudOperationHandler.handleDeleteSuccess(
        context: context,
        isDeleting: true,
        entityName: 'Orden de Reparación',
        durationMs: _deleteWatch.elapsedMilliseconds,
        onClose: reset,
      );
    } else if (state is OrdenReparacionOperationFailure && state.operacion == OrdenOperacion.eliminar) {
      CrudOperationHandler.handleDeleteError(
        context: context,
        isDeleting: true,
        entityName: 'Orden de Reparación',
        errorMessage: state.message,
        onClose: reset,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdenReparacionBloc, OrdenReparacionState>(
      listener: _onDeleteResult,
      builder: (BuildContext context, OrdenReparacionState state) {
        if (state is OrdenReparacionError) {
          return TallerTableErrorView(
            title: 'Error al cargar órdenes',
            message: state.message,
            onRetry: () => context.read<OrdenReparacionBloc>().add(const OrdenReparacionLoadRequested()),
          );
        }
        if (state is! OrdenReparacionLoaded) {
          return const TallerTableLoadingView(message: 'Cargando órdenes de reparación...');
        }
        return _OrdenesLoadedView(
          ordenes: state.ordenes,
          searchController: _searchController,
          searchQuery: _searchQuery,
          estado: _estado,
          currentPage: _currentPage,
          itemsPerPage: _itemsPerPage,
          onSearchChanged: (String v) => setState(() {
            _searchQuery = v;
            _currentPage = 0;
          }),
          onEstadoChanged: (String v) => setState(() {
            _estado = v;
            _currentPage = 0;
          }),
          onPageChanged: (int p) => setState(() => _currentPage = p),
          onView: (OrdenReparacionEntity o) => showOrdenDetailDialog(context, o),
          onEdit: (OrdenReparacionEntity o) => showOrdenFormDialog(context, orden: o),
          onDelete: _confirmDelete,
        );
      },
    );
  }
}

/// Página actual (acotada) y filas visibles
({int page, int totalPages, List<OrdenReparacionEntity> rows}) _paginar(
  List<OrdenReparacionEntity> items,
  int currentPage,
  int perPage,
) {
  final int totalPages = (items.length / perPage).ceil();
  final int page = totalPages == 0 ? 0 : currentPage.clamp(0, totalPages - 1);
  final int start = page * perPage;
  final int end = (start + perPage).clamp(0, items.length);
  return (page: page, totalPages: totalPages, rows: items.sublist(start, end));
}

const String _emptyFiltered = 'No se encontraron órdenes con los filtros aplicados';
const String _emptyNoData = 'No hay órdenes de reparación. Pulsa "Nueva Orden" para crear una.';

class _OrdenesLoadedView extends StatelessWidget {
  const _OrdenesLoadedView({
    required this.ordenes,
    required this.searchController,
    required this.searchQuery,
    required this.estado,
    required this.currentPage,
    required this.itemsPerPage,
    required this.onSearchChanged,
    required this.onEstadoChanged,
    required this.onPageChanged,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final List<OrdenReparacionEntity> ordenes;
  final TextEditingController searchController;
  final String searchQuery;
  final String estado;
  final int currentPage;
  final int itemsPerPage;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onEstadoChanged;
  final ValueChanged<int> onPageChanged;
  final void Function(OrdenReparacionEntity) onView;
  final void Function(OrdenReparacionEntity) onEdit;
  final void Function(OrdenReparacionEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    final List<OrdenReparacionEntity> filtered = filterOrdenes(ordenes, query: searchQuery, estado: estado);
    final ({int page, int totalPages, List<OrdenReparacionEntity> rows}) p = _paginar(
      filtered,
      currentPage,
      itemsPerPage,
    );
    final bool hasFilters = searchQuery.isNotEmpty || estado != filtroOrdenesTodas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        OrdenFiltersBar(
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          estado: estado,
          onEstadoChanged: onEstadoChanged,
        ),
        const SizedBox(height: AppSizes.spacing),
        if (hasFilters) _FilteredCount(shown: filtered.length, total: ordenes.length),
        Expanded(
          child: AppDataGridV5<OrdenReparacionEntity>(
            columns: ordenTableColumns,
            rows: p.rows,
            buildCells: buildOrdenCells,
            onView: onView,
            onEdit: onEdit,
            onDelete: onDelete,
            emptyMessage: hasFilters ? _emptyFiltered : _emptyNoData,
          ),
        ),
        const SizedBox(height: AppSizes.spacing),
        TallerPaginationBar(
          currentPage: p.page,
          totalPages: p.totalPages,
          totalItems: filtered.length,
          itemsPerPage: itemsPerPage,
          entityLabel: 'órdenes',
          onPageChanged: onPageChanged,
        ),
      ],
    );
  }
}

class _FilteredCount extends StatelessWidget {
  const _FilteredCount({required this.shown, required this.total});

  final int shown;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing),
      child: Text('Mostrando $shown de $total órdenes', style: AppTextStyles.bodySmallSecondary),
    );
  }
}
