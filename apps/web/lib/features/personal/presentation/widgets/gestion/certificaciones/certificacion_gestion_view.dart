import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/certificacion_catalogo/certificacion_catalogo_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/certificacion_catalogo/certificacion_catalogo_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/certificacion_catalogo/certificacion_catalogo_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/certificacion_form_dialog.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/certificaciones/certificacion_detail_panel.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/certificaciones/certificacion_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/certificaciones/certificacion_gestion_filters.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Catálogo de certificaciones con layout de programa de gestión
class CertificacionGestionView extends StatefulWidget {
  const CertificacionGestionView({super.key});

  @override
  State<CertificacionGestionView> createState() => _CertificacionGestionViewState();
}

class _CertificacionGestionViewState extends State<CertificacionGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  CertificacionEstadoFiltro _estado = CertificacionEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Borrado solicitado desde esta vista (id + nombre para el aviso de éxito)
  String? _deletingId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<CertificacionEntity>? _items;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != CertificacionEstadoFiltro.todos;

  CertificacionEntity? get _selected {
    for (final CertificacionEntity c in _items ?? const <CertificacionEntity>[]) {
      if (c.id == _selectedId) {
        return c;
      }
    }
    return null;
  }

  List<CertificacionEntity> get _visibles => _sort.apply(
        filtrarCertificaciones(_items ?? <CertificacionEntity>[], query: _query, estado: _estado),
        certificacionGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = CertificacionEstadoFiltro.todos;
      });

  void _refresh() =>
      context.read<CertificacionCatalogoBloc>().add(const CertificacionCatalogoLoadRequested());

  Future<void> _openForm([CertificacionEntity? item]) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => CertificacionFormDialog(item: item),
    );
    if (result == true && mounted) {
      _refresh();
    }
  }

  Future<void> _confirmDelete(CertificacionEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar certificación',
      message: '¿Estás seguro de que deseas eliminar esta certificación? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Código': item.codigo,
        'Nombre': item.nombre,
        'Estado': item.activa ? 'Activa' : 'Inactiva',
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingId = item.id;
        _deletingNombre = item.nombre;
      });
      context.read<CertificacionCatalogoBloc>().add(CertificacionCatalogoDeleteRequested(item.id));
    }
  }

  void _onStateChanged(BuildContext context, CertificacionCatalogoState state) {
    if (state is CertificacionCatalogoLoaded) {
      final String? deletingId = _deletingId;
      final bool eliminado = deletingId != null && !state.items.any((CertificacionEntity e) => e.id == deletingId);
      final String? nombre = _deletingNombre;
      setState(() {
        _items = state.items;
        if (eliminado) {
          _deletingId = null;
          _deletingNombre = null;
        }
      });
      if (eliminado) {
        GestionFeedback.eliminado(context, entidad: 'Certificación', nombre: nombre);
      }
    } else if (state is CertificacionCatalogoError && _deletingId != null) {
      setState(() {
        _deletingId = null;
        _deletingNombre = null;
      });
      showResultDialog(
        context: context,
        title: 'Error al eliminar certificación',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CertificacionCatalogoBloc, CertificacionCatalogoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, CertificacionCatalogoState state) {
        final List<CertificacionEntity> visibles = _visibles;
        final CertificacionEntity? selected = _selected;
        return GestionLayout(
          toolbar: GestionStandardToolbar(
            title: 'Catálogo de Certificaciones',
            icon: Icons.verified,
            newLabel: 'Nueva',
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirCertificaciones(visibles),
          ),
          filterBar: CertificacionGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (CertificacionEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: GestionGridContent<CertificacionEntity>(
            hasData: _items != null,
            isLoading: state is CertificacionCatalogoLoading,
            errorMessage: state is CertificacionCatalogoError ? state.message : null,
            errorTitle: 'Error al cargar certificaciones',
            columns: certificacionGestionColumns,
            rows: gestionPageOf(visibles, _page, _pageSize),
            rowId: (CertificacionEntity c) => c.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            onSelect: (CertificacionEntity c) => setState(() => _selectedId = c.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
            emptyMessage: _hasFilters
                ? 'Ninguna certificación coincide con los filtros'
                : 'No hay certificaciones registradas. Pulsa "Nueva" para crear una.',
          ),
          detailPanel: CertificacionDetailPanel(
            certificacion: selected,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenCertificaciones(_items ?? <CertificacionEntity>[], visibles.length),
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
