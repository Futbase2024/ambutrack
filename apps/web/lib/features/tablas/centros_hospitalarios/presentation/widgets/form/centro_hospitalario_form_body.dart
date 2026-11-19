import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cuerpo del formulario de centro hospitalario
class CentroHospitalarioFormBody extends StatelessWidget {
  const CentroHospitalarioFormBody({
    required this.nombreController,
    required this.direccionController,
    required this.telefonoController,
    required this.emailController,
    required this.tiposCentro,
    required this.tipoCentro,
    required this.provincias,
    required this.provinciaId,
    required this.localidades,
    required this.localidadId,
    required this.activo,
    required this.onTipoCentroChanged,
    required this.onProvinciaChanged,
    required this.onLocalidadChanged,
    required this.onActivoChanged,
    super.key,
  });

  final TextEditingController nombreController;
  final TextEditingController direccionController;
  final TextEditingController telefonoController;
  final TextEditingController emailController;
  final List<GestionOption<String>> tiposCentro;
  final String? tipoCentro;
  final List<ProvinciaEntity> provincias;
  final String? provinciaId;

  /// Localidades ya filtradas por la provincia seleccionada
  final List<LocalidadEntity> localidades;
  final String? localidadId;
  final bool activo;
  final ValueChanged<String?> onTipoCentroChanged;
  final ValueChanged<String?> onProvinciaChanged;
  final ValueChanged<String?> onLocalidadChanged;
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
                hint: 'Nombre del centro',
                inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
            ),
            GestionFormRow(
              label: 'Tipo de centro',
              child: GestionDropdownField<String>(
                value: tipoCentro,
                hint: 'Seleccione el tipo',
                options: tiposCentro,
                onChanged: onTipoCentroChanged,
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Dirección'),
        GestionFormRow(
          label: 'Dirección',
          multiline: true,
          child: GestionTextField(
            controller: direccionController,
            hint: 'Dirección completa',
            maxLines: 2,
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Provincia',
              child: GestionSearchField<String>(
                value: provinciaId,
                hint: 'Seleccione la provincia',
                options: provincias.map((ProvinciaEntity p) => GestionOption<String>(p.id, p.nombre)).toList(),
                onChanged: onProvinciaChanged,
              ),
            ),
            GestionFormRow(
              label: 'Localidad',
              child: GestionSearchField<String>(
                value: localidadId,
                hint: provinciaId == null ? 'Primero la provincia' : 'Seleccione la localidad',
                enabled: provinciaId != null,
                options: localidades.map((LocalidadEntity l) => GestionOption<String>(l.id, l.nombre)).toList(),
                onChanged: onLocalidadChanged,
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
                hint: 'Teléfono',
                keyboardType: TextInputType.phone,
              ),
            ),
            GestionFormRow(
              label: 'Email',
              child: GestionTextField(
                controller: emailController,
                hint: 'Email',
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
