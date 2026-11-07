import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/repuestos/control_repuestos_columns.dart';
import 'package:flutter/material.dart';

/// Barra de filtros del control de repuestos
class ControlRepuestosFilters extends StatelessWidget {
  const ControlRepuestosFilters({
    required this.searchController,
    required this.filtro,
    required this.proveedores,
    required this.vehiculos,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ControlRepuestosFiltro filtro;
  final Map<String, String> proveedores;
  final Map<String, String> vehiculos;
  final ValueChanged<ControlRepuestosFiltro> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return TallerConsultaFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          width: 240,
          hint: 'Buscar repuesto, referencia, orden...',
          onChanged: (String v) => onChanged(filtro.copyWith(query: v)),
        ),
        GestionFilterDropdown<String>(
          label: 'Estado',
          value: filtro.estado,
          options: repuestoEstadoOptions,
          onChanged: (String v) => onChanged(filtro.copyWith(estado: v)),
        ),
        GestionFilterDropdown<String>(
          label: 'Proveedor',
          value: proveedores.containsKey(filtro.proveedor) ? filtro.proveedor : tallerFiltroTodos,
          options: proveedores,
          onChanged: (String v) => onChanged(filtro.copyWith(proveedor: v)),
        ),
        GestionFilterDropdown<String>(
          label: 'Vehículo',
          value: vehiculos.containsKey(filtro.vehiculo) ? filtro.vehiculo : tallerFiltroTodos,
          options: vehiculos,
          onChanged: (String v) => onChanged(filtro.copyWith(vehiculo: v)),
        ),
        TallerDateRangeFilter(
          label: 'Pedido',
          rango: filtro.rango,
          onChanged: (DateTimeRange? r) => onChanged(filtro.copyWith(rango: r, clearRango: r == null)),
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
