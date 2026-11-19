import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Barra de filtros de la documentación del personal
class DocumentacionGestionFilters extends StatelessWidget {
  const DocumentacionGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.tipo,
    required this.onTipoChanged,
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
  final TipoDocumentoPersonal? tipo;
  final ValueChanged<TipoDocumentoPersonal?> onTipoChanged;
  final EstadoDocumentoPersonal? estado;
  final ValueChanged<EstadoDocumentoPersonal?> onEstadoChanged;
  final VoidCallback? onClear;
  final GestionColumnFilters columnFilters;
  final List<GestionColumn<DocumentoPersonalEntity>> columns;
  final ValueChanged<GestionColumnFilters> onColumnFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar personal, documento, número...',
        ),
        GestionFilterDropdown<TipoDocumentoPersonal?>(
          label: 'Tipo',
          value: tipo,
          options: <TipoDocumentoPersonal?, String>{
            null: 'Todos',
            for (final TipoDocumentoPersonal t in TipoDocumentoPersonal.values) t: t.label,
          },
          onChanged: onTipoChanged,
        ),
        GestionFilterDropdown<EstadoDocumentoPersonal?>(
          label: 'Estado',
          value: estado,
          options: <EstadoDocumentoPersonal?, String>{
            null: 'Todos',
            for (final EstadoDocumentoPersonal e in EstadoDocumentoPersonal.values) e: e.label,
          },
          onChanged: onEstadoChanged,
        ),
        GestionColumnFilterChips<DocumentoPersonalEntity>(
          filters: columnFilters,
          columns: columns,
          onChanged: onColumnFiltersChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
