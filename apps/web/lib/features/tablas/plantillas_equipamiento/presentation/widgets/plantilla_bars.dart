import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantilla_items_columns.dart';
import 'package:flutter/material.dart';

/// Acciones de la barra de herramientas de plantillas (null = deshabilitada)
class PlantillaToolbarActions {
  const PlantillaToolbarActions({
    required this.onNuevaPlantilla,
    required this.onRefresh,
    this.onEditarPlantilla,
    this.onNuevoItem,
    this.onEditarItem,
    this.onToggleItem,
    this.onReaplicar,
    this.onPrint,
  });

  final VoidCallback onNuevaPlantilla;
  final VoidCallback onRefresh;
  final VoidCallback? onEditarPlantilla;
  final VoidCallback? onNuevoItem;
  final VoidCallback? onEditarItem;
  final VoidCallback? onToggleItem;
  final VoidCallback? onReaplicar;
  final VoidCallback? onPrint;
}

/// Barra de herramientas de la pantalla de plantillas de equipamiento
class PlantillaToolbar extends StatelessWidget {
  const PlantillaToolbar({
    required this.actions,
    required this.loading,
    required this.itemActivo,
    super.key,
  });

  final PlantillaToolbarActions actions;
  final bool loading;

  /// Estado del item seleccionado (para el texto Desactivar / Activar)
  final bool itemActivo;

  VoidCallback? _si(VoidCallback? cb) => loading ? null : cb;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Plantillas de equipamiento',
      icon: Icons.inventory_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.add,
            label: 'Nuevo item',
            tooltip: 'Añadir material o documento a la plantilla (llega a todos sus vehículos)',
            primary: true,
            onPressed: _si(actions.onNuevoItem),
          ),
          GestionToolbarAction(icon: Icons.edit_outlined, label: 'Editar item', onPressed: _si(actions.onEditarItem)),
          GestionToolbarAction(
            icon: itemActivo ? Icons.block : Icons.check_circle_outline,
            label: itemActivo ? 'Desactivar' : 'Activar',
            tooltip: 'Sacar o volver a meter el item en la plantilla (no borra datos de los vehículos)',
            onPressed: _si(actions.onToggleItem),
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.library_add_outlined,
            label: 'Nueva plantilla',
            onPressed: _si(actions.onNuevaPlantilla),
          ),
          GestionToolbarAction(
            icon: Icons.settings_outlined,
            label: 'Plantilla',
            tooltip: 'Editar nombre, tipos de vehículo y versión de la plantilla',
            onPressed: _si(actions.onEditarPlantilla),
          ),
          GestionToolbarAction(
            icon: Icons.sync,
            label: 'Reaplicar',
            tooltip: 'Crear en los vehículos las líneas que falten (no modifica las existentes)',
            onPressed: _si(actions.onReaplicar),
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: _si(actions.onRefresh)),
          GestionToolbarAction(
            icon: Icons.print_outlined,
            label: 'Imprimir',
            tooltip: 'Imprimir o guardar como PDF los items filtrados',
            onPressed: actions.onPrint,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros: plantilla, texto, sección, tipo y estado
class PlantillaFilters extends StatelessWidget {
  const PlantillaFilters({
    required this.plantillas,
    required this.plantillaId,
    required this.onPlantillaChanged,
    required this.searchController,
    required this.onSearchChanged,
    required this.secciones,
    required this.seccion,
    required this.onSeccionChanged,
    required this.tipo,
    required this.onTipoChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final List<PlantillaEquipamientoEntity> plantillas;
  final String? plantillaId;
  final ValueChanged<String?> onPlantillaChanged;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<String> secciones;
  final String? seccion;
  final ValueChanged<String?> onSeccionChanged;
  final TipoItemEquipamiento? tipo;
  final ValueChanged<TipoItemEquipamiento?> onTipoChanged;
  final ItemEstadoFiltro estado;
  final ValueChanged<ItemEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionFilterDropdown<String?>(
          label: 'Plantilla',
          value: plantillaId,
          options: <String?, String>{
            if (plantillas.isEmpty) null: 'Sin plantillas',
            for (final PlantillaEquipamientoEntity p in plantillas)
              p.id: '${p.nombre}${p.activo ? '' : ' (inactiva)'}',
          },
          onChanged: onPlantillaChanged,
        ),
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar item, código, notas...',
          width: 240,
        ),
        GestionFilterDropdown<String?>(
          label: 'Sección',
          value: secciones.contains(seccion) ? seccion : null,
          options: <String?, String>{null: 'Todas', for (final String s in secciones) s: s},
          onChanged: onSeccionChanged,
        ),
        GestionFilterDropdown<TipoItemEquipamiento?>(
          label: 'Tipo',
          value: tipo,
          options: const <TipoItemEquipamiento?, String>{
            null: 'Todos',
            TipoItemEquipamiento.material: 'Material',
            TipoItemEquipamiento.documento: 'Documento',
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<ItemEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: <ItemEstadoFiltro, String>{
            for (final ItemEstadoFiltro e in ItemEstadoFiltro.values) e: e.label,
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
