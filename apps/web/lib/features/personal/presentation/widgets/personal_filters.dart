import 'dart:async';

import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';

/// Widget de filtros para la lista de personal
class PersonalFilters extends StatefulWidget {
  const PersonalFilters({
    super.key,
    required this.onFiltersChanged,
  });

  final void Function(PersonalFilterData) onFiltersChanged;

  @override
  State<PersonalFilters> createState() => _PersonalFiltersState();
}

class _PersonalFiltersState extends State<PersonalFilters> {
  final TextEditingController _searchController = TextEditingController();
  final TablasMaestrasService _tablasMaestrasService = TablasMaestrasService();

  String? _selectedCategoriaId;

  List<CategoriaPersonalEntity> _categorias = <CategoriaPersonalEntity>[];

  Timer? _debounceTimer;
  DateTime? _filterStartTime;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    final List<CategoriaPersonalEntity> categorias =
        await _tablasMaestrasService.getCategorias();

    if (mounted) {
      setState(() {
        _categorias = categorias;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _notifyFilters() {
    if (_filterStartTime != null) {
      final Duration elapsed = DateTime.now().difference(_filterStartTime!);
      debugPrint('⏱️ Tiempo total de filtrado: ${elapsed.inMilliseconds}ms');
      _filterStartTime = null;
    }

    widget.onFiltersChanged(
      PersonalFilterData(
        searchQuery: _searchController.text,
        categoriaId: _selectedCategoriaId,
      ),
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _searchController.clear();
      _selectedCategoriaId = null;
    });
    _notifyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters = _searchController.text.isNotEmpty || _selectedCategoriaId != null;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        // Búsqueda por nombre
        SizedBox(
          width: 400,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar',
              hintText: 'Nombre, apellidos, DNI...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _filterStartTime = DateTime.now();
                        _searchController.clear();
                        _notifyFilters();
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
              _debounceTimer = Timer(const Duration(milliseconds: 150), _notifyFilters);
            },
          ),
        ),

        // Filtro por categoría
        AppDropdown<String?>(
          value: _selectedCategoriaId,
          width: 200,
          label: 'Categoría',
          hint: 'Todas',
          items: <AppDropdownItem<String?>>[
            const AppDropdownItem<String?>(
              value: null,
              label: 'Todas',
              icon: Icons.filter_list,
            ),
            ..._categorias.map(
              (CategoriaPersonalEntity cat) => AppDropdownItem<String?>(
                value: cat.id,
                label: cat.categoria,
                icon: Icons.person,
                iconColor: AppColors.primary,
              ),
            ),
          ],
          onChanged: (String? value) {
            setState(() {
              _selectedCategoriaId = value;
            });
            _notifyFilters();
          },
          clearable: false,
        ),

        // Botón limpiar filtros (solo visible si hay filtros activos)
        if (hasActiveFilters)
          AppButton(
            onPressed: _limpiarFiltros,
            icon: Icons.clear_all,
            label: 'Limpiar',
            variant: AppButtonVariant.text,
          ),
      ],
    );
  }
}

/// Datos de filtro de personal
class PersonalFilterData {
  const PersonalFilterData({
    this.searchQuery,
    this.categoriaId,
  });

  final String? searchQuery;
  final String? categoriaId;

  /// Filtra una lista de personal según los criterios
  List<PersonalEntity> apply(List<PersonalEntity> personal) {
    return personal.where((PersonalEntity persona) {
      // Filtro por búsqueda de texto
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final String search = searchQuery!.toLowerCase();
        final bool matchesNombre = persona.nombreCompleto.toLowerCase().contains(search);
        final bool matchesDNI = persona.dni?.toLowerCase().contains(search) ?? false;

        if (!matchesNombre && !matchesDNI) {
          return false;
        }
      }

      // Filtro por categoría
      if (categoriaId != null && persona.categoriaId != categoriaId) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Verifica si hay filtros activos
  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) || categoriaId != null;
}
