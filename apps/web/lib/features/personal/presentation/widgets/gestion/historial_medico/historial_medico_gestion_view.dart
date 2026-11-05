import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/historial_medico/historial_medico_detail_panel.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/historial_medico/historial_medico_gestion_bars.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/historial_medico/historial_medico_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/historial_medico_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de historial médico con layout de programa de gestión
class HistorialMedicoGestionView extends StatefulWidget {
  const HistorialMedicoGestionView({super.key});

  @override
  State<HistorialMedicoGestionView> createState() => _HistorialMedicoGestionViewState();
}

class _HistorialMedicoGestionViewState extends State<HistorialMedicoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _aptitud;
  VigenciaReconocimiento? _vigencia;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<HistorialMedicoEntity>? _items;

  /// Nombres del personal por ID
  final Map<String, String> _nombres = <String, String>{};

  @override
  void initState() {
    super.initState();
    _cargarPersonal();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarPersonal() async {
    try {
      final List<PersonalEntity> personal = await getIt<PersonalRepository>().getAll();
      if (mounted) {
        setState(() {
          for (final PersonalEntity p in personal) {
            _nombres[p.id] = p.nombreCompleto;
          }
        });
      }
    } catch (e) {
      debugPrint('⚠️ HistorialMedico: error al cargar personal para lookup: $e');
    }
  }

  String _nombre(String personalId) => _nombres[personalId] ?? 'Desconocido';

  bool get _hasFilters => _query.isNotEmpty || _aptitud != null || _vigencia != null;

  HistorialMedicoEntity? get _selected {
    for (final HistorialMedicoEntity h in _items ?? const <HistorialMedicoEntity>[]) {
      if (h.id == _selectedId) {
        return h;
      }
    }
    return null;
  }

  List<HistorialMedicoEntity> _visibles(List<GestionColumn<HistorialMedicoEntity>> columns) {
    return _sort.apply(
      filtrarHistorialMedico(
        _items ?? <HistorialMedicoEntity>[],
        query: _query,
        aptitud: _aptitud,
        vigencia: _vigencia,
        nombre: _nombre,
      ),
      columns,
    );
  }

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _aptitud = null;
        _vigencia = null;
      });

  void _refresh() {
    context.read<HistorialMedicoBloc>().add(const HistorialMedicoLoadRequested());
    _cargarPersonal();
  }

  Future<void> _openForm([HistorialMedicoEntity? item]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<HistorialMedicoBloc>.value(
        value: context.read<HistorialMedicoBloc>(),
        child: HistorialMedicoFormDialog(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(HistorialMedicoEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar reconocimiento médico',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Personal': _nombre(item.personalId),
        'Fecha Reconocimiento': GestionFormatters.fecha(item.fechaReconocimiento),
        'Fecha Caducidad': GestionFormatters.fecha(item.fechaCaducidad),
        'Aptitud': aptitudLabel(item.aptitud),
        'Centro Médico': GestionFormatters.texto(item.centroMedico),
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando reconocimiento médico: ${item.id}');
      setState(() {
        _selectedId = null;
        _deletingNombre = '${_nombre(item.personalId)} — ${GestionFormatters.fecha(item.fechaReconocimiento)}';
      });
      context.read<HistorialMedicoBloc>().add(HistorialMedicoDeleteRequested(item.id));
    }
  }

  void _onStateChanged(BuildContext context, HistorialMedicoState state) {
    if (state is HistorialMedicoLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _items = state.items;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Reconocimiento médico', nombre: eliminado);
      }
    } else if (state is HistorialMedicoError && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error en historial médico',
        message: 'No se pudo eliminar el reconocimiento médico.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HistorialMedicoBloc, HistorialMedicoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, HistorialMedicoState state) {
        final List<GestionColumn<HistorialMedicoEntity>> columns = historialMedicoColumns(_nombre);
        final List<HistorialMedicoEntity> visibles = _visibles(columns);
        final HistorialMedicoEntity? selected = _selected;
        return GestionLayout(
          toolbar: HistorialMedicoGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirHistorialMedico(visibles, _nombre),
          ),
          filterBar: HistorialMedicoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            aptitud: _aptitud,
            onAptitudChanged: (String? v) => _updateFilters(() => _aptitud = v),
            vigencia: _vigencia,
            onVigenciaChanged: (VigenciaReconocimiento? v) => _updateFilters(() => _vigencia = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: _HistorialGridContent(
            state: state,
            hasData: _items != null,
            columns: columns,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (HistorialMedicoEntity h) => setState(() => _selectedId = h.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: HistorialMedicoDetailPanel(
            item: selected,
            todos: _items ?? const <HistorialMedicoEntity>[],
            nombre: _nombre,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenHistorialMedico(_items ?? <HistorialMedicoEntity>[], visibles.length),
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

  List<HistorialMedicoEntity> _pageOf(List<HistorialMedicoEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}

/// Contenido central: carga inicial, error o rejilla
class _HistorialGridContent extends StatelessWidget {
  const _HistorialGridContent({
    required this.state,
    required this.hasData,
    required this.columns,
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

  final HistorialMedicoState state;
  final bool hasData;
  final List<GestionColumn<HistorialMedicoEntity>> columns;
  final List<HistorialMedicoEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<HistorialMedicoEntity> onSelect;
  final ValueChanged<HistorialMedicoEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final HistorialMedicoState s = state;
    if (!hasData && s is HistorialMedicoError) {
      return _HistorialLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<HistorialMedicoEntity>(
          columns: columns,
          rows: rows,
          rowId: (HistorialMedicoEntity h) => h.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún reconocimiento coincide con los filtros'
              : 'No hay reconocimientos médicos registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (s is HistorialMedicoLoading)
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

class _HistorialLoadError extends StatelessWidget {
  const _HistorialLoadError({required this.message, required this.onRetry});

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
            'Error al cargar el historial médico',
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
