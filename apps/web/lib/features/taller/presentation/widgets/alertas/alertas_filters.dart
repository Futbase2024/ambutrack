import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/alertas/alertas_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:flutter/material.dart';

/// Barra de filtros de alertas de mantenimiento
class AlertasFilters extends StatelessWidget {
  const AlertasFilters({
    required this.searchController,
    required this.filtro,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final AlertasFiltro filtro;
  final ValueChanged<AlertasFiltro> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return TallerConsultaFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          width: 260,
          hint: 'Buscar matrícula o detalle...',
          onChanged: (String v) => onChanged(filtro.copyWith(query: v)),
        ),
        GestionFilterDropdown<String>(
          label: 'Tipo',
          value: filtro.tipo,
          options: alertaTipoOptions,
          onChanged: (String v) => onChanged(filtro.copyWith(tipo: v)),
        ),
        GestionFilterDropdown<String>(
          label: 'Severidad',
          value: filtro.severidad,
          options: alertaSeveridadOptions,
          onChanged: (String v) => onChanged(filtro.copyWith(severidad: v)),
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
