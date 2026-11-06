import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_event.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_state.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantilla_bars.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantilla_item_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantilla_items_columns.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantillas_view_actions.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tabla maestra de plantillas de equipamiento por tipo de vehículo
class PlantillasEquipamientoView extends StatefulWidget {
  const PlantillasEquipamientoView({super.key});

  @override
  State<PlantillasEquipamientoView> createState() => _PlantillasEquipamientoViewState();
}

class _PlantillasEquipamientoViewState extends State<PlantillasEquipamientoView>
    with PlantillasViewActions<PlantillasEquipamientoView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _seccion;
  TipoItemEquipamiento? _tipo;
  ItemEstadoFiltro _estado = ItemEstadoFiltro.activos;
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
      _query.isNotEmpty || _seccion != null || _tipo != null || _estado != ItemEstadoFiltro.activos;

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _seccion = null;
        _tipo = null;
        _estado = ItemEstadoFiltro.activos;
      });

  void _selectPlantilla(String? id) {
    if (id == null) {
      return;
    }
    _updateFilters(() {
      _selectedId = null;
      _seccion = null;
    });
    context.read<PlantillasEquipamientoBloc>().add(PlantillaSelected(id));
  }

  PlantillaEquipamientoItemEntity? _selectedIn(List<PlantillaEquipamientoItemEntity> items) {
    for (final PlantillaEquipamientoItemEntity i in items) {
      if (i.id == _selectedId) {
        return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlantillasEquipamientoBloc, PlantillasEquipamientoState>(
      listenWhen: (PlantillasEquipamientoState a, PlantillasEquipamientoState b) => a.operacion != b.operacion,
      listener: onResultado,
      builder: (BuildContext context, PlantillasEquipamientoState state) {
        final PlantillaEquipamientoEntity? plantilla = state.plantilla;
        final List<PlantillaEquipamientoItemEntity> visibles = _sort.apply(
          filtrarItems(state.items, query: _query, seccion: _seccion, tipo: _tipo, estado: _estado),
          plantillaItemsColumns,
        );
        final PlantillaEquipamientoItemEntity? item = _selectedIn(state.items);
        final bool ocupado = state.status == PlantillasStatus.loading || state.saving || state.cargandoItems;
        return GestionLayout(
          toolbar: PlantillaToolbar(
            loading: ocupado,
            itemActivo: item?.activo ?? true,
            actions: PlantillaToolbarActions(
              onNuevaPlantilla: abrirPlantilla,
              onRefresh: () => context.read<PlantillasEquipamientoBloc>().add(const PlantillasLoadRequested()),
              onEditarPlantilla: plantilla == null ? null : () => abrirPlantilla(plantilla),
              onNuevoItem: plantilla == null ? null : () => abrirItem(state),
              onEditarItem: item == null ? null : () => abrirItem(state, item),
              onToggleItem: item == null ? null : () => toggleItem(item),
              onReaplicar: plantilla == null ? null : () => reaplicar(plantilla),
              onPrint: visibles.isEmpty ? null : () => imprimirItems(visibles, plantilla?.nombre ?? 'Plantilla'),
            ),
          ),
          filterBar: PlantillaFilters(
            plantillas: state.plantillas,
            plantillaId: state.plantillaId,
            onPlantillaChanged: _selectPlantilla,
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            secciones: seccionesPlantilla(state.items).keys.toList(),
            seccion: _seccion,
            onSeccionChanged: (String? v) => _updateFilters(() => _seccion = v),
            tipo: _tipo,
            onTipoChanged: (TipoItemEquipamiento? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (ItemEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: FlotaGridArea(
            hasData: state.status == PlantillasStatus.loaded || state.plantillas.isNotEmpty,
            loading: state.status == PlantillasStatus.loading || state.cargandoItems,
            errorMessage: state.status == PlantillasStatus.failure ? state.error : null,
            errorTitle: 'Error al cargar plantillas',
            onRetry: () => context.read<PlantillasEquipamientoBloc>().add(const PlantillasLoadRequested()),
            child: GestionGrid<PlantillaEquipamientoItemEntity>(
              columns: plantillaItemsColumns,
              rows: flotaPageOf(visibles, _page, _pageSize),
              rowId: (PlantillaEquipamientoItemEntity i) => i.id,
              selectedId: _selectedId,
              onSelect: (PlantillaEquipamientoItemEntity i) => setState(() => _selectedId = i.id),
              onActivate: (PlantillaEquipamientoItemEntity i) => abrirItem(state, i),
              sort: _sort,
              onSort: (GestionSort s) => setState(() => _sort = s),
              firstRowNumber: _page * _pageSize + 1,
              emptyMessage: plantilla == null
                  ? 'No hay plantillas. Pulsa "Nueva plantilla".'
                  : (_hasFilters ? 'Ningún item coincide con los filtros' : 'Plantilla sin items. Pulsa "Nuevo item".'),
            ),
          ),
          detailPanel: PlantillaItemDetailPanel(
            item: item,
            plantilla: plantilla,
            onEdit: item == null ? null : () => abrirItem(state, item),
            onDelete: item == null ? null : () => eliminarItem(item),
          ),
          statusBar: GestionStatusBar(
            items: resumenItems(state.items, visibles.length),
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
