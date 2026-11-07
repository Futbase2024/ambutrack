import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/form/paciente_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sección de datos personales del formulario de paciente
class PacienteTabPersonal extends StatelessWidget {
  const PacienteTabPersonal({required this.data, required this.onChanged, super.key});

  final PacienteFormData data;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  static final List<TextInputFormatter> _upper = <TextInputFormatter>[PacienteUpperCaseFormatter()];

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Datos personales', first: true),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Nombre',
              required: true,
              child: GestionTextField(
                controller: data.nombre,
                hint: 'JUAN',
                inputFormatters: _upper,
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
              ),
            ),
            GestionFormRow(
              label: '1er apellido',
              required: true,
              child: GestionTextField(
                controller: data.primerApellido,
                hint: 'GARCÍA',
                inputFormatters: _upper,
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'El primer apellido es obligatorio' : null,
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: '2º apellido',
              child: GestionTextField(controller: data.segundoApellido, hint: 'LÓPEZ', inputFormatters: _upper),
            ),
            GestionFormRow(
              label: 'Sexo',
              child: GestionDropdownField<String>(
                value: data.sexo,
                options: PacienteFormOptions.withValue(PacienteFormOptions.sexos, data.sexo),
                onChanged: (String? v) => _set(() => data.sexo = v ?? data.sexo),
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Tipo documento',
              child: GestionDropdownField<String>(
                value: data.tipoDocumento,
                options: PacienteFormOptions.withValue(PacienteFormOptions.tiposDocumento, data.tipoDocumento),
                onChanged: (String? v) => _set(() => data.tipoDocumento = v ?? data.tipoDocumento),
              ),
            ),
            GestionFormRow(
              label: 'Nº documento',
              child: GestionTextField(controller: data.documento, hint: '12345678A', inputFormatters: _upper),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'F. nacimiento',
              child: GestionDateField(
                value: data.fechaNacimiento,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                onChanged: (DateTime? v) {
                  debugPrint('📅 Fecha de nacimiento: $v');
                  _set(() => data.fechaNacimiento = v);
                },
              ),
            ),
            GestionFormRow(
              label: 'País de origen',
              child: GestionDropdownField<String>(
                value: data.paisOrigen,
                options: PacienteFormOptions.withValue(PacienteFormOptions.paises, data.paisOrigen),
                onChanged: (String? v) => _set(() => data.paisOrigen = v ?? data.paisOrigen),
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Nº Seg. Social',
              child: GestionTextField(
                controller: data.seguridadSocial,
                hint: '281234567890',
                inputFormatters: _upper,
              ),
            ),
            GestionFormRow(
              label: 'Nº historia',
              child: GestionTextField(controller: data.numHistoria, hint: 'HC-12345', inputFormatters: _upper),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Profesión',
              child: GestionTextField(controller: data.profesion, hint: 'Médico, Ingeniero, etc.'),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}
