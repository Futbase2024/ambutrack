import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/documento_personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/documento_personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/documento_personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/documentacion/documentacion_detail_panel.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/documentacion/documentacion_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/documentacion/documentacion_gestion_filters.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/documentacion/documento_personal_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Documentación del personal con layout de programa de gestión
class DocumentacionGestionView extends StatefulWidget {
  const DocumentacionGestionView({super.key});

  @override
  State<DocumentacionGestionView> createState() => _DocumentacionGestionViewState();
}

class _DocumentacionGestionViewState extends State<DocumentacionGestionView> {
  final TextEditingController _searchController = TextEditingController();
  final List<GestionColumn<DocumentoPersonalEntity>> _columns = documentacionGestionColumns();
  String _query = '';
  GestionColumnFilters _colFilters = const GestionColumnFilters();
  TipoDocumentoPersonal? _tipo;
  EstadoDocumentoPersonal? _estado;

  /// Por defecto: caducidad más próxima primero
  GestionSort _sort = const GestionSort(columnIndex: 5);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  String? _deletingId;
  String? _deletingNombre;
  List<DocumentoPersonalEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _tipo != null || _estado != null || !_colFilters.isEmpty;

  DocumentoPersonalEntity? get _selected =>
      _items?.where((DocumentoPersonalEntity d) => d.id == _selectedId).firstOrNull;

  List<DocumentoPersonalEntity> get _base => filtrarDocumentos(
        _items ?? <DocumentoPersonalEntity>[],
        query: _query,
        tipo: _tipo,
        estado: _estado,
      );

  List<DocumentoPersonalEntity> get _visibles => _sort.apply(_colFilters.apply(_base, _columns), _columns);

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _estado = null;
        _colFilters = const GestionColumnFilters();
      });

  void _onColumnFiltersChanged(GestionColumnFilters f) => _updateFilters(() => _colFilters = f);

  void _refresh() => context.read<DocumentoPersonalBloc>().add(const DocumentoPersonalLoadRequested());

  Future<void> _openForm([DocumentoPersonalEntity? item]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<DocumentoPersonalBloc>.value(
        value: context.read<DocumentoPersonalBloc>(),
        child: DocumentoPersonalFormDialog(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(DocumentoPersonalEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar documento',
      message: '¿Estás seguro de que deseas eliminar este documento? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Personal': item.personalNombre ?? GestionFormatters.vacio,
        'Tipo': item.tipo.label,
        if (item.nombre?.isNotEmpty ?? false) 'Documento': item.nombre!,
        if (item.numero?.isNotEmpty ?? false) 'Número': item.numero!,
        'F. caducidad': GestionFormatters.fecha(item.fechaCaducidad),
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingId = item.id;
        _deletingNombre = item.descripcion;
      });
      context.read<DocumentoPersonalBloc>().add(DocumentoPersonalDeleteRequested(item.id));
    }
  }

  void _onStateChanged(BuildContext context, DocumentoPersonalState state) {
    if (state is DocumentoPersonalLoaded) {
      final String? deletingId = _deletingId;
      final bool eliminado = deletingId != null && !state.items.any((DocumentoPersonalEntity d) => d.id == deletingId);
      final String? nombre = _deletingNombre;
      setState(() {
        _items = state.items;
        if (eliminado) {
          _deletingId = null;
          _deletingNombre = null;
        }
      });
      if (eliminado) {
        GestionFeedback.eliminado(context, entidad: 'Documento', nombre: nombre);
      }
    } else if (state is DocumentoPersonalError && _deletingId != null) {
      setState(() {
        _deletingId = null;
        _deletingNombre = null;
      });
      showResultDialog(
        context: context,
        title: 'Error al eliminar documento',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocumentoPersonalBloc, DocumentoPersonalState>(
      listener: _onStateChanged,
      builder: (BuildContext context, DocumentoPersonalState state) {
        final List<DocumentoPersonalEntity> visibles = _visibles;
        final DocumentoPersonalEntity? selected = _selected;
        return GestionLayout(
          toolbar: GestionStandardToolbar(
            title: 'Documentación del Personal',
            icon: Icons.folder_outlined,
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirDocumentos(visibles),
          ),
          filterBar: DocumentacionGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipo: _tipo,
            onTipoChanged: (TipoDocumentoPersonal? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (EstadoDocumentoPersonal? v) => _updateFilters(() => _estado = v),
            columnFilters: _colFilters,
            columns: _columns,
            onColumnFiltersChanged: _onColumnFiltersChanged,
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: GestionGridContent<DocumentoPersonalEntity>(
            hasData: _items != null,
            isLoading: state is DocumentoPersonalLoading,
            errorMessage: state is DocumentoPersonalError ? state.message : null,
            errorTitle: 'Error al cargar la documentación',
            columns: _columns,
            rows: gestionPageOf(visibles, _page, _pageSize),
            filters: _colFilters,
            onFiltersChanged: _onColumnFiltersChanged,
            filterSource: _base,
            rowId: (DocumentoPersonalEntity d) => d.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            onSelect: (DocumentoPersonalEntity d) => setState(() => _selectedId = d.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
            emptyMessage: _hasFilters
                ? 'Ningún documento coincide con los filtros'
                : 'No hay documentos registrados. Pulsa "Nuevo" para añadir uno.',
          ),
          detailPanel: DocumentacionDetailPanel(
            item: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenDocumentos(_items ?? <DocumentoPersonalEntity>[], visibles.length),
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
