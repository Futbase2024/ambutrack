import 'dart:async';

import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_bloc.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_event.dart';
import 'package:ambutrack_web/features/incidencias/presentation/bloc/incidencia/incidencia_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Barra de filtros para incidencias
class IncidenciasFilters extends StatefulWidget {
  const IncidenciasFilters({super.key});

  @override
  State<IncidenciasFilters> createState() => _IncidenciasFiltersState();
}

class _IncidenciasFiltersState extends State<IncidenciasFilters> {
  final TextEditingController _searchController = TextEditingController();
  CategoriaIncidencia? _categoria;
  PrioridadIncidencia? _prioridad;
  EstadoIncidencia? _estado;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  Timer? _debounceTimer;

  bool get _hasActiveFilters =>
      _searchController.text.isNotEmpty ||
      _categoria != null ||
      _prioridad != null ||
      _estado != null ||
      _fechaDesde != null ||
      _fechaHasta != null;

  @override
  void initState() {
    super.initState();
    final IncidenciaState state = context.read<IncidenciaBloc>().state;
    if (state is IncidenciaLoaded) {
      _syncFromFilters(state.filters);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _syncFromFilters(IncidenciaFilters filters) {
    if (_searchController.text != filters.searchQuery) {
      _searchController.text = filters.searchQuery;
    }
    _categoria = filters.categoria;
    _prioridad = filters.prioridad;
    _estado = filters.estado;
    _fechaDesde = filters.fechaDesde;
    _fechaHasta = filters.fechaHasta;
  }

  void _applyFilters() {
    context.read<IncidenciaBloc>().add(
          IncidenciaFilterRequested(IncidenciaFilters(
            searchQuery: _searchController.text.trim(),
            categoria: _categoria,
            prioridad: _prioridad,
            estado: _estado,
            fechaDesde: _fechaDesde,
            fechaHasta: _fechaHasta,
          )),
        );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _categoria = null;
      _prioridad = null;
      _estado = null;
      _fechaDesde = null;
      _fechaHasta = null;
    });
    context.read<IncidenciaBloc>().add(
          const IncidenciaFilterRequested(IncidenciaFilters()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spacing,
      runSpacing: AppSizes.spacing,
      alignment: WrapAlignment.end,
      children: <Widget>[
        SizedBox(
          width: 400,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar',
              hintText: 'Título, descripción, responsable...',
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

        // Categoría
        AppDropdown<CategoriaIncidencia?>(
          value: _categoria,
          width: 160,
          label: 'Categoría',
          items: <AppDropdownItem<CategoriaIncidencia?>>[
            const AppDropdownItem<CategoriaIncidencia?>(
              value: null,
              label: 'Todas',
              icon: Icons.filter_list,
            ),
            ...CategoriaIncidencia.values.map(
              (CategoriaIncidencia c) => AppDropdownItem<CategoriaIncidencia?>(
                value: c,
                label: c.displayName,
              ),
            ),
          ],
          onChanged: (CategoriaIncidencia? value) {
            setState(() => _categoria = value);
            _applyFilters();
          },
        ),

        // Prioridad
        AppDropdown<PrioridadIncidencia?>(
          value: _prioridad,
          width: 140,
          label: 'Prioridad',
          items: <AppDropdownItem<PrioridadIncidencia?>>[
            const AppDropdownItem<PrioridadIncidencia?>(
              value: null,
              label: 'Todas',
              icon: Icons.filter_list,
            ),
            ...PrioridadIncidencia.values.map(
              (PrioridadIncidencia p) => AppDropdownItem<PrioridadIncidencia?>(
                value: p,
                label: p.displayName,
              ),
            ),
          ],
          onChanged: (PrioridadIncidencia? value) {
            setState(() => _prioridad = value);
            _applyFilters();
          },
        ),

        // Estado
        AppDropdown<EstadoIncidencia?>(
          value: _estado,
          width: 140,
          label: 'Estado',
          items: <AppDropdownItem<EstadoIncidencia?>>[
            const AppDropdownItem<EstadoIncidencia?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            ...EstadoIncidencia.values.map(
              (EstadoIncidencia e) => AppDropdownItem<EstadoIncidencia?>(
                value: e,
                label: e.displayName,
              ),
            ),
          ],
          onChanged: (EstadoIncidencia? value) {
            setState(() => _estado = value);
            _applyFilters();
          },
        ),

        // Fecha desde
        _DateFilterChip(
          label: 'Desde',
          value: _fechaDesde,
          onChanged: (DateTime? d) {
            setState(() => _fechaDesde = d);
            _applyFilters();
          },
        ),

        // Fecha hasta
        _DateFilterChip(
          label: 'Hasta',
          value: _fechaHasta,
          onChanged: (DateTime? d) {
            setState(() => _fechaHasta = d);
            _applyFilters();
          },
        ),

        // Limpiar filtros
        if (_hasActiveFilters)
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

/// Chip de fecha compacto para la barra de filtros
class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.label,
    this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          locale: const Locale('es', 'ES'),
        );
        onChanged(picked);
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: value != null ? AppColors.primarySurface : AppColors.gray50,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: value != null
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              value != null
                  ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
                  : label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value != null ? AppColors.primary : AppColors.gray500,
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.close, size: 14, color: AppColors.gray400),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child:
                    Icon(Icons.calendar_today, size: 14, color: AppColors.gray400),
              ),
          ],
        ),
      ),
    );
  }
}
