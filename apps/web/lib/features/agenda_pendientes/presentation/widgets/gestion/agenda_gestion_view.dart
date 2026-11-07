import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_bloc.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_event.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_state.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/agenda_pendiente_form_dialog.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/gestion/agenda_detail_panel.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/gestion/agenda_gestion_bars.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/gestion/agenda_gestion_columns.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/gestion/agenda_grid_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Agenda de pendientes con layout de programa de gestión
class AgendaGestionView extends StatefulWidget {
  const AgendaGestionView({required this.empresaId, super.key});

  final String empresaId;

  @override
  State<AgendaGestionView> createState() => _AgendaGestionViewState();
}

class _AgendaGestionViewState extends State<AgendaGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  AgendaEstadoFiltro _estado = AgendaEstadoFiltro.todos;
  AgendaFechaFiltro _fecha = AgendaFechaFiltro.todas;
  GestionSort _sort = const GestionSort(columnIndex: 0, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Identificador del pendiente cuyo borrado se ha solicitado desde esta vista
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<AgendaPendienteEntity>? _pendientes;
  int _pendientesHoy = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _estado != AgendaEstadoFiltro.todos || _fecha != AgendaFechaFiltro.todas;

  AgendaPendienteEntity? get _selected {
    for (final AgendaPendienteEntity p in _pendientes ?? const <AgendaPendienteEntity>[]) {
      if (p.id == _selectedId) {
        return p;
      }
    }
    return null;
  }

  List<AgendaPendienteEntity> get _visibles => _sort.apply(
        filtrarAgenda(_pendientes ?? <AgendaPendienteEntity>[], query: _query, estado: _estado, fecha: _fecha),
        agendaGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = AgendaEstadoFiltro.todos;
        _fecha = AgendaFechaFiltro.todas;
      });

  void _refresh() =>
      context.read<AgendaPendienteBloc>().add(AgendaPendienteLoadRequested(empresaId: widget.empresaId));

  Future<void> _openForm([AgendaPendienteEntity? pendiente]) => showAgendaPendienteFormDialog(
        context: context,
        empresaId: widget.empresaId,
        pendiente: pendiente,
      );

  void _toggleCompletado(AgendaPendienteEntity p) => context
      .read<AgendaPendienteBloc>()
      .add(AgendaPendienteCompletadoToggled(id: p.id, completado: !p.completado));

  Future<void> _confirmDelete(AgendaPendienteEntity p) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar pendiente',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Fecha': GestionFormatters.fecha(p.fecha),
        'Nombre': p.nombreApellidos,
        'Localidad': GestionFormatters.texto(p.localidad),
        'Estado': p.completado ? 'Completado' : 'Pendiente',
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingNombre = '${p.nombreApellidos} — ${GestionFormatters.fecha(p.fecha)}';
      });
      context.read<AgendaPendienteBloc>().add(AgendaPendienteDeleteRequested(id: p.id));
    }
  }

  void _onStateChanged(BuildContext context, AgendaPendienteState state) {
    if (state is AgendaPendienteLoaded) {
      setState(() {
        _pendientes = state.pendientes;
        _pendientesHoy = state.pendientesHoy.length;
      });
      final String? message = state.message;
      final String? eliminado = _deletingNombre;
      if (message != null && message.startsWith('Error')) {
        _deletingNombre = null;
        _showError(message);
      } else if (message != null && eliminado != null) {
        _deletingNombre = null;
        GestionFeedback.eliminado(context, entidad: 'Pendiente', nombre: eliminado);
      } else if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else if (state is AgendaPendienteError && _pendientes != null) {
      _deletingNombre = null;
      _showError(state.message);
    }
  }

  void _showError(String details) {
    showResultDialog(
      context: context,
      title: 'Error en la agenda de pendientes',
      message: 'No se pudo completar la operación.',
      details: details,
      type: ResultType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AgendaPendienteBloc, AgendaPendienteState>(
      listener: _onStateChanged,
      builder: (BuildContext context, AgendaPendienteState state) {
        final List<AgendaPendienteEntity> visibles = _visibles;
        final AgendaPendienteEntity? selected = _selected;
        return GestionLayout(
          toolbar: AgendaGestionToolbar(
            hasSelection: selected != null,
            selectedCompletado: selected?.completado ?? false,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onToggleCompletado: () => _toggleCompletado(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirAgenda(visibles),
          ),
          filterBar: AgendaGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (AgendaEstadoFiltro v) => _updateFilters(() => _estado = v),
            fecha: _fecha,
            onFechaChanged: (AgendaFechaFiltro v) => _updateFilters(() => _fecha = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: AgendaGridContent(
            state: state,
            hasData: _pendientes != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (AgendaPendienteEntity p) => setState(() => _selectedId = p.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: AgendaDetailPanel(
            pendiente: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onToggleCompletado: () => _toggleCompletado(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenAgenda(_pendientes ?? <AgendaPendienteEntity>[], visibles.length, _pendientesHoy),
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

  List<AgendaPendienteEntity> _pageOf(List<AgendaPendienteEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
