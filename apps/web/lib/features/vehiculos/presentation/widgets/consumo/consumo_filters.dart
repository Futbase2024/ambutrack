import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Filtros para la tabla de consumo de combustible
class ConsumoFilters extends StatelessWidget {
  const ConsumoFilters({
    required this.vehiculos,
    required this.filtroVehiculoId,
    required this.filtroFechaInicio,
    required this.filtroFechaFin,
    required this.onVehiculoChanged,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onClearFilters,
    super.key,
  });

  final List<VehiculoEntity> vehiculos;
  final String? filtroVehiculoId;
  final DateTime? filtroFechaInicio;
  final DateTime? filtroFechaFin;
  final ValueChanged<String?> onVehiculoChanged;
  final ValueChanged<DateTime?> onFechaInicioChanged;
  final ValueChanged<DateTime?> onFechaFinChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final bool hasFilters =
        filtroVehiculoId != null || filtroFechaInicio != null || filtroFechaFin != null;

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Filtro por vehículo
          const Icon(
            Icons.directions_car,
            color: AppColors.primary,
            size: AppSizes.iconMedium,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: AppDropdown<String>(
              value: filtroVehiculoId,
              hint: 'Todos los vehículos',
              items: vehiculos
                  .map((VehiculoEntity v) => AppDropdownItem<String>(
                        value: v.id,
                        label: v.matricula,
                      ))
                  .toList(),
              onChanged: onVehiculoChanged,
            ),
          ),
          const SizedBox(width: AppSizes.spacing),

          // Filtro por fecha inicio
          const Icon(
            Icons.calendar_today,
            color: AppColors.primary,
            size: AppSizes.iconMedium,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: _DateFilterButton(
              value: filtroFechaInicio,
              hint: 'Fecha inicio',
              onDateSelected: onFechaInicioChanged,
            ),
          ),
          const SizedBox(width: AppSizes.spacing),

          // Filtro por fecha fin
          const Icon(
            Icons.event,
            color: AppColors.primary,
            size: AppSizes.iconMedium,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: _DateFilterButton(
              value: filtroFechaFin,
              hint: 'Fecha fin',
              onDateSelected: onFechaFinChanged,
            ),
          ),
          const SizedBox(width: AppSizes.spacing),

          // Botón limpiar filtros
          if (hasFilters)
            IconButton(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear),
              tooltip: 'Limpiar filtros',
              color: AppColors.warning,
            ),
        ],
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.value,
    required this.hint,
    required this.onDateSelected,
  });

  final DateTime? value;
  final String hint;
  final ValueChanged<DateTime?> onDateSelected;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      onDateSelected(DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? dateValue = value;

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.spacingSmall,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: dateValue != null
                ? AppColors.primary
                : AppColors.textSecondaryLight.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.calendar_month,
              size: AppSizes.iconMedium,
              color: dateValue != null ? AppColors.primary : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Text(
              dateValue != null
                  ? '${dateValue.day}/${dateValue.month}/${dateValue.year}'
                  : hint,
              style: TextStyle(
                color: dateValue != null ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
                fontSize: AppSizes.fontSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
