import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_columns.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_estado.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de equipamiento de un vehículo.
///
/// [puedeGestionar]: admin / jefe de mantenimiento (añadir extras y excluir items).
class EquipamientoToolbar extends StatelessWidget {
  const EquipamientoToolbar({
    required this.title,
    required this.loading,
    required this.puedeGestionar,
    required this.onEditar,
    required this.onAdjuntar,
    required this.onAddExtra,
    required this.onRefresh,
    required this.onPrint,
    required this.onClose,
    super.key,
  });

  final String title;
  final bool loading;
  final bool puedeGestionar;

  /// null = sin selección o no editable
  final VoidCallback? onEditar;
  final VoidCallback? onAdjuntar;
  final VoidCallback onAddExtra;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: title,
      icon: Icons.medical_services_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.edit_note,
            label: 'Registrar',
            tooltip: 'Registrar cantidad, caducidad y lote del item seleccionado',
            primary: true,
            onPressed: onEditar,
          ),
          GestionToolbarAction(
            icon: Icons.attach_file,
            label: 'Adjuntar',
            tooltip: 'Adjuntar documento (PDF o imagen) al item seleccionado',
            onPressed: onAdjuntar,
          ),
          if (puedeGestionar)
            GestionToolbarAction(
              icon: Icons.add,
              label: 'Añadir extra',
              tooltip: 'Añadir material que no está en la plantilla',
              onPressed: loading ? null : onAddExtra,
            ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: loading ? null : onRefresh),
          GestionToolbarAction(
            icon: Icons.print_outlined,
            label: 'Imprimir',
            tooltip: 'Imprimir o guardar como PDF el listado filtrado',
            onPressed: onPrint,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.close,
            label: 'Cerrar',
            tooltip: 'Volver al listado de vehículos',
            destructive: true,
            onPressed: onClose,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de la pantalla de equipamiento
class EquipamientoFilters extends StatelessWidget {
  const EquipamientoFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.vista,
    required this.onVistaChanged,
    required this.secciones,
    required this.seccion,
    required this.onSeccionChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final EquipamientoVista vista;
  final ValueChanged<EquipamientoVista> onVistaChanged;
  final List<String> secciones;
  final String? seccion;
  final ValueChanged<String?> onSeccionChanged;
  final EstadoDotacion? estado;
  final ValueChanged<EstadoDotacion?> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar item, lote, observaciones...',
        ),
        GestionFilterDropdown<EquipamientoVista>(
          label: 'Ver',
          value: vista,
          options: <EquipamientoVista, String>{
            for (final EquipamientoVista v in EquipamientoVista.values) v: v.label,
          },
          onChanged: onVistaChanged,
        ),
        GestionFilterDropdown<String?>(
          label: 'Sección',
          value: secciones.contains(seccion) ? seccion : null,
          options: <String?, String>{null: 'Todas', for (final String s in secciones) s: s},
          onChanged: onSeccionChanged,
        ),
        GestionFilterDropdown<EstadoDotacion?>(
          label: 'Estado',
          value: estado,
          options: <EstadoDotacion?, String>{
            null: 'Todos',
            for (final EstadoDotacion e in EstadoDotacion.values) e: e.label,
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
