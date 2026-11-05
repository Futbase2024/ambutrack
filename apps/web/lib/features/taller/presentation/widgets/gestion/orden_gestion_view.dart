import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/orden_detail_panel.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/orden_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/orden_gestion_filters.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de órdenes de reparación con layout de programa de gestión
class OrdenGestionView extends StatefulWidget {
  const OrdenGestionView({super.key});

  @override
  State<OrdenGestionView> createState() => _OrdenGestionViewState();
}

class _OrdenGestionViewState extends State<OrdenGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _estado = ordenFiltroTodas;
  PrioridadOrdenReparacion? _prioridad;
  GestionSort _sort = const GestionSort(columnIndex: 6, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Operación lanzada desde esta pantalla pendiente de resultado
  OrdenOperacion? _pendingOp;

  /// Identificador de la orden cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<OrdenReparacionEntity>? _ordenes;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != ordenFiltroTodas || _prioridad != null;

  OrdenReparacionEntity? get _selected {
    for (final OrdenReparacionEntity o in _ordenes ?? const <OrdenReparacionEntity>[]) {
      if (o.id == _selectedId) {
        return o;
      }
    }
    return null;
  }

  List<OrdenReparacionEntity> get _visibles => _sort.apply(
        filtrarOrdenes(
          _ordenes ?? <OrdenReparacionEntity>[],
          query: _query,
          estado: _estado,
          prioridad: _prioridad,
        ),
        ordenGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = ordenFiltroTodas;
        _prioridad = null;
      });

  void _refresh() => context.read<OrdenReparacionBloc>().add(const OrdenReparacionLoadRequested());

  Future<void> _openForm([OrdenReparacionEntity? orden]) => showOrdenFormDialog(context, orden: orden);

  Future<void> _openDetail(OrdenReparacionEntity orden) => showOrdenDetailDialog(context, orden);

  Future<void> _confirmDelete(OrdenReparacionEntity orden) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar orden de reparación',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nº Orden': orden.numeroOrden.isEmpty ? GestionFormatters.vacio : orden.numeroOrden,
        'Matrícula': GestionFormatters.texto(orden.vehiculoMatricula),
        'Taller': GestionFormatters.texto(orden.tallerNombre),
      },
      warningMessage: 'Se eliminarán también todos los repuestos de la orden.',
      icon: Icons.delete_forever,
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _pendingOp = OrdenOperacion.eliminar;
        _deletingNombre = orden.numeroOrden.isEmpty
            ? GestionFormatters.texto(orden.vehiculoMatricula)
            : 'Nº ${orden.numeroOrden}';
      });
      context.read<OrdenReparacionBloc>().add(OrdenReparacionDeleteRequested(id: orden.id));
    }
  }

  Future<void> _cambiarEstado(OrdenReparacionEntity orden, EstadoOrdenReparacion destino) async {
    if (destino == EstadoOrdenReparacion.anulada || destino == EstadoOrdenReparacion.cerrada) {
      final bool anular = destino == EstadoOrdenReparacion.anulada;
      final bool? ok = await showSimpleConfirmationDialog(
        context: context,
        title: anular ? 'Anular orden' : 'Cerrar orden',
        message: anular
            ? '¿Seguro que deseas anular esta orden?\n\nNo podrá modificarse después.'
            : '¿Seguro que deseas cerrar esta orden?\n\nLos repuestos y datos quedarán bloqueados.',
        confirmText: anular ? 'Anular' : 'Cerrar orden',
        icon: anular ? Icons.block : Icons.lock_outline,
        iconColor: anular ? AppColors.error : AppColors.secondaryDark,
        confirmButtonColor: anular ? AppColors.error : AppColors.secondaryDark,
      );
      if (ok != true || !mounted) {
        return;
      }
    }
    setState(() => _pendingOp = OrdenOperacion.cambiarEstado);
    context
        .read<OrdenReparacionBloc>()
        .add(OrdenReparacionEstadoChangeRequested(id: orden.id, estado: destino));
  }

  void _onStateChanged(BuildContext context, OrdenReparacionState state) {
    if (state is OrdenReparacionLoaded) {
      setState(() => _ordenes = state.ordenes);
    }
    final OrdenOperacion? pending = _pendingOp;
    if (state is OrdenReparacionOperationSuccess && state.operacion == pending) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _pendingOp = null;
        _deletingNombre = null;
      });
      if (pending == OrdenOperacion.eliminar) {
        GestionFeedback.eliminado(context, entidad: 'Orden de reparación', nombre: eliminado);
      }
    } else if (state is OrdenReparacionOperationFailure && state.operacion == pending) {
      setState(() {
        _pendingOp = null;
        _deletingNombre = null;
      });
      showResultDialog(
        context: context,
        title: pending == OrdenOperacion.eliminar ? 'Error al eliminar' : 'Error al cambiar estado',
        message: 'No se pudo completar la operación sobre la orden.',
        details: state.message,
        type: ResultType.error,
      );
    } else if (state is OrdenReparacionError && _ordenes != null) {
      showResultDialog(
        context: context,
        title: 'Error en órdenes',
        message: 'No se pudieron recargar las órdenes de reparación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdenReparacionBloc, OrdenReparacionState>(
      listener: _onStateChanged,
      builder: (BuildContext context, OrdenReparacionState state) {
        final List<OrdenReparacionEntity> visibles = _visibles;
        final OrdenReparacionEntity? selected = _selected;
        return GestionLayout(
          toolbar: TallerCrudToolbar(
            title: 'Órdenes de Reparación',
            icon: Icons.build,
            entityLabel: 'la orden',
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirOrdenes(visibles),
            extraActions: <GestionToolbarAction>[
              GestionToolbarAction(
                icon: Icons.open_in_new,
                label: 'Detalle',
                tooltip: 'Detalle completo: cambio de estado, costes y repuestos',
                onPressed: selected == null ? null : () => _openDetail(selected),
              ),
            ],
          ),
          filterBar: OrdenGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (String v) => _updateFilters(() => _estado = v),
            prioridad: _prioridad,
            onPrioridadChanged: (PrioridadOrdenReparacion? v) => _updateFilters(() => _prioridad = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: TallerGestionGridContent<OrdenReparacionEntity>(
            hasData: _ordenes != null,
            isLoading: state is OrdenReparacionLoading || _pendingOp != null,
            errorTitle: 'Error al cargar órdenes',
            errorMessage: state is OrdenReparacionError ? state.message : null,
            columns: ordenGestionColumns,
            rows: tallerPageOf(visibles, _page, _pageSize),
            rowId: (OrdenReparacionEntity o) => o.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            emptyMessage: _hasFilters
                ? 'Ninguna orden coincide con los filtros'
                : 'No hay órdenes de reparación. Pulsa "Nuevo" para crear una.',
            onSelect: (OrdenReparacionEntity o) => setState(() => _selectedId = o.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: OrdenDetailPanel(
            orden: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onCambiarEstado: (EstadoOrdenReparacion destino) => _cambiarEstado(selected!, destino),
            onVerDetalle: () => _openDetail(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenOrdenes(_ordenes ?? <OrdenReparacionEntity>[], visibles),
            pagination: GestionPagination(
              page: _page,
              pageSize: _pageSize,
              totalItems: visibles.length,
              onPageChanged: (int p) => setState(() => _page = p),
              onPageSizeChanged: (int s) => _updateFilters(() => _pageSize = s),
            ),
          ),
        );
      },
    );
  }
}
