import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/fichajes/fichajes_date_filter.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/fichajes/fichajes_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de fichajes (vista de solo lectura)
class FichajesGestionToolbar extends StatelessWidget {
  const FichajesGestionToolbar({
    required this.onMap,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  /// Abre el mapa del fichaje seleccionado (null = sin selección)
  final VoidCallback? onMap;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: 'Fichajes',
      icon: Icons.location_on_outlined,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.map_outlined,
            label: 'Ver mapa',
            tooltip: 'Ver la ubicación GPS del fichaje seleccionado (doble clic / Intro)',
            onPressed: onMap,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.refresh,
            label: 'Actualizar',
            tooltip: 'Recargar los fichajes de los últimos 30 días',
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

/// Barra de filtros de la pantalla de fichajes
class FichajesGestionFilters extends StatelessWidget {
  const FichajesGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipo,
    required this.onTipoChanged,
    required this.desde,
    required this.onDesdeChanged,
    required this.hasta,
    required this.onHastaChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final FichajeTipoFiltro tipo;
  final ValueChanged<FichajeTipoFiltro> onTipoChanged;
  final DateTime? desde;
  final ValueChanged<DateTime?> onDesdeChanged;
  final DateTime? hasta;
  final ValueChanged<DateTime?> onHastaChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre del personal...',
          width: 260,
        ),
        GestionFilterDropdown<FichajeTipoFiltro>(
          label: 'Tipo',
          value: tipo,
          options: const <FichajeTipoFiltro, String>{
            FichajeTipoFiltro.todos: 'Todos',
            FichajeTipoFiltro.entradas: 'Entradas',
            FichajeTipoFiltro.salidas: 'Salidas',
          },
          onChanged: onTipoChanged,
        ),
        FichajesDateFilter(label: 'Desde', value: desde, onChanged: onDesdeChanged),
        FichajesDateFilter(
          label: 'Hasta',
          value: hasta,
          firstDate: desde,
          onChanged: onHastaChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
