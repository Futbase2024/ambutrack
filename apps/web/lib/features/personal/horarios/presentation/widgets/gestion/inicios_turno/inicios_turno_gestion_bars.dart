import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicios_turno_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de inicios de turno
class IniciosTurnoGestionToolbar extends StatelessWidget {
  const IniciosTurnoGestionToolbar({
    required this.onAprobar,
    required this.onRechazar,
    required this.onFoto,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  /// null = sin selección o el inicio no está pendiente
  final VoidCallback? onAprobar;
  final VoidCallback? onRechazar;

  /// null = sin selección o sin foto
  final VoidCallback? onFoto;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Inicios de turno',
      icon: Icons.play_circle_outline,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.check_circle_outline,
            label: 'Aprobar',
            primary: true,
            tooltip: 'Aprobar el inicio de turno pendiente seleccionado',
            onPressed: onAprobar,
          ),
          GestionToolbarAction(
            icon: Icons.cancel_outlined,
            label: 'Rechazar',
            destructive: true,
            tooltip: 'Rechazar el inicio de turno pendiente seleccionado (pide motivo)',
            onPressed: onRechazar,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.photo_camera_outlined,
            label: 'Foto km',
            tooltip: 'Ver la foto del cuentakilómetros del inicio seleccionado',
            onPressed: onFoto,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.refresh,
            label: 'Actualizar',
            tooltip: 'Recargar los inicios de turno de los últimos 30 días',
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

/// Barra de filtros de la pantalla de inicios de turno
class IniciosTurnoGestionFilters extends StatelessWidget {
  const IniciosTurnoGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.filtro,
    required this.onFiltroChanged,
    required this.pendientes,
    required this.columnFilters,
    required this.onColumnFiltersChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final InicioTurnoFiltro filtro;
  final ValueChanged<InicioTurnoFiltro> onFiltroChanged;

  /// Nº de inicios pendientes (se muestra en la opción del filtro)
  final int pendientes;
  final GestionColumnFilters columnFilters;
  final ValueChanged<GestionColumnFilters> onColumnFiltersChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar técnico, compañero o matrícula...',
          width: 280,
        ),
        GestionFilterDropdown<InicioTurnoFiltro>(
          label: 'Mostrar',
          value: filtro,
          options: <InicioTurnoFiltro, String>{
            InicioTurnoFiltro.pendientes: 'Pendientes ($pendientes)',
            InicioTurnoFiltro.todos: 'Todos',
          },
          onChanged: onFiltroChanged,
        ),
        GestionColumnFilterChips<InicioTurnoEntity>(
          filters: columnFilters,
          columns: iniciosTurnoColumns,
          onChanged: onColumnFiltersChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
