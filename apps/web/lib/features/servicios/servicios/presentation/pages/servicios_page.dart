import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_event.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_state.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/gestion/servicio_acciones.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/gestion/servicio_gestion_columns.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/gestion/servicio_grid_content.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/servicios_page_bars.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/servicios_side_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de servicios (layout tipo programa de gestión)
class ServiciosPage extends StatelessWidget {
  const ServiciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ServiciosBloc>(
        create: (_) => getIt<ServiciosBloc>()..add(const ServiciosEvent.estadoFilterChanged(estado: 'ACTIVO')),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: _ServiciosView(),
        ),
      ),
    );
  }
}

/// Barra de herramientas + filtros + rejilla + ficha lateral + barra de estado
class _ServiciosView extends StatefulWidget {
  const _ServiciosView();

  @override
  State<_ServiciosView> createState() => _ServiciosViewState();
}

class _ServiciosViewState extends State<_ServiciosView> {
  /// Ancho de la ficha: mayor que el estándar por las pestañas y la tabla de trayectos
  static const double _detailWidth = 520;

  final TextEditingController _searchController = TextEditingController();
  int _year = DateTime.now().year;
  String? _estado = 'ACTIVO';

  GestionColumnFilters _colFilters = const GestionColumnFilters();
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<ServicioEntity>? _servicios;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _searchController.text.isNotEmpty || _estado != null || !_colFilters.isEmpty;

  List<ServicioEntity> get _base => _servicios ?? const <ServicioEntity>[];

  List<ServicioEntity> get _visibles =>
      _sort.apply(_colFilters.apply(_base, servicioGestionColumns), servicioGestionColumns);

  /// Filtros de la barra superior: se resuelven en el BLoC (consulta a Supabase)
  void _applyFilters() {
    final ServiciosBloc bloc = context.read<ServiciosBloc>();
    debugPrint('🔍 Filtros: búsqueda=${_searchController.text}, año=$_year, estado=$_estado');
    setState(() => _page = 0);
    if (_searchController.text.isNotEmpty) {
      bloc.add(ServiciosEvent.searchChanged(query: _searchController.text));
    } else if (_estado != null) {
      bloc.add(ServiciosEvent.estadoFilterChanged(estado: _estado));
    } else {
      bloc.add(ServiciosEvent.yearFilterChanged(year: _year));
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _estado = null;
      _colFilters = const GestionColumnFilters();
    });
    _applyFilters();
  }

  void _onColumnFiltersChanged(GestionColumnFilters f) => setState(() {
        _colFilters = f;
        _page = 0;
      });

  void _select(ServicioEntity s) {
    final String? id = s.id;
    if (id == null || id == _selectedId) {
      return;
    }
    setState(() => _selectedId = id);
    context.read<ServiciosBloc>().add(ServiciosEvent.loadServicioDetailsRequested(id: id));
  }

  void _onStateChanged(BuildContext context, ServiciosState state) {
    state.maybeWhen(
      loaded: (
        List<ServicioEntity> servicios,
        String searchQuery,
        int? yearFilter,
        String? estadoFilter,
        bool isRefreshing,
        ServicioEntity? selectedServicio,
        bool isLoadingDetails,
      ) =>
          setState(() {
        _servicios = servicios;
        _error = null;
      }),
      error: (String message, List<ServicioEntity>? previous) => setState(() {
        _servicios = previous ?? _servicios;
        _error = message;
      }),
      orElse: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiciosBloc, ServiciosState>(
      listener: _onStateChanged,
      builder: (BuildContext context, ServiciosState state) {
        final List<ServicioEntity> visibles = _visibles;
        return GestionLayout(
          detailWidth: _detailWidth,
          toolbar: ServiciosToolbar(
            state: state,
            onNuevo: () => ServicioAcciones.abrirFormulario(context),
            onEditar: (ServicioEntity s) => ServicioAcciones.abrirFormulario(context, s),
            onEliminar: (ServicioEntity s) => ServicioAcciones.eliminar(context, s),
            onFinalizar: (ServicioEntity s) => ServicioAcciones.finalizar(context, s),
            onSuspender: (ServicioEntity s) => ServicioAcciones.suspender(context, s),
            onReanudar: (ServicioEntity s) => ServicioAcciones.reanudar(context, s),
            onExcluir: (ServicioEntity s) => ServicioAcciones.excluir(context, s),
          ),
          filterBar: ServiciosFilterBar(
            searchController: _searchController,
            onSearchChanged: (_) => _applyFilters(),
            year: _year,
            onYearChanged: (int value) {
              _year = value;
              _applyFilters();
            },
            estado: _estado,
            onEstadoChanged: (String? value) {
              _estado = value;
              _applyFilters();
            },
            columnFilters: _colFilters,
            onColumnFiltersChanged: _onColumnFiltersChanged,
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: ServicioGridContent(
            servicios: _servicios,
            isLoading: state.maybeWhen(loading: () => true, orElse: () => false),
            errorMessage: _error,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: _select,
            onActivate: (ServicioEntity s) => ServicioAcciones.abrirFormulario(context, s),
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _applyFilters,
            filters: _colFilters,
            onFiltersChanged: _onColumnFiltersChanged,
            filterSource: _base,
          ),
          detailPanel: ServiciosSidePanel(servicioId: _selectedId),
          statusBar: ServiciosStatusBar(
            state: state,
            servicios: _servicios,
            visibles: visibles.length,
            pagination: GestionPagination(
              page: _page,
              pageSize: _pageSize,
              totalItems: visibles.length,
              onPageChanged: (int p) => setState(() => _page = p),
              onPageSizeChanged: (int s) => setState(() {
                _pageSize = s;
                _page = 0;
              }),
            ),
          ),
        );
      },
    );
  }

  List<ServicioEntity> _pageOf(List<ServicioEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
