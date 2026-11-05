import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de vehículos
class VehiculoGestionToolbar extends StatelessWidget {
  const VehiculoGestionToolbar({
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    required this.onPrint,
    required this.onStock,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;
  final VoidCallback onStock;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Vehículos',
      icon: Icons.directions_car,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el vehículo seleccionado (doble clic / Intro)',
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
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.medical_services_outlined,
            label: 'Stock',
            tooltip: 'Abrir el stock de equipamiento del vehículo seleccionado',
            onPressed: hasSelection ? onStock : null,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de la pantalla de vehículos
class VehiculoGestionFilters extends StatelessWidget {
  const VehiculoGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.tipo,
    required this.onTipoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VehiculoEstado? estado;
  final ValueChanged<VehiculoEstado?> onEstadoChanged;
  final String? tipo;
  final ValueChanged<String?> onTipoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar matrícula, marca, modelo, nº interno...',
        ),
        GestionFilterDropdown<VehiculoEstado?>(
          label: 'Estado',
          value: estado,
          options: <VehiculoEstado?, String>{
            null: 'Todos',
            for (final VehiculoEstado e in VehiculoEstado.values) e: vehiculoEstadoLabel(e),
          },
          onChanged: onEstadoChanged,
        ),
        GestionFilterDropdown<String?>(
          label: 'Tipo',
          value: tipo,
          options: vehiculoTiposFiltro,
          onChanged: onTipoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
