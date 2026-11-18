import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/certificaciones/certificacion_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de filtros del catálogo de certificaciones
class CertificacionGestionFilters extends StatelessWidget {
  const CertificacionGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.columnFilters,
    required this.columns,
    required this.onColumnFiltersChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final CertificacionEstadoFiltro estado;
  final ValueChanged<CertificacionEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  /// Filtros por columna (embudo de la cabecera) activos
  final GestionColumnFilters columnFilters;
  final List<GestionColumn<CertificacionEntity>> columns;
  final ValueChanged<GestionColumnFilters> onColumnFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar código, nombre o descripción...',
        ),
        GestionFilterDropdown<CertificacionEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <CertificacionEstadoFiltro, String>{
            CertificacionEstadoFiltro.todos: 'Todas',
            CertificacionEstadoFiltro.activas: 'Activas',
            CertificacionEstadoFiltro.inactivas: 'Inactivas',
          },
          onChanged: onEstadoChanged,
        ),
        GestionColumnFilterChips<CertificacionEntity>(
          filters: columnFilters,
          columns: columns,
          onChanged: onColumnFiltersChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
