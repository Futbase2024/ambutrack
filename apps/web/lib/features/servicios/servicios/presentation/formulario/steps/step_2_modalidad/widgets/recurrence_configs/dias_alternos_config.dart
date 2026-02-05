import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Configuración para servicio DÍAS ALTERNOS (cada N días)
class DiasAlternosConfig extends StatelessWidget {
  const DiasAlternosConfig({
    required this.intervaloDias,
    required this.fechaInicio,
    required this.fechaFin,
    required this.sinFechaFin,
    required this.onIntervaloDiasChanged,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onSinFechaFinChanged,
    super.key,
  });

  final int? intervaloDias;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final bool sinFechaFin;
  final void Function(int?) onIntervaloDiasChanged;
  final void Function(DateTime) onFechaInicioChanged;
  final void Function(DateTime?) onFechaFinChanged;
  final void Function({required bool value}) onSinFechaFinChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Intervalo de días
        Row(
          children: <Widget>[
            Text(
              'Repetir cada',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: intervaloDias?.toString() ?? '2',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSmall,
                    vertical: AppSizes.spacingSmall,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                ),
                textAlign: TextAlign.center,
                onChanged: (String value) {
                  final int? numero = int.tryParse(value);
                  if (numero != null && numero >= 2) {
                    onIntervaloDiasChanged(numero);
                  }
                },
              ),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Text(
              'días',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),

        // Resto de configuración igual que DiarioConfig
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
              color: enabled ? AppColors.textSecondaryLight : AppColors.gray400,
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
              color: enabled ? AppColors.textSecondaryLight : AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
