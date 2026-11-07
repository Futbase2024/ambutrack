import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_event.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_state.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_bars.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_columns.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_detail_panel.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_estado.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_view_actions.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de equipamiento (dotación de plantilla + extras) de un vehículo
class EquipamientoVehiculoView extends StatefulWidget {
  const EquipamientoVehiculoView({required this.vehiculoId, super.key});

  final String vehiculoId;

  @override
  State<EquipamientoVehiculoView> createState() => _EquipamientoVehiculoViewState();
}

class _EquipamientoVehiculoViewState extends State<EquipamientoVehiculoView>
    with EquipamientoViewActions<EquipamientoVehiculoView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  EquipamientoVista _vista = EquipamientoVista.todos;
  String? _seccion;
  EstadoDotacion? _estado;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _vista != EquipamientoVista.todos || _seccion != null || _estado != null;

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _vista = EquipamientoVista.todos;
        _seccion = null;
        _estado = null;
      });

  void _refresh() =>
      context.read<EquipamientoVehiculoBloc>().add(EquipamientoVehiculoLoadRequested(widget.vehiculoId));

  StockVehiculoEntity? _selectedIn(List<StockVehiculoEntity> lineas) {
    for (final StockVehiculoEntity l in lineas) {
      if (l.id == _selectedId) {
        return l;
      }
    }
    return null;
  }

  String _titulo(BuildContext context) {
    final VehiculosState vState = context.watch<VehiculosBloc>().state;
    if (vState is VehiculosLoaded) {
      for (final VehiculoEntity v in vState.vehiculos) {
        if (v.id == widget.vehiculoId) {
          return 'Equipamiento · ${v.matricula} (${v.tipoVehiculo})';
        }
      }
    }
    return 'Equipamiento del vehículo';
  }

  @override
  Widget build(BuildContext context) {
    final String titulo = _titulo(context);
    return BlocConsumer<EquipamientoVehiculoBloc, EquipamientoVehiculoState>(
      listenWhen: (EquipamientoVehiculoState a, EquipamientoVehiculoState b) => a.operacion != b.operacion,
      listener: onResultado,
      builder: (BuildContext context, EquipamientoVehiculoState state) {
        final List<StockVehiculoEntity> visibles = _sort.apply(
          filtrarEquipamiento(state.lineas, query: _query, seccion: _seccion, estado: _estado, vista: _vista),
          equipamientoColumns,
        );
        final StockVehiculoEntity? selected = _selectedIn(state.lineas);
        final EquipamientoAcciones acciones = accionesPara(selected);
        final bool ocupado = state.status == EquipamientoStatus.loading || state.saving;
        return GestionLayout(
          toolbar: EquipamientoToolbar(
            title: titulo,
            loading: ocupado,
            puedeGestionar: puedeGestionar,
            onEditar: ocupado ? null : acciones.onRegistrar,
            onAdjuntar: ocupado ? null : acciones.onAdjuntar,
            onAddExtra: () => abrirExtra(state.lineas),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimir(visibles, titulo),
            onClose: () => context.goNamed('vehiculos'),
          ),
          filterBar: EquipamientoFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            vista: _vista,
            onVistaChanged: (EquipamientoVista v) => _updateFilters(() => _vista = v),
            secciones: seccionesEquipamiento(state.lineas),
            seccion: _seccion,
            onSeccionChanged: (String? v) => _updateFilters(() => _seccion = v),
            estado: _estado,
            onEstadoChanged: (EstadoDotacion? v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: FlotaGridArea(
            hasData: state.hasData,
            loading: state.status == EquipamientoStatus.loading,
            errorMessage: state.status == EquipamientoStatus.failure ? state.error : null,
            errorTitle: 'Error al cargar el equipamiento',
            onRetry: _refresh,
            child: GestionGrid<StockVehiculoEntity>(
              columns: equipamientoColumns,
              rows: flotaPageOf(visibles, _page, _pageSize),
              rowId: (StockVehiculoEntity l) => l.id,
              selectedId: _selectedId,
              onSelect: (StockVehiculoEntity l) => setState(() => _selectedId = l.id),
              onActivate: (StockVehiculoEntity l) => accionesPara(l).onRegistrar?.call(),
              sort: _sort,
              onSort: (GestionSort s) => setState(() => _sort = s),
              firstRowNumber: _page * _pageSize + 1,
              emptyMessage: _hasFilters
                  ? 'Ningún item coincide con los filtros'
                  : 'Este vehículo no tiene plantilla de equipamiento asignada para su tipo.',
            ),
          ),
          detailPanel: EquipamientoDetailPanel(linea: selected, acciones: acciones),
          statusBar: GestionStatusBar(
            items: resumenEquipamiento(state.lineas, visibles.length),
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
