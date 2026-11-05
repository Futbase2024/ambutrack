import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_table_cells.dart';
import 'package:flutter/material.dart';

/// Opciones del filtro por estado (incluye "Activas")
final List<AppDropdownItem<String>> _estadoItems = <AppDropdownItem<String>>[
  const AppDropdownItem<String>(value: filtroOrdenesTodas, label: 'Todos los estados'),
  const AppDropdownItem<String>(value: filtroOrdenesActivas, label: 'Activas'),
  ...EstadoOrdenReparacion.values.map(
    (EstadoOrdenReparacion e) => AppDropdownItem<String>(value: e.value, label: e.displayName),
  ),
];

/// Barra de búsqueda + filtro de estado de órdenes
class OrdenFiltersBar extends StatelessWidget {
  const OrdenFiltersBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String estado;
  final ValueChanged<String> onEstadoChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: AppSizes.paddingSmall),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Buscar por nº orden, matrícula o taller...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacingMedium),
            AppDropdown<String>(
              width: 220,
              value: estado,
              label: 'Estado',
              clearable: false,
              items: _estadoItems,
              onChanged: (String? v) => onEstadoChanged(v ?? filtroOrdenesTodas),
            ),
          ],
        ),
      ),
    );
  }
}
