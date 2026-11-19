import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/contratos/domain/repositories/contrato_repository.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_filter.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_event.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Barra de filtros compacta del cuadrante:
/// búsqueda, "solo con turnos", contrato, dotación y limpiar
class CuadranteFilterBar extends StatefulWidget {
  const CuadranteFilterBar({required this.state, super.key});

  final CuadranteLoaded state;

  @override
  State<CuadranteFilterBar> createState() => _CuadranteFilterBarState();
}

class _CuadranteFilterBarState extends State<CuadranteFilterBar> {
  late final TextEditingController _searchController =
      TextEditingController(text: widget.state.filter.searchQuery);

  Map<String?, String> _contratos = const <String?, String>{null: 'Todos'};
  Map<String?, String> _dotaciones = const <String?, String>{null: 'Todas'};

  CuadranteFilter get _filter => widget.state.filter;

  @override
  void initState() {
    super.initState();
    _loadFilterData();
  }

  @override
  void didUpdateWidget(covariant CuadranteFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sincroniza el buscador cuando se limpian los filtros
    if (_filter.searchQuery.isEmpty && _searchController.text.isNotEmpty) {
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga los datos para los filtros (contratos y dotaciones)
  Future<void> _loadFilterData() async {
    try {
      final List<ContratoEntity> contratos = await getIt<ContratoRepository>().getActivos();
      final List<DotacionEntity> dotaciones = await getIt<DotacionesRepository>().getActivas();

      // Ordenar alfabéticamente y eliminar duplicados por ID
      contratos.sort((ContratoEntity a, ContratoEntity b) =>
          (a.tipoContrato ?? a.codigo).toLowerCase().compareTo((b.tipoContrato ?? b.codigo).toLowerCase()));
      dotaciones.sort((DotacionEntity a, DotacionEntity b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

      if (mounted) {
        setState(() {
          _contratos = <String?, String>{
            null: 'Todos',
            for (final ContratoEntity c in contratos)
              c.id: c.tipoContrato != null && c.tipoContrato!.isNotEmpty ? '${c.codigo} - ${c.tipoContrato}' : c.codigo,
          };
          _dotaciones = <String?, String>{
            null: 'Todas',
            for (final DotacionEntity d in dotaciones) d.id: d.nombre,
          };
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando filtros: $e');
    }
  }

  void _emit(CuadranteFilter filter) => context.read<CuadranteBloc>().add(CuadranteFilterChanged(filter));

  /// Copia del filtro permitiendo poner contrato/dotación a null ("Todos")
  CuadranteFilter _withRelations({required String? contratoId, required String? dotacionId}) {
    return CuadranteFilter(
      categoriaServicio: _filter.categoriaServicio,
      puestoId: _filter.puestoId,
      fechaInicio: _filter.fechaInicio,
      fechaFin: _filter.fechaFin,
      soloConTurnos: _filter.soloConTurnos,
      searchQuery: _filter.searchQuery,
      contratoId: contratoId,
      dotacionId: dotacionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: _searchController,
          hint: 'Buscar personal...',
          width: 240,
          onChanged: (String value) => _emit(_filter.copyWith(searchQuery: value)),
        ),
        GestionToggleChip(
          label: 'Solo con turnos',
          icon: Icons.schedule,
          value: _filter.soloConTurnos,
          onChanged: (bool value) => _emit(_filter.copyWith(soloConTurnos: value)),
        ),
        GestionCompactDropdown<String>(
          label: 'Contrato',
          value: _filter.contratoId,
          options: _contratos,
          onChanged: (String? id) => _emit(_withRelations(contratoId: id, dotacionId: _filter.dotacionId)),
        ),
        GestionCompactDropdown<String>(
          label: 'Dotación',
          value: _filter.dotacionId,
          options: _dotaciones,
          onChanged: (String? id) => _emit(_withRelations(contratoId: _filter.contratoId, dotacionId: id)),
        ),
        GestionClearFiltersButton(
          onPressed: _filter.hasActiveFilters
              ? () => context.read<CuadranteBloc>().add(const CuadranteFilterCleared())
              : null,
        ),
      ],
    );
  }
}
