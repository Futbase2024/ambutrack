import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/control_repuestos_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/control_repuestos_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/control_repuestos_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/repuestos/control_repuestos_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/repuestos/control_repuestos_detail_panel.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/repuestos/control_repuestos_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const String _rutaOrdenes = '/taller/ordenes-reparacion';
const String _rutaProveedores = '/taller/proveedores';

/// Pantalla de consulta de todos los repuestos de las órdenes de reparación
class ControlRepuestosView extends StatefulWidget {
  const ControlRepuestosView({super.key});

  @override
  State<ControlRepuestosView> createState() => _ControlRepuestosViewState();
}

class _ControlRepuestosViewState extends State<ControlRepuestosView> {
  final TextEditingController _searchController = TextEditingController();
  ControlRepuestosFiltro _filtro = const ControlRepuestosFiltro();
  GestionSort _sort = const GestionSort(columnIndex: 9, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<RepuestoControlItem>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RepuestoControlItem> get _todos => _items ?? <RepuestoControlItem>[];

  List<RepuestoControlItem> get _visibles =>
      _sort.apply(_todos.where(_filtro.matches).toList(), controlRepuestosColumns);

  RepuestoControlItem? get _selected {
    for (final RepuestoControlItem i in _todos) {
      if (i.id == _selectedId) {
        return i;
      }
    }
    return null;
  }

  void _setFiltro(ControlRepuestosFiltro f) => setState(() {
        _filtro = f;
        _page = 0;
      });

  void _clearFilters() {
    _searchController.clear();
    _setFiltro(const ControlRepuestosFiltro());
  }

  void _refresh() => context.read<ControlRepuestosBloc>().add(const ControlRepuestosLoadRequested());

  void _onStateChanged(BuildContext context, ControlRepuestosState state) {
    if (state is ControlRepuestosLoaded) {
      setState(() => _items = state.items);
    } else if (state is ControlRepuestosError && _items != null) {
      showResultDialog(
        context: context,
        title: 'Error en repuestos',
        message: 'No se pudo recargar el listado de repuestos.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ControlRepuestosBloc, ControlRepuestosState>(
      listener: _onStateChanged,
      builder: (BuildContext context, ControlRepuestosState state) {
        final List<RepuestoControlItem> visibles = _visibles;
        return GestionLayout(
          toolbar: TallerConsultaToolbar(
            title: 'Control de Repuestos',
            icon: Icons.inventory_2_outlined,
            onRefresh: _refresh,
            onPrint: visibles.isEmpty
                ? null
                : () => imprimirControlRepuestos(visibles, subtitle: tallerRangoTexto(_filtro.rango)),
            extraActions: <GestionToolbarAction>[
              GestionToolbarAction(
                icon: Icons.build_outlined,
                label: 'Órdenes',
                tooltip: 'Ir a la gestión de órdenes de reparación',
                onPressed: () => context.go(_rutaOrdenes),
              ),
              GestionToolbarAction(
                icon: Icons.local_shipping_outlined,
                label: 'Proveedores',
                tooltip: 'Ir a la gestión de proveedores del taller',
                onPressed: () => context.go(_rutaProveedores),
              ),
            ],
          ),
          filterBar: ControlRepuestosFilters(
            searchController: _searchController,
            filtro: _filtro,
            proveedores: tallerOpcionesDe(_todos.map((RepuestoControlItem i) => i.repuesto.proveedorNombre)),
            vehiculos: tallerOpcionesDe(_todos.map((RepuestoControlItem i) => i.vehiculoMatricula)),
            onChanged: _setFiltro,
            onClear: _filtro.activo ? _clearFilters : null,
          ),
          content: TallerGestionGridContent<RepuestoControlItem>(
            hasData: _items != null,
            isLoading: state is ControlRepuestosLoading,
            errorTitle: 'Error al cargar repuestos',
            errorMessage: state is ControlRepuestosError ? state.message : null,
            columns: controlRepuestosColumns,
            rows: tallerPageOf(visibles, _page, _pageSize),
            rowId: (RepuestoControlItem i) => i.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            emptyMessage: _filtro.activo
                ? 'Ningún repuesto coincide con los filtros'
                : 'No hay repuestos registrados en las órdenes de reparación',
            onSelect: (RepuestoControlItem i) => setState(() => _selectedId = i.id),
            onActivate: (RepuestoControlItem i) => setState(() => _selectedId = i.id),
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: ControlRepuestosDetailPanel(
            item: _selected,
            onVerOrdenes: () => context.go(_rutaOrdenes),
          ),
          statusBar: GestionStatusBar(
            items: resumenControlRepuestos(_todos, visibles),
            pagination: GestionPagination(
              page: _page,
              pageSize: _pageSize,
              totalItems: visibles.length,
              onPageChanged: (int p) => setState(() => _page = p),
              onPageSizeChanged: (int s) => setState(() {
                _pageSize = s;
                _page = 0;
              }),
            ),
          ),
        );
      },
    );
  }
}
