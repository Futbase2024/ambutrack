import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/gestion/documentacion_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de documentación de vehículos
class DocumentacionGestionToolbar extends StatelessWidget {
  const DocumentacionGestionToolbar({
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    required this.onPrint,
    required this.onView,
    required this.onRenovar,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;
  final VoidCallback onView;
  final VoidCallback onRenovar;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Documentación',
      icon: Icons.description_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el documento seleccionado (doble clic / Intro)',
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
            icon: Icons.visibility_outlined,
            label: 'Ver',
            tooltip: 'Ver el detalle completo y los archivos adjuntos',
            onPressed: hasSelection ? onView : null,
          ),
          GestionToolbarAction(
            icon: Icons.autorenew,
            label: 'Renovar',
            tooltip: 'Recalcular el estado del documento seleccionado',
            onPressed: hasSelection ? onRenovar : null,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de la pantalla de documentación de vehículos
class DocumentacionGestionFilters extends StatelessWidget {
  const DocumentacionGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipos,
    required this.tipo,
    required this.onTipoChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.vencimiento,
    required this.onVencimientoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  /// Tipos de documento presentes en los datos
  final List<String> tipos;
  final String? tipo;
  final ValueChanged<String?> onTipoChanged;
  final String? estado;
  final ValueChanged<String?> onEstadoChanged;
  final DocVencimientoFiltro vencimiento;
  final ValueChanged<DocVencimientoFiltro> onVencimientoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar matrícula, póliza, compañía...',
          width: 220,
        ),
        GestionFilterDropdown<String?>(
          label: 'Tipo',
          value: tipos.contains(tipo) ? tipo : null,
          options: <String?, String>{null: 'Todos', for (final String t in tipos) t: t},
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<String?>(
          label: 'Estado',
          value: estado,
          options: docEstadosFiltro,
          onChanged: onEstadoChanged,
        ),
        GestionFilterDropdown<DocVencimientoFiltro>(
          label: 'Vencimiento',
          value: vencimiento,
          options: const <DocVencimientoFiltro, String>{
            DocVencimientoFiltro.todos: 'Todos',
            DocVencimientoFiltro.proximos: 'Próximos a vencer',
            DocVencimientoFiltro.vencidos: 'Vencidos',
          },
          onChanged: onVencimientoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
