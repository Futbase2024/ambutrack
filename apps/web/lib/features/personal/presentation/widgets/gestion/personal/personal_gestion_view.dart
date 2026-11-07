import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_detail_panel.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_gestion_filters.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_lookups.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/personal_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de personal con layout de programa de gestión:
/// barra de herramientas + filtros + rejilla + ficha lateral + barra de estado
class PersonalGestionView extends StatefulWidget {
  const PersonalGestionView({super.key});

  @override
  State<PersonalGestionView> createState() => _PersonalGestionViewState();
}

class _PersonalGestionViewState extends State<PersonalGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  /// Registro abierto desde la búsqueda global (Ctrl+K): solo se muestra ese
  String? _soloId;
  String? _enlaceAplicado;
  String? _categoriaId;
  PersonalEstadoFiltro _estado = PersonalEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<PersonalEntity>? _personal;
  PersonalLookups _lookups = const PersonalLookups();

  @override
  void initState() {
    super.initState();
    final PersonalState state = context.read<PersonalBloc>().state;
    if (state is PersonalLoaded) {
      _personal = state.personal;
    }
    _loadLookups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    final PersonalLookups lookups = await PersonalLookups.load();
    if (mounted) {
      setState(() => _lookups = lookups);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GestionDeepLink enlace = GestionDeepLink.of(context);
    if (enlace.isEmpty || enlace.clave == _enlaceAplicado) {
      return;
    }
    _enlaceAplicado = enlace.clave;
    _soloId = enlace.id;
    _selectedId = enlace.id;
    _query = '';
    _searchController.text = enlace.texto ?? '';
    _page = 0;
  }

  List<PersonalEntity> _filtrarEnlace(List<PersonalEntity> items) =>
      _soloId == null ? items : items.where((PersonalEntity e) => e.id == _soloId).toList();

  bool get _hasFilters =>
      _soloId != null || _query.isNotEmpty || _categoriaId != null || _estado != PersonalEstadoFiltro.todos;

  PersonalEntity? get _selected {
    for (final PersonalEntity p in _personal ?? const <PersonalEntity>[]) {
      if (p.id == _selectedId) {
        return p;
      }
    }
    return null;
  }

  List<PersonalEntity> get _visibles => _sort.apply(
        filtrarPersonal(
          _filtrarEnlace(_personal ?? <PersonalEntity>[]),
          query: _query,
          categoriaId: _categoriaId,
          estado: _estado,
        ),
        personalGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _soloId = null;
        _query = '';
        _categoriaId = null;
        _estado = PersonalEstadoFiltro.todos;
      });

  void _refresh() => context.read<PersonalBloc>().add(const PersonalLoadRequested());

  Future<void> _openForm([PersonalEntity? persona]) {
    debugPrint('🚀 PersonalGestionView: abriendo formulario (${persona == null ? 'nuevo' : persona.id})');
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<PersonalBloc>.value(
        value: context.read<PersonalBloc>(),
        child: PersonalFormDialog(persona: persona),
      ),
    );
  }

  Future<void> _confirmDelete(PersonalEntity p) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar personal',
      message: '¿Estás seguro de que deseas eliminar este personal? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': p.nombre,
        'Apellidos': p.apellidos,
        if (p.dni?.isNotEmpty ?? false) 'DNI': p.dni!,
        if (p.categoria?.isNotEmpty ?? false) 'Categoría': p.categoria!,
        if (p.telefono?.isNotEmpty ?? false) 'Teléfono': p.telefono!,
        if (p.movil?.isNotEmpty ?? false) 'Móvil': p.movil!,
        if (p.email?.isNotEmpty ?? false) 'Email': p.email!,
        if (p.fechaInicio != null) 'Fecha Inicio': GestionFormatters.fecha(p.fechaInicio),
      },
    );
    if (confirmed == true && mounted) {
      debugPrint('🗑️ Eliminando personal: ${p.nombreCompleto} (${p.id})');
      setState(() {
        _selectedId = null;
        _deletingNombre = p.nombreCompleto;
      });
      context.read<PersonalBloc>().add(PersonalDeleteRequested(id: p.id));
    }
  }

  void _onStateChanged(BuildContext context, PersonalState state) {
    if (state is PersonalLoaded) {
      final String? eliminado = _deletingNombre;
      setState(() {
        _personal = state.personal;
        _deletingNombre = null;
      });
      if (eliminado != null) {
        GestionFeedback.eliminado(context, entidad: 'Personal', nombre: eliminado);
      }
    } else if (state is PersonalError && _deletingNombre != null) {
      setState(() => _deletingNombre = null);
      showResultDialog(
        context: context,
        title: 'Error al eliminar personal',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonalBloc, PersonalState>(
      listener: _onStateChanged,
      builder: (BuildContext context, PersonalState state) {
        final List<PersonalEntity> visibles = _visibles;
        final PersonalEntity? selected = _selected;
        return GestionLayout(
          detailWidth: 400,
          toolbar: GestionStandardToolbar(
            title: 'Personal',
            icon: Icons.people,
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirPersonal(visibles),
          ),
          filterBar: PersonalGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() {
              _soloId = null;
              _query = v;
            }),
            categorias: _lookups.categorias,
            categoriaId: _categoriaId,
            onCategoriaChanged: (String? v) => _updateFilters(() => _categoriaId = v),
            estado: _estado,
            onEstadoChanged: (PersonalEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: GestionGridContent<PersonalEntity>(
            hasData: _personal != null,
            isLoading: state is PersonalLoading,
            errorMessage: state is PersonalError ? state.message : null,
            errorTitle: 'Error al cargar personal',
            columns: personalGestionColumns,
            rows: gestionPageOf(visibles, _page, _pageSize),
            rowId: (PersonalEntity p) => p.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            onSelect: (PersonalEntity p) => setState(() => _selectedId = p.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
            emptyMessage: _hasFilters
                ? 'Ningún empleado coincide con los filtros'
                : 'No hay personal registrado. Pulsa "Nuevo" para crear uno.',
          ),
          detailPanel: PersonalDetailPanel(
            persona: selected,
            lookups: _lookups,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenPersonal(_personal ?? <PersonalEntity>[], visibles.length),
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
