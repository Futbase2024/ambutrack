import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_bloc.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_event.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_state.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/gestion/paciente_detail_panel.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/gestion/paciente_gestion_bars.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/gestion/paciente_gestion_columns.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/gestion/paciente_grid_content.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/paciente_form_dialog.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/servicio_form_wizard_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de pacientes con layout de programa de gestión:
/// barra de herramientas + filtros + rejilla + ficha lateral + barra de estado
class PacienteGestionView extends StatefulWidget {
  const PacienteGestionView({super.key});

  @override
  State<PacienteGestionView> createState() => _PacienteGestionViewState();
}

class _PacienteGestionViewState extends State<PacienteGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  PacienteEstadoFiltro _estado = PacienteEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 1);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Hay una eliminación en curso (para mostrar su error si falla)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<PacienteEntity>? _pacientes;

  @override
  void initState() {
    super.initState();
    final PacientesBloc bloc = context.read<PacientesBloc>();
    final PacientesState state = bloc.state;
    if (state is PacientesLoaded) {
      debugPrint('⚡ PacientesPage: reutilizando ${state.pacientes.length} pacientes del BLoC');
      _pacientes = state.pacientes;
    } else if (state is PacientesInitial) {
      debugPrint('🚀 PacientesPage: primera carga, solicitando pacientes...');
      bloc.add(const PacientesLoadRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != PacienteEstadoFiltro.todos;

  PacienteEntity? get _selected {
    for (final PacienteEntity p in _pacientes ?? const <PacienteEntity>[]) {
      if (p.id == _selectedId) {
        return p;
      }
    }
    return null;
  }

  List<PacienteEntity> get _visibles => _sort.apply(
        filtrarPacientes(_pacientes ?? <PacienteEntity>[], query: _query, estado: _estado),
        pacienteGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = PacienteEstadoFiltro.todos;
      });

  void _refresh() => context.read<PacientesBloc>().add(const PacientesLoadRequested());

  Future<void> _openForm([PacienteEntity? paciente]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<PacientesBloc>.value(
        value: context.read<PacientesBloc>(),
        child: PacienteFormDialog(paciente: paciente),
      ),
    );
  }

  Future<void> _createServicio(PacienteEntity paciente) {
    debugPrint('🚑 Abriendo wizard de servicio para: ${paciente.nombreCompleto} (${paciente.id})');
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => ServicioFormWizardDialog(paciente: paciente),
    );
  }

  Future<void> _confirmDelete(PacienteEntity p) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar paciente',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Identificación': GestionFormatters.texto(p.identificacion),
        'Nombre': p.nombreCompleto,
        'Documento': pacienteDocumento(p),
        'Edad': '${p.edad} años',
        'Teléfono': GestionFormatters.telefono(pacienteTelefono(p)),
        'Estado': p.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando paciente: ${p.nombreCompleto} (${p.id})');
      setState(() {
        _selectedId = null;
        _deletingNombre = p.nombreCompleto;
      });
      context.read<PacientesBloc>().add(PacientesDeleteRequested(p.id));
    }
  }

  void _onStateChanged(BuildContext context, PacientesState state) {
    if (state is PacientesLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _pacientes = state.pacientes;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Paciente', nombre: eliminado);
      }
    } else if (state is PacientesError && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error al eliminar paciente',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PacientesBloc, PacientesState>(
      listener: _onStateChanged,
      builder: (BuildContext context, PacientesState state) {
        final List<PacienteEntity> visibles = _visibles;
        final PacienteEntity? selected = _selected;
        return GestionLayout(
          toolbar: PacienteGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onCreateServicio: () => _createServicio(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirPacientes(visibles),
          ),
          filterBar: PacienteGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (PacienteEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: PacienteGridContent(
            state: state,
            hasData: _pacientes != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (PacienteEntity p) => setState(() => _selectedId = p.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: PacienteDetailPanel(
            paciente: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenPacientes(_pacientes ?? <PacienteEntity>[], visibles.length),
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

  List<PacienteEntity> _pageOf(List<PacienteEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
