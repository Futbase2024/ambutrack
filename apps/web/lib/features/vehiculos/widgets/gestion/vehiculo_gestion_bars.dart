import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de vehículos
class VehiculoGestionToolbar extends StatelessWidget {
  const VehiculoGestionToolbar({
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    required this.onExport,
    required this.onStock,
    required this.onQr,
    required this.editing,
    required this.onToggleEditing,
    super.key,
  });

  final bool hasSelection;
  final bool editing;
  final VoidCallback onToggleEditing;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;
  final VoidCallback? onExport;
  final VoidCallback onStock;

  /// Imprime la etiqueta QR del vehículo seleccionado
  final VoidCallback onQr;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Vehículos',
      icon: Icons.directions_car,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el vehículo seleccionado (doble clic / Intro)',
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
            icon: editing ? Icons.edit_off_outlined : Icons.edit_note,
            label: editing ? 'Salir de edición' : 'Modo edición',
            tooltip: editing
                ? 'Volver a la rejilla de solo lectura'
                : 'Cambiar CAP, silla, soporte, carros, estado y km en la propia rejilla '
                    'y marcar varios vehículos para cambiarlos a la vez',
            active: editing,
            onPressed: onToggleEditing,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: onRefresh),
          GestionToolbarAction(
            icon: Icons.file_download_outlined,
            label: 'Exportar',
            tooltip: 'Imprimir o exportar a PDF / Excel el listado, la ficha o el informe completo',
            onPressed: onExport,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.medical_services_outlined,
            label: 'Stock',
            tooltip: 'Abrir el stock de equipamiento del vehículo seleccionado',
            onPressed: hasSelection ? onStock : null,
          ),
          GestionToolbarAction(
            icon: Icons.qr_code_2,
            label: 'Imprimir QR',
            tooltip: 'Imprimir la etiqueta QR del vehículo seleccionado para el salpicadero',
            onPressed: hasSelection ? onQr : null,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de la pantalla de vehículos: búsqueda + filtros de columna activos.
/// Los filtros por valor (estado, tipo, CAP...) se eligen en el embudo de cada cabecera.
class VehiculoGestionFilters extends StatelessWidget {
  const VehiculoGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.columnFilters,
    required this.onColumnFiltersChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
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
          hint: 'Buscar matrícula, marca, modelo, nº interno...',
        ),
        if (columnFilters.isEmpty)
          const Text(
            'Filtra por varios valores con el embudo de cada columna',
            style: TextStyle(fontSize: 12, color: AppColors.gray500),
          )
        else
          GestionColumnFilterChips<VehiculoEntity>(
            filters: columnFilters,
            columns: vehiculoGestionColumns,
            onChanged: onColumnFiltersChanged,
          ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
