import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_state.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/widgets/categoria_vehiculo_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/widgets/gestion/categoria_vehiculo_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/widgets/gestion/categoria_vehiculo_gestion_bars.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/widgets/gestion/categoria_vehiculo_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de categorías de vehículo con layout de programa de gestión
class CategoriaVehiculoGestionView extends StatefulWidget {
  const CategoriaVehiculoGestionView({super.key});

  @override
  State<CategoriaVehiculoGestionView> createState() => _CategoriaVehiculoGestionViewState();
}

class _CategoriaVehiculoGestionViewState extends State<CategoriaVehiculoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  CategoriaVehiculoEstadoFiltro _estado = CategoriaVehiculoEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Operación lanzada desde esta vista (eliminar/actualizar) pendiente de resultado
  bool _awaitingResult = false;

  /// Nombre del registro cuyo borrado se ha lanzado desde esta vista
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<CategoriaVehiculoEntity>? _categorias;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != CategoriaVehiculoEstadoFiltro.todos;

  CategoriaVehiculoEntity? get _selected {
    for (final CategoriaVehiculoEntity c in _categorias ?? const <CategoriaVehiculoEntity>[]) {
      if (c.id == _selectedId) {
        return c;
      }
    }
    return null;
  }

  List<CategoriaVehiculoEntity> get _visibles => _sort.apply(
        filtrarCategoriasVehiculo(
          _categorias ?? <CategoriaVehiculoEntity>[],
          query: _query,
          estado: _estado,
        ),
        categoriaVehiculoGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = CategoriaVehiculoEstadoFiltro.todos;
      });

  void _refresh() {
    _awaitingResult = true;
    context.read<CategoriaVehiculoBloc>().add(const CategoriaVehiculoLoadAllRequested());
  }

  Future<void> _openForm([CategoriaVehiculoEntity? categoria]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<CategoriaVehiculoBloc>.value(
        value: context.read<CategoriaVehiculoBloc>(),
        child: CategoriaVehiculoFormDialog(categoriaVehiculo: categoria),
      ),
    );
  }

  Future<void> _confirmDelete(CategoriaVehiculoEntity categoria) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar categoría de vehículo',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': categoria.nombre,
        'Descripción': GestionFormatters.texto(categoria.descripcion),
        'Estado': categoria.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _awaitingResult = true;
        _deletingNombre = categoria.nombre;
      });
      context.read<CategoriaVehiculoBloc>().add(CategoriaVehiculoDeleteRequested(categoria.id));
    }
  }

  void _onStateChanged(BuildContext context, CategoriaVehiculoState state) {
    if (state is CategoriaVehiculoLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _categorias = state.categorias;
        _awaitingResult = false;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Categoría', nombre: eliminado);
      }
    } else if (state is CategoriaVehiculoError && _categorias != null && _awaitingResult) {
      _awaitingResult = false;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en categorías de vehículo',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoriaVehiculoBloc, CategoriaVehiculoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, CategoriaVehiculoState state) {
        final List<CategoriaVehiculoEntity> visibles = _visibles;
        final CategoriaVehiculoEntity? selected = _selected;
        return GestionLayout(
          toolbar: CategoriaVehiculoGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirCategoriasVehiculo(visibles),
          ),
          filterBar: CategoriaVehiculoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (CategoriaVehiculoEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _CategoriaVehiculoGridContent(
            state: state,
            hasData: _categorias != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (CategoriaVehiculoEntity c) => setState(() => _selectedId = c.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: CategoriaVehiculoDetailPanel(
            categoria: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenCategoriasVehiculo(_categorias ?? <CategoriaVehiculoEntity>[], visibles.length),
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

  List<CategoriaVehiculoEntity> _pageOf(List<CategoriaVehiculoEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _CategoriaVehiculoGridContent extends StatelessWidget {
  const _CategoriaVehiculoGridContent({
    required this.state,
    required this.hasData,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.hasFilters,
    required this.onSelect,
    required this.onActivate,
    required this.onSort,
    required this.onRetry,
  });

  final CategoriaVehiculoState state;
  final bool hasData;
  final List<CategoriaVehiculoEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<CategoriaVehiculoEntity> onSelect;
  final ValueChanged<CategoriaVehiculoEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final CategoriaVehiculoState s = state;
    if (!hasData && s is CategoriaVehiculoError) {
      return _CategoriaVehiculoLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<CategoriaVehiculoEntity>(
          columns: categoriaVehiculoGestionColumns,
          rows: rows,
          rowId: (CategoriaVehiculoEntity c) => c.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ninguna categoría coincide con los filtros'
              : 'No hay categorías registradas. Pulsa "Nuevo" para crear una.',
        ),
        if (s is CategoriaVehiculoLoading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}

class _CategoriaVehiculoLoadError extends StatelessWidget {
  const _CategoriaVehiculoLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 40, color: AppColors.error),
          const SizedBox(height: 8),
          const Text(
            'Error al cargar categorías de vehículo',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
          ),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(fontSize: 12.5, color: AppColors.gray600)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
