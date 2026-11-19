import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/incidencia_vehiculo_repository.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/incidencia_vehiculo/incidencia_vehiculo_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/incidencias/incidencia_form_modal.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/averia_detail_panel.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/averia_gestion_bars.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/averia_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/averia_orden_reparacion.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de historial de averías con layout de programa de gestión.
///
/// El BLoC entrega el listado COMPLETO de incidencias filtrado por
/// estado/prioridad/tipo; la vista busca, ordena, cuenta, imprime y pagina
/// en cliente sobre ese listado.
class AveriaGestionView extends StatefulWidget {
  const AveriaGestionView({super.key});

  @override
  State<AveriaGestionView> createState() => _AveriaGestionViewState();
}

class _AveriaGestionViewState extends State<AveriaGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  /// Filtros por columna (estilo Excel, varios valores por columna)
  GestionColumnFilters _colFilters = const GestionColumnFilters();
  GestionSort _sort = const GestionSort(columnIndex: 0, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Se incrementa para recargar las órdenes vinculadas de la ficha
  int _ordenesRefresh = 0;

  /// Identificador de la avería cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingNombre;

  /// Último listado recibido del BLoC (evita parpadeos durante recargas)
  AveriasSnapshot? _data;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IncidenciaVehiculoBloc get _bloc => context.read<IncidenciaVehiculoBloc>();

  bool get _hasFilters => _query.isNotEmpty || !_colFilters.isEmpty || (_data?.hasBlocFilters ?? false);

  IncidenciaVehiculoEntity? get _selected {
    for (final IncidenciaVehiculoEntity i in _data?.incidencias ?? const <IncidenciaVehiculoEntity>[]) {
      if (i.id == _selectedId) {
        return i;
      }
    }
    return null;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _query = '';
      _colFilters = const GestionColumnFilters();
      _page = 0;
    });
    _bloc.add(const IncidenciaVehiculoEvent.clearFilters());
  }

  void _onColumnFiltersChanged(GestionColumnFilters f) => setState(() {
        _colFilters = f;
        _page = 0;
      });

  /// Lanza un filtro del BLoC volviendo a la primera página
  void _filterBloc(IncidenciaVehiculoEvent event) {
    setState(() => _page = 0);
    _bloc.add(event);
  }

  void _refresh() {
    _bloc.add(const IncidenciaVehiculoEvent.loadIncidencias());
    context.read<VehiculosBloc>().add(const VehiculosRefreshRequested());
  }

  Future<void> _openForm([IncidenciaVehiculoEntity? incidencia]) {
    final IncidenciaVehiculoBloc bloc = _bloc;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VehiculosBloc>.value(value: context.read<VehiculosBloc>()),
          BlocProvider<TallerBloc>.value(value: context.read<TallerBloc>()),
        ],
        child: IncidenciaFormModal(
          incidencia: incidencia,
          onSave: (IncidenciaVehiculoEntity result) async {
            bloc.add(
              incidencia == null
                  ? IncidenciaVehiculoEvent.createIncidencia(result)
                  : IncidenciaVehiculoEvent.updateIncidencia(result),
            );
          },
        ),
      ),
    );
  }

  /// Crea una orden de reparación desde la avería y la pasa a "En reparación"
  Future<void> _crearOrden(IncidenciaVehiculoEntity incidencia) async {
    final OrdenReparacionEntity? orden = await crearOrdenDesdeAveria(context, incidencia);
    if (orden == null || !mounted) {
      return;
    }
    setState(() => _ordenesRefresh++);
    _bloc.add(IncidenciaVehiculoEvent.updateIncidencia(averiaTrasCrearOrden(incidencia, orden)));
  }

  /// Vuelve a enviar el aviso de la avería (notificación + push) a los gestores de flota
  Future<void> _reenviarAviso(IncidenciaVehiculoEntity incidencia) async {
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Reenviar aviso',
      message: 'Se volverá a notificar la avería "${incidencia.titulo}" a los gestores de flota '
          '(también en el móvil).\n\n¿Quieres reenviar el aviso?',
      confirmText: 'Reenviar',
      icon: Icons.notifications_active_outlined,
      iconColor: AppColors.warning,
      confirmButtonColor: AppColors.warning,
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      final int avisados = await getIt<IncidenciaVehiculoRepository>().reenviarAviso(incidencia.id);
      if (!mounted) {
        return;
      }
      await showResultDialog(
        context: context,
        title: avisados > 0 ? 'Aviso reenviado' : 'Nadie a quien avisar',
        message: avisados > 0
            ? 'Se ha avisado a $avisados ${avisados == 1 ? 'gestor' : 'gestores'} de flota.'
            : 'No hay otros gestores de flota activos a los que enviar el aviso.',
        type: avisados > 0 ? ResultType.success : ResultType.warning,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      await showResultDialog(
        context: context,
        title: 'No se pudo reenviar el aviso',
        message: 'Ha ocurrido un error al reenviar el aviso de la avería.',
        details: e.toString(),
        type: ResultType.error,
      );
    }
  }

  Future<void> _confirmDelete(IncidenciaVehiculoEntity incidencia, Map<String, VehiculoEntity> vehiculos) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar incidencia',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Título': incidencia.titulo,
        'Vehículo': averiaVehiculo(incidencia, vehiculos),
        'Fecha': GestionFormatters.fecha(incidencia.fechaReporte),
        'Tipo': incidencia.tipo.nombre,
        'Estado': incidencia.estado.nombre,
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingNombre = '${incidencia.titulo} — ${averiaVehiculo(incidencia, vehiculos)}';
      });
      _bloc.add(IncidenciaVehiculoEvent.deleteIncidencia(incidencia.id));
    }
  }

  void _onStateChanged(BuildContext context, IncidenciaVehiculoState state) {
    state.whenOrNull<void>(
      loaded:
          (
            List<IncidenciaVehiculoEntity> incidencias,
            int currentPage,
            int totalPages,
            EstadoIncidencia? filtroEstado,
            PrioridadIncidencia? filtroPrioridad,
            TipoIncidencia? filtroTipo,
          ) {
            final String? eliminado = _deletingNombre;
            setState(() {
              _deletingNombre = null;
              _data = AveriasSnapshot(
                incidencias: incidencias,
                filtroEstado: filtroEstado,
                filtroPrioridad: filtroPrioridad,
                filtroTipo: filtroTipo,
              );
            });
            if (eliminado != null) {
              GestionFeedback.eliminado(context, entidad: 'Avería', nombre: eliminado);
            }
          },
      error: (String message) {
        _deletingNombre = null;
        if (_data != null) {
          showResultDialog(
            context: context,
            title: 'Error en averías',
            message: 'No se pudo completar la operación.',
            details: message,
            type: ResultType.error,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final VehiculosState vState = context.watch<VehiculosBloc>().state;
    final Map<String, VehiculoEntity> vehiculos = <String, VehiculoEntity>{
      if (vState is VehiculosLoaded)
        for (final VehiculoEntity v in vState.vehiculos) v.id: v,
    };
    final List<GestionColumn<IncidenciaVehiculoEntity>> columns = averiaGestionColumns(vehiculos);
    return BlocConsumer<IncidenciaVehiculoBloc, IncidenciaVehiculoState>(
      listener: _onStateChanged,
      builder: (BuildContext context, IncidenciaVehiculoState state) {
        final AveriasSnapshot? data = _data;
        // Base: búsqueda aplicada (valores posibles de los filtros de columna)
        final List<IncidenciaVehiculoEntity> base =
            buscarAverias(data?.incidencias ?? <IncidenciaVehiculoEntity>[], vehiculos, _query);
        final List<IncidenciaVehiculoEntity> visibles = _sort.apply(_colFilters.apply(base, columns), columns);
        final IncidenciaVehiculoEntity? selected = _selected;
        final int page = _page.clamp(0, visibles.isEmpty ? 0 : (visibles.length - 1) ~/ _pageSize);
        return GestionLayout(
          toolbar: AveriaGestionToolbar(
            hasSelection: selected != null,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!, vehiculos),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirAverias(visibles, vehiculos),
          ),
          filterBar: AveriaGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => setState(() {
              _query = v;
              _page = 0;
            }),
            estado: data?.filtroEstado,
            onEstadoChanged: (EstadoIncidencia? v) => _filterBloc(IncidenciaVehiculoEvent.filterByEstado(v)),
            prioridad: data?.filtroPrioridad,
            onPrioridadChanged: (PrioridadIncidencia? v) => _filterBloc(IncidenciaVehiculoEvent.filterByPrioridad(v)),
            tipo: data?.filtroTipo,
            onTipoChanged: (TipoIncidencia? v) => _filterBloc(IncidenciaVehiculoEvent.filterByTipo(v)),
            columns: columns,
            columnFilters: _colFilters,
            onColumnFiltersChanged: _onColumnFiltersChanged,
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: FlotaGridArea(
            hasData: data != null,
            loading: state.maybeWhen(loading: () => true, orElse: () => false),
            errorMessage: state.whenOrNull(error: (String message) => message),
            errorTitle: 'Error al cargar incidencias',
            onRetry: _refresh,
            child: GestionGrid<IncidenciaVehiculoEntity>(
              columns: columns,
              rows: flotaPageOf(visibles, page, _pageSize),
              filters: _colFilters,
              onFiltersChanged: _onColumnFiltersChanged,
              filterSource: base,
              rowId: (IncidenciaVehiculoEntity i) => i.id,
              selectedId: _selectedId,
              onSelect: (IncidenciaVehiculoEntity i) => setState(() => _selectedId = i.id),
              onActivate: _openForm,
              sort: _sort,
              onSort: (GestionSort s) => setState(() => _sort = s),
              firstRowNumber: page * _pageSize + 1,
              emptyMessage: _hasFilters
                  ? 'Ninguna avería coincide con los filtros'
                  : 'No hay averías registradas. Pulsa "Nuevo" para reportar una.',
            ),
          ),
          detailPanel: AveriaDetailPanel(
            incidencia: selected,
            vehiculos: vehiculos,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!, vehiculos),
            onCrearOrden: () => _crearOrden(selected!),
            onReenviarAviso: () => _reenviarAviso(selected!),
            ordenesRefresh: _ordenesRefresh,
          ),
          statusBar: GestionStatusBar(
            items: data == null ? const <String>[] : resumenAverias(data, visibles.length),
            pagination: GestionPagination(
              page: page,
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
}
