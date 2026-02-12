import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Widget de filtros para incidencias de vehículos
///
/// Permite filtrar por estado, prioridad y tipo con dropdowns
class IncidenciaFilters extends StatelessWidget {
  const IncidenciaFilters({
    required this.filtroEstado,
    required this.filtroPrioridad,
    required this.filtroTipo,
    required this.onEstadoChanged,
    required this.onPrioridadChanged,
    required this.onTipoChanged,
    required this.onClearFilters,
    super.key,
  });

  final EstadoIncidencia? filtroEstado;
  final PrioridadIncidencia? filtroPrioridad;
  final TipoIncidencia? filtroTipo;
  final ValueChanged<EstadoIncidencia?> onEstadoChanged;
  final ValueChanged<PrioridadIncidencia?> onPrioridadChanged;
  final ValueChanged<TipoIncidencia?> onTipoChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final bool hayFiltrosActivos =
        filtroEstado != null || filtroPrioridad != null || filtroTipo != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray300,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(width: 12),
              if (hayFiltrosActivos)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(
                    Icons.clear,
                    size: 16,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'Limpiar filtros',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: AppDropdown<EstadoIncidencia?>(
                  label: 'Estado',
                  value: filtroEstado,
                  items: <AppDropdownItem<EstadoIncidencia?>>[
                    const AppDropdownItem<EstadoIncidencia?>(
                      value: null,
                      label: 'Todos',
                    ),
                    ...EstadoIncidencia.values.map(
                      (EstadoIncidencia estado) =>
                          AppDropdownItem<EstadoIncidencia?>(
                        value: estado,
                        label: estado.nombre,
                      ),
                    ),
                  ],
                  onChanged: onEstadoChanged,
                  clearable: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown<PrioridadIncidencia?>(
                  label: 'Prioridad',
                  value: filtroPrioridad,
                  items: <AppDropdownItem<PrioridadIncidencia?>>[
                    const AppDropdownItem<PrioridadIncidencia?>(
                      value: null,
                      label: 'Todas',
                    ),
                    ...PrioridadIncidencia.values.map(
                      (PrioridadIncidencia prioridad) =>
                          AppDropdownItem<PrioridadIncidencia?>(
                        value: prioridad,
                        label: prioridad.nombre,
                      ),
                    ),
                  ],
                  onChanged: onPrioridadChanged,
                  clearable: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown<TipoIncidencia?>(
                  label: 'Tipo',
                  value: filtroTipo,
                  items: <AppDropdownItem<TipoIncidencia?>>[
                    const AppDropdownItem<TipoIncidencia?>(
                      value: null,
                      label: 'Todos',
                    ),
                    ...TipoIncidencia.values.map(
                      (TipoIncidencia tipo) => AppDropdownItem<TipoIncidencia?>(
                        value: tipo,
                        label: tipo.nombre,
                      ),
                    ),
                  ],
                  onChanged: onTipoChanged,
                  clearable: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
