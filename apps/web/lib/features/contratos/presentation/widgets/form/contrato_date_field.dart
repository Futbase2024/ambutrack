import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Campo de fecha del formulario de contrato
class ContratoDateField extends StatelessWidget {
  const ContratoDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.enabled,
    this.validator,
  });

  final String label;
  final DateTime? value;
  final void Function(DateTime?) onChanged;
  final bool enabled;
  final String? Function(DateTime?)? validator;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (date != null) {
      onChanged(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? fecha = value;
    return InkWell(
      onTap: enabled ? () => _pickDate(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          errorText: validator?.call(fecha),
        ),
        child: Text(
          fecha == null
              ? 'Selecciona fecha'
              : '${fecha.day.toString().padLeft(2, '0')}/'
                  '${fecha.month.toString().padLeft(2, '0')}/'
                  '${fecha.year}',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: fecha == null ? AppColors.textSecondaryLight : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}
