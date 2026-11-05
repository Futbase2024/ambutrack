import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/form/contrato_date_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fila con las fechas de inicio y fin del contrato
class ContratoFechasRow extends StatelessWidget {
  const ContratoFechasRow({
    super.key,
    required this.fechaInicio,
    required this.fechaFin,
    required this.enabled,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
  });

  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final bool enabled;
  final ValueChanged<DateTime?> onFechaInicioChanged;
  final ValueChanged<DateTime?> onFechaFinChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ContratoDateField(
            label: 'Fecha Inicio',
            value: fechaInicio,
            enabled: enabled,
            onChanged: onFechaInicioChanged,
            validator: (DateTime? value) {
              if (value == null) {
                return 'Fecha obligatoria';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: ContratoDateField(
            label: 'Fecha Fin (Opcional)',
            value: fechaFin,
            enabled: enabled,
            onChanged: onFechaFinChanged,
            validator: (DateTime? value) {
              if (value != null && fechaInicio != null && value.isBefore(fechaInicio!)) {
                return 'Debe ser posterior a inicio';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

/// Checkbox de estado activo del contrato
class ContratoActivoCheckbox extends StatelessWidget {
  const ContratoActivoCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Checkbox(
          value: value,
          onChanged: (bool? v) => onChanged(v ?? true),
          activeColor: AppColors.primary,
        ),
        Text(
          'Contrato activo',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

/// Diálogo mostrado mientras se cargan los datos del formulario
class ContratoFormLoadingDialog extends StatelessWidget {
  const ContratoFormLoadingDialog({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      content: const SizedBox(
        height: 400,
        child: Center(
          child: AppLoadingIndicator(
            message: 'Cargando datos...',
            size: 100,
          ),
        ),
      ),
      actions: <Widget>[
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
      ],
    );
  }
}
