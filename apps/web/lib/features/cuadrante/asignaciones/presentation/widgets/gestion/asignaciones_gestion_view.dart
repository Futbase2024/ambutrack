import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_state.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/asignacion_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/gestion/asignaciones_catalogos.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/gestion/asignaciones_detail_panel.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/gestion/asignaciones_gestion_bars.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/gestion/asignaciones_gestion_columns.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/gestion/asignaciones_grid_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de asignaciones de vehículos a turnos con layout de programa de gestión
class AsignacionesGestionView extends StatefulWidget {
  const AsignacionesGestionView({super.key});

  @override
  State<AsignacionesGestionView> createState() => _AsignacionesGestionViewState();
}

class _AsignacionesGestionViewState extends State<AsignacionesGestionView> {
  final TextEditingController _searchController = TextEditingController();
  DateTime _fecha = DateTime.now();
  String _query = '';
  String? _estado;
  GestionSort _sort = const GestionSort(columnIndex: 1);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Borrado solicitado desde esta vista (id + texto para el aviso de éxito)
  String? _deletingId;
  String? _deletingNombre;
  AsignacionesCatalogos _catalogos = const AsignacionesCatalogos();

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<AsignacionVehiculoTurnoEntity>? _asignaciones;

  @override
  void initState() {
    super.initState();
    final AsignacionesBloc bloc = context.read<AsignacionesBloc>();
    final AsignacionesState state = bloc.state;
    if (state is AsignacionesLoaded) {
      _asignaciones = state.asignaciones;
    } else if (state is AsignacionesInitial) {
      bloc.add(AsignacionesLoadByFechaRequested(_fecha));
    }
    _loadCatalogos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogos() async {
    final AsignacionesCatalogos cat = await AsignacionesCatalogos.cargar();
    if (mounted) {
      setState(() => _catalogos = cat);
    }
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != null;

  AsignacionVehiculoTurnoEntity? get _selected {
    for (final AsignacionVehiculoTurnoEntity a in _asignaciones ?? const <AsignacionVehiculoTurnoEntity>[]) {
      if (a.id == _selectedId) {
        return a;
      }
    }
    return null;
  }

  List<AsignacionVehiculoTurnoEntity> _visibles(List<GestionColumn<AsignacionVehiculoTurnoEntity>> columns) =>
      _sort.apply(
        filtrarAsignaciones(
          _asignaciones ?? <AsignacionVehiculoTurnoEntity>[],
          _catalogos,
          query: _query,
          estado: _estado,
        ),
        columns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = null;
      });

  void _loadFecha(DateTime fecha) {
    _updateFilters(() {
      _fecha = fecha;
      _selectedId = null;
    });
    context.read<AsignacionesBloc>().add(AsignacionesLoadByFechaRequested(fecha));
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _fecha && mounted) {
      _loadFecha(picked);
    }
  }

  void _refresh() {
    context.read<AsignacionesBloc>().add(AsignacionesLoadByFechaRequested(_fecha));
    _loadCatalogos();
  }

  /// El formulario devuelve la asignación al cerrarse con "Guardar"
  Future<void> _openForm([AsignacionVehiculoTurnoEntity? asignacion]) async {
    final AsignacionesBloc bloc = context.read<AsignacionesBloc>();
    final AsignacionVehiculoTurnoEntity? result = await showDialog<AsignacionVehiculoTurnoEntity>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<AsignacionesBloc>.value(
        value: bloc,
        child: AsignacionFormDialog(asignacion: asignacion),
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() => _fecha = result.fecha);
    bloc.add(asignacion == null ? AsignacionCreateRequested(result) : AsignacionUpdateRequested(result));
  }

  Future<void> _confirmDelete(AsignacionVehiculoTurnoEntity a) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar asignación',
      message: '¿Estás seguro de que deseas eliminar esta asignación? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Fecha': GestionFormatters.fecha(a.fecha),
        'Vehículo': _catalogos.vehiculo(a),
        'Dotación': _catalogos.dotacion(a),
        'Estado': asignacionEstadoLabel(a.estado),
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando asignación: ${a.id}');
      setState(() {
        _selectedId = null;
        _deletingId = a.id;
        _deletingNombre = '${_catalogos.vehiculo(a)} — ${GestionFormatters.fecha(a.fecha)}';
      });
      context.read<AsignacionesBloc>().add(AsignacionDeleteRequested(a.id));
    }
  }

  void _onStateChanged(BuildContext context, AsignacionesState state) {
    if (state is AsignacionesLoaded) {
      final String? deletingId = _deletingId;
      final bool eliminado = deletingId != null &&
          !state.asignaciones.any((AsignacionVehiculoTurnoEntity a) => a.id == deletingId);
      final String? nombre = _deletingNombre;
      setState(() {
        _asignaciones = state.asignaciones;
        if (eliminado) {
          _deletingId = null;
          _deletingNombre = null;
        }
      });
      if (eliminado) {
        GestionFeedback.eliminado(context, entidad: 'Asignación', nombre: nombre);
      }
    } else if (state is AsignacionesError && _asignaciones != null) {
      _deletingId = null;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en asignaciones',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AsignacionesBloc, AsignacionesState>(
      listener: _onStateChanged,
      builder: (BuildContext context, AsignacionesState state) {
        final List<GestionColumn<AsignacionVehiculoTurnoEntity>> columns = asignacionesGestionColumns(_catalogos);
        final List<AsignacionVehiculoTurnoEntity> visibles = _visibles(columns);
        final AsignacionVehiculoTurnoEntity? selected = _selected;
        return GestionLayout(
          toolbar: AsignacionesGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirAsignaciones(visibles, _catalogos, _fecha),
          ),
          filterBar: AsignacionesGestionFilters(
            fecha: _fecha,
            onMoveDays: (int d) => _loadFecha(_fecha.add(Duration(days: d))),
            onToday: () => _loadFecha(DateTime.now()),
            onPickDate: _pickDate,
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (String? v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: AsignacionesGridContent(
            state: state,
            hasData: _asignaciones != null,
            columns: columns,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (AsignacionVehiculoTurnoEntity a) => setState(() => _selectedId = a.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: AsignacionesDetailPanel(
            asignacion: selected,
            catalogos: _catalogos,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenAsignaciones(_asignaciones ?? <AsignacionVehiculoTurnoEntity>[], visibles.length),
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

  List<AsignacionVehiculoTurnoEntity> _pageOf(List<AsignacionVehiculoTurnoEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
