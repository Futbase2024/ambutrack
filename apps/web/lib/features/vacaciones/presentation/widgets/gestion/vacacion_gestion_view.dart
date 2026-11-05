import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_bloc.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_event.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_state.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/calendario_vacaciones_widget.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/gestion/vacacion_detail_panel.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/gestion/vacacion_gestion_bars.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/gestion/vacacion_gestion_columns.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/gestion/vacacion_gestion_content.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/gestionar_vacacion_dialog.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/vacacion_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de vacaciones con layout de programa de gestión.
/// El calendario mensual sigue disponible desde la barra de herramientas.
class VacacionGestionView extends StatefulWidget {
  const VacacionGestionView({super.key});

  @override
  State<VacacionGestionView> createState() => _VacacionGestionViewState();
}

class _VacacionGestionViewState extends State<VacacionGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _estado;
  int _year = DateTime.now().year;
  GestionSort _sort = const GestionSort(columnIndex: 1);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  bool _calendario = false;

  /// Operación lanzada desde esta vista (para mostrar sus errores)
  bool _operacionPropia = false;

  /// Identificador de las vacaciones cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<VacacionesEntity>? _vacaciones;
  Map<String, PersonalEntity> _personal = <String, PersonalEntity>{};

  @override
  void initState() {
    super.initState();
    final VacacionesBloc bloc = context.read<VacacionesBloc>();
    final VacacionesState state = bloc.state;
    if (state is VacacionesLoaded) {
      _vacaciones = state.vacaciones;
      _year = state.year ?? _year;
    } else if (state is VacacionesInitial) {
      bloc.add(VacacionesLoadByYearRequested(_year));
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
      debugPrint('❌ VacacionesPage: error al cargar personal: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != null;

  VacacionesEntity? get _selected {
    for (final VacacionesEntity v in _vacaciones ?? const <VacacionesEntity>[]) {
      if (v.id == _selectedId) {
        return v;
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
        _estado = null;
      });

  void _loadYear(int year) {
    _operacionPropia = true;
    _updateFilters(() => _year = year);
    context.read<VacacionesBloc>().add(VacacionesLoadByYearRequested(year));
  }

  void _refresh() {
    _loadYear(_year);
    _loadPersonal();
  }

  void _toggleVista() {
    final bool aCalendario = !_calendario;
    setState(() => _calendario = aCalendario);
    // El calendario arranca en el año actual: sincroniza los datos cargados
    final int actual = DateTime.now().year;
    if (aCalendario && _year != actual) {
      _loadYear(actual);
    }
  }

  Future<void> _openForm([VacacionesEntity? vacacion]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<VacacionesBloc>.value(
        value: context.read<VacacionesBloc>(),
        child: VacacionFormDialog(vacacion: vacacion),
      ),
    );
  }

  Future<void> _openGestionar(VacacionesEntity vacacion) {
    final String nombre = _personal[vacacion.idPersonal]?.nombreCompleto ?? 'Desconocido';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<VacacionesBloc>.value(
        value: context.read<VacacionesBloc>(),
        child: GestionarVacacionDialog(vacacion: vacacion, nombrePersonal: nombre),
      ),
    );
  }

  Future<void> _confirmDelete(VacacionesEntity vacacion) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar vacaciones',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Personal': vacacionNombre(_personal, vacacion.idPersonal),
        'Periodo': '${GestionFormatters.fecha(vacacion.fechaInicio)} - '
            '${GestionFormatters.fecha(vacacion.fechaFin)}',
        'Días': '${vacacion.diasSolicitados}',
        'Estado': vacacionEstadoLabel(vacacion.estado),
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingNombre = '${vacacionNombre(_personal, vacacion.idPersonal)} — '
            '${GestionFormatters.fecha(vacacion.fechaInicio)} - ${GestionFormatters.fecha(vacacion.fechaFin)}';
      });
      _operacionPropia = true;
      context.read<VacacionesBloc>().add(VacacionesDeleteRequested(vacacion.id));
    }
  }

  void _onStateChanged(BuildContext context, VacacionesState state) {
    if (state is VacacionesLoaded) {
      _operacionPropia = false;
      final String? eliminado = _deletingNombre;
      setState(() {
        _vacaciones = state.vacaciones;
        _year = state.year ?? _year;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Vacaciones', nombre: eliminado);
      }
    } else if (state is VacacionesError && _vacaciones != null && _operacionPropia) {
      _operacionPropia = false;
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en vacaciones',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VacacionesBloc, VacacionesState>(
      listener: _onStateChanged,
      builder: (BuildContext context, VacacionesState state) {
        final List<GestionColumn<VacacionesEntity>> columns = vacacionGestionColumns(_personal);
        final List<VacacionesEntity> todas = _vacaciones ?? <VacacionesEntity>[];
        final List<VacacionesEntity> visibles = _sort.apply(
          filtrarVacaciones(todas, personal: _personal, query: _query, estado: _estado),
          columns,
        );
        final VacacionesEntity? selected = _selected;
        return GestionLayout(
          toolbar: VacacionGestionToolbar(
            hasSelection: selected != null,
            calendario: _calendario,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onGestionar: () => _openGestionar(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirVacaciones(visibles, _personal, _year),
            onToggleVista: _toggleVista,
          ),
          filterBar: _calendario
              ? null
              : VacacionGestionFilters(
                  searchController: _searchController,
                  onSearchChanged: (String v) => _updateFilters(() => _query = v),
                  year: _year,
                  onYearChanged: _loadYear,
                  estado: _estado,
                  onEstadoChanged: (String? v) => _updateFilters(() => _estado = v),
                  onClear: _hasFilters ? _clearFilters : null,
                ),
          content: _calendario
              ? const Padding(padding: EdgeInsets.all(8), child: CalendarioVacacionesWidget())
              : VacacionGridContent(
                  state: state,
                  hasData: _vacaciones != null,
                  columns: columns,
                  rows: _pageOf(visibles),
                  firstRowNumber: _page * _pageSize + 1,
                  selectedId: _selectedId,
                  sort: _sort,
                  hasFilters: _hasFilters,
                  onSelect: (VacacionesEntity v) => setState(() => _selectedId = v.id),
                  onActivate: _openForm,
                  onSort: (GestionSort s) => setState(() => _sort = s),
                  onRetry: _refresh,
                ),
          detailPanel: _calendario
              ? null
              : VacacionDetailPanel(
                  vacacion: selected,
                  todas: todas,
                  personal: _personal,
                  onGestionar: () => _openGestionar(selected!),
                  onEdit: () => _openForm(selected),
                  onDelete: () => _confirmDelete(selected!),
                ),
          statusBar: GestionStatusBar(
            items: <String>['Año $_year', ...resumenVacaciones(todas, visibles.length)],
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

  List<VacacionesEntity> _pageOf(List<VacacionesEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
