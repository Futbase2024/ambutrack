import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/cubit/inicio_turno_validacion_cubit.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/cubit/inicio_turno_validacion_state.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicios_turno_acciones.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicios_turno_detail_panel.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicios_turno_gestion_bars.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicios_turno_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicios_turno_grid_content.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicios_turno_parte_diario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de inicios de turno con layout de programa de gestión.
/// Coordinación valida (aprueba / rechaza) los inicios fuera de base.
class IniciosTurnoGestionView extends StatefulWidget {
  const IniciosTurnoGestionView({super.key});

  @override
  State<IniciosTurnoGestionView> createState() => _IniciosTurnoGestionViewState();
}

class _IniciosTurnoGestionViewState extends State<IniciosTurnoGestionView>
    with IniciosTurnoAcciones<IniciosTurnoGestionView>, IniciosTurnoParteDiario<IniciosTurnoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  GestionColumnFilters _colFilters = const GestionColumnFilters();

  /// null hasta la primera carga: entonces Pendientes si hay alguno, si no Todos
  InicioTurnoFiltro? _filtro;
  GestionSort _sort = const GestionSort(columnIndex: 0, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Último resultado de validación ya mostrado (evita repetir el diálogo)
  int _resultadoMostrado = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  InicioTurnoFiltro get _filtroEfectivo => _filtro ?? InicioTurnoFiltro.todos;

  bool get _hasFilters => _query.isNotEmpty || !_colFilters.isEmpty;

  InicioTurnoEntity? _selected(List<InicioTurnoEntity> inicios) {
    for (final InicioTurnoEntity i in inicios) {
      if (i.id == _selectedId) {
        return i;
      }
    }
    return null;
  }

  List<InicioTurnoEntity> _base(List<InicioTurnoEntity> inicios) =>
      filtrarIniciosTurno(inicios, query: _query, filtro: _filtroEfectivo);

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _colFilters = const GestionColumnFilters();
      });

  void _onColumnFiltersChanged(GestionColumnFilters f) => _updateFilters(() => _colFilters = f);

  void _refresh() => context.read<InicioTurnoValidacionCubit>().cargar();

  void _onStateChanged(BuildContext context, InicioTurnoValidacionState state) {
    final InicioTurnoValidacionResultado? resultado = state.resultado;
    if (_filtro == null && state.inicios != null) {
      setState(() => _filtro = state.pendientes > 0 ? InicioTurnoFiltro.pendientes : InicioTurnoFiltro.todos);
    }
    if (resultado != null && resultado.secuencia != _resultadoMostrado) {
      _resultadoMostrado = resultado.secuencia;
      mostrarResultadoValidacion(resultado);
    } else if (state.error != null && state.inicios != null && !state.cargando) {
      showResultDialog(
        context: context,
        title: 'Error en inicios de turno',
        message: 'No se pudieron recargar los inicios de turno.',
        details: state.error,
        type: ResultType.error,
      );
    }
  }

  bool _listenWhen(InicioTurnoValidacionState prev, InicioTurnoValidacionState cur) =>
      prev.resultado != cur.resultado || prev.error != cur.error || prev.inicios == null && cur.inicios != null;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InicioTurnoValidacionCubit, InicioTurnoValidacionState>(
      listenWhen: _listenWhen,
      listener: _onStateChanged,
      builder: (BuildContext context, InicioTurnoValidacionState state) {
        final List<InicioTurnoEntity> todos = state.inicios ?? <InicioTurnoEntity>[];
        final List<InicioTurnoEntity> base = _base(todos);
        final List<InicioTurnoEntity> visibles =
            _sort.apply(_colFilters.apply(base, iniciosTurnoColumns), iniciosTurnoColumns);
        final InicioTurnoEntity? selected = _selected(todos);
        final bool puedeValidar = selected != null && esPendiente(selected) && !state.validando;
        final bool tieneFoto = selected?.fotoKmUrl?.isNotEmpty ?? false;
        return GestionLayout(
          toolbar: IniciosTurnoGestionToolbar(
            onAprobar: puedeValidar ? () => aprobarInicio(selected) : null,
            onRechazar: puedeValidar ? () => rechazarInicio(selected) : null,
            onFoto: tieneFoto ? () => verFotoKm(selected!) : null,
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirIniciosTurno(visibles),
            onParteDiario: selected == null ? null : () => imprimirParteDiario(selected),
            onPartesDelDia: selected == null ? null : () => imprimirPartesDelDia(selected, todos),
          ),
          filterBar: IniciosTurnoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            filtro: _filtroEfectivo,
            onFiltroChanged: (InicioTurnoFiltro v) => _updateFilters(() => _filtro = v),
            pendientes: state.pendientes,
            columnFilters: _colFilters,
            onColumnFiltersChanged: _onColumnFiltersChanged,
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: IniciosTurnoGridContent(
            state: state,
            rows: _pageOf(visibles),
            filters: _colFilters,
            onFiltersChanged: _onColumnFiltersChanged,
            filterSource: base,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            emptyMessage: _emptyMessage,
            onSelect: (InicioTurnoEntity i) => setState(() => _selectedId = i.id),
            onActivate: verFotoKm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: IniciosTurnoDetailPanel(
            inicio: selected,
            validando: state.validando,
            onAprobar: () => aprobarInicio(selected!),
            onRechazar: () => rechazarInicio(selected!),
            onFoto: () => verFotoKm(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenIniciosTurno(todos, visibles.length),
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

  String get _emptyMessage {
    if (_hasFilters) {
      return 'Ningún inicio de turno coincide con los filtros';
    }
    return _filtroEfectivo == InicioTurnoFiltro.pendientes
        ? 'No hay inicios de turno pendientes de validar'
        : 'No hay inicios de turno en los últimos 30 días';
  }

  List<InicioTurnoEntity> _pageOf(List<InicioTurnoEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
