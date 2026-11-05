import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Barra de filtros para Excepciones y Festivos (patrón Vehículos)
class ExcepcionesFestivosFilters extends StatefulWidget {
  const ExcepcionesFestivosFilters({
    super.key,
    required this.onFilterChanged,
  });

  final void Function(ExcepcionesFestivosFilterData) onFilterChanged;

  @override
  State<ExcepcionesFestivosFilters> createState() =>
      _ExcepcionesFestivosFiltersState();
}

class _ExcepcionesFestivosFiltersState
    extends State<ExcepcionesFestivosFilters> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTipo;
  bool? _selectedActivo; // null = todos, true = activos, false = inactivos

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFilterChanged(
      ExcepcionesFestivosFilterData(
        searchText: _searchController.text.trim(),
        tipo: _selectedTipo,
        activo: _selectedActivo,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedTipo = null;
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
          width: 350,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar',
              hintText: 'Nombre, tipo, descripción...',
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

        // Filtro por tipo
        AppDropdown<String?>(
          value: _selectedTipo,
          width: 170,
          label: 'Tipo',
          items: const <AppDropdownItem<String?>>[
            AppDropdownItem<String?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<String?>(
              value: ExcepcionFestivoEntity.tipoFestivo,
              label: 'Festivo',
              icon: Icons.celebration,
              iconColor: AppColors.success,
            ),
            AppDropdownItem<String?>(
              value: ExcepcionFestivoEntity.tipoExcepcion,
              label: 'Excepción',
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.warning,
            ),
            AppDropdownItem<String?>(
              value: ExcepcionFestivoEntity.tipoEspecial,
              label: 'Especial',
              icon: Icons.star,
              iconColor: AppColors.info,
            ),
          ],
          onChanged: (String? value) {
            setState(() => _selectedTipo = value);
            _applyFilters();
          },
        ),

        // Filtro por estado activo/inactivo
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

        // Botón limpiar filtros
        if (_searchController.text.isNotEmpty ||
            _selectedTipo != null ||
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

/// Datos de filtro para excepciones/festivos (filtrado client-side)
class ExcepcionesFestivosFilterData {
  const ExcepcionesFestivosFilterData({
    this.searchText,
    this.tipo,
    this.activo,
  });

  final String? searchText;
  final String? tipo;
  final bool? activo;

  /// Filtra una lista de excepciones/festivos según los criterios
  List<ExcepcionFestivoEntity> apply(
    List<ExcepcionFestivoEntity> items,
  ) {
    return items.where((ExcepcionFestivoEntity item) {
      // Filtro por búsqueda de texto
      if (searchText != null && searchText!.isNotEmpty) {
        final String search = searchText!.toLowerCase();
        final bool matchesNombre =
            item.nombre.toLowerCase().contains(search);
        final bool matchesTipo =
            item.tipo.toLowerCase().contains(search);
        final bool matchesDescripcion =
            item.descripcion?.toLowerCase().contains(search) ?? false;

        if (!matchesNombre && !matchesTipo && !matchesDescripcion) {
          return false;
        }
      }

      // Filtro por tipo
      if (tipo != null && item.tipo != tipo) {
        return false;
      }

      // Filtro por estado activo
      if (activo != null && item.activo != activo) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters {
    return searchText != null && searchText!.isNotEmpty ||
        tipo != null ||
        activo != null;
  }
}
