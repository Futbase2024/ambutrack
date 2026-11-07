import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_state.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/gestion/plantilla_detail_panel.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/gestion/plantilla_gestion_bars.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/gestion/plantilla_gestion_columns.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/plantilla_turno_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de plantillas de turnos con layout de programa de gestión
class PlantillaGestionView extends StatefulWidget {
  const PlantillaGestionView({super.key});

  @override
  State<PlantillaGestionView> createState() => _PlantillaGestionViewState();
}

class _PlantillaGestionViewState extends State<PlantillaGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  TipoTurno? _tipo;
  PlantillaEstadoFiltro _estado = PlantillaEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Nombre de la plantilla cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<PlantillaTurnoEntity>? _plantillas;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _tipo != null || _estado != PlantillaEstadoFiltro.todos;

  PlantillaTurnoEntity? get _selected {
    for (final PlantillaTurnoEntity p in _plantillas ?? const <PlantillaTurnoEntity>[]) {
      if (p.id == _selectedId) {
        return p;
      }
    }
    return null;
  }

  List<PlantillaTurnoEntity> get _visibles => _sort.apply(
        filtrarPlantillas(_plantillas ?? <PlantillaTurnoEntity>[], query: _query, tipo: _tipo, estado: _estado),
        plantillaGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _estado = PlantillaEstadoFiltro.todos;
      });

  void _refresh() => context.read<PlantillasTurnosBloc>().add(const PlantillasTurnosRefreshRequested());

  Future<void> _openForm([PlantillaTurnoEntity? plantilla]) {
    final PlantillasTurnosBloc bloc = context.read<PlantillasTurnosBloc>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => PlantillaTurnoFormDialog(
        plantilla: plantilla,
        onSave: (PlantillaTurnoEntity p) => bloc.add(
          plantilla == null ? PlantillaTurnoCreateRequested(p) : PlantillaTurnoUpdateRequested(p),
        ),
      ),
    );
  }

  void _duplicate(PlantillaTurnoEntity plantilla) =>
      context.read<PlantillasTurnosBloc>().add(PlantillaTurnoDuplicateRequested(plantilla.id));

  Future<void> _confirmDelete(PlantillaTurnoEntity plantilla) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar plantilla',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': plantilla.nombre,
        if (plantilla.descripcion?.trim().isNotEmpty ?? false) 'Descripción': plantilla.descripcion!,
        'Tipo': plantilla.tipoTurno.nombre,
        'Horario': plantillaHorario(plantilla),
        'Estado': plantilla.activo ? 'Activa' : 'Inactiva',
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingNombre = plantilla.nombre;
      });
      context.read<PlantillasTurnosBloc>().add(PlantillaTurnoDeleteRequested(plantilla.id));
    }
  }

  void _onStateChanged(BuildContext context, PlantillasTurnosState state) {
    if (state is PlantillasTurnosLoaded) {
      setState(() => _plantillas = state.plantillas);
    } else if (state is PlantillaTurnoDeleted) {
      final String? eliminado = _deletingNombre;
      if (eliminado != null) {
        setState(() => _deletingNombre = null);
        GestionFeedback.eliminado(context, entidad: 'Plantilla de turno', nombre: eliminado);
      }
    } else if (state is PlantillaTurnoDuplicated) {
      setState(() => _selectedId = state.plantilla.id);
    } else if (state is PlantillasTurnosError) {
      _deletingNombre = null;
      if (_plantillas == null) {
        return;
      }
      showResultDialog(
        context: context,
        title: 'Error en plantillas de turnos',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlantillasTurnosBloc, PlantillasTurnosState>(
      listener: _onStateChanged,
      builder: (BuildContext context, PlantillasTurnosState state) {
        final List<PlantillaTurnoEntity> visibles = _visibles;
        final PlantillaTurnoEntity? selected = _selected;
        return GestionLayout(
          toolbar: PlantillaGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onDuplicate: () => _duplicate(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirPlantillas(visibles),
          ),
          filterBar: PlantillaGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipo: _tipo,
            onTipoChanged: (TipoTurno? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (PlantillaEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _PlantillaGridContent(
            state: state,
            hasData: _plantillas != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (PlantillaTurnoEntity p) => setState(() => _selectedId = p.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: PlantillaDetailPanel(
            plantilla: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenPlantillas(_plantillas ?? <PlantillaTurnoEntity>[], visibles.length),
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

  List<PlantillaTurnoEntity> _pageOf(List<PlantillaTurnoEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _PlantillaGridContent extends StatelessWidget {
  const _PlantillaGridContent({
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

  final PlantillasTurnosState state;
  final bool hasData;
  final List<PlantillaTurnoEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<PlantillaTurnoEntity> onSelect;
  final ValueChanged<PlantillaTurnoEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final PlantillasTurnosState s = state;
    if (!hasData && s is PlantillasTurnosError) {
      return _PlantillaLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<PlantillaTurnoEntity>(
          columns: plantillaGestionColumns,
          rows: rows,
          rowId: (PlantillaTurnoEntity p) => p.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ninguna plantilla coincide con los filtros'
              : 'No hay plantillas registradas. Pulsa "Nuevo" para crear una.',
        ),
        if (s is PlantillasTurnosLoading)
          const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

class _PlantillaLoadError extends StatelessWidget {
  const _PlantillaLoadError({required this.message, required this.onRetry});

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
            'Error al cargar plantillas',
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
