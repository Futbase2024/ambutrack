import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/historial_medico/historial_medico_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de historial médico
class HistorialMedicoGestionToolbar extends StatelessWidget {
  const HistorialMedicoGestionToolbar({
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
      title: 'Historial Médico',
      icon: Icons.medical_services_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nuevo',
            tooltip: 'Nuevo reconocimiento médico',
            primary: true,
            onPressed: onNew,
          ),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el reconocimiento seleccionado (doble clic / Intro)',
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

/// Barra de filtros de la pantalla de historial médico
class HistorialMedicoGestionFilters extends StatelessWidget {
  const HistorialMedicoGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.aptitud,
    required this.onAptitudChanged,
    required this.vigencia,
    required this.onVigenciaChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String? aptitud;
  final ValueChanged<String?> onAptitudChanged;
  final VigenciaReconocimiento? vigencia;
  final ValueChanged<VigenciaReconocimiento?> onVigenciaChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar personal, fecha, centro, médico...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Aptitud',
          value: aptitud,
          options: const <String?, String>{
            null: 'Todas',
            ...aptitudesReconocimiento,
          },
          onChanged: onAptitudChanged,
        ),
        GestionFilterDropdown<VigenciaReconocimiento?>(
          label: 'Estado',
          value: vigencia,
          options: <VigenciaReconocimiento?, String>{
            null: 'Todos',
            for (final VigenciaReconocimiento v in VigenciaReconocimiento.values) v: v.label,
          },
          onChanged: onVigenciaChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
