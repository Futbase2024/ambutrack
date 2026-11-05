import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/documentacion_detail_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/documentacion_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/gestion/documentacion_detail_panel.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/gestion/documentacion_gestion_bars.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/gestion/documentacion_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de documentación de vehículos con layout de programa de gestión
class DocumentacionGestionView extends StatefulWidget {
  const DocumentacionGestionView({this.vehiculoId, super.key});

  /// Vehículo con el que se crean los documentos nuevos (si se conoce)
  final String? vehiculoId;

  @override
  State<DocumentacionGestionView> createState() => _DocumentacionGestionViewState();
}

class _DocumentacionGestionViewState extends State<DocumentacionGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _tipo;
  String? _estado;
  DocVencimientoFiltro _vencimiento = DocVencimientoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 5);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Identificador del documento cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<DocumentacionVehiculoEntity>? _docs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _tipo != null || _estado != null || _vencimiento != DocVencimientoFiltro.todos;

  DocumentacionVehiculoEntity? get _selected {
    for (final DocumentacionVehiculoEntity d in _docs ?? const <DocumentacionVehiculoEntity>[]) {
      if (d.id == _selectedId) {
        return d;
      }
    }
    return null;
  }

  List<DocumentacionVehiculoEntity> get _visibles => _sort.apply(
        filtrarDocumentos(
          _docs ?? <DocumentacionVehiculoEntity>[],
          query: _query,
          tipo: _tipo,
          estado: _estado,
          vencimiento: _vencimiento,
        ),
        documentacionGestionColumns,
      );

  List<String> get _tipos =>
      (_docs ?? <DocumentacionVehiculoEntity>[]).map(docTipoLabel).toSet().toList()..sort();

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _estado = null;
        _vencimiento = DocVencimientoFiltro.todos;
      });

  void _refresh() =>
      context.read<DocumentacionVehiculosBloc>().add(const DocumentacionVehiculosLoadRequested());

  Future<void> _openForm([DocumentacionVehiculoEntity? documento]) async {
    final DocumentacionVehiculosBloc bloc = context.read<DocumentacionVehiculosBloc>();
    final DocumentacionVehiculoEntity? result = await showDialog<DocumentacionVehiculoEntity>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => DocumentacionFormDialog(
        documento: documento,
        vehiculoId: widget.vehiculoId ?? '',
      ),
    );
    if (result == null) {
      return;
    }
    if (documento == null) {
      bloc.add(DocumentacionVehiculoCreateRequested(result));
    } else {
      bloc.add(DocumentacionVehiculoUpdateRequested(result));
    }
  }

  Future<void> _openView(DocumentacionVehiculoEntity documento) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) => DocumentacionDetailDialog(documento: documento),
    );
  }

  void _renovar(DocumentacionVehiculoEntity documento) => context
      .read<DocumentacionVehiculosBloc>()
      .add(DocumentacionVehiculoActualizarEstadoRequested(documento.id));

  Future<void> _confirmDelete(DocumentacionVehiculoEntity documento) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar documento',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Vehículo': GestionFormatters.texto(documento.vehiculoMatricula),
        'Tipo': docTipoLabel(documento),
        'Número': GestionFormatters.texto(documento.numeroPoliza),
        'Compañía': GestionFormatters.texto(documento.compania),
        'Vencimiento': GestionFormatters.fecha(documento.fechaVencimiento),
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingNombre =
            '${docTipoLabel(documento)} — ${GestionFormatters.texto(documento.vehiculoMatricula)}';
      });
      context.read<DocumentacionVehiculosBloc>().add(DocumentacionVehiculoDeleteRequested(documento.id));
    }
  }

  void _onStateChanged(BuildContext context, DocumentacionVehiculosState state) {
    if (state is DocumentacionVehiculosLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _docs = state.documentos;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Documento', nombre: eliminado);
      }
    } else if (state is DocumentacionVehiculosError && _docs != null) {
      _deletingNombre = null;
      showResultDialog(
        context: context,
        title: 'Error en documentación',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocumentacionVehiculosBloc, DocumentacionVehiculosState>(
      listener: _onStateChanged,
      builder: (BuildContext context, DocumentacionVehiculosState state) {
        final List<DocumentacionVehiculoEntity> visibles = _visibles;
        final DocumentacionVehiculoEntity? selected = _selected;
        return GestionLayout(
          toolbar: DocumentacionGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirDocumentos(visibles),
            onView: () => _openView(selected!),
            onRenovar: () => _renovar(selected!),
          ),
          filterBar: DocumentacionGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipos: _tipos,
            tipo: _tipo,
            onTipoChanged: (String? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (String? v) => _updateFilters(() => _estado = v),
            vencimiento: _vencimiento,
            onVencimientoChanged: (DocVencimientoFiltro v) => _updateFilters(() => _vencimiento = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: FlotaGridArea(
            hasData: _docs != null,
            loading: state is DocumentacionVehiculosLoading ||
                (state is DocumentacionVehiculosLoaded && state.isRefreshing),
            errorMessage: state is DocumentacionVehiculosError ? state.message : null,
            errorTitle: 'Error al cargar los documentos',
            onRetry: _refresh,
            child: GestionGrid<DocumentacionVehiculoEntity>(
              columns: documentacionGestionColumns,
              rows: flotaPageOf(visibles, _page, _pageSize),
              rowId: (DocumentacionVehiculoEntity d) => d.id,
              selectedId: _selectedId,
              onSelect: (DocumentacionVehiculoEntity d) => setState(() => _selectedId = d.id),
              onActivate: _openForm,
              sort: _sort,
              onSort: (GestionSort s) => setState(() => _sort = s),
              firstRowNumber: _page * _pageSize + 1,
              emptyMessage: _hasFilters
                  ? 'Ningún documento coincide con los filtros'
                  : 'No hay documentos registrados. Pulsa "Nuevo" para agregar uno.',
            ),
          ),
          detailPanel: DocumentacionDetailPanel(
            documento: selected,
            todos: _docs ?? <DocumentacionVehiculoEntity>[],
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenDocumentos(_docs ?? <DocumentacionVehiculoEntity>[], visibles.length),
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
}
