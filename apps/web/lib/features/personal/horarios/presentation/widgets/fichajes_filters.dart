import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget de filtros para la lista de fichajes
class FichajesFilters extends StatefulWidget {
  const FichajesFilters({
    super.key,
    required this.onFiltersChanged,
  });

  final void Function(FichajesFilterData) onFiltersChanged;

  @override
  State<FichajesFilters> createState() => _FichajesFiltersState();
}

class _FichajesFiltersState extends State<FichajesFilters> {
  final TextEditingController _searchController = TextEditingController();

  String _tipoSeleccionado = 'todos'; // todos, entrada, salida
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), _notifyFilters);
  }

  void _notifyFilters() {
    widget.onFiltersChanged(
      FichajesFilterData(
        searchText: _searchController.text,
        tipo: _tipoSeleccionado,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
      ),
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _searchController.clear();
      _tipoSeleccionado = 'todos';
      _fechaInicio = null;
      _fechaFin = null;
    });
    _notifyFilters();
  }

  Future<void> _selectFechaInicio() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
      });
      _notifyFilters();
    }
  }

  Future<void> _selectFechaFin() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: _fechaInicio ?? DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaFin = picked;
      });
      _notifyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters = _searchController.text.isNotEmpty ||
        _tipoSeleccionado != 'todos' ||
        _fechaInicio != null ||
        _fechaFin != null;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        // Búsqueda por nombre
        SizedBox(
          width: 350,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar',
              hintText: 'Nombre del personal...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(_searchController.clear);
                        _notifyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        // Filtro por tipo
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            initialValue: _tipoSeleccionado,
            decoration: InputDecoration(
              labelText: 'Tipo de Fichaje',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
            ),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: 'todos',
                child: Text('Todos'),
              ),
              DropdownMenuItem<String>(
                value: 'entrada',
                child: Text('Entradas'),
              ),
              DropdownMenuItem<String>(
                value: 'salida',
                child: Text('Salidas'),
              ),
            ],
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _tipoSeleccionado = value;
                });
                _notifyFilters();
              }
            },
          ),
        ),

        // Fecha inicio
        SizedBox(
          width: 180,
          child: InkWell(
            onTap: _selectFechaInicio,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Desde',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                suffixIcon: _fechaInicio != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _fechaInicio = null;
                          });
                          _notifyFilters();
                        },
                      )
                    : const Icon(Icons.calendar_today, size: 20),
              ),
              child: Text(
                _fechaInicio != null
                    ? DateFormat('dd/MM/yyyy').format(_fechaInicio!)
                    : 'Seleccionar',
                style: TextStyle(
                  color: _fechaInicio != null
                      ? AppColors.textPrimaryLight
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ),

        // Fecha fin
        SizedBox(
          width: 180,
          child: InkWell(
            onTap: _selectFechaFin,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Hasta',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                suffixIcon: _fechaFin != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _fechaFin = null;
                          });
                          _notifyFilters();
                        },
                      )
                    : const Icon(Icons.calendar_today, size: 20),
              ),
              child: Text(
                _fechaFin != null
                    ? DateFormat('dd/MM/yyyy').format(_fechaFin!)
                    : 'Seleccionar',
                style: TextStyle(
                  color: _fechaFin != null
                      ? AppColors.textPrimaryLight
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ),

        // Botón limpiar filtros
        if (hasActiveFilters)
          AppButton(
            label: 'Limpiar Filtros',
            icon: Icons.clear_all,
            onPressed: _limpiarFiltros,
            variant: AppButtonVariant.secondary,
          ),
      ],
    );
  }
}

/// Clase de datos para los filtros de fichajes
class FichajesFilterData {
  const FichajesFilterData({
    this.searchText = '',
    this.tipo = 'todos',
    this.fechaInicio,
    this.fechaFin,
  });

  final String searchText;
  final String tipo;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  /// Aplica los filtros a una lista de registros
  List<RegistroHorarioEntity> apply(List<RegistroHorarioEntity> registros) {
    return registros.where((RegistroHorarioEntity registro) {
      // Filtro por búsqueda de nombre
      final bool matchesSearch = searchText.isEmpty ||
          (registro.nombrePersonal?.toLowerCase().contains(searchText.toLowerCase()) ?? false);

      // Filtro por tipo
      final bool matchesTipo =
          tipo == 'todos' || registro.tipo.toLowerCase() == tipo.toLowerCase();

      // Filtro por fechas
      final bool matchesFechas = (fechaInicio == null ||
              registro.fechaHora
                  .isAfter(fechaInicio!.subtract(const Duration(days: 1)))) &&
          (fechaFin == null ||
              registro.fechaHora.isBefore(fechaFin!.add(const Duration(days: 1))));

      return matchesSearch && matchesTipo && matchesFechas;
    }).toList();
  }

  /// Indica si hay filtros activos
  bool get hasActiveFilters =>
      searchText.isNotEmpty || tipo != 'todos' || fechaInicio != null || fechaFin != null;
}
