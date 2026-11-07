import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/gestion/mantenimiento_detail_panel.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/gestion/mantenimiento_gestion_bars.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/gestion/mantenimiento_gestion_columns.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimiento_edit_dialog.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimiento_form_dialog.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimiento_view_dialog.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de Mantenimiento Preventivo con layout de programa de gestión
class MantenimientoGestionView extends StatefulWidget {
  const MantenimientoGestionView({super.key});

  @override
  State<MantenimientoGestionView> createState() => _MantenimientoGestionViewState();
}

class _MantenimientoGestionViewState extends State<MantenimientoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  TipoMantenimiento? _tipo;
  EstadoMantenimiento? _estado;
  GestionSort _sort = const GestionSort(columnIndex: 1, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Registro cuyo borrado se ha solicitado desde esta vista (para el aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<MantenimientoEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _tipo != null || _estado != null;

  MantenimientoEntity? get _selected {
    for (final MantenimientoEntity m in _items ?? const <MantenimientoEntity>[]) {
      if (m.id == _selectedId) {
        return m;
      }
    }
    return null;
  }

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _estado = null;
      });

  void _refresh() {
    context.read<MantenimientoBloc>().add(const MantenimientoLoadRequested());
    context.read<VehiculosBloc>().add(const VehiculosRefreshRequested());
  }

  Future<void> _openDialog(Widget dialog) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VehiculosBloc>.value(value: context.read<VehiculosBloc>()),
          BlocProvider<MantenimientoBloc>.value(value: context.read<MantenimientoBloc>()),
          BlocProvider<TallerBloc>.value(value: context.read<TallerBloc>()),
        ],
        child: dialog,
      ),
    );
  }

  Future<void> _openNew() => _openDialog(const MantenimientoFormDialog());

  Future<void> _openEdit(MantenimientoEntity item) => _openDialog(MantenimientoEditDialog(mantenimiento: item));

  Future<void> _openView(MantenimientoEntity item) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) => MantenimientoViewDialog(mantenimiento: item),
    );
  }

  Future<void> _confirmDelete(MantenimientoEntity item, Map<String, VehiculoEntity> vehiculos) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar mantenimiento',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Vehículo': mantMatricula(item, vehiculos),
        'Tipo': item.tipoMantenimiento.displayName,
        'Fecha': GestionFormatters.fecha(mantFechaRef(item)),
        'Descripción': GestionFormatters.texto(item.descripcion),
        'Coste': GestionFormatters.moneda(item.costoTotal),
        'Estado': mantEstadoLabel(item),
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingNombre = '${mantMatricula(item, vehiculos)} — ${GestionFormatters.fecha(mantFechaRef(item))}';
      });
      context.read<MantenimientoBloc>().add(MantenimientoDeleteRequested(id: item.id));
    }
  }

  void _onStateChanged(BuildContext context, MantenimientoState state) {
    if (state is MantenimientoLoaded) {
      setState(() => _items = state.mantenimientos);
      if (_deletingNombre != null) {
        final String eliminado = _deletingNombre!;
        setState(() => _deletingNombre = null);
        GestionFeedback.eliminado(context, entidad: 'Mantenimiento', nombre: eliminado);
      }
    } else if (state is MantenimientoError && _items != null) {
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en Mantenimiento Preventivo',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final VehiculosState vState = context.watch<VehiculosBloc>().state;
    final Map<String, VehiculoEntity> vehiculos = <String, VehiculoEntity>{
      if (vState is VehiculosLoaded)
        for (final VehiculoEntity v in vState.vehiculos) v.id: v,
    };
    final List<GestionColumn<MantenimientoEntity>> columns = mantGestionColumns(vehiculos);
    return BlocConsumer<MantenimientoBloc, MantenimientoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, MantenimientoState state) {
        final List<MantenimientoEntity> todos = _items ?? <MantenimientoEntity>[];
        final List<MantenimientoEntity> visibles = _sort.apply(
          filtrarMantenimientos(todos, vehiculos: vehiculos, query: _query, tipo: _tipo, estado: _estado),
          columns,
        );
        final MantenimientoEntity? selected = _selected;
        return GestionLayout(
          toolbar: MantenimientoGestionToolbar(
            hasSelection: selected != null,
            onNew: _openNew,
            onEdit: () => _openEdit(selected!),
            onDelete: () => _confirmDelete(selected!, vehiculos),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirMantenimientos(visibles, vehiculos),
            onView: () => _openView(selected!),
          ),
          filterBar: MantenimientoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipo: _tipo,
            onTipoChanged: (TipoMantenimiento? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (EstadoMantenimiento? v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: FlotaGridArea(
            hasData: _items != null,
            loading: state is MantenimientoLoading,
            errorMessage: state is MantenimientoError ? state.message : null,
            errorTitle: 'Error al cargar mantenimientos',
            onRetry: _refresh,
            child: GestionGrid<MantenimientoEntity>(
              columns: columns,
              rows: flotaPageOf(visibles, _page, _pageSize),
              rowId: (MantenimientoEntity m) => m.id,
              selectedId: _selectedId,
              onSelect: (MantenimientoEntity m) => setState(() => _selectedId = m.id),
              onActivate: _openEdit,
              sort: _sort,
              onSort: (GestionSort s) => setState(() => _sort = s),
              firstRowNumber: _page * _pageSize + 1,
              emptyMessage: _hasFilters
                  ? 'Ningún mantenimiento coincide con los filtros'
                  : 'No hay mantenimientos registrados. Pulsa "Nuevo" para programar uno.',
            ),
          ),
          detailPanel: MantenimientoDetailPanel(
            item: selected,
            todos: todos,
            vehiculos: vehiculos,
            onEdit: () => _openEdit(selected!),
            onDelete: () => _confirmDelete(selected!, vehiculos),
          ),
          statusBar: GestionStatusBar(
            items: resumenMantenimientos(todos, visibles.length),
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
