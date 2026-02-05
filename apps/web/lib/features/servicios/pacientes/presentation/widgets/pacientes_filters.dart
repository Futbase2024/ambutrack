import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';

/// Barra de filtros para pacientes
class PacientesFilters extends StatefulWidget {
  const PacientesFilters({
    super.key,
    required this.onFilterChanged,
  });

  final void Function(PacientesFilterData) onFilterChanged;

  @override
  State<PacientesFilters> createState() => _PacientesFiltersState();
}

class _PacientesFiltersState extends State<PacientesFilters> {
  final TextEditingController _searchController = TextEditingController();

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
      PacientesFilterData(
        searchText: _searchController.text.trim(),
      ),
    );
  }

  void _clearFilters() {
    setState(_searchController.clear);
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
              hintText: 'Identificación, nombre, teléfono...',
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

        // Botón limpiar filtros (solo visible si hay filtros activos)
        if (_searchController.text.isNotEmpty)
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

/// Datos de filtro para pacientes
class PacientesFilterData {
  const PacientesFilterData({
    this.searchText,
  });

  final String? searchText;

  /// Filtra una lista de pacientes según los criterios
  List<PacienteEntity> apply(List<PacienteEntity> pacientes) {
    return pacientes.where((PacienteEntity paciente) {
      // Filtro por búsqueda de texto
      if (searchText != null && searchText!.isNotEmpty) {
        final String search = searchText!.toLowerCase();

        // Buscar en identificación
        final bool matchesIdentificacion =
            paciente.identificacion != null &&
            paciente.identificacion!.toLowerCase().contains(search);

        // Buscar en nombre completo
        final bool matchesNombre = paciente.nombreCompleto.toLowerCase().contains(search);

        // Buscar en teléfono (móvil o fijo)
        final bool matchesTelefono =
            (paciente.telefonoMovil != null &&
             paciente.telefonoMovil!.toLowerCase().contains(search)) ||
            (paciente.telefonoFijo != null &&
             paciente.telefonoFijo!.toLowerCase().contains(search));

        // Buscar en dirección
        final bool matchesDireccion =
            paciente.domicilioDireccion != null &&
            paciente.domicilioDireccion!.toLowerCase().contains(search);

        if (!matchesIdentificacion &&
            !matchesNombre &&
            !matchesTelefono &&
            !matchesDireccion) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters {
    return searchText != null && searchText!.isNotEmpty;
  }
}
