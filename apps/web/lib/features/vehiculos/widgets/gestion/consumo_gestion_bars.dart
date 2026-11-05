import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_bars_common.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de consumo y kilometraje
class ConsumoGestionToolbar extends StatelessWidget {
  const ConsumoGestionToolbar({
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback? onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Consumo y Kilometraje',
      icon: Icons.local_gas_station_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nuevo',
            tooltip: 'Registrar consumo',
            primary: true,
            onPressed: onNew,
          ),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el registro seleccionado (doble clic / Intro)',
            onPressed: hasSelection ? onEdit : null,
          ),
          GestionToolbarAction(
            icon: Icons.delete_outline,
            label: 'Eliminar',
            destructive: true,
            onPressed: hasSelection ? onDelete : null,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: onRefresh),
          GestionToolbarAction(
            icon: Icons.print_outlined,
            label: 'Imprimir',
            tooltip: 'Imprimir o guardar como PDF el listado filtrado',
            onPressed: onPrint,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de la pantalla de consumo.
///
/// Vehículo y fechas los filtra el BLoC; la búsqueda de texto se aplica en la
/// vista sobre el listado completo.
class ConsumoGestionFilters extends StatelessWidget {
  const ConsumoGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.vehiculos,
    required this.vehiculoId,
    required this.onVehiculoChanged,
    required this.fechaInicio,
    required this.onFechaInicioChanged,
    required this.fechaFin,
    required this.onFechaFinChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<VehiculoEntity> vehiculos;
  final String? vehiculoId;
  final ValueChanged<String?> onVehiculoChanged;
  final DateTime? fechaInicio;
  final ValueChanged<DateTime?> onFechaInicioChanged;
  final DateTime? fechaFin;
  final ValueChanged<DateTime?> onFechaFinChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final List<VehiculoEntity> ordenados = List<VehiculoEntity>.of(vehiculos)
      ..sort((VehiculoEntity a, VehiculoEntity b) => a.matricula.compareTo(b.matricula));
    final bool known = vehiculoId == null || ordenados.any((VehiculoEntity v) => v.id == vehiculoId);
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar matrícula, estación, conductor...',
          width: 220,
        ),
        GestionFilterDropdown<String?>(
          label: 'Vehículo',
          value: known ? vehiculoId : null,
          options: <String?, String>{
            null: 'Todos',
            for (final VehiculoEntity v in ordenados) v.id: v.matricula,
          },
          onChanged: onVehiculoChanged,
        ),
        FlotaDateFilter(label: 'Desde', value: fechaInicio, onChanged: onFechaInicioChanged),
        FlotaDateFilter(label: 'Hasta', value: fechaFin, onChanged: onFechaFinChanged),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
