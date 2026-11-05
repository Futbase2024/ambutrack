import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/form/taller_form_components.dart';
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

/// Campos de dirección, teléfono, email, contacto y observaciones
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

  static const SizedBox _hGap = SizedBox(width: AppSizes.spacingMedium);
  static const SizedBox _vGap = SizedBox(height: AppSizes.spacingMedium);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TallerFormField(
          controller: controllers.direccion,
          label: 'Dirección',
          hint: 'Polígono Industrial, Nave 5',
          icon: Icons.location_on_outlined,
        ),
        _vGap,
        Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: TallerFormField(controller: controllers.ciudad, label: 'Ciudad', hint: 'Madrid'),
            ),
            _hGap,
            Expanded(
              flex: 3,
              child: TallerFormField(controller: controllers.provincia, label: 'Provincia', hint: 'Madrid'),
            ),
            _hGap,
            Expanded(
              flex: 2,
              child: TallerFormField(controller: controllers.codigoPostal, label: 'C.P.', hint: '28001'),
            ),
          ],
        ),
        _vGap,
        Row(
          children: <Widget>[
            Expanded(
              child: TallerFormField(
                controller: controllers.telefono,
                label: 'Teléfono',
                hint: '912345678',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),
            _hGap,
            Expanded(
              child: TallerFormField(
                controller: controllers.email,
                label: 'Email',
                hint: emailHint,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
        _vGap,
        TallerFormField(
          controller: controllers.contactoNombre,
          label: 'Persona de contacto',
          hint: contactoHint,
          icon: Icons.person_outline,
        ),
        _vGap,
        TallerFormField(
          controller: controllers.observaciones,
          label: 'Observaciones',
          hint: 'Notas adicionales...',
          maxLines: 2,
        ),
      ],
    );
  }
}
