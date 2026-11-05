import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Barra de filtros para Bases (patrón Vehículos)
class BasesFilters extends StatefulWidget {
  const BasesFilters({
    super.key,
    required this.onFilterChanged,
  });

  final void Function(BasesFilterData) onFilterChanged;

  @override
  State<BasesFilters> createState() => _BasesFiltersState();
}

class _BasesFiltersState extends State<BasesFilters> {
  final TextEditingController _searchController = TextEditingController();
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
      BasesFilterData(
        searchText: _searchController.text.trim(),
        activo: _selectedActivo,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
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
        SizedBox(
          width: 350,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar',
              hintText: 'Nombre, dirección, población...',
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

        AppDropdown<bool?>(
          value: _selectedActivo,
          width: 150,
          label: 'Estado',
          items: const <AppDropdownItem<bool?>>[
            AppDropdownItem<bool?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<bool?>(
              value: true,
              label: 'Activo',
              icon: Icons.check_circle,
              iconColor: AppColors.success,
            ),
            AppDropdownItem<bool?>(
              value: false,
              label: 'Inactivo',
              icon: Icons.cancel,
              iconColor: AppColors.inactive,
            ),
          ],
          onChanged: (bool? value) {
            setState(() => _selectedActivo = value);
            _applyFilters();
          },
        ),

        if (_searchController.text.isNotEmpty || _selectedActivo != null)
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

/// Datos de filtro para bases (filtrado client-side)
class BasesFilterData {
  const BasesFilterData({
    this.searchText,
    this.activo,
  });

  final String? searchText;
  final bool? activo;

  /// Filtra una lista de bases según los criterios
  List<BaseCentroEntity> apply(List<BaseCentroEntity> items) {
    return items.where((BaseCentroEntity base) {
      if (searchText != null && searchText!.isNotEmpty) {
        final String search = searchText!.toLowerCase();
        final bool matchesNombre =
            base.nombre.toLowerCase().contains(search);
        final bool matchesDireccion =
            base.direccion?.toLowerCase().contains(search) ?? false;
        final bool matchesPoblacion =
            base.poblacionNombre?.toLowerCase().contains(search) ?? false;

        final bool matchesTipo =
            base.tipo?.toLowerCase().contains(search) ?? false;

        if (!matchesNombre && !matchesDireccion && !matchesPoblacion && !matchesTipo) {
          return false;
        }
      }

      if (activo != null && base.activo != activo) {
        return false;
      }

      return true;
    }).toList();
  }

  bool get hasActiveFilters {
    return searchText != null && searchText!.isNotEmpty || activo != null;
  }
}
