import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/cursos/curso_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de filtros del catálogo de cursos
class CursoGestionFilters extends StatelessWidget {
  const CursoGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipo,
    required this.onTipoChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.columnFilters,
    required this.columns,
    required this.onColumnFiltersChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String? tipo;
  final ValueChanged<String?> onTipoChanged;
  final CursoEstadoFiltro estado;
  final ValueChanged<CursoEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  /// Filtros por columna (embudo de la cabecera) activos
  final GestionColumnFilters columnFilters;
  final List<GestionColumn<CursoEntity>> columns;
  final ValueChanged<GestionColumnFilters> onColumnFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre o descripción...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Tipo',
          value: tipo,
          options: <String?, String>{
            null: 'Todos',
            for (final String t in <String>[CursoTipo.presencial, CursoTipo.online, CursoTipo.mixto])
              t: cursoTipoLabel(t),
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<CursoEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <CursoEstadoFiltro, String>{
            CursoEstadoFiltro.todos: 'Todos',
            CursoEstadoFiltro.activos: 'Activos',
            CursoEstadoFiltro.inactivos: 'Inactivos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionColumnFilterChips<CursoEntity>(
          filters: columnFilters,
          columns: columns,
          onChanged: onColumnFiltersChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
