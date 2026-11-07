import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/bloc/especialidad_bloc.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/bloc/especialidad_event.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/bloc/especialidad_state.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/widgets/especialidad_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/widgets/gestion/especialidad_detail_panel.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/widgets/gestion/especialidad_gestion_bars.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/widgets/gestion/especialidad_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de especialidades médicas con layout de programa de gestión
class EspecialidadGestionView extends StatefulWidget {
  const EspecialidadGestionView({super.key});

  @override
  State<EspecialidadGestionView> createState() => _EspecialidadGestionViewState();
}

class _EspecialidadGestionViewState extends State<EspecialidadGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _tipo;
  EspecialidadEstadoFiltro _estado = EspecialidadEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Operación lanzada desde esta vista (eliminar/actualizar) pendiente de resultado
  bool _awaitingResult = false;

  /// Nombre del registro cuyo borrado se ha lanzado desde esta vista
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<EspecialidadEntity>? _especialidades;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _tipo != null || _estado != EspecialidadEstadoFiltro.todos;

  EspecialidadEntity? get _selected {
    for (final EspecialidadEntity c in _especialidades ?? const <EspecialidadEntity>[]) {
      if (c.id == _selectedId) {
        return c;
      }
    }
    return null;
  }

  List<EspecialidadEntity> get _visibles => _sort.apply(
        filtrarEspecialidades(
          _especialidades ?? <EspecialidadEntity>[],
          query: _query,
          tipo: _tipo,
          estado: _estado,
        ),
        especialidadGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _estado = EspecialidadEstadoFiltro.todos;
      });

  void _refresh() {
    _awaitingResult = true;
    context.read<EspecialidadBloc>().add(const EspecialidadLoadAllRequested());
  }

  Future<void> _openForm([EspecialidadEntity? especialidad]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<EspecialidadBloc>.value(
        value: context.read<EspecialidadBloc>(),
        child: EspecialidadFormDialog(especialidad: especialidad),
      ),
    );
  }

  Future<void> _confirmDelete(EspecialidadEntity especialidad) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar especialidad médica',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': especialidad.nombre,
        'Tipo': especialidadTipoLabel(especialidad.tipoEspecialidad),
        'Descripción': GestionFormatters.texto(especialidad.descripcion),
        'Estado': especialidad.activo ? 'Activa' : 'Inactiva',
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _awaitingResult = true;
        _deletingNombre = especialidad.nombre;
      });
      context.read<EspecialidadBloc>().add(EspecialidadDeleteRequested(especialidad.id));
    }
  }

  void _onStateChanged(BuildContext context, EspecialidadState state) {
    if (state is EspecialidadLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _especialidades = state.especialidades;
        _awaitingResult = false;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Especialidad', nombre: eliminado);
      }
    } else if (state is EspecialidadError && _especialidades != null && _awaitingResult) {
      _awaitingResult = false;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en especialidades médicas',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EspecialidadBloc, EspecialidadState>(
      listener: _onStateChanged,
      builder: (BuildContext context, EspecialidadState state) {
        final List<EspecialidadEntity> visibles = _visibles;
        final EspecialidadEntity? selected = _selected;
        return GestionLayout(
          toolbar: EspecialidadGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirEspecialidades(visibles),
          ),
          filterBar: EspecialidadGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipo: _tipo,
            onTipoChanged: (String? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (EspecialidadEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _EspecialidadGridContent(
            state: state,
            hasData: _especialidades != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (EspecialidadEntity c) => setState(() => _selectedId = c.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: EspecialidadDetailPanel(
            especialidad: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenEspecialidades(_especialidades ?? <EspecialidadEntity>[], visibles.length),
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

  List<EspecialidadEntity> _pageOf(List<EspecialidadEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _EspecialidadGridContent extends StatelessWidget {
  const _EspecialidadGridContent({
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

  final EspecialidadState state;
  final bool hasData;
  final List<EspecialidadEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<EspecialidadEntity> onSelect;
  final ValueChanged<EspecialidadEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final EspecialidadState s = state;
    if (!hasData && s is EspecialidadError) {
      return _EspecialidadLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<EspecialidadEntity>(
          columns: especialidadGestionColumns,
          rows: rows,
          rowId: (EspecialidadEntity c) => c.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ninguna especialidad coincide con los filtros'
              : 'No hay especialidades registradas. Pulsa "Nuevo" para crear una.',
        ),
        if (s is EspecialidadLoading ||
            s is EspecialidadCreating ||
            s is EspecialidadUpdating ||
            s is EspecialidadDeleting)
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

class _EspecialidadLoadError extends StatelessWidget {
  const _EspecialidadLoadError({required this.message, required this.onRetry});

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
            'Error al cargar especialidades médicas',
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
