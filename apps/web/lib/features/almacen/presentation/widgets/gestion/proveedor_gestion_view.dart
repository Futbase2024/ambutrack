import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/proveedor_detail_panel.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/proveedor_gestion_columns.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/proveedor_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de proveedores del almacén con layout de programa de gestión
class ProveedorGestionView extends StatefulWidget {
  const ProveedorGestionView({super.key});

  @override
  State<ProveedorGestionView> createState() => _ProveedorGestionViewState();
}

class _ProveedorGestionViewState extends State<ProveedorGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  AlmacenEstadoFiltro _estado = AlmacenEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 1);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  /// Nombre del proveedor cuyo borrado se ha solicitado desde esta vista
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<ProveedorEntity>? _proveedores;

  @override
  void initState() {
    super.initState();
    final ProveedoresBloc bloc = context.read<ProveedoresBloc>();
    if (bloc.state is ProveedoresInitial) {
      bloc.add(const ProveedoresLoadRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != AlmacenEstadoFiltro.todos;

  ProveedorEntity? get _selected {
    for (final ProveedorEntity p in _proveedores ?? const <ProveedorEntity>[]) {
      if (p.id == _selectedId) {
        return p;
      }
    }
    return null;
  }

  List<ProveedorEntity> get _visibles => _sort.apply(
        filtrarProveedores(_proveedores ?? <ProveedorEntity>[], query: _query, estado: _estado),
        proveedorGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = AlmacenEstadoFiltro.todos;
      });

  void _refresh() {
    context.read<ProveedoresBloc>().add(const ProveedoresLoadRequested());
    context.read<ProductoBloc>().add(const ProductoLoadAllRequested());
  }

  Future<void> _openForm([ProveedorEntity? proveedor]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<ProveedoresBloc>.value(
        value: context.read<ProveedoresBloc>(),
        child: ProveedorFormDialog(proveedor: proveedor),
      ),
    );
  }

  Future<void> _confirmDelete(ProveedorEntity proveedor) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar proveedor',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Código': GestionFormatters.texto(proveedor.codigo),
        'Nombre comercial': proveedor.nombreComercial,
        'Razón social': GestionFormatters.texto(proveedor.razonSocial),
        'CIF/NIF': GestionFormatters.texto(proveedor.cifNif),
        'Estado': proveedor.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando proveedor: ${proveedor.nombreComercial} (${proveedor.id})');
      setState(() {
        _selectedId = null;
        _deletingNombre = proveedor.nombreComercial;
      });
      context.read<ProveedoresBloc>().add(ProveedorDeleteRequested(proveedor.id));
    }
  }

  void _onStateChanged(BuildContext context, ProveedoresState state) {
    if (state is ProveedoresLoaded) {
      setState(() => _proveedores = state.proveedores);
    } else if (state is ProveedoresOperationSuccess && _deletingNombre != null) {
      final String eliminado = _deletingNombre!;
      setState(() => _deletingNombre = null);
      GestionFeedback.eliminado(context, entidad: 'Proveedor', nombre: eliminado);
    } else if (state is ProveedoresError && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error al eliminar',
        message: 'No se pudo eliminar el proveedor.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProveedoresBloc, ProveedoresState>(
      listener: _onStateChanged,
      builder: (BuildContext context, ProveedoresState state) {
        final List<ProveedorEntity> visibles = _visibles;
        final ProveedorEntity? selected = _selected;
        return GestionLayout(
          toolbar: AlmacenCrudToolbar(
            title: 'Proveedores',
            icon: Icons.business_outlined,
            entityLabel: 'el proveedor',
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirProveedores(visibles),
          ),
          filterBar: GestionFilterBar(
            children: <Widget>[
              GestionSearchField(
                controller: _searchController,
                onChanged: (String v) => _updateFilters(() => _query = v),
                hint: 'Buscar código, nombre, CIF, email, teléfono...',
              ),
              GestionFilterDropdown<AlmacenEstadoFiltro>(
                label: 'Estado',
                value: _estado,
                options: almacenEstadoFiltroOptions,
                onChanged: (AlmacenEstadoFiltro v) => _updateFilters(() => _estado = v),
              ),
              GestionClearFiltersButton(onPressed: _hasFilters ? _clearFilters : null),
            ],
          ),
          content: AlmacenGestionGridContent<ProveedorEntity>(
            hasData: _proveedores != null,
            isLoading: state is ProveedoresLoading || state is ProveedoresOperationInProgress,
            errorTitle: 'Error al cargar proveedores',
            errorMessage: state is ProveedoresError ? state.message : null,
            columns: proveedorGestionColumns,
            rows: almacenPageOf(visibles, _page, _pageSize),
            rowId: (ProveedorEntity p) => p.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            emptyMessage: _hasFilters
                ? 'Ningún proveedor coincide con los filtros'
                : 'No hay proveedores registrados. Pulsa "Nuevo" para crear uno.',
            onSelect: (ProveedorEntity p) => setState(() => _selectedId = p.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: ProveedorDetailPanel(
            proveedor: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenProveedores(_proveedores ?? <ProveedorEntity>[], visibles.length),
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
