import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/proveedor_taller_detail_panel.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/proveedor_taller_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/proveedor_taller_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de proveedores de taller con layout de programa de gestión
class ProveedorTallerGestionView extends StatefulWidget {
  const ProveedorTallerGestionView({super.key});

  @override
  State<ProveedorTallerGestionView> createState() => _ProveedorTallerGestionViewState();
}

class _ProveedorTallerGestionViewState extends State<ProveedorTallerGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  TipoProveedor? _tipo;
  TallerEstadoFiltro _estado = TallerEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Nombre del proveedor cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<ProveedorTallerEntity>? _proveedores;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _tipo != null || _estado != TallerEstadoFiltro.todos;

  ProveedorTallerEntity? get _selected {
    for (final ProveedorTallerEntity p in _proveedores ?? const <ProveedorTallerEntity>[]) {
      if (p.id == _selectedId) {
        return p;
      }
    }
    return null;
  }

  List<ProveedorTallerEntity> get _visibles => _sort.apply(
        filtrarProveedoresTaller(
          _proveedores ?? <ProveedorTallerEntity>[],
          query: _query,
          tipo: _tipo,
          estado: _estado,
        ),
        proveedorTallerGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _estado = TallerEstadoFiltro.todos;
      });

  void _refresh() => context.read<ProveedorTallerBloc>().add(const ProveedorTallerLoadRequested());

  Future<void> _openForm([ProveedorTallerEntity? proveedor]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<ProveedorTallerBloc>.value(
        value: context.read<ProveedorTallerBloc>(),
        child: ProveedorTallerFormDialog(proveedor: proveedor),
      ),
    );
  }

  Future<void> _confirmDelete(ProveedorTallerEntity proveedor) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar proveedor',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': proveedor.nombre,
        'Tipo': proveedor.tipo.displayName,
        'Ciudad': GestionFormatters.texto(proveedor.ciudad),
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingNombre = proveedor.nombre;
      });
      context.read<ProveedorTallerBloc>().add(ProveedorTallerDeleteRequested(id: proveedor.id));
    }
  }

  void _onStateChanged(BuildContext context, ProveedorTallerState state) {
    if (state is ProveedorTallerLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _proveedores = state.proveedores;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Proveedor', nombre: eliminado);
      }
    } else if (state is ProveedorTallerError) {
      _deletingNombre = null;
      if (_proveedores == null) {
        return;
      }
      showResultDialog(
        context: context,
        title: 'Error en proveedores',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProveedorTallerBloc, ProveedorTallerState>(
      listener: _onStateChanged,
      builder: (BuildContext context, ProveedorTallerState state) {
        final List<ProveedorTallerEntity> visibles = _visibles;
        final ProveedorTallerEntity? selected = _selected;
        return GestionLayout(
          toolbar: TallerCrudToolbar(
            title: 'Proveedores',
            icon: Icons.local_shipping,
            entityLabel: 'el proveedor',
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirProveedoresTaller(visibles),
          ),
          filterBar: _ProveedorTallerFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipo: _tipo,
            onTipoChanged: (TipoProveedor? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (TallerEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: TallerGestionGridContent<ProveedorTallerEntity>(
            hasData: _proveedores != null,
            isLoading: state is ProveedorTallerLoading,
            errorTitle: 'Error al cargar proveedores',
            errorMessage: state is ProveedorTallerError ? state.message : null,
            columns: proveedorTallerGestionColumns,
            rows: tallerPageOf(visibles, _page, _pageSize),
            rowId: (ProveedorTallerEntity p) => p.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            emptyMessage: _hasFilters
                ? 'Ningún proveedor coincide con los filtros'
                : 'No hay proveedores registrados. Pulsa "Nuevo" para crear uno.',
            onSelect: (ProveedorTallerEntity p) => setState(() => _selectedId = p.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: ProveedorTallerDetailPanel(
            proveedor: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenProveedoresTaller(_proveedores ?? <ProveedorTallerEntity>[], visibles.length),
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

/// Barra de filtros de proveedores de taller
class _ProveedorTallerFilters extends StatelessWidget {
  const _ProveedorTallerFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipo,
    required this.onTipoChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final TipoProveedor? tipo;
  final ValueChanged<TipoProveedor?> onTipoChanged;
  final TallerEstadoFiltro estado;
  final ValueChanged<TallerEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre, ciudad, teléfono, contacto...',
        ),
        GestionFilterDropdown<TipoProveedor?>(
          label: 'Tipo',
          value: tipo,
          options: <TipoProveedor?, String>{
            null: 'Todos',
            for (final TipoProveedor t in TipoProveedor.values) t: t.displayName,
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<TallerEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <TallerEstadoFiltro, String>{
            TallerEstadoFiltro.todos: 'Todos',
            TallerEstadoFiltro.activos: 'Activos',
            TallerEstadoFiltro.inactivos: 'Inactivos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
