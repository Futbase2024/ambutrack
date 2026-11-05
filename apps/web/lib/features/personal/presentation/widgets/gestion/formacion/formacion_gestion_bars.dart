import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/formacion/formacion_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de filtros de la pantalla de formación
class FormacionGestionFilters extends StatelessWidget {
  const FormacionGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String estado;
  final ValueChanged<String> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar por nombre del empleado...',
        ),
        GestionFilterDropdown<String>(
          label: 'Estado',
          value: estado,
          options: formacionEstadoOpciones,
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
