import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_state.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/widgets/gestion/tipo_vehiculo_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/widgets/gestion/tipo_vehiculo_gestion_bars.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/widgets/gestion/tipo_vehiculo_gestion_columns.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/widgets/tipo_vehiculo_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de tipos de vehículo con layout de programa de gestión
class TipoVehiculoGestionView extends StatefulWidget {
  const TipoVehiculoGestionView({super.key});

  @override
  State<TipoVehiculoGestionView> createState() => _TipoVehiculoGestionViewState();
}

class _TipoVehiculoGestionViewState extends State<TipoVehiculoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  TipoVehiculoEstadoFiltro _estado = TipoVehiculoEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Operación lanzada desde esta vista (eliminar/actualizar) pendiente de resultado
  bool _awaitingResult = false;

  /// Nombre del tipo cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<TipoVehiculoEntity>? _tipos;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != TipoVehiculoEstadoFiltro.todos;

  TipoVehiculoEntity? get _selected {
    for (final TipoVehiculoEntity c in _tipos ?? const <TipoVehiculoEntity>[]) {
      if (c.id == _selectedId) {
        return c;
      }
    }
    return null;
  }

  List<TipoVehiculoEntity> get _visibles => _sort.apply(
        filtrarTiposVehiculo(
          _tipos ?? <TipoVehiculoEntity>[],
          query: _query,
          estado: _estado,
        ),
        tipoVehiculoGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = TipoVehiculoEstadoFiltro.todos;
      });

  void _refresh() {
    _awaitingResult = true;
    context.read<TipoVehiculoBloc>().add(const TipoVehiculoLoadAllRequested());
  }

  Future<void> _openForm([TipoVehiculoEntity? tipo]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<TipoVehiculoBloc>.value(
        value: context.read<TipoVehiculoBloc>(),
        child: TipoVehiculoFormDialog(tipoVehiculo: tipo),
      ),
    );
  }

  Future<void> _confirmDelete(TipoVehiculoEntity tipo) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar tipo de vehículo',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': tipo.nombre,
        'Descripción': GestionFormatters.texto(tipo.descripcion),
        'Estado': tipo.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _awaitingResult = true;
        _deletingNombre = tipo.nombre;
      });
      context.read<TipoVehiculoBloc>().add(TipoVehiculoDeleteRequested(tipo.id));
    }
  }

  void _onStateChanged(BuildContext context, TipoVehiculoState state) {
    if (state is TipoVehiculoDeleted) {
      final String? eliminado = _deletingNombre;
      if (eliminado != null) {
        _deletingNombre = null;
        GestionFeedback.eliminado(context, entidad: 'Tipo de vehículo', nombre: eliminado);
      }
    } else if (state is TipoVehiculoLoaded) {
      setState(() {
        _tipos = state.tiposVehiculo;
        _awaitingResult = false;
      });
    } else if (state is TipoVehiculoError && _tipos != null && _awaitingResult) {
      _awaitingResult = false;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en tipos de vehículo',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TipoVehiculoBloc, TipoVehiculoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, TipoVehiculoState state) {
        final List<TipoVehiculoEntity> visibles = _visibles;
        final TipoVehiculoEntity? selected = _selected;
        return GestionLayout(
          toolbar: TipoVehiculoGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirTiposVehiculo(visibles),
          ),
          filterBar: TipoVehiculoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (TipoVehiculoEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _TipoVehiculoGridContent(
            state: state,
            hasData: _tipos != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (TipoVehiculoEntity c) => setState(() => _selectedId = c.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: TipoVehiculoDetailPanel(
            tipo: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenTiposVehiculo(_tipos ?? <TipoVehiculoEntity>[], visibles.length),
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

  List<TipoVehiculoEntity> _pageOf(List<TipoVehiculoEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _TipoVehiculoGridContent extends StatelessWidget {
  const _TipoVehiculoGridContent({
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

  final TipoVehiculoState state;
  final bool hasData;
  final List<TipoVehiculoEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<TipoVehiculoEntity> onSelect;
  final ValueChanged<TipoVehiculoEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final TipoVehiculoState s = state;
    if (!hasData && s is TipoVehiculoError) {
      return _TipoVehiculoLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<TipoVehiculoEntity>(
          columns: tipoVehiculoGestionColumns,
          rows: rows,
          rowId: (TipoVehiculoEntity c) => c.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún tipo coincide con los filtros'
              : 'No hay tipos registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (s is TipoVehiculoLoading ||
            s is TipoVehiculoCreating ||
            s is TipoVehiculoUpdating ||
            s is TipoVehiculoDeleting)
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

class _TipoVehiculoLoadError extends StatelessWidget {
  const _TipoVehiculoLoadError({required this.message, required this.onRetry});

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
            'Error al cargar tipos de vehículo',
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
