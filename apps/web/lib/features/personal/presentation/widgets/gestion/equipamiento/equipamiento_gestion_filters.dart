import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/equipamiento/equipamiento_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de filtros del equipamiento personal
class EquipamientoGestionFilters extends StatelessWidget {
  const EquipamientoGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipo,
    required this.onTipoChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String? tipo;
  final ValueChanged<String?> onTipoChanged;
  final EquipamientoEstadoFiltro estado;
  final ValueChanged<EquipamientoEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre, personal, talla, nº serie...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Tipo',
          value: tipo,
          options: <String?, String>{
            null: 'Todos',
            for (final String t in equipamientoTipos) t: equipamientoTipoLabel(t),
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<EquipamientoEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <EquipamientoEstadoFiltro, String>{
            EquipamientoEstadoFiltro.todos: 'Todos',
            EquipamientoEstadoFiltro.asignados: 'Asignados',
            EquipamientoEstadoFiltro.devueltos: 'Devueltos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
