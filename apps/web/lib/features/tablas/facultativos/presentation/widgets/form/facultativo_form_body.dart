import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cuerpo del formulario de facultativo
class FacultativoFormBody extends StatelessWidget {
  const FacultativoFormBody({
    super.key,
    required this.nombreController,
    required this.apellidosController,
    required this.numColegiadoController,
    required this.telefonoController,
    required this.emailController,
    required this.especialidades,
    required this.especialidadId,
    required this.activo,
    required this.onEspecialidadChanged,
    required this.onActivoChanged,
  });

  final TextEditingController nombreController;
  final TextEditingController apellidosController;
  final TextEditingController numColegiadoController;
  final TextEditingController telefonoController;
  final TextEditingController emailController;
  final List<EspecialidadEntity> especialidades;
  final String? especialidadId;
  final bool activo;
  final ValueChanged<String?> onEspecialidadChanged;
  final ValueChanged<bool> onActivoChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Datos', first: true),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Nombre',
              required: true,
              child: GestionTextField(
                controller: nombreController,
                inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
            ),
            GestionFormRow(
              label: 'Apellidos',
              required: true,
              child: GestionTextField(
                controller: apellidosController,
                inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Los apellidos son obligatorios';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Nº colegiado',
              child: GestionTextField(controller: numColegiadoController, hint: 'Ej: 28/1234567'),
            ),
            GestionFormRow(
              label: 'Especialidad',
              child: GestionSearchField<String>(
                value: especialidadId,
                hint: 'Selecciona una especialidad',
                options: especialidades
                    .map((EspecialidadEntity e) => GestionOption<String>(e.id, e.nombre))
                    .toList(),
                onChanged: onEspecialidadChanged,
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Contacto'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Teléfono',
              child: GestionTextField(
                controller: telefonoController,
                hint: 'Ej: 612345678',
                keyboardType: TextInputType.phone,
              ),
            ),
            GestionFormRow(
              label: 'Email',
              child: GestionTextField(
                controller: emailController,
                hint: 'ejemplo@hospital.com',
                keyboardType: TextInputType.emailAddress,
                validator: (String? value) {
                  if (value != null && value.trim().isNotEmpty && !value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Estado'),
        GestionFormRow(
          label: 'Estado',
          child: GestionSwitchField(
            value: activo,
            text: activo ? 'Activo' : 'Inactivo',
            onChanged: onActivoChanged,
          ),
        ),
      ],
    );
  }
}
