import 'dart:async';

import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';

/// Barra de filtros para servicios
class ServiciosFilters extends StatefulWidget {
  const ServiciosFilters({super.key});

  @override
  State<ServiciosFilters> createState() => _ServiciosFiltersState();
}

class _ServiciosFiltersState extends State<ServiciosFilters> {
  final TextEditingController _searchController = TextEditingController();
  String? _estadoSeleccionado;
  int? _yearSeleccionado;
  DateTime? _fechaInicio;
  bool _todoElAno = true;

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    debugPrint('🔍 Aplicando filtros: estado=$_estadoSeleccionado, year=$_yearSeleccionado');
    // TODO(dev): Implementar lógica de filtrado con BLoC
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _estadoSeleccionado = null;
      _yearSeleccionado = null;
      _fechaInicio = null;
      _todoElAno = true;
    });
    _applyFilters();
  }

  bool get _hasActiveFilters =>
      _searchController.text.isNotEmpty ||
      _estadoSeleccionado != null ||
      _yearSeleccionado != null ||
      _fechaInicio != null ||
      !_todoElAno;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Primera fila: Filtros de estado
          Wrap(
            spacing: AppSizes.spacing,
            runSpacing: AppSizes.spacing,
            children: <Widget>[
              _buildEstadoChip('ACTIVO', AppColors.success),
              _buildEstadoChip('NO ACTIVOS', AppColors.inactive),
              _buildEstadoChip('SUSPENDIDO', AppColors.warning),
              _buildEstadoChip('FINALIZADO', AppColors.info),
              _buildEstadoChip('ELIMINADO', AppColors.error),
            ],
          ),

          const SizedBox(height: AppSizes.spacing),

          // Segunda fila: Búsqueda, año, fecha
          Wrap(
            spacing: AppSizes.spacing,
            runSpacing: AppSizes.spacing,
            children: <Widget>[
              // Búsqueda
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar servicio',
                    hintText: 'Paciente, código, dirección...',
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

              // Selector de año
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<int?>(
                  initialValue: _yearSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Año',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                  items: <DropdownMenuItem<int?>>[
                    const DropdownMenuItem<int?>(
                      child: Text('Todos'),
                    ),
                    // ignore: always_specify_types
                    ...List.generate(5, (int index) {
                      final int year = DateTime.now().year - index;
                      return DropdownMenuItem<int?>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                  ],
                  onChanged: (int? value) {
                    setState(() {
                      _yearSeleccionado = value;
                    });
                    _applyFilters();
                  },
                ),
              ),

              // Checkbox "TODO EL AÑO"
              InkWell(
                onTap: () {
                  setState(() {
                    _todoElAno = !_todoElAno;
                  });
                  _applyFilters();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray300),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Checkbox(
                        value: _todoElAno,
                        onChanged: (bool? value) {
                          setState(() {
                            _todoElAno = value ?? true;
                          });
                          _applyFilters();
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      const Text('TODO EL AÑO'),
                    ],
                  ),
                ),
              ),

              // Selector de fecha inicio (solo si no es "todo el año")
              if (!_todoElAno)
                SizedBox(
                  width: 200,
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _fechaInicio ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _fechaInicio = picked;
                        });
                        _applyFilters();
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha Inicio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                      child: Text(
                        _fechaInicio != null
                            ? '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}'
                            : 'Seleccionar',
                      ),
                    ),
                  ),
                ),

              // Botón limpiar filtros
              if (_hasActiveFilters)
                AppButton(
                  onPressed: _clearFilters,
                  icon: Icons.clear_all,
                  label: 'Limpiar',
                  variant: AppButtonVariant.text,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoChip(String label, Color color) {
    final bool isSelected = _estadoSeleccionado == label;

    return InkWell(
      onTap: () {
        setState(() {
          _estadoSeleccionado = isSelected ? null : label;
        });
        _applyFilters();
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecondaryLight,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: AppSizes.fontSmall,
          ),
        ),
      ),
    );
  }
}
