import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/form/paciente_form_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Sección administrativa y de consentimientos del formulario de paciente
class PacienteTabAdministrativo extends StatelessWidget {
  const PacienteTabAdministrativo({
    required this.data,
    required this.consentimientoInformadoFecha,
    required this.consentimientoRgpdFecha,
    required this.onChanged,
    super.key,
  });

  final PacienteFormData data;
  final DateTime? consentimientoInformadoFecha;
  final DateTime? consentimientoRgpdFecha;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Aseguradora y consentimientos'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Mutua',
              child: GestionTextField(
                controller: data.mutuaAseguradora,
                hint: 'Compañía de seguros',
              ),
            ),
            GestionFormRow(
              label: 'Nº póliza',
              child: GestionTextField(controller: data.numPoliza, hint: 'Número de póliza'),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Consentimiento',
              child: _ConsentField(
                text: 'Informado (tratamiento médico)',
                value: data.consentimientoInformado,
                fecha: consentimientoInformadoFecha,
                onChanged: (bool v) => _set(() => data.consentimientoInformado = v),
              ),
            ),
            GestionFormRow(
              label: 'RGPD',
              child: _ConsentField(
                text: 'Autoriza tratamiento de datos',
                value: data.consentimientoRgpd,
                fecha: consentimientoRgpdFecha,
                onChanged: (bool v) => _set(() => data.consentimientoRgpd = v),
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(
            controller: data.observaciones,
            hint: 'Información adicional relevante sobre el paciente',
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}

/// Casilla de consentimiento con la fecha de firma (si existe)
class _ConsentField extends StatelessWidget {
  const _ConsentField({required this.text, required this.value, required this.fecha, required this.onChanged});

  final String text;
  final bool value;
  final DateTime? fecha;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool showFecha = value && fecha != null;
    return Row(
      children: <Widget>[
        Flexible(child: GestionCheckField(value: value, text: text, onChanged: onChanged)),
        if (showFecha) ...<Widget>[
          const SizedBox(width: 8),
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(fecha!),
            style: const TextStyle(fontSize: 11.5, color: AppColors.gray500, fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }
}
