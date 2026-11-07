import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de filtros de la pantalla de personal
class PersonalGestionFilters extends StatelessWidget {
  const PersonalGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.categorias,
    required this.categoriaId,
    required this.onCategoriaChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  /// id de categoría → nombre
  final Map<String, String> categorias;
  final String? categoriaId;
  final ValueChanged<String?> onCategoriaChanged;
  final PersonalEstadoFiltro estado;
  final ValueChanged<PersonalEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final bool categoriaValida = categoriaId == null || categorias.containsKey(categoriaId);
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre, apellidos, DNI, teléfono, email...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Categoría',
          value: categoriaValida ? categoriaId : null,
          options: <String?, String>{null: 'Todas', ...categorias},
          onChanged: onCategoriaChanged,
        ),
        GestionFilterDropdown<PersonalEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <PersonalEstadoFiltro, String>{
            PersonalEstadoFiltro.todos: 'Todos',
            PersonalEstadoFiltro.activos: 'Activos',
            PersonalEstadoFiltro.inactivos: 'Inactivos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
