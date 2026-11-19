import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitudes_vestuario_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de solicitudes de vestuario
class SolicitudesVestuarioToolbar extends StatelessWidget {
  const SolicitudesVestuarioToolbar({
    required this.onAprobar,
    required this.onRechazar,
    required this.onEntregar,
    required this.onFoto,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  /// null = sin selección o la acción no aplica al estado de la solicitud
  final VoidCallback? onAprobar;
  final VoidCallback? onRechazar;
  final VoidCallback? onEntregar;
  final VoidCallback? onFoto;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Solicitudes de vestuario',
      icon: Icons.assignment_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.local_shipping_outlined,
            label: 'Entregar',
            primary: true,
            tooltip: 'Entregar la prenda (o registrar la devolución) moviendo el stock',
            onPressed: onEntregar,
          ),
          GestionToolbarAction(
            icon: Icons.check_circle_outline,
            label: 'Aprobar',
            tooltip: 'Aprobar la solicitud pendiente seleccionada',
            onPressed: onAprobar,
          ),
          GestionToolbarAction(
            icon: Icons.cancel_outlined,
            label: 'Rechazar',
            destructive: true,
            tooltip: 'Rechazar la solicitud seleccionada (pide motivo)',
            onPressed: onRechazar,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.photo_outlined,
            label: 'Foto',
            tooltip: 'Ver la foto adjunta a la solicitud',
            onPressed: onFoto,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.refresh,
            label: 'Actualizar',
            tooltip: 'Recargar solicitudes y stock',
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

/// Barra de filtros de la pantalla de solicitudes de vestuario
class SolicitudesVestuarioFilters extends StatelessWidget {
  const SolicitudesVestuarioFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.filtro,
    required this.onFiltroChanged,
    required this.abiertas,
    required this.columnFilters,
    required this.onColumnFiltersChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final SolicitudVestuarioFiltro filtro;
  final ValueChanged<SolicitudVestuarioFiltro> onFiltroChanged;

  /// Nº de solicitudes abiertas (pendientes + aprobadas)
  final int abiertas;
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
          hint: 'Buscar trabajador, prenda o talla...',
          width: 280,
        ),
        GestionFilterDropdown<SolicitudVestuarioFiltro>(
          label: 'Mostrar',
          value: filtro,
          options: <SolicitudVestuarioFiltro, String>{
            SolicitudVestuarioFiltro.abiertas: 'Abiertas ($abiertas)',
            SolicitudVestuarioFiltro.todas: 'Todas',
          },
          onChanged: onFiltroChanged,
        ),
        GestionColumnFilterChips<SolicitudVestuarioEntity>(
          filters: columnFilters,
          columns: solicitudesVestuarioColumns,
          onChanged: onColumnFiltersChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
