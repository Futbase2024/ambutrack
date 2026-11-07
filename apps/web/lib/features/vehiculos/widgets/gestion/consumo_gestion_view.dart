import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/consumo_combustible/consumo_combustible_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/consumo_combustible/consumo_combustible_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/consumo_combustible/consumo_combustible_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/consumo/consumo_form_modal.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/consumo_detail_panel.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/consumo_gestion_bars.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/consumo_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de consumo y kilometraje con layout de programa de gestión.
///
/// El BLoC entrega el listado COMPLETO de registros filtrado por vehículo y
/// fechas, junto con las estadísticas del filtro; la vista busca, ordena,
/// cuenta, imprime y pagina en cliente sobre ese listado.
class ConsumoGestionView extends StatefulWidget {
  const ConsumoGestionView({super.key});

  @override
  State<ConsumoGestionView> createState() => _ConsumoGestionViewState();
}

class _ConsumoGestionViewState extends State<ConsumoGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  GestionSort _sort = const GestionSort(columnIndex: 0, ascending: false);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;

  /// Identificador del repostaje cuyo borrado está en curso (para el aviso de éxito)
  String? _deletingNombre;

  /// Último listado recibido del BLoC (evita parpadeos durante recargas)
  ConsumoSnapshot? _data;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ConsumoCombustibleBloc get _bloc => context.read<ConsumoCombustibleBloc>();

  bool get _hasFilters => _query.isNotEmpty || (_data?.hasBlocFilters ?? false);

  ConsumoCombustibleEntity? get _selected {
    for (final ConsumoCombustibleEntity c in _data?.registros ?? const <ConsumoCombustibleEntity>[]) {
      if (c.id == _selectedId) {
        return c;
      }
    }
    return null;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _query = '';
      _page = 0;
    });
    _bloc.add(const ConsumoCombustibleEvent.clearFilters());
  }

  /// Lanza un filtro del BLoC volviendo a la primera página
  void _filterBloc(ConsumoCombustibleEvent event) {
    setState(() => _page = 0);
    _bloc.add(event);
  }

  void _refresh() => _bloc.add(const ConsumoCombustibleEvent.loadRegistros());

  Future<void> _openForm([ConsumoCombustibleEntity? consumo]) {
    final ConsumoCombustibleBloc bloc = _bloc;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => ConsumoFormModal(
        consumo: consumo,
        vehiculos: _data?.vehiculos ?? const <VehiculoEntity>[],
        onSave: (ConsumoCombustibleEntity result) async {
          bloc.add(
            consumo == null
                ? ConsumoCombustibleEvent.createRegistro(result)
                : ConsumoCombustibleEvent.updateRegistro(result),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(ConsumoCombustibleEntity consumo, Map<String, VehiculoEntity> vehiculos) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar registro de consumo',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Vehículo': consumoMatricula(consumo, vehiculos),
        'Fecha': GestionFormatters.fecha(consumo.fecha),
        'Litros': flotaDecimal(consumo.litros, sufijo: ' L'),
        'Coste': GestionFormatters.moneda(consumo.costoTotal),
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _deletingNombre = '${consumoMatricula(consumo, vehiculos)} — ${GestionFormatters.fecha(consumo.fecha)}';
      });
      _bloc.add(ConsumoCombustibleEvent.deleteRegistro(consumo.id));
    }
  }

  void _onStateChanged(BuildContext context, ConsumoCombustibleState state) {
    state.whenOrNull<void>(
      loaded: (
        List<ConsumoCombustibleEntity> registros,
        List<VehiculoEntity> vehiculos,
        int currentPage,
        int totalPages,
        Map<String, double> estadisticas,
        String? filtroVehiculoId,
        DateTime? filtroFechaInicio,
        DateTime? filtroFechaFin,
      ) {
        final String? eliminado = _deletingNombre;
        setState(() {
          _deletingNombre = null;
          _data = ConsumoSnapshot(
            registros: registros,
            vehiculos: vehiculos,
            estadisticas: estadisticas,
            filtroVehiculoId: filtroVehiculoId,
            filtroFechaInicio: filtroFechaInicio,
            filtroFechaFin: filtroFechaFin,
          );
        });
        if (eliminado != null) {
          GestionFeedback.eliminado(context, entidad: 'Repostaje', nombre: eliminado);
        }
      },
      error: (String message) {
        _deletingNombre = null;
        if (_data != null) {
          showResultDialog(
            context: context,
            title: 'Error en consumos',
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
    return BlocConsumer<ConsumoCombustibleBloc, ConsumoCombustibleState>(
      listener: _onStateChanged,
      builder: (BuildContext context, ConsumoCombustibleState state) {
        final ConsumoSnapshot? data = _data;
        final Map<String, VehiculoEntity> vehiculos = data?.vehiculosPorId ?? <String, VehiculoEntity>{};
        final List<GestionColumn<ConsumoCombustibleEntity>> columns = consumoGestionColumns(vehiculos);
        final List<ConsumoCombustibleEntity> visibles = _sort.apply(
          buscarConsumos(data?.registros ?? <ConsumoCombustibleEntity>[], vehiculos, _query),
          columns,
        );
        final ConsumoCombustibleEntity? selected = _selected;
        final int page = _page.clamp(0, visibles.isEmpty ? 0 : (visibles.length - 1) ~/ _pageSize);
        return GestionLayout(
          toolbar: ConsumoGestionToolbar(
            hasSelection: selected != null,
            onNew: data == null ? null : _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!, vehiculos),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirConsumos(visibles, vehiculos),
          ),
          filterBar: ConsumoGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => setState(() {
              _query = v;
              _page = 0;
            }),
            vehiculos: data?.vehiculos ?? const <VehiculoEntity>[],
            vehiculoId: data?.filtroVehiculoId,
            onVehiculoChanged: (String? v) => _filterBloc(ConsumoCombustibleEvent.filterByVehiculo(v)),
            fechaInicio: data?.filtroFechaInicio,
            onFechaInicioChanged: (DateTime? f) =>
                _filterBloc(ConsumoCombustibleEvent.filterByFecha(f, data?.filtroFechaFin)),
            fechaFin: data?.filtroFechaFin,
            onFechaFinChanged: (DateTime? f) =>
                _filterBloc(ConsumoCombustibleEvent.filterByFecha(data?.filtroFechaInicio, f)),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: FlotaGridArea(
            hasData: data != null,
            loading: state.maybeWhen(loading: () => true, orElse: () => false),
            errorMessage: state.whenOrNull(error: (String message) => message),
            errorTitle: 'Error al cargar los datos',
            onRetry: _refresh,
            child: GestionGrid<ConsumoCombustibleEntity>(
              columns: columns,
              rows: flotaPageOf(visibles, page, _pageSize),
              rowId: (ConsumoCombustibleEntity c) => c.id,
              selectedId: _selectedId,
              onSelect: (ConsumoCombustibleEntity c) => setState(() => _selectedId = c.id),
              onActivate: _openForm,
              sort: _sort,
              onSort: (GestionSort s) => setState(() => _sort = s),
              firstRowNumber: page * _pageSize + 1,
              emptyMessage: _hasFilters
                  ? 'Ningún registro coincide con los filtros'
                  : 'No hay registros de consumo. Pulsa "Nuevo" para registrar uno.',
            ),
          ),
          detailPanel: ConsumoDetailPanel(
            consumo: selected,
            vehiculos: vehiculos,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!, vehiculos),
          ),
          statusBar: GestionStatusBar(
            items: data == null ? const <String>[] : resumenConsumos(data, visibles.length),
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
