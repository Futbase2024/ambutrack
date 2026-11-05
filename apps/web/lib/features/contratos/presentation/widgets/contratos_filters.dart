import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Barra de filtros para contratos
class ContratosFilters extends StatefulWidget {
  const ContratosFilters({
    super.key,
    required this.onFilterChanged,
  });

  final void Function(ContratosFilterData) onFilterChanged;

  @override
  State<ContratosFilters> createState() => _ContratosFiltersState();
}

class _ContratosFiltersState extends State<ContratosFilters> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedEstado;
  String? _selectedTipo;

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFilterChanged(
      ContratosFilterData(
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
              hintText: 'Código, tipo, descripción...',
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
              _debounceTimer =
                  Timer(const Duration(milliseconds: 150), _applyFilters);
            },
          ),
        ),

        // Filtro por estado (activo/inactivo)
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
              value: 'activo',
              label: 'Activo',
              icon: Icons.check_circle,
              iconColor: AppColors.success,
            ),
            AppDropdownItem<String?>(
              value: 'inactivo',
              label: 'Inactivo',
              icon: Icons.cancel,
              iconColor: AppColors.error,
            ),
          ],
          onChanged: (String? value) {
            setState(() {
              _selectedEstado = value;
            });
            _applyFilters();
          },
        ),

        // Filtro por tipo de contrato
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
              value: 'URGENCIAS',
              label: 'Urgencias',
              icon: Icons.emergency,
              iconColor: AppColors.error,
            ),
            AppDropdownItem<String?>(
              value: 'PROGRAMADO',
              label: 'Programado',
              icon: Icons.schedule,
              iconColor: AppColors.info,
            ),
            AppDropdownItem<String?>(
              value: 'MIXTO',
              label: 'Mixto',
              icon: Icons.merge_type,
              iconColor: AppColors.secondary,
            ),
            AppDropdownItem<String?>(
              value: 'EVENTOS',
              label: 'Eventos',
              icon: Icons.event,
              iconColor: AppColors.warning,
            ),
            AppDropdownItem<String?>(
              value: 'TRASLADOS',
              label: 'Traslados',
              icon: Icons.local_shipping,
              iconColor: AppColors.primary,
            ),
          ],
          onChanged: (String? value) {
            setState(() {
              _selectedTipo = value;
            });
            _applyFilters();
          },
        ),

        // Botón limpiar filtros
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

/// Datos de filtro para contratos
class ContratosFilterData {
  const ContratosFilterData({
    this.searchText,
    this.estado,
    this.tipo,
  });

  final String? searchText;
  final String? estado;
  final String? tipo;

  /// Filtra una lista de contratos según los criterios
  List<ContratoEntity> apply(
    List<ContratoEntity> contratos,
    Map<String, String> hospitalNames,
  ) {
    return contratos.where((ContratoEntity contrato) {
      // Filtro por búsqueda de texto
      if (searchText != null && searchText!.isNotEmpty) {
        final String search = searchText!.toLowerCase();
        final bool matchesCodigo =
            contrato.codigo.toLowerCase().contains(search);
        final bool matchesTipo = contrato.tipoContrato
                ?.toLowerCase()
                .contains(search) ??
            false;
        final bool matchesDescripcion = contrato.descripcion
                ?.toLowerCase()
                .contains(search) ??
            false;
        final String hospitalName =
            hospitalNames[contrato.hospitalId] ?? '';
        final bool matchesHospital =
            hospitalName.toLowerCase().contains(search);

        if (!matchesCodigo &&
            !matchesTipo &&
            !matchesDescripcion &&
            !matchesHospital) {
          return false;
        }
      }

      // Filtro por estado
      if (estado != null) {
        if (estado == 'activo' && !contrato.activo) {
          return false;
        }
        if (estado == 'inactivo' && contrato.activo) {
          return false;
        }
      }

      // Filtro por tipo
      if (tipo != null && contrato.tipoContrato != tipo) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters {
    return (searchText != null && searchText!.isNotEmpty) ||
        estado != null ||
        tipo != null;
  }
}
