import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Barra de filtros para vehículos
class VehiculosFilters extends StatefulWidget {
  const VehiculosFilters({
    super.key,
    required this.onFilterChanged,
  });

  final void Function(VehiculosFilterData) onFilterChanged;

  @override
  State<VehiculosFilters> createState() => _VehiculosFiltersState();
}

class _VehiculosFiltersState extends State<VehiculosFilters> {
  final TextEditingController _searchController = TextEditingController();
  VehiculoEstado? _selectedEstado;
  String? _selectedTipo;

  Timer? _debounceTimer;
  DateTime? _filterStartTime;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    if (_filterStartTime != null) {
      final Duration elapsed = DateTime.now().difference(_filterStartTime!);
      debugPrint('⏱️ Tiempo total de filtrado: ${elapsed.inMilliseconds}ms');
      _filterStartTime = null;
    }

    widget.onFilterChanged(
      VehiculosFilterData(
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
          width: 400,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar',
              hintText: 'Matrícula, marca, modelo...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _filterStartTime = DateTime.now();
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
              // Marcar inicio de tiempo si es la primera tecla
              _filterStartTime ??= DateTime.now();

              setState(() {});

              // Cancelar el timer anterior si existe
              _debounceTimer?.cancel();

              // Crear un nuevo timer que ejecutará la búsqueda después de 150ms
              _debounceTimer = Timer(const Duration(milliseconds: 150), _applyFilters);
            },
          ),
        ),

        // Filtro por estado
        AppDropdown<VehiculoEstado?>(
          value: _selectedEstado,
          width: 180,
          label: 'Estado',
          items: const <AppDropdownItem<VehiculoEstado?>>[
            AppDropdownItem<VehiculoEstado?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<VehiculoEstado?>(
              value: VehiculoEstado.activo,
              label: 'Activo',
              icon: Icons.check_circle,
              iconColor: AppColors.success,
            ),
            AppDropdownItem<VehiculoEstado?>(
              value: VehiculoEstado.mantenimiento,
              label: 'Mantenimiento',
              icon: Icons.build,
              iconColor: AppColors.warning,
            ),
            AppDropdownItem<VehiculoEstado?>(
              value: VehiculoEstado.reparacion,
              label: 'Reparación',
              icon: Icons.warning,
              iconColor: AppColors.error,
            ),
            AppDropdownItem<VehiculoEstado?>(
              value: VehiculoEstado.baja,
              label: 'Baja',
              icon: Icons.cancel,
              iconColor: AppColors.inactive,
            ),
          ],
          onChanged: (VehiculoEstado? value) {
            setState(() {
              _selectedEstado = value;
            });
            _applyFilters();
          },
        ),

        // Filtro por tipo
        AppDropdown<String?>(
          value: _selectedTipo,
          width: 180,
          label: 'Tipo',
          items: const <AppDropdownItem<String?>>[
            AppDropdownItem<String?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<String?>(
              value: 'CONVENCIONAL',
              label: 'Convencional',
              icon: Icons.local_shipping,
              iconColor: AppColors.info,
            ),
            AppDropdownItem<String?>(
              value: 'COLECTIVA',
              label: 'Colectiva',
              icon: Icons.groups,
              iconColor: AppColors.secondary,
            ),
            AppDropdownItem<String?>(
              value: 'UVI MÓVIL',
              label: 'UVI Móvil',
              icon: Icons.local_hospital,
              iconColor: AppColors.error,
            ),
          ],
          onChanged: (String? value) {
            setState(() {
              _selectedTipo = value;
            });
            _applyFilters();
          },
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

/// Datos de filtro para vehículos
class VehiculosFilterData {
  const VehiculosFilterData({
    this.searchText,
    this.estado,
    this.tipo,
  });

  final String? searchText;
  final VehiculoEstado? estado;
  final String? tipo;

  /// Filtra una lista de vehículos según los criterios
  List<VehiculoEntity> apply(List<VehiculoEntity> vehiculos) {
    return vehiculos.where((VehiculoEntity vehiculo) {
      // Filtro por búsqueda de texto
      if (searchText != null && searchText!.isNotEmpty) {
        final String search = searchText!.toLowerCase();
        final bool matchesMatricula = vehiculo.matricula.toLowerCase().contains(search);
        final bool matchesMarca = vehiculo.marca.toLowerCase().contains(search);
        final bool matchesModelo = vehiculo.modelo.toLowerCase().contains(search);

        if (!matchesMatricula && !matchesMarca && !matchesModelo) {
          return false;
        }
      }

      // Filtro por estado
      if (estado != null && vehiculo.estado != estado) {
        return false;
      }

      // Filtro por tipo
      if (tipo != null && vehiculo.tipoVehiculo != tipo) {
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
