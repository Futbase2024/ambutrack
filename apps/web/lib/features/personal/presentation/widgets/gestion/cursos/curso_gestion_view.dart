import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/certificacion_repository.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/curso_catalogo/curso_catalogo_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/curso_catalogo/curso_catalogo_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/curso_catalogo/curso_catalogo_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/curso_form_dialog.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/cursos/curso_detail_panel.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/cursos/curso_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/cursos/curso_gestion_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Catálogo de cursos con layout de programa de gestión
class CursoGestionView extends StatefulWidget {
  const CursoGestionView({super.key});

  @override
  State<CursoGestionView> createState() => _CursoGestionViewState();
}

class _CursoGestionViewState extends State<CursoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _tipo;
  CursoEstadoFiltro _estado = CursoEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 0);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Borrado solicitado desde esta vista (id + nombre para el aviso de éxito)
  String? _deletingId;
  String? _deletingNombre;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<CursoEntity>? _cursos;

  /// id de certificación → "CÓDIGO - Nombre" (para la ficha)
  final Map<String, String> _certificacionesNombres = <String, String>{};

  @override
  void initState() {
    super.initState();
    _loadCertificaciones();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificaciones() async {
    try {
      final List<CertificacionEntity> certs = await getIt<CertificacionRepository>().getAll();
      if (mounted) {
        setState(() {
          for (final CertificacionEntity c in certs) {
            _certificacionesNombres[c.id] = '${c.codigo} - ${c.nombre}';
          }
        });
      }
    } catch (e) {
      debugPrint('❌ CursoGestionView: error al cargar certificaciones: $e');
    }
  }

  bool get _hasFilters => _query.isNotEmpty || _tipo != null || _estado != CursoEstadoFiltro.todos;

  CursoEntity? get _selected {
    for (final CursoEntity c in _cursos ?? const <CursoEntity>[]) {
      if (c.id == _selectedId) {
        return c;
      }
    }
    return null;
  }

  List<CursoEntity> get _visibles => _sort.apply(
        filtrarCursos(_cursos ?? <CursoEntity>[], query: _query, tipo: _tipo, estado: _estado),
        cursoGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _tipo = null;
        _estado = CursoEstadoFiltro.todos;
      });

  void _refresh() => context.read<CursoCatalogoBloc>().add(const CursoCatalogoLoadRequested());

  Future<void> _openForm([CursoEntity? curso]) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => CursoFormDialog(item: curso),
    );
    if (result == true && mounted) {
      _refresh();
    }
  }

  Future<void> _confirmDelete(CursoEntity curso) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar curso',
      message: '¿Estás seguro de que deseas eliminar este curso? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': curso.nombre,
        'Tipo': cursoTipoLabel(curso.tipo),
        'Duración': '${curso.duracionHoras} h',
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingId = curso.id;
        _deletingNombre = curso.nombre;
      });
      context.read<CursoCatalogoBloc>().add(CursoCatalogoDeleteRequested(curso.id));
    }
  }

  void _onStateChanged(BuildContext context, CursoCatalogoState state) {
    if (state is CursoCatalogoLoaded) {
      final String? deletingId = _deletingId;
      final bool eliminado = deletingId != null && !state.items.any((CursoEntity e) => e.id == deletingId);
      final String? nombre = _deletingNombre;
      setState(() {
        _cursos = state.items;
        if (eliminado) {
          _deletingId = null;
          _deletingNombre = null;
        }
      });
      if (eliminado) {
        GestionFeedback.eliminado(context, entidad: 'Curso', nombre: nombre);
      }
    } else if (state is CursoCatalogoError && _deletingId != null) {
      setState(() {
        _deletingId = null;
        _deletingNombre = null;
      });
      showResultDialog(
        context: context,
        title: 'Error al eliminar curso',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CursoCatalogoBloc, CursoCatalogoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, CursoCatalogoState state) {
        final List<CursoEntity> visibles = _visibles;
        final CursoEntity? selected = _selected;
        return GestionLayout(
          toolbar: GestionStandardToolbar(
            title: 'Catálogo de Cursos',
            icon: Icons.menu_book,
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirCursos(visibles),
          ),
          filterBar: CursoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            tipo: _tipo,
            onTipoChanged: (String? v) => _updateFilters(() => _tipo = v),
            estado: _estado,
            onEstadoChanged: (CursoEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: GestionGridContent<CursoEntity>(
            hasData: _cursos != null,
            isLoading: state is CursoCatalogoLoading,
            errorMessage: state is CursoCatalogoError ? state.message : null,
            errorTitle: 'Error al cargar cursos',
            columns: cursoGestionColumns,
            rows: gestionPageOf(visibles, _page, _pageSize),
            rowId: (CursoEntity c) => c.id,
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            onSelect: (CursoEntity c) => setState(() => _selectedId = c.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
            emptyMessage: _hasFilters
                ? 'Ningún curso coincide con los filtros'
                : 'No hay cursos registrados. Pulsa "Nuevo" para crear uno.',
          ),
          detailPanel: CursoDetailPanel(
            curso: selected,
            certificacionesNombres: _certificacionesNombres,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenCursos(_cursos ?? <CursoEntity>[], visibles.length),
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
