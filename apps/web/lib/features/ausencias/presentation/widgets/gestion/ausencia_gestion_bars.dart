import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/gestion/ausencia_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de ausencias
class AusenciaGestionToolbar extends StatelessWidget {
  const AusenciaGestionToolbar({
    required this.hasSelection,
    required this.calendario,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onGestionar,
    required this.onRefresh,
    required this.onPrint,
    required this.onToggleVista,
    super.key,
  });

  final bool hasSelection;

  /// true si se está mostrando la vista de calendario
  final bool calendario;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onGestionar;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;
  final VoidCallback onToggleVista;

  @override
  Widget build(BuildContext context) {
    final bool enabled = hasSelection && !calendario;
    return GestionToolbar(
      title: 'Ausencias',
      icon: Icons.event_busy,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar la ausencia seleccionada (doble clic / Intro)',
            onPressed: enabled ? onEdit : null,
          ),
          GestionToolbarAction(
            icon: Icons.delete_outline,
            label: 'Eliminar',
            destructive: true,
            onPressed: enabled ? onDelete : null,
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
            icon: Icons.fact_check_outlined,
            label: 'Gestionar',
            tooltip: 'Aprobar, rechazar, volver a pendiente o eliminar días',
            onPressed: enabled ? onGestionar : null,
          ),
          GestionToolbarAction(
            icon: calendario ? Icons.table_rows_outlined : Icons.calendar_month_outlined,
            label: calendario ? 'Listado' : 'Calendario',
            tooltip: calendario ? 'Volver al listado' : 'Ver el calendario mensual de ausencias',
            onPressed: onToggleVista,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de la pantalla de ausencias
class AusenciaGestionFilters extends StatelessWidget {
  const AusenciaGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipos,
    required this.tipoId,
    required this.onTipoChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<TipoAusenciaEntity> tipos;
  final String? tipoId;
  final ValueChanged<String?> onTipoChanged;
  final EstadoAusencia? estado;
  final ValueChanged<EstadoAusencia?> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final bool tipoValido = tipoId == null || tipos.any((TipoAusenciaEntity t) => t.id == tipoId);
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar personal, tipo, motivo, fecha...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Tipo',
          value: tipoValido ? tipoId : null,
          options: <String?, String>{
            null: 'Todos',
            for (final TipoAusenciaEntity t in tipos) t.id: t.nombre,
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<EstadoAusencia?>(
          label: 'Estado',
          value: estado,
          options: <EstadoAusencia?, String>{
            null: 'Todos',
            for (final EstadoAusencia e in EstadoAusencia.values) e: ausenciaEstadoLabel(e),
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
