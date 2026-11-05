import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/contratos/presentation/bloc/bloc.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/contrato_form_dialog.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/gestion/contratos_detail_panel.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/gestion/contratos_gestion_bars.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/gestion/contratos_gestion_columns.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/gestion/contratos_grid_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de contratos con layout de programa de gestión
class ContratosGestionView extends StatefulWidget {
  const ContratosGestionView({super.key});

  @override
  State<ContratosGestionView> createState() => _ContratosGestionViewState();
}

class _ContratosGestionViewState extends State<ContratosGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  ContratoEstadoFiltro _estado = ContratoEstadoFiltro.todos;
  String? _tipo;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Eliminación lanzada desde esta vista (el formulario gestiona sus propios errores)
  bool _deletePending = false;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<ContratoEntity>? _contratos;
  Map<String, String> _hospitales = const <String, String>{};

  @override
  void initState() {
    super.initState();
    final ContratoBloc bloc = context.read<ContratoBloc>();
    final ContratoState state = bloc.state;
    if (state is ContratoInitial) {
      bloc.add(const ContratoLoadRequested());
    } else {
      _cache(state);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Guarda los datos si el estado los trae; devuelve si los traía
  bool _cache(ContratoState state) {
    if (state is ContratoLoaded) {
      _contratos = state.contratos;
      _hospitales = state.hospitalNames;
      return true;
    }
    if (state is ContratoOperationSuccess) {
      _contratos = state.contratos;
      _hospitales = state.hospitalNames;
      return true;
    }
    return false;
  }

  bool get _hasFilters => _query.isNotEmpty || _tipo != null || _estado != ContratoEstadoFiltro.todos;

  ContratoEntity? get _selected {
    for (final ContratoEntity c in _contratos ?? const <ContratoEntity>[]) {
      if (c.id == _selectedId) {
        return c;
      }
    }
    return null;
  }

  List<ContratoEntity> _visibles(List<GestionColumn<ContratoEntity>> columns) => _sort.apply(
        filtrarContratos(
          _contratos ?? <ContratoEntity>[],
          _hospitales,
          query: _query,
          estado: _estado,
          tipo: _tipo,
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
        _tipo = null;
        _estado = ContratoEstadoFiltro.todos;
      });

  void _refresh() => context.read<ContratoBloc>().add(const ContratoLoadRequested());

  Future<void> _openForm([ContratoEntity? contrato]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<ContratoBloc>.value(
        value: context.read<ContratoBloc>(),
        child: ContratoFormDialog(contrato: contrato),
      ),
    );
  }

  Future<void> _confirmDelete(ContratoEntity c) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar contrato',
      message: '¿Estás seguro de que deseas eliminar este contrato? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Código': c.codigo,
        'Centro hospitalario': GestionFormatters.texto(_hospitales[c.hospitalId]),
        'Tipo': c.tipoContrato == null ? GestionFormatters.vacio : contratoTipoLabel(c.tipoContrato!),
        'Vigencia': contratoPeriodo(c),
        'Importe mensual': contratoImporte(c),
        'Estado': c.activo ? 'Activo' : 'Inactivo',
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletePending = true;
      });
      context.read<ContratoBloc>().add(ContratoDeleteRequested(c.id));
    }
  }

  void _onStateChanged(BuildContext context, ContratoState state) {
    if (_cache(state)) {
      final bool wasDelete = _deletePending && state is ContratoOperationSuccess;
      setState(() => _deletePending = false);
      if (wasDelete) {
        showResultDialog(
          context: context,
          type: ResultType.success,
          title: 'Contrato eliminado',
          message: state.message,
        );
      }
    } else if (state is ContratoError && _deletePending) {
      setState(() => _deletePending = false);
      showResultDialog(
        context: context,
        title: 'Error en contratos',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContratoBloc, ContratoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, ContratoState state) {
        final List<GestionColumn<ContratoEntity>> columns = contratosGestionColumns(_hospitales);
        final List<ContratoEntity> visibles = _visibles(columns);
        final ContratoEntity? selected = _selected;
        return GestionLayout(
          toolbar: ContratosGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirContratos(visibles, _hospitales),
          ),
          filterBar: ContratosGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (ContratoEstadoFiltro v) => _updateFilters(() => _estado = v),
            tipo: _tipo,
            onTipoChanged: (String? v) => _updateFilters(() => _tipo = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: ContratosGridContent(
            state: state,
            hasData: _contratos != null,
            columns: columns,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (ContratoEntity c) => setState(() => _selectedId = c.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: ContratosDetailPanel(
            contrato: selected,
            hospitales: _hospitales,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenContratos(_contratos ?? <ContratoEntity>[], visibles.length),
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

  List<ContratoEntity> _pageOf(List<ContratoEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
