import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Barra de filtros para mantenimientos
class MantenimientosFilters extends StatefulWidget {
  const MantenimientosFilters({
    required this.onFilterChanged,
    super.key,
  });

  final void Function(MantenimientosFilterData) onFilterChanged;

  @override
  State<MantenimientosFilters> createState() => _MantenimientosFiltersState();
}

class _MantenimientosFiltersState extends State<MantenimientosFilters> {
  final TextEditingController _searchController = TextEditingController();
  EstadoMantenimiento? _selectedEstado;
  TipoMantenimiento? _selectedTipo;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFilterChanged(
      MantenimientosFilterData(
        searchText: _searchController.text.trim(),
        estado: _selectedEstado,
        tipo: _selectedTipo,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedEstado = null;
      _selectedTipo = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spacing,
      runSpacing: AppSizes.spacing,
      alignment: WrapAlignment.end,
      children: <Widget>[
        // Búsqueda por texto
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar',
              hintText: 'Vehículo, descripción...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
            ),
            onSubmitted: (String value) {
              _applyFilters();
            },
            onChanged: (String value) {
              setState(() {});
            },
          ),
        ),

        // Filtro por estado
        AppDropdown<EstadoMantenimiento?>(
          value: _selectedEstado,
          width: 180,
          label: 'Estado',
          items: const <AppDropdownItem<EstadoMantenimiento?>>[
            AppDropdownItem<EstadoMantenimiento?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<EstadoMantenimiento?>(
              value: EstadoMantenimiento.programado,
              label: 'Programado',
              icon: Icons.schedule,
              iconColor: AppColors.info,
            ),
            AppDropdownItem<EstadoMantenimiento?>(
              value: EstadoMantenimiento.enProceso,
              label: 'En Proceso',
              icon: Icons.build,
              iconColor: AppColors.warning,
            ),
            AppDropdownItem<EstadoMantenimiento?>(
              value: EstadoMantenimiento.completado,
              label: 'Completado',
              icon: Icons.check_circle,
              iconColor: AppColors.success,
            ),
            AppDropdownItem<EstadoMantenimiento?>(
              value: EstadoMantenimiento.cancelado,
              label: 'Cancelado',
              icon: Icons.cancel,
              iconColor: AppColors.error,
            ),
          ],
          onChanged: (EstadoMantenimiento? value) {
            setState(() {
              _selectedEstado = value;
            });
            _applyFilters();
          },
        ),

        // Filtro por tipo
        AppDropdown<TipoMantenimiento?>(
          value: _selectedTipo,
          width: 180,
          label: 'Tipo',
          items: const <AppDropdownItem<TipoMantenimiento?>>[
            AppDropdownItem<TipoMantenimiento?>(
              value: null,
              label: 'Todos',
              icon: Icons.category,
            ),
            AppDropdownItem<TipoMantenimiento?>(
              value: TipoMantenimiento.basico,
              label: 'Básico',
              icon: Icons.build,
              iconColor: AppColors.info,
            ),
            AppDropdownItem<TipoMantenimiento?>(
              value: TipoMantenimiento.completo,
              label: 'Completo',
              icon: Icons.build_circle,
              iconColor: AppColors.warning,
            ),
            AppDropdownItem<TipoMantenimiento?>(
              value: TipoMantenimiento.especial,
              label: 'Especial',
              icon: Icons.star,
              iconColor: AppColors.secondary,
            ),
            AppDropdownItem<TipoMantenimiento?>(
              value: TipoMantenimiento.urgente,
              label: 'Urgente',
              icon: Icons.priority_high,
              iconColor: AppColors.error,
            ),
          ],
          onChanged: (TipoMantenimiento? value) {
            setState(() {
              _selectedTipo = value;
            });
            _applyFilters();
          },
        ),

        // Botón aplicar filtros
        AppButton(
          onPressed: _applyFilters,
          icon: Icons.filter_alt,
          label: 'Filtrar',
        ),

        // Botón limpiar filtros (solo visible si hay filtros activos)
        if (_searchController.text.isNotEmpty ||
            _selectedEstado != null ||
            _selectedTipo != null)
          AppButton(
            onPressed: _clearFilters,
            icon: Icons.clear_all,
            label: 'Limpiar',
            variant: AppButtonVariant.text,
          ),
      ],
    );
  }
}

/// Datos de filtro para mantenimientos
class MantenimientosFilterData {
  const MantenimientosFilterData({
    this.searchText,
    this.estado,
    this.tipo,
  });

  final String? searchText;
  final EstadoMantenimiento? estado;
  final TipoMantenimiento? tipo;

  /// Filtra una lista de mantenimientos según los criterios
  List<MantenimientoEntity> apply(List<MantenimientoEntity> mantenimientos) {
    return mantenimientos.where((MantenimientoEntity mantenimiento) {
      // Filtro por búsqueda de texto
      if (searchText != null && searchText!.isNotEmpty) {
        final String search = searchText!.toLowerCase();
        final bool matchesVehiculo = mantenimiento.vehiculoId.toLowerCase().contains(search);
        final bool matchesDescripcion = mantenimiento.descripcion.toLowerCase().contains(search);
        final bool matchesTaller = mantenimiento.taller?.toLowerCase().contains(search) ?? false;

        if (!matchesVehiculo && !matchesDescripcion && !matchesTaller) {
          return false;
        }
      }

      // Filtro por estado
      if (estado != null && mantenimiento.estado != estado) {
        return false;
      }

      // Filtro por tipo
      if (tipo != null && mantenimiento.tipoMantenimiento != tipo) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters {
    return (searchText != null && searchText!.isNotEmpty) || estado != null || tipo != null;
  }
}
