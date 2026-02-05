import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/servicios/utils/recurrence_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Configuración para servicio SEMANAL (días fijos de la semana)
class SemanalConfig extends StatelessWidget {
  const SemanalConfig({
    required this.diasSemanaSeleccionados,
    required this.fechaInicio,
    required this.fechaFin,
    required this.sinFechaFin,
    required this.onDiasSemanaChanged,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onSinFechaFinChanged,
    super.key,
  });

  final List<int> diasSemanaSeleccionados;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final bool sinFechaFin;
  final void Function(List<int>) onDiasSemanaChanged;
  final void Function(DateTime) onFechaInicioChanged;
  final void Function(DateTime?) onFechaFinChanged;
  final void Function({required bool value}) onSinFechaFinChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Selector de días de la semana
        Text(
          'Días de la Semana *',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        _WeekdaySelector(
          diasSeleccionados: diasSemanaSeleccionados,
          onChanged: onDiasSemanaChanged,
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
      initialDate: fechaFin ?? fechaInicio!.add(const Duration(days: 7)),
      firstDate: fechaInicio!,
      lastDate: fechaInicio!.add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      onFechaFinChanged(picked);
    }
  }
}

/// Selector de días de la semana (L M X J V S D)
class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector({
    required this.diasSeleccionados,
    required this.onChanged,
  });

  final List<int> diasSeleccionados;
  final void Function(List<int>) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (int i = 1; i <= 7; i++) // 1=Lunes...7=Domingo (ajustar a 0-6)
          _WeekdayChip(
            dia: i % 7, // Convertir a 0-6 donde 0=Domingo
            isSelected: diasSeleccionados.contains(i % 7),
            onTap: () => _toggleDia(i % 7),
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
    onChanged(nuevaSeleccion);
  }
}

/// Chip individual para un día de la semana
class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.dia,
    required this.isSelected,
    required this.onTap,
  });

  final int dia;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String label = RecurrenceUtils.obtenerNombreDiaSemanaCorto(dia);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray200,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
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
