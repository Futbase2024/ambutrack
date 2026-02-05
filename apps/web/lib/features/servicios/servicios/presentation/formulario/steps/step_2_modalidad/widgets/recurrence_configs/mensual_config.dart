import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Configuración para servicio MENSUAL (días específicos del mes)
class MensualConfig extends StatelessWidget {
  const MensualConfig({
    required this.diasMesSeleccionados,
    required this.fechaInicio,
    required this.fechaFin,
    required this.sinFechaFin,
    required this.onDiasMesChanged,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onSinFechaFinChanged,
    super.key,
  });

  final List<int> diasMesSeleccionados;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final bool sinFechaFin;
  final void Function(List<int>) onDiasMesChanged;
  final void Function(DateTime) onFechaInicioChanged;
  final void Function(DateTime?) onFechaFinChanged;
  final void Function({required bool value}) onSinFechaFinChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Selector de días del mes
        Text(
          'Días del Mes *',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        _MonthDaysSelector(
          diasSeleccionados: diasMesSeleccionados,
          onChanged: onDiasMesChanged,
        ),
        const SizedBox(height: AppSizes.spacing),

        // Fecha de inicio
        Text(
          'Fecha de Inicio *',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        _DatePickerField(
          fecha: fechaInicio,
          hint: 'Seleccionar fecha de inicio',
          onTap: () => _selectFechaInicio(context),
        ),
        const SizedBox(height: AppSizes.spacing),

        // Checkbox "Sin fecha de finalización"
        Row(
          children: <Widget>[
            Checkbox(
              value: sinFechaFin,
              onChanged: (bool? value) {
                onSinFechaFinChanged(value: value ?? false);
                if (value == true) {
                  onFechaFinChanged(null);
                }
              },
              activeColor: AppColors.primary,
            ),
            Text(
              'Sin fecha de finalización',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),

        // Fecha de fin (solo si no es indefinido)
        if (!sinFechaFin) ...<Widget>[
          Text(
            'Fecha de Finalización *',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMedium,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          _DatePickerField(
            fecha: fechaFin,
            hint: 'Seleccionar fecha de finalización',
            onTap: () => _selectFechaFin(context),
            enabled: fechaInicio != null,
          ),
        ],
      ],
    );
  }

  Future<void> _selectFechaInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaInicio ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      onFechaInicioChanged(picked);
      if (fechaFin != null && fechaFin!.isBefore(picked)) {
        onFechaFinChanged(null);
      }
    }
  }

  Future<void> _selectFechaFin(BuildContext context) async {
    if (fechaInicio == null) {
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaFin ?? fechaInicio!.add(const Duration(days: 30)),
      firstDate: fechaInicio!,
      lastDate: fechaInicio!.add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      onFechaFinChanged(picked);
    }
  }
}

/// Selector de días del mes (1-31 + "Último día")
class _MonthDaysSelector extends StatelessWidget {
  const _MonthDaysSelector({
    required this.diasSeleccionados,
    required this.onChanged,
  });

  final List<int> diasSeleccionados;
  final void Function(List<int>) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Grid de días 1-31
        Wrap(
          spacing: AppSizes.spacingSmall,
          runSpacing: AppSizes.spacingSmall,
          children: <Widget>[
            for (int dia = 1; dia <= 31; dia++)
              _MonthDayChip(
                dia: dia,
                isSelected: diasSeleccionados.contains(dia),
                onTap: () => _toggleDia(dia),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),

        // Opción "Último día" (representado con 32)
        _LastDayOption(
          isSelected: diasSeleccionados.contains(32),
          onTap: () => _toggleDia(32),
        ),
      ],
    );
  }

  void _toggleDia(int dia) {
    final List<int> nuevaSeleccion = List<int>.from(diasSeleccionados);
    if (nuevaSeleccion.contains(dia)) {
      nuevaSeleccion.remove(dia);
    } else {
      nuevaSeleccion.add(dia);
    }
    nuevaSeleccion.sort(); // Ordenar días
    onChanged(nuevaSeleccion);
  }
}

/// Chip individual para un día del mes
class _MonthDayChip extends StatelessWidget {
  const _MonthDayChip({
    required this.dia,
    required this.isSelected,
    required this.onTap,
  });

  final int dia;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray200,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Center(
          child: Text(
            dia.toString(),
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

/// Opción "Último día del mes"
class _LastDayOption extends StatelessWidget {
  const _LastDayOption({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.gray200,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.calendar_month,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Text(
              'Último día del mes',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget reutilizable para selector de fecha
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.fecha,
    required this.hint,
    required this.onTap,
    this.enabled = true,
  });

  final DateTime? fecha;
  final String hint;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? AppColors.gray300 : AppColors.gray200,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          color: enabled ? Colors.white : AppColors.gray100,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.calendar_today,
              size: 20,
              color: enabled
                  ? AppColors.textSecondaryLight
                  : AppColors.gray400,
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Expanded(
              child: Text(
                fecha != null
                    ? DateFormat('dd/MM/yyyy', 'es').format(fecha!)
                    : hint,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMedium,
                  color: fecha != null
                      ? AppColors.textPrimaryLight
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: enabled
                  ? AppColors.textSecondaryLight
                  : AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
