import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/formacion_details_dialog.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/formacion_personal_form_dialog.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/formacion/formacion_catalogos.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/formacion/formacion_detail_panel.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/formacion/formacion_gestion_bars.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/formacion/formacion_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Formación y certificaciones del personal con layout de programa de gestión
class FormacionGestionView extends StatefulWidget {
  const FormacionGestionView({super.key});

  @override
  State<FormacionGestionView> createState() => _FormacionGestionViewState();
}

class _FormacionGestionViewState extends State<FormacionGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _estado = 'todos';
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<FormacionPersonalEntity>? _items;
  FormacionCatalogos _catalogos = const FormacionCatalogos();
  late List<GestionColumn<FormacionPersonalEntity>> _columns = formacionGestionColumns(_catalogos);

  @override
  void initState() {
    super.initState();
    _loadCatalogos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogos() async {
    final FormacionCatalogos catalogos = await FormacionCatalogos.load();
    if (mounted) {
      setState(() {
        _catalogos = catalogos;
        _columns = formacionGestionColumns(catalogos);
      });
    }
  }

  bool get _hasFilters => _query.isNotEmpty || _estado != 'todos';

  FormacionPersonalEntity? get _selected {
    for (final FormacionPersonalEntity f in _items ?? const <FormacionPersonalEntity>[]) {
      if (f.id == _selectedId) {
        return f;
      }
    }
    return null;
  }

  List<FormacionPersonalEntity> get _visibles => _sort.apply(
        filtrarFormacion(
          _items ?? <FormacionPersonalEntity>[],
          catalogos: _catalogos,
          query: _query,
          estado: _estado,
        ),
        _columns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _estado = 'todos';
      });

  void _refresh() => context.read<FormacionBloc>().add(const FormacionLoadRequested());

  Future<void> _openForm([FormacionPersonalEntity? item]) async {
    final FormacionBloc bloc = context.read<FormacionBloc>();
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<FormacionBloc>.value(
        value: bloc,
        child: FormacionPersonalFormDialog(item: item),
      ),
    );
    if (result == true && mounted) {
      bloc.add(const FormacionLoadRequested());
    }
  }

  Future<void> _openDetails(FormacionPersonalEntity item) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) => FormacionDetailsDialog(
        formacion: item,
        nombreEmpleado: _catalogos.personal(item),
        nombreFormacion: _catalogos.formacion(item),
      ),
    );
  }

  Future<void> _confirmDelete(FormacionPersonalEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar formación',
      message: '¿Estás seguro de que deseas eliminar este registro de formación? '
          'Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Empleado': _catalogos.personal(item),
        'Formación': _catalogos.formacion(item),
        'Expiración': GestionFormatters.fecha(item.fechaExpiracion),
        'Estado': formacionEstadoLabel(item.estado),
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingNombre = '${_catalogos.personal(item)} — ${_catalogos.formacion(item)}';
      });
      context.read<FormacionBloc>().add(FormacionDeleteRequested(item.id));
    }
  }

  void _onStateChanged(BuildContext context, FormacionState state) {
    if (state is FormacionLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _items = state.items;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Formación', nombre: eliminado);
      }
    } else if (state is FormacionError && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error al eliminar formación',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  List<GestionToolbarAction> _extraActions(FormacionPersonalEntity? selected) {
    return <GestionToolbarAction>[
      GestionToolbarAction(
        icon: Icons.visibility_outlined,
        label: 'Detalle',
        tooltip: 'Ver el detalle del registro seleccionado',
        onPressed: selected == null ? null : () => _openDetails(selected),
      ),
      GestionToolbarAction(
        icon: Icons.verified,
        label: 'Certificaciones',
        tooltip: 'Abrir el catálogo de certificaciones',
        onPressed: () => context.go('/personal/formacion/certificaciones'),
      ),
      GestionToolbarAction(
        icon: Icons.menu_book,
        label: 'Cursos',
        tooltip: 'Abrir el catálogo de cursos',
        onPressed: () => context.go('/personal/formacion/cursos'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FormacionBloc, FormacionState>(
      listener: _onStateChanged,
      builder: (BuildContext context, FormacionState state) {
        final List<FormacionPersonalEntity> visibles = _visibles;
        final FormacionPersonalEntity? selected = _selected;
        return GestionLayout(
          toolbar: GestionStandardToolbar(
            title: 'Formación',
            icon: Icons.school,
            newLabel: 'Asignar',
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirFormacion(visibles, _catalogos),
            extraActions: _extraActions(selected),
          ),
          filterBar: FormacionGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            estado: _estado,
            onEstadoChanged: (String v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: GestionGridContent<FormacionPersonalEntity>(
            hasData: _items != null,
            isLoading: state is FormacionLoading,
            errorMessage: state is FormacionError ? state.message : null,
            errorTitle: 'Error al cargar la formación',
            columns: _columns,
            rows: gestionPageOf(visibles, _page, _pageSize),
            rowId: (FormacionPersonalEntity f) => f.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            onSelect: (FormacionPersonalEntity f) => setState(() => _selectedId = f.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
            emptyMessage: _hasFilters
                ? 'Ningún registro coincide con los filtros'
                : 'No hay registros de formación. Pulsa "Asignar" para crear uno.',
          ),
          detailPanel: FormacionDetailPanel(
            item: selected,
            catalogos: _catalogos,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenFormacion(_items ?? <FormacionPersonalEntity>[], visibles.length),
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
