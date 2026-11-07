import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_bloc.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_event.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_state.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/ausencia_form_dialog.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/calendario_ausencias_widget.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/gestion/ausencia_detail_panel.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/gestion/ausencia_gestion_bars.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/gestion/ausencia_gestion_columns.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/gestion/ausencia_gestion_content.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/gestionar_ausencia_dialog.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de ausencias con layout de programa de gestión.
/// El calendario mensual sigue disponible desde la barra de herramientas.
class AusenciaGestionView extends StatefulWidget {
  const AusenciaGestionView({super.key});

  @override
  State<AusenciaGestionView> createState() => _AusenciaGestionViewState();
}

class _AusenciaGestionViewState extends State<AusenciaGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _tipoId;
  EstadoAusencia? _estado;
  GestionSort _sort = const GestionSort(columnIndex: 2, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  bool _calendario = false;

  /// Operación lanzada desde esta vista (para mostrar sus errores)
  bool _operacionPropia = false;

  /// Descripción de la ausencia cuyo borrado está en curso (aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<AusenciaEntity>? _ausencias;
  List<TipoAusenciaEntity> _tipos = <TipoAusenciaEntity>[];
  Map<String, PersonalEntity> _personal = <String, PersonalEntity>{};

  @override
  void initState() {
    super.initState();
    final AusenciasBloc bloc = context.read<AusenciasBloc>();
    final AusenciasState state = bloc.state;
    if (state is AusenciasLoaded) {
      debugPrint('⚡ AusenciasPage: reutilizando ${state.ausencias.length} ausencias en caché');
      _ausencias = state.ausencias;
      _tipos = state.tiposAusencia;
    } else if (state is AusenciasInitial) {
      bloc.add(const AusenciasLoadRequested());
    }
    _loadPersonal();
  }

  Future<void> _loadPersonal() async {
    try {
      final List<PersonalEntity> lista = await getIt<PersonalRepository>().getAll();
      if (mounted) {
        setState(() => _personal = <String, PersonalEntity>{
              for (final PersonalEntity p in lista) p.id: p,
            });
      }
    } catch (e) {
      debugPrint('❌ AusenciasPage: error al cargar personal: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  AusenciaLookup get _lookup => AusenciaLookup(
        personal: _personal,
        tipos: <String, TipoAusenciaEntity>{for (final TipoAusenciaEntity t in _tipos) t.id: t},
      );

  bool get _hasFilters => _query.isNotEmpty || _tipoId != null || _estado != null;

  AusenciaEntity? get _selected {
    for (final AusenciaEntity a in _ausencias ?? const <AusenciaEntity>[]) {
      if (a.id == _selectedId) {
        return a;
      }
    }
    return null;
  }

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipoId = null;
        _estado = null;
      });

  void _refresh() {
    _operacionPropia = true;
    context.read<AusenciasBloc>().add(const AusenciasLoadRequested());
    _loadPersonal();
  }

  Future<void> _openForm([AusenciaEntity? ausencia]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<AusenciasBloc>.value(
        value: context.read<AusenciasBloc>(),
        child: AusenciaFormDialog(ausencia: ausencia),
      ),
    );
  }

  Future<void> _openGestionar(AusenciaEntity ausencia) {
    final String nombre = _personal[ausencia.idPersonal]?.nombreCompleto ?? 'Desconocido';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<AusenciasBloc>.value(
        value: context.read<AusenciasBloc>(),
        child: GestionarAusenciaDialog(ausencia: ausencia, nombrePersonal: nombre),
      ),
    );
  }

  Future<void> _confirmDelete(AusenciaEntity ausencia) async {
    final AusenciaLookup lookup = _lookup;
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar ausencia',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Personal': lookup.nombre(ausencia.idPersonal),
        'Tipo': lookup.tipoNombre(ausencia.idTipoAusencia),
        'Periodo': '${GestionFormatters.fecha(ausencia.fechaInicio)} - '
            '${GestionFormatters.fecha(ausencia.fechaFin)}',
        'Días': '${ausencia.diasAusencia}',
        'Estado': ausenciaEstadoLabel(ausencia.estado),
      },
    );
    if (confirmed == true && mounted) {
      setState(() => _selectedId = null);
      _operacionPropia = true;
      _deletingNombre = '${lookup.nombre(ausencia.idPersonal)} — '
          '${GestionFormatters.fecha(ausencia.fechaInicio)}';
      context.read<AusenciasBloc>().add(AusenciaDeleteRequested(ausencia.id));
    }
  }

  void _onStateChanged(BuildContext context, AusenciasState state) {
    if (state is AusenciasLoaded) {
      // Durante un borrado, los Loaded intermedios (optimista/rollback) no cierran la operación
      if (_deletingNombre == null) {
        _operacionPropia = false;
      }
      setState(() {
        _ausencias = state.ausencias;
        _tipos = state.tiposAusencia;
      });
      final String? eliminado = _deletingNombre;
      if (state is AusenciaDeleted && eliminado != null) {
        _deletingNombre = null;
        _operacionPropia = false;
        GestionFeedback.eliminado(context, entidad: 'Ausencia', nombre: eliminado);
      }
    } else if (state is AusenciasError && _ausencias != null && _operacionPropia) {
      _operacionPropia = false;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en ausencias',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AusenciasBloc, AusenciasState>(
      listener: _onStateChanged,
      builder: (BuildContext context, AusenciasState state) {
        final AusenciaLookup lookup = _lookup;
        final List<GestionColumn<AusenciaEntity>> columns = ausenciaGestionColumns(lookup);
        final List<AusenciaEntity> todas = _ausencias ?? <AusenciaEntity>[];
        final List<AusenciaEntity> visibles = _sort.apply(
          filtrarAusencias(todas, lookup: lookup, query: _query, tipoId: _tipoId, estado: _estado),
          columns,
        );
        final AusenciaEntity? selected = _selected;
        return GestionLayout(
          toolbar: AusenciaGestionToolbar(
            hasSelection: selected != null,
            calendario: _calendario,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onGestionar: () => _openGestionar(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirAusencias(visibles, lookup),
            onToggleVista: () => setState(() => _calendario = !_calendario),
          ),
          filterBar: _calendario
              ? null
              : AusenciaGestionFilters(
                  searchController: _searchController,
                  onSearchChanged: (String v) => _updateFilters(() => _query = v),
                  tipos: _tipos,
                  tipoId: _tipoId,
                  onTipoChanged: (String? v) => _updateFilters(() => _tipoId = v),
                  estado: _estado,
                  onEstadoChanged: (EstadoAusencia? v) => _updateFilters(() => _estado = v),
                  onClear: _hasFilters ? _clearFilters : null,
                ),
          content: _calendario
              ? const Padding(padding: EdgeInsets.all(8), child: CalendarioAusenciasWidget())
              : AusenciaGridContent(
                  state: state,
                  hasData: _ausencias != null,
                  columns: columns,
                  rows: _pageOf(visibles),
                  firstRowNumber: _page * _pageSize + 1,
                  selectedId: _selectedId,
                  sort: _sort,
                  hasFilters: _hasFilters,
                  onSelect: (AusenciaEntity a) => setState(() => _selectedId = a.id),
                  onActivate: _openForm,
                  onSort: (GestionSort s) => setState(() => _sort = s),
                  onRetry: _refresh,
                ),
          detailPanel: _calendario
              ? null
              : AusenciaDetailPanel(
                  ausencia: selected,
                  todas: todas,
                  lookup: lookup,
                  onGestionar: () => _openGestionar(selected!),
                  onEdit: () => _openForm(selected),
                  onDelete: () => _confirmDelete(selected!),
                ),
          statusBar: GestionStatusBar(
            items: resumenAusencias(todas, visibles.length),
            pagination: _calendario
                ? null
                : GestionPagination(
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

  List<AusenciaEntity> _pageOf(List<AusenciaEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
