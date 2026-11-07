import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/widgets/gestion/especialidad_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de especialidades médicas
class EspecialidadGestionToolbar extends StatelessWidget {
  const EspecialidadGestionToolbar({
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Especialidades Médicas',
      icon: Icons.medical_services_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nuevo',
            primary: true,
            onPressed: onNew,
          ),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar la especialidad seleccionada (doble clic / Intro)',
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
          GestionToolbarAction(
            icon: Icons.refresh,
            label: 'Actualizar',
            onPressed: onRefresh,
          ),
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

/// Barra de filtros de la pantalla de especialidades médicas
class EspecialidadGestionFilters extends StatelessWidget {
  const EspecialidadGestionFilters({
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
  final EspecialidadEstadoFiltro estado;
  final ValueChanged<EspecialidadEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

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
          options: const <String?, String>{
            null: 'Todos',
            ...especialidadTipos,
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<EspecialidadEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <EspecialidadEstadoFiltro, String>{
            EspecialidadEstadoFiltro.todos: 'Todas',
            EspecialidadEstadoFiltro.activas: 'Activas',
            EspecialidadEstadoFiltro.inactivas: 'Inactivas',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
