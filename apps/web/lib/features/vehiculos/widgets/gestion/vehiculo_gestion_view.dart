import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/vehiculo_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_detail_panel.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_bars.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de vehículos con layout de programa de gestión:
/// barra de herramientas + filtros + rejilla + ficha lateral + barra de estado
class VehiculoGestionView extends StatefulWidget {
  const VehiculoGestionView({super.key});

  @override
  State<VehiculoGestionView> createState() => _VehiculoGestionViewState();
}

class _VehiculoGestionViewState extends State<VehiculoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  VehiculoEstado? _estado;
  String? _tipo;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Vehículo cuyo borrado está en curso (para el aviso de éxito)
  VehiculoEntity? _deleting;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<VehiculoEntity>? _vehiculos;

  @override
  void initState() {
    super.initState();
    final VehiculosState state = context.read<VehiculosBloc>().state;
    if (state is VehiculosLoaded) {
      _vehiculos = state.vehiculos;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != null || _tipo != null;

  VehiculoEntity? get _selected {
    for (final VehiculoEntity v in _vehiculos ?? const <VehiculoEntity>[]) {
      if (v.id == _selectedId) {
        return v;
      }
    }
    return null;
  }

  List<VehiculoEntity> get _visibles => _sort.apply(
        filtrarVehiculos(_vehiculos ?? <VehiculoEntity>[], query: _query, estado: _estado, tipo: _tipo),
        vehiculoGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = null;
        _tipo = null;
      });

  void _refresh() {
    context.read<VehiculosBloc>().add(const VehiculosLoadRequested());
    context.read<ItvRevisionBloc>().add(const ItvRevisionLoadRequested());
    context.read<DocumentacionVehiculosBloc>().add(const DocumentacionVehiculosLoadRequested());
    context.read<OrdenReparacionBloc>().add(const OrdenReparacionLoadRequested(silent: true));
    context.read<StockEquipamientoBloc>().add(const StockEquipamientoRefreshRequested());
  }

  Future<void> _openForm([VehiculoEntity? vehiculo]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<VehiculosBloc>.value(
        value: context.read<VehiculosBloc>(),
        child: VehiculoFormDialog(vehiculo: vehiculo),
      ),
    );
  }

  /// Abre la pantalla de stock del vehículo (antigua acción "Ver" de la tabla)
  void _openStock(VehiculoEntity vehiculo) {
    context.goNamed(
      'flota_stock_vehiculo',
      pathParameters: <String, String>{'vehiculoId': vehiculo.id},
    );
  }

  Future<void> _confirmDelete(VehiculoEntity vehiculo) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar vehículo',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Matrícula': vehiculo.matricula,
        'Marca': vehiculo.marca,
        'Modelo': vehiculo.modelo,
        if (vehiculo.numeroBastidor.isNotEmpty) 'Bastidor': vehiculo.numeroBastidor,
        'Estado': vehiculoEstadoLabel(vehiculo.estado),
        'Tipo': vehiculo.tipoVehiculo,
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deleting = vehiculo;
      });
      context.read<VehiculosBloc>().add(VehiculoDeleteRequested(vehiculoId: vehiculo.id));
    }
  }

  void _onStateChanged(BuildContext context, VehiculosState state) {
    if (state is VehiculosLoaded) {
      final VehiculoEntity? eliminado = _deleting;
      // El stream en tiempo real puede emitir antes de que el borrado se refleje
      final bool borrado =
          eliminado != null && !state.vehiculos.any((VehiculoEntity v) => v.id == eliminado.id);
      setState(() {
        _vehiculos = state.vehiculos;
        if (borrado) {
          _deleting = null;
        }
      });
      if (borrado) {
        GestionFeedback.eliminado(context, entidad: 'Vehículo', nombre: eliminado.matricula);
      }
    } else if (state is VehiculosError) {
      _deleting = null;
      if (_vehiculos == null) {
        return;
      }
      showResultDialog(
        context: context,
        title: 'Error en vehículos',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VehiculosBloc, VehiculosState>(
      listener: _onStateChanged,
      builder: (BuildContext context, VehiculosState state) {
        final List<VehiculoEntity> visibles = _visibles;
        final VehiculoEntity? selected = _selected;
        return GestionLayout(
          toolbar: VehiculoGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirVehiculos(visibles),
            onStock: () => _openStock(selected!),
          ),
          filterBar: VehiculoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (VehiculoEstado? v) => _updateFilters(() => _estado = v),
            tipo: _tipo,
            onTipoChanged: (String? v) => _updateFilters(() => _tipo = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: FlotaGridArea(
            hasData: _vehiculos != null,
            loading: state is VehiculosLoading,
            errorMessage: state is VehiculosError ? state.message : null,
            errorTitle: 'Error al cargar vehículos',
            onRetry: _refresh,
            child: GestionGrid<VehiculoEntity>(
              columns: vehiculoGestionColumns,
              rows: flotaPageOf(visibles, _page, _pageSize),
              rowId: (VehiculoEntity v) => v.id,
              selectedId: _selectedId,
              onSelect: (VehiculoEntity v) => setState(() => _selectedId = v.id),
              onActivate: _openForm,
              sort: _sort,
              onSort: (GestionSort s) => setState(() => _sort = s),
              firstRowNumber: _page * _pageSize + 1,
              emptyMessage: _hasFilters
                  ? 'Ningún vehículo coincide con los filtros'
                  : 'No hay vehículos registrados. Pulsa "Nuevo" para crear uno.',
            ),
          ),
          detailPanel: VehiculoDetailPanel(
            vehiculo: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onStock: () => _openStock(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenVehiculos(_vehiculos ?? <VehiculoEntity>[], visibles.length),
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
