import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Controllers de los datos de dirección y contacto comunes a Taller y Proveedor
class DatosContactoControllers {
  final TextEditingController direccion = TextEditingController();
  final TextEditingController ciudad = TextEditingController();
  final TextEditingController provincia = TextEditingController();
  final TextEditingController codigoPostal = TextEditingController();
  final TextEditingController telefono = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController contactoNombre = TextEditingController();
  final TextEditingController observaciones = TextEditingController();

  /// Rellena los controllers con los valores existentes
  void populate({
    String? direccion,
    String? ciudad,
    String? provincia,
    String? codigoPostal,
    String? telefono,
    String? email,
    String? contactoNombre,
    String? observaciones,
  }) {
    this.direccion.text = direccion ?? '';
    this.ciudad.text = ciudad ?? '';
    this.provincia.text = provincia ?? '';
    this.codigoPostal.text = codigoPostal ?? '';
    this.telefono.text = telefono ?? '';
    this.email.text = email ?? '';
    this.contactoNombre.text = contactoNombre ?? '';
    this.observaciones.text = observaciones ?? '';
  }

  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      direccion,
      ciudad,
      provincia,
      codigoPostal,
      telefono,
      email,
      contactoNombre,
      observaciones,
    ]) {
      c.dispose();
    }
  }
}

/// Secciones de dirección, contacto y observaciones (estilo gestión)
class DatosContactoFields extends StatelessWidget {
  const DatosContactoFields({
    required this.controllers,
    required this.emailHint,
    required this.contactoHint,
    super.key,
  });

  final DatosContactoControllers controllers;
  final String emailHint;
  final String contactoHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Dirección'),
        GestionFormRow(
          label: 'Dirección',
          child: GestionTextField(controller: controllers.direccion, hint: 'Polígono Industrial, Nave 5'),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Ciudad',
              child: GestionTextField(controller: controllers.ciudad, hint: 'Madrid'),
            ),
            GestionFormRow(
              label: 'Provincia',
              child: GestionTextField(controller: controllers.provincia, hint: 'Madrid'),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'C.P.',
              child: GestionTextField(controller: controllers.codigoPostal, hint: '28001'),
            ),
            const SizedBox.shrink(),
          ],
        ),
        const GestionFormSection(title: 'Contacto'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Teléfono',
              child: GestionTextField(
                controller: controllers.telefono,
                hint: '912345678',
                keyboardType: TextInputType.phone,
              ),
            ),
            GestionFormRow(
              label: 'Email',
              child: GestionTextField(
                controller: controllers.email,
                hint: emailHint,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Persona contacto',
          child: GestionTextField(controller: controllers.contactoNombre, hint: contactoHint),
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(
            controller: controllers.observaciones,
            hint: 'Notas adicionales',
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
