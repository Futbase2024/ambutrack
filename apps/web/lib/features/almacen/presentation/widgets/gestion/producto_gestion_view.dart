import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/producto_detail_panel.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/producto_gestion_columns.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/producto_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de productos del almacén con layout de programa de gestión
class ProductoGestionView extends StatefulWidget {
  const ProductoGestionView({super.key});

  @override
  State<ProductoGestionView> createState() => _ProductoGestionViewState();
}

class _ProductoGestionViewState extends State<ProductoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  CategoriaProducto? _categoria;
  AlmacenEstadoFiltro _estado = AlmacenEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 1);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  /// Nombre del producto cuyo borrado se ha solicitado desde esta vista
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<ProductoEntity>? _productos;

  /// Nombre comercial de cada proveedor (para el proveedor habitual)
  Map<String, String> _proveedores = <String, String>{};

  @override
  void initState() {
    super.initState();
    final ProductoBloc bloc = context.read<ProductoBloc>();
    if (bloc.state is ProductoInitial) {
      bloc.add(const ProductoLoadAllRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _categoria != null || _estado != AlmacenEstadoFiltro.todos;

  ProductoEntity? get _selected {
    for (final ProductoEntity p in _productos ?? const <ProductoEntity>[]) {
      if (p.id == _selectedId) {
        return p;
      }
    }
    return null;
  }

  List<ProductoEntity> get _visibles => _sort.apply(
        filtrarProductos(
          _productos ?? <ProductoEntity>[],
          query: _query,
          categoria: _categoria,
          estado: _estado,
        ),
        productoGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _categoria = null;
        _estado = AlmacenEstadoFiltro.todos;
      });

  void _refresh() {
    context.read<ProductoBloc>().add(const ProductoLoadAllRequested());
    context.read<ProveedoresBloc>().add(const ProveedoresLoadRequested());
  }

  Future<void> _openForm([ProductoEntity? producto]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<ProductoBloc>.value(
        value: context.read<ProductoBloc>(),
        child: ProductoFormDialog(producto: producto),
      ),
    );
  }

  Future<void> _confirmDelete(ProductoEntity producto) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar producto',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Código': GestionFormatters.texto(producto.codigo),
        'Nombre': producto.nombre,
        'Nombre comercial': GestionFormatters.texto(producto.nombreComercial),
        'Categoría': producto.categoria?.label ?? GestionFormatters.vacio,
        'Estado': producto.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando producto: ${producto.nombre} (${producto.id})');
      setState(() {
        _selectedId = null;
        _deletingNombre = producto.nombre;
      });
      context.read<ProductoBloc>().add(ProductoDeleteRequested(producto.id));
    }
  }

  void _onStateChanged(BuildContext context, ProductoState state) {
    if (state is ProductoLoaded) {
      setState(() => _productos = state.productos);
    } else if (state is ProductoOperationSuccess && _deletingNombre != null) {
      final String eliminado = _deletingNombre!;
      setState(() => _deletingNombre = null);
      GestionFeedback.eliminado(context, entidad: 'Producto', nombre: eliminado);
    } else if (state is ProductoError && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error al eliminar',
        message: 'No se pudo eliminar el producto.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  void _onProveedoresChanged(BuildContext context, ProveedoresState state) {
    if (state is ProveedoresLoaded) {
      setState(() {
        _proveedores = <String, String>{
          for (final ProveedorEntity p in state.proveedores) p.id: p.nombreComercial,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProveedoresBloc, ProveedoresState>(
      listener: _onProveedoresChanged,
      child: BlocConsumer<ProductoBloc, ProductoState>(
        listener: _onStateChanged,
        builder: (BuildContext context, ProductoState state) {
          final List<ProductoEntity> visibles = _visibles;
          final ProductoEntity? selected = _selected;
          return GestionLayout(
            toolbar: AlmacenCrudToolbar(
              title: 'Productos',
              icon: Icons.inventory_2_outlined,
              entityLabel: 'el producto',
              hasSelection: selected != null,
              onNew: _openForm,
              onEdit: () => _openForm(selected),
              onDelete: () => _confirmDelete(selected!),
              onRefresh: _refresh,
              onPrint: visibles.isEmpty ? null : () => imprimirProductos(visibles),
            ),
            filterBar: _ProductoFilters(
              searchController: _searchController,
              onSearchChanged: (String v) => _updateFilters(() => _query = v),
              categoria: _categoria,
              onCategoriaChanged: (CategoriaProducto? v) => _updateFilters(() => _categoria = v),
              estado: _estado,
              onEstadoChanged: (AlmacenEstadoFiltro v) => _updateFilters(() => _estado = v),
              onClear: _hasFilters ? _clearFilters : null,
            ),
            content: AlmacenGestionGridContent<ProductoEntity>(
              hasData: _productos != null,
              isLoading: state is ProductoLoading || state is ProductoOperationInProgress,
              errorTitle: 'Error al cargar productos',
              errorMessage: state is ProductoError ? state.message : null,
              columns: productoGestionColumns,
              rows: almacenPageOf(visibles, _page, _pageSize),
              rowId: (ProductoEntity p) => p.id,
              firstRowNumber: _page * _pageSize + 1,
              selectedId: _selectedId,
              sort: _sort,
              emptyMessage: _hasFilters
                  ? 'Ningún producto coincide con los filtros'
                  : 'No hay productos registrados. Pulsa "Nuevo" para crear uno.',
              onSelect: (ProductoEntity p) => setState(() => _selectedId = p.id),
              onActivate: _openForm,
              onSort: (GestionSort s) => setState(() => _sort = s),
              onRetry: _refresh,
            ),
            detailPanel: ProductoDetailPanel(
              producto: selected,
              proveedorHabitual: _proveedores[selected?.proveedorHabitualId],
              onEdit: () => _openForm(selected),
              onDelete: () => _confirmDelete(selected!),
            ),
            statusBar: GestionStatusBar(
              items: resumenProductos(_productos ?? <ProductoEntity>[], visibles.length),
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
      ),
    );
  }
}

/// Barra de filtros de productos
class _ProductoFilters extends StatelessWidget {
  const _ProductoFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.categoria,
    required this.onCategoriaChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final CategoriaProducto? categoria;
  final ValueChanged<CategoriaProducto?> onCategoriaChanged;
  final AlmacenEstadoFiltro estado;
  final ValueChanged<AlmacenEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar código, nombre, nombre comercial...',
        ),
        GestionFilterDropdown<CategoriaProducto?>(
          label: 'Categoría',
          value: categoria,
          options: <CategoriaProducto?, String>{
            null: 'Todas',
            for (final CategoriaProducto c in CategoriaProducto.values) c: c.label,
          },
          onChanged: onCategoriaChanged,
        ),
        GestionFilterDropdown<AlmacenEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: almacenEstadoFiltroOptions,
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
