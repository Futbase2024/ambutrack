import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/gestion/bases_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de bases
///
/// "Desactivar/Activar" sustituye a "Eliminar": las bases usan baja lógica.
class BasesGestionToolbar extends StatelessWidget {
  const BasesGestionToolbar({
    required this.selected,
    required this.onNew,
    required this.onEdit,
    required this.onToggleActivo,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  final BaseCentroEntity? selected;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onToggleActivo;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selected != null;
    final bool activa = selected?.activo ?? true;
    return GestionToolbar(
      title: 'Bases',
      icon: Icons.location_city,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nueva', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar la base seleccionada (doble clic / Intro)',
            onPressed: hasSelection ? onEdit : null,
          ),
          GestionToolbarAction(
            icon: activa ? Icons.block : Icons.check_circle_outline,
            label: activa ? 'Desactivar' : 'Activar',
            destructive: activa,
            tooltip: activa ? 'Dar de baja la base seleccionada' : 'Reactivar la base seleccionada',
            onPressed: hasSelection ? onToggleActivo : null,
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

/// Barra de filtros de la pantalla de bases
class BasesGestionFilters extends StatelessWidget {
  const BasesGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final BaseEstadoFiltro estado;
  final ValueChanged<BaseEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre, dirección, población, tipo...',
        ),
        GestionFilterDropdown<BaseEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <BaseEstadoFiltro, String>{
            BaseEstadoFiltro.todos: 'Todos',
            BaseEstadoFiltro.activas: 'Activas',
            BaseEstadoFiltro.inactivas: 'Inactivas',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
