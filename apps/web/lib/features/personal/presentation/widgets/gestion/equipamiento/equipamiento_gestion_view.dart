import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/equipamiento_personal_form_dialog.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/equipamiento/equipamiento_detail_panel.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/equipamiento/equipamiento_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/equipamiento/equipamiento_gestion_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Equipamiento del personal con layout de programa de gestión
class EquipamientoGestionView extends StatefulWidget {
  const EquipamientoGestionView({super.key});

  @override
  State<EquipamientoGestionView> createState() => _EquipamientoGestionViewState();
}

class _EquipamientoGestionViewState extends State<EquipamientoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _tipo;
  EquipamientoEstadoFiltro _estado = EquipamientoEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 1);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Borrado solicitado desde esta vista (id + nombre para el aviso de éxito)
  String? _deletingId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<EquipamientoPersonalEntity>? _items;

  /// id de personal → nombre completo
  Map<String, String> _nombres = <String, String>{};
  late List<GestionColumn<EquipamientoPersonalEntity>> _columns = equipamientoGestionColumns(_nombres);

  @override
  void initState() {
    super.initState();
    _loadPersonal();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonal() async {
    try {
      final List<PersonalEntity> personal = await getIt<PersonalRepository>().getAll();
      if (mounted) {
        setState(() {
          _nombres = <String, String>{
            for (final PersonalEntity p in personal) p.id: p.nombreCompleto,
          };
          _columns = equipamientoGestionColumns(_nombres);
        });
      }
    } catch (e) {
      debugPrint('❌ EquipamientoGestionView: error al cargar personal: $e');
    }
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _tipo != null || _estado != EquipamientoEstadoFiltro.todos;

  EquipamientoPersonalEntity? get _selected {
    for (final EquipamientoPersonalEntity e in _items ?? const <EquipamientoPersonalEntity>[]) {
      if (e.id == _selectedId) {
        return e;
      }
    }
    return null;
  }

  List<EquipamientoPersonalEntity> get _visibles => _sort.apply(
        filtrarEquipamiento(
          _items ?? <EquipamientoPersonalEntity>[],
          nombres: _nombres,
          query: _query,
          tipo: _tipo,
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
        _tipo = null;
        _estado = EquipamientoEstadoFiltro.todos;
      });

  void _refresh() =>
      context.read<EquipamientoPersonalBloc>().add(const EquipamientoPersonalLoadRequested());

  Future<void> _openForm([EquipamientoPersonalEntity? item]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<EquipamientoPersonalBloc>.value(
        value: context.read<EquipamientoPersonalBloc>(),
        child: EquipamientoPersonalFormDialog(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(EquipamientoPersonalEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar equipamiento',
      message: '¿Estás seguro de que deseas eliminar este equipamiento? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': item.nombreEquipamiento,
        'Tipo': equipamientoTipoLabel(item.tipoEquipamiento),
        if (_nombres[item.personalId] != null) 'Personal': _nombres[item.personalId]!,
        if (item.talla?.isNotEmpty ?? false) 'Talla': item.talla!,
        if (item.numeroSerie?.isNotEmpty ?? false) 'Nº Serie': item.numeroSerie!,
        'Fecha Asignación': GestionFormatters.fecha(item.fechaAsignacion),
        'Estado': item.estaAsignado ? 'Asignado' : 'Devuelto',
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingId = item.id;
        _deletingNombre = item.nombreEquipamiento;
      });
      context.read<EquipamientoPersonalBloc>().add(EquipamientoPersonalDeleteRequested(item.id));
    }
  }

  void _onStateChanged(BuildContext context, EquipamientoPersonalState state) {
    if (state is EquipamientoPersonalLoaded) {
      final String? deletingId = _deletingId;
      final bool eliminado = deletingId != null && !state.items.any((EquipamientoPersonalEntity e) => e.id == deletingId);
      final String? nombre = _deletingNombre;
      setState(() {
        _items = state.items;
        if (eliminado) {
          _deletingId = null;
          _deletingNombre = null;
        }
      });
      if (eliminado) {
        GestionFeedback.eliminado(context, entidad: 'Equipamiento', nombre: nombre);
      }
    } else if (state is EquipamientoPersonalError && _deletingId != null) {
      setState(() {
        _deletingId = null;
        _deletingNombre = null;
      });
      showResultDialog(
        context: context,
        title: 'Error al eliminar equipamiento',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EquipamientoPersonalBloc, EquipamientoPersonalState>(
      listener: _onStateChanged,
      builder: (BuildContext context, EquipamientoPersonalState state) {
        final List<EquipamientoPersonalEntity> visibles = _visibles;
        final EquipamientoPersonalEntity? selected = _selected;
        return GestionLayout(
          toolbar: GestionStandardToolbar(
            title: 'Equipamiento Personal',
            icon: Icons.inventory_2_outlined,
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirEquipamiento(visibles, _nombres),
          ),
          filterBar: EquipamientoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipo: _tipo,
            onTipoChanged: (String? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (EquipamientoEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: GestionGridContent<EquipamientoPersonalEntity>(
            hasData: _items != null,
            isLoading: state is EquipamientoPersonalLoading,
            errorMessage: state is EquipamientoPersonalError ? state.message : null,
            errorTitle: 'Error al cargar equipamiento',
            columns: _columns,
            rows: gestionPageOf(visibles, _page, _pageSize),
            rowId: (EquipamientoPersonalEntity e) => e.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            onSelect: (EquipamientoPersonalEntity e) => setState(() => _selectedId = e.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
            emptyMessage: _hasFilters
                ? 'Ningún equipamiento coincide con los filtros'
                : 'No hay equipamiento registrado. Pulsa "Nuevo" para asignar uno.',
          ),
          detailPanel: EquipamientoDetailPanel(
            item: selected,
            personalNombre: selected == null ? null : _nombres[selected.personalId],
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenEquipamiento(_items ?? <EquipamientoPersonalEntity>[], visibles.length),
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
