import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Barra de filtros para Asignaciones (patrón Vehículos)
class AsignacionesFilters extends StatefulWidget {
  const AsignacionesFilters({
    super.key,
    required this.onFilterChanged,
  });

  final void Function(AsignacionesFilterData) onFilterChanged;

  @override
  State<AsignacionesFilters> createState() => _AsignacionesFiltersState();
}

class _AsignacionesFiltersState extends State<AsignacionesFilters> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedEstado;

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFilterChanged(
      AsignacionesFilterData(
        searchText: _searchController.text.trim(),
        estado: _selectedEstado,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedEstado = null;
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
              hintText: 'Vehículo, dotación, destino...',
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

        // Filtro por estado
        AppDropdown<String?>(
          value: _selectedEstado,
          width: 160,
          label: 'Estado',
          items: const <AppDropdownItem<String?>>[
            AppDropdownItem<String?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<String?>(
              value: 'planificada',
              label: 'Planificada',
              icon: Icons.schedule,
              iconColor: AppColors.info,
            ),
            AppDropdownItem<String?>(
              value: 'confirmada',
              label: 'Confirmada',
              icon: Icons.check_circle,
              iconColor: AppColors.success,
            ),
            AppDropdownItem<String?>(
              value: 'en_curso',
              label: 'En Curso',
              icon: Icons.play_circle,
              iconColor: AppColors.warning,
            ),
            AppDropdownItem<String?>(
              value: 'completada',
              label: 'Completada',
              icon: Icons.done_all,
              iconColor: AppColors.gray500,
            ),
            AppDropdownItem<String?>(
              value: 'cancelada',
              label: 'Cancelada',
              icon: Icons.cancel,
              iconColor: AppColors.error,
            ),
          ],
          onChanged: (String? value) {
            setState(() => _selectedEstado = value);
            _applyFilters();
          },
        ),

        if (_searchController.text.isNotEmpty || _selectedEstado != null)
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

/// Datos de filtro para asignaciones (filtrado client-side)
class AsignacionesFilterData {
  const AsignacionesFilterData({
    this.searchText,
    this.estado,
  });

  final String? searchText;
  final String? estado;

  /// Filtra una lista de asignaciones según los criterios
  List<AsignacionVehiculoTurnoEntity> apply(
    List<AsignacionVehiculoTurnoEntity> items,
  ) {
    return items.where((AsignacionVehiculoTurnoEntity item) {
      // Filtro por búsqueda de texto
      if (searchText != null && searchText!.isNotEmpty) {
        final String search = searchText!.toLowerCase();
        final bool matchesVehiculo =
            item.vehiculoId.toLowerCase().contains(search);
        final bool matchesDotacion =
            item.dotacionId.toLowerCase().contains(search);
        final bool matchesHospital =
            item.hospitalId?.toLowerCase().contains(search) ?? false;
        final bool matchesBase =
            item.baseId?.toLowerCase().contains(search) ?? false;
        final bool matchesTurno =
            item.plantillaTurnoId?.toLowerCase().contains(search) ?? false;

        if (!matchesVehiculo &&
            !matchesDotacion &&
            !matchesHospital &&
            !matchesBase &&
            !matchesTurno) {
          return false;
        }
      }

      // Filtro por estado
      if (estado != null && item.estado.toLowerCase() != estado) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters {
    return searchText != null && searchText!.isNotEmpty ||
        estado != null;
  }
}
