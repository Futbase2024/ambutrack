import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/gestion/centro_hospitalario_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de centros hospitalarios
class CentroHospitalarioGestionToolbar extends StatelessWidget {
  const CentroHospitalarioGestionToolbar({
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
      title: 'Centros Hospitalarios',
      icon: Icons.local_hospital_outlined,
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
            tooltip: 'Editar el centro seleccionado (doble clic / Intro)',
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

/// Barra de filtros de la pantalla de centros hospitalarios
class CentroHospitalarioGestionFilters extends StatelessWidget {
  const CentroHospitalarioGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipos,
    required this.tipo,
    required this.onTipoChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final Map<String, String> tipos;
  final String? tipo;
  final ValueChanged<String?> onTipoChanged;
  final CentroHospitalarioEstadoFiltro estado;
  final ValueChanged<CentroHospitalarioEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre, tipo, localidad, dirección, teléfono...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Tipo',
          value: tipos.containsKey(tipo) ? tipo : null,
          options: <String?, String>{
            null: 'Todos',
            ...tipos,
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<CentroHospitalarioEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <CentroHospitalarioEstadoFiltro, String>{
            CentroHospitalarioEstadoFiltro.todos: 'Todos',
            CentroHospitalarioEstadoFiltro.activos: 'Activos',
            CentroHospitalarioEstadoFiltro.inactivos: 'Inactivos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
