import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_event.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de incidencias
class IncidenciaGestionToolbar extends StatelessWidget {
  const IncidenciaGestionToolbar({
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
      title: 'Incidencias',
      icon: Icons.report_problem_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar la incidencia seleccionada (doble clic / Intro)',
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
      ],
    );
  }
}

/// Barra de filtros de la pantalla de incidencias
class IncidenciaGestionFilters extends StatelessWidget {
  const IncidenciaGestionFilters({
    required this.searchController,
    required this.filters,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final IncidenciaFilters filters;
  final ValueChanged<IncidenciaFilters> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final IncidenciaFilters f = filters;
    final List<Widget> items = <Widget>[
        GestionSearchField(
          controller: searchController,
          width: 260,
          hint: 'Buscar título, descripción, responsable...',
          onChanged: (String v) => onChanged(f.copyWith(searchQuery: () => v)),
        ),
        GestionFilterDropdown<CategoriaIncidencia?>(
          label: 'Categoría',
          value: f.categoria,
          options: <CategoriaIncidencia?, String>{
            null: 'Todas',
            for (final CategoriaIncidencia c in CategoriaIncidencia.values) c: c.displayName,
          },
          onChanged: (CategoriaIncidencia? v) => onChanged(f.copyWith(categoria: () => v)),
        ),
        GestionFilterDropdown<PrioridadIncidencia?>(
          label: 'Prioridad',
          value: f.prioridad,
          options: <PrioridadIncidencia?, String>{
            null: 'Todas',
            for (final PrioridadIncidencia p in PrioridadIncidencia.values) p: p.displayName,
          },
          onChanged: (PrioridadIncidencia? v) => onChanged(f.copyWith(prioridad: () => v)),
        ),
        GestionFilterDropdown<EstadoIncidencia?>(
          label: 'Estado',
          value: f.estado,
          options: <EstadoIncidencia?, String>{
            null: 'Todos',
            for (final EstadoIncidencia e in EstadoIncidencia.values) e: e.displayName,
          },
          onChanged: (EstadoIncidencia? v) => onChanged(f.copyWith(estado: () => v)),
        ),
        IncidenciaDateFilter(
          label: 'Desde',
          value: f.fechaDesde,
          onChanged: (DateTime? d) => onChanged(f.copyWith(fechaDesde: () => d)),
        ),
        IncidenciaDateFilter(
          label: 'Hasta',
          value: f.fechaHasta,
          onChanged: (DateTime? d) => onChanged(f.copyWith(fechaHasta: () => d)),
        ),
        GestionClearFiltersButton(onPressed: onClear),
    ];
    // Desplazable en horizontal: hay más filtros de los que caben en pantallas estrechas
    return GestionFilterBar(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < items.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: 12),
                  items[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Selector de fecha compacto (32px) para la barra de filtros
class IncidenciaDateFilter extends StatelessWidget {
  const IncidenciaDateFilter({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? v = value;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('$label:', style: const TextStyle(fontSize: 12.5, color: AppColors.gray600)),
        const SizedBox(width: 6),
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: v == null ? AppColors.gray300 : AppColors.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  v == null ? 'dd/mm/aaaa' : GestionFormatters.fecha(v),
                  style: TextStyle(fontSize: 13, color: v == null ? AppColors.gray400 : AppColors.gray900),
                ),
                const SizedBox(width: 6),
                if (v == null)
                  const Icon(Icons.calendar_today, size: 13, color: AppColors.gray500)
                else
                  InkWell(
                    onTap: () => onChanged(null),
                    child: const Icon(Icons.close, size: 14, color: AppColors.gray500),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
