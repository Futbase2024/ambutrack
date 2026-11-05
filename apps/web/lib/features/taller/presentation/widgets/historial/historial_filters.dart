import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/historial/historial_columns.dart';
import 'package:flutter/material.dart';

/// Barra de filtros del historial de reparaciones
class HistorialFilters extends StatelessWidget {
  const HistorialFilters({
    required this.searchController,
    required this.filtro,
    required this.vehiculos,
    required this.talleres,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final HistorialFiltro filtro;

  /// Opciones de vehículo / taller derivadas de los datos
  final Map<String, String> vehiculos;
  final Map<String, String> talleres;
  final ValueChanged<HistorialFiltro> onChanged;
  final VoidCallback? onClear;

  HistorialFiltro _with({
    String? query,
    String? estado,
    String? vehiculo,
    String? taller,
    OrigenOrdenReparacion? origen,
    bool clearOrigen = false,
    DateTimeRange? rango,
    bool clearRango = false,
  }) {
    return HistorialFiltro(
      query: query ?? filtro.query,
      estado: estado ?? filtro.estado,
      vehiculo: vehiculo ?? filtro.vehiculo,
      taller: taller ?? filtro.taller,
      origen: clearOrigen ? null : origen ?? filtro.origen,
      rango: clearRango ? null : rango ?? filtro.rango,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TallerConsultaFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          width: 240,
          hint: 'Buscar nº orden, matrícula, taller...',
          onChanged: (String v) => onChanged(_with(query: v)),
        ),
        GestionFilterDropdown<String>(
          label: 'Estado',
          value: filtro.estado,
          options: historialEstadoOptions,
          onChanged: (String v) => onChanged(_with(estado: v)),
        ),
        GestionFilterDropdown<String>(
          label: 'Vehículo',
          value: vehiculos.containsKey(filtro.vehiculo) ? filtro.vehiculo : tallerFiltroTodos,
          options: vehiculos,
          onChanged: (String v) => onChanged(_with(vehiculo: v)),
        ),
        GestionFilterDropdown<String>(
          label: 'Taller',
          value: talleres.containsKey(filtro.taller) ? filtro.taller : tallerFiltroTodos,
          options: talleres,
          onChanged: (String v) => onChanged(_with(taller: v)),
        ),
        GestionFilterDropdown<String>(
          label: 'Origen',
          value: filtro.origen?.value ?? tallerFiltroTodos,
          options: <String, String>{
            tallerFiltroTodos: 'Todos',
            for (final OrigenOrdenReparacion o in OrigenOrdenReparacion.values) o.value: o.displayName,
          },
          onChanged: (String v) => onChanged(
            v.isEmpty ? _with(clearOrigen: true) : _with(origen: OrigenOrdenReparacion.fromString(v)),
          ),
        ),
        TallerDateRangeFilter(
          label: 'Salida',
          rango: filtro.rango,
          onChanged: (DateTimeRange? r) => onChanged(_with(rango: r, clearRango: r == null)),
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
