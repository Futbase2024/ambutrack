import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Barra de filtros para dotaciones (patrón Vehículos)
class DotacionesFilters extends StatefulWidget {
  const DotacionesFilters({
    super.key,
    required this.onFilterChanged,
  });

  final void Function(DotacionesFilterData) onFilterChanged;

  @override
  State<DotacionesFilters> createState() => _DotacionesFiltersState();
}

class _DotacionesFiltersState extends State<DotacionesFilters> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTipoDestino;
  bool? _selectedActivo;

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFilterChanged(
      DotacionesFilterData(
        searchText: _searchController.text.trim(),
        tipoDestino: _selectedTipoDestino,
        activo: _selectedActivo,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedTipoDestino = null;
      _selectedActivo = null;
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
          width: 400,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar',
              hintText: 'Nombre, código, descripción...',
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
                vertical: 12,
              ),
              isDense: true,
            ),
            onChanged: (String value) {
              setState(() {});
              _debounceTimer?.cancel();
              _debounceTimer = Timer(
                const Duration(milliseconds: 150),
                _applyFilters,
              );
            },
          ),
        ),

        // Filtro por tipo de destino
        AppDropdown<String?>(
          value: _selectedTipoDestino,
          width: 180,
          label: 'Destino',
          items: const <AppDropdownItem<String?>>[
            AppDropdownItem<String?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<String?>(
              value: 'Hospital',
              label: 'Hospital',
              icon: Icons.local_hospital,
              iconColor: AppColors.error,
            ),
            AppDropdownItem<String?>(
              value: 'Base',
              label: 'Base',
              icon: Icons.home_work,
              iconColor: AppColors.primary,
            ),
            AppDropdownItem<String?>(
              value: 'Contrato',
              label: 'Contrato',
              icon: Icons.description,
              iconColor: AppColors.warning,
            ),
          ],
          onChanged: (String? value) {
            setState(() => _selectedTipoDestino = value);
            _applyFilters();
          },
        ),

        // Filtro por estado activo/inactivo
        AppDropdown<bool?>(
          value: _selectedActivo,
          width: 160,
          label: 'Estado',
          items: const <AppDropdownItem<bool?>>[
            AppDropdownItem<bool?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<bool?>(
              value: true,
              label: 'Activa',
              icon: Icons.check_circle,
              iconColor: AppColors.success,
            ),
            AppDropdownItem<bool?>(
              value: false,
              label: 'Inactiva',
              icon: Icons.cancel,
              iconColor: AppColors.inactive,
            ),
          ],
          onChanged: (bool? value) {
            setState(() => _selectedActivo = value);
            _applyFilters();
          },
        ),

        // Botón limpiar filtros (solo visible si hay filtros activos)
        if (_searchController.text.isNotEmpty ||
            _selectedTipoDestino != null ||
            _selectedActivo != null)
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

/// Datos de filtro para dotaciones (filtrado client-side)
class DotacionesFilterData {
  const DotacionesFilterData({
    this.searchText,
    this.tipoDestino,
    this.activo,
  });

  final String? searchText;
  final String? tipoDestino;
  final bool? activo;

  /// Filtra una lista de dotaciones según los criterios
  List<DotacionEntity> apply(List<DotacionEntity> dotaciones) {
    return dotaciones.where((DotacionEntity d) {
      // Filtro por búsqueda de texto
      if (searchText != null && searchText!.isNotEmpty) {
        final String search = searchText!.toLowerCase();
        final bool matchesNombre = d.nombre.toLowerCase().contains(search);
        final bool matchesCodigo =
            d.codigo?.toLowerCase().contains(search) ?? false;
        final bool matchesDescripcion =
            d.descripcion?.toLowerCase().contains(search) ?? false;

        if (!matchesNombre && !matchesCodigo && !matchesDescripcion) {
          return false;
        }
      }

      // Filtro por tipo de destino
      if (tipoDestino != null && d.tipoDestino != tipoDestino) {
        return false;
      }

      // Filtro por estado activo
      if (activo != null && d.activo != activo) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters {
    return (searchText != null && searchText!.isNotEmpty) ||
        tipoDestino != null ||
        activo != null;
  }
}
