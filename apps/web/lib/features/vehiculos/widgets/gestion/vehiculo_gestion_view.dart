import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/export/gestion_report_grid.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/vehiculo_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/export/vehiculo_export_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/export/vehiculo_export_options.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_detail_panel.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_bars.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_bulk_bar.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_edicion.dart';
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

class _VehiculoGestionViewState extends State<VehiculoGestionView> with VehiculoEdicionMixin<VehiculoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  /// Registro abierto desde la búsqueda global (Ctrl+K): solo se muestra ese
  String? _soloId;
  String? _enlaceAplicado;

  /// Filtros por columna (estilo Excel, varios valores por columna)
  GestionColumnFilters _colFilters = const GestionColumnFilters();

  /// Columnas con edición en línea (solo se activa en modo edición)
  late final List<GestionColumn<VehiculoEntity>> _columns = buildVehiculoGestionColumns(onEdit: guardarCambio);
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GestionDeepLink enlace = GestionDeepLink.of(context);
    if (enlace.isEmpty || enlace.clave == _enlaceAplicado) {
      return;
    }
    _enlaceAplicado = enlace.clave;
    _soloId = enlace.id;
    _selectedId = enlace.id;
    _query = '';
    _searchController.text = enlace.texto ?? '';
    _page = 0;
  }

  List<VehiculoEntity> _filtrarEnlace(List<VehiculoEntity> items) =>
      _soloId == null ? items : items.where((VehiculoEntity e) => e.id == _soloId).toList();

  bool get _hasFilters => _soloId != null || _query.isNotEmpty || !_colFilters.isEmpty;

  VehiculoEntity? get _selected {
    for (final VehiculoEntity v in _vehiculos ?? const <VehiculoEntity>[]) {
      if (v.id == _selectedId) {
        return v;
      }
    }
    return null;
  }

  /// Vehículos con búsqueda aplicada (base de los valores de los filtros de columna)
  List<VehiculoEntity> get _base => filtrarVehiculos(_filtrarEnlace(_vehiculos ?? <VehiculoEntity>[]), query: _query);

  List<VehiculoEntity> get _visibles => _sort.apply(_colFilters.apply(_base, _columns), _columns);

  @override
  List<VehiculoEntity> get vehiculosVisibles => _visibles;

  @override
  void aplicarLocal(List<VehiculoEntity> actualizados) {
    final Map<String, VehiculoEntity> porId = <String, VehiculoEntity>{
      for (final VehiculoEntity v in actualizados) v.id: v,
    };
    setState(() {
      _vehiculos = _vehiculos?.map((VehiculoEntity v) => porId[v.id] ?? v).toList();
    });
  }

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _soloId = null;
        _query = '';
        _colFilters = const GestionColumnFilters();
      });

  void _onColumnFiltersChanged(GestionColumnFilters f) => _updateFilters(() {
        _soloId = null;
        _colFilters = f;
      });

  void _refresh() {
    context.read<VehiculosBloc>().add(const VehiculosLoadRequested());
    context.read<ItvRevisionBloc>().add(const ItvRevisionLoadRequested());
    context.read<DocumentacionVehiculosBloc>().add(const DocumentacionVehiculosLoadRequested());
    context.read<OrdenReparacionBloc>().add(const OrdenReparacionLoadRequested(silent: true));
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

  /// Descripción de los filtros activos para la cabecera de los informes
  String get _filtrosTexto {
    final List<String> partes = <String>[
      if (_query.trim().isNotEmpty) 'Búsqueda "${_query.trim()}"',
      ..._colFilters.describe(vehiculoGestionColumns),
    ];
    final String? orden = gestionSortDescription(_sort, vehiculoGestionColumns);
    final String filtros = partes.isEmpty ? 'Todos los vehículos' : 'Filtros: ${partes.join(' · ')}';
    return orden == null ? filtros : '$filtros · $orden';
  }

  Future<void> _openExport({VehiculoExportAlcance? alcance}) {
    return showVehiculoExportDialog(
      context,
      vehiculos: _visibles,
      seleccionado: _selected,
      filtros: _filtrosTexto,
      alcance: alcance,
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
      if (editando) {
        // Un cambio en línea ha fallado: se recargan los datos reales
        context.read<VehiculosBloc>().add(const VehiculosRefreshRequested());
      }
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
            onExport: visibles.isEmpty && selected == null ? null : _openExport,
            onStock: () => _openStock(selected!),
            editing: editando,
            onToggleEditing: toggleEdicion,
          ),
          filterBar: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              VehiculoGestionFilters(
                searchController: _searchController,
                onSearchChanged: (String v) => _updateFilters(() {
                  _soloId = null;
                  _query = v;
                }),
                columnFilters: _colFilters,
                onColumnFiltersChanged: _onColumnFiltersChanged,
                onClear: _hasFilters ? _clearFilters : null,
              ),
              if (editando)
                VehiculoBulkEditBar(
                  count: marcadosVisibles.length,
                  onEstado: cambiarEstadoEnBloque,
                  onCap: (bool v) => cambiarCapEnBloque(valor: v),
                  onSilla: (bool v) => cambiarSillaEnBloque(valor: v),
                  onCarros: cambiarCarrosEnBloque,
                  onSoporte: (bool v) => cambiarSoporteEnBloque(valor: v),
                  onClear: () => setState(() => marcados = <String>{}),
                ),
            ],
          ),
          content: FlotaGridArea(
            hasData: _vehiculos != null,
            loading: state is VehiculosLoading,
            errorMessage: state is VehiculosError ? state.message : null,
            errorTitle: 'Error al cargar vehículos',
            onRetry: _refresh,
            child: GestionGrid<VehiculoEntity>(
              columns: _columns,
              rows: flotaPageOf(visibles, _page, _pageSize),
              filters: _colFilters,
              onFiltersChanged: _onColumnFiltersChanged,
              filterSource: _base,
              editing: editando,
              checkedIds: editando ? marcados : null,
              onCheckedChanged: (Set<String> ids) => setState(() => marcados = ids),
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
            onExport: () => _openExport(alcance: VehiculoExportAlcance.ficha),
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
