import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Campos del formulario de proveedor de almacén
class ProveedorFormBody extends StatelessWidget {
  const ProveedorFormBody({
    super.key,
    required this.codigo,
    required this.nombreComercial,
    required this.razonSocial,
    required this.cifNif,
    required this.direccion,
    required this.codigoPostal,
    required this.telefono,
    required this.email,
    required this.provincias,
    required this.localidades,
    required this.provinciaId,
    required this.localidadId,
    required this.onProvincia,
    required this.onLocalidad,
    required this.activo,
    required this.onActivo,
  });

  final TextEditingController codigo;
  final TextEditingController nombreComercial;
  final TextEditingController razonSocial;
  final TextEditingController cifNif;
  final TextEditingController direccion;
  final TextEditingController codigoPostal;
  final TextEditingController telefono;
  final TextEditingController email;
  final List<ProvinciaEntity> provincias;
  final List<LocalidadEntity> localidades;
  final String? provinciaId;
  final String? localidadId;
  final ValueChanged<String?> onProvincia;
  final ValueChanged<String?> onLocalidad;
  final bool activo;
  final ValueChanged<bool> onActivo;

  static String? _requerido(String? v, String msg) => (v == null || v.trim().isEmpty) ? msg : null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Datos generales', first: true),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Código',
              required: true,
              child: GestionTextField(
                controller: codigo,
                hint: 'PROV001',
                validator: (String? v) => _requerido(v, 'El código es requerido'),
              ),
            ),
            GestionFormRow(
              label: 'Estado',
              child: GestionSwitchField(value: activo, text: activo ? 'Activo' : 'Inactivo', onChanged: onActivo),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Nombre comercial',
          required: true,
          child: GestionTextField(
            controller: nombreComercial,
            hint: 'Suministros Médicos SA',
            validator: (String? v) => _requerido(v, 'El nombre comercial es requerido'),
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(label: 'Razón social', child: GestionTextField(controller: razonSocial)),
            GestionFormRow(label: 'CIF/NIF', child: GestionTextField(controller: cifNif)),
          ],
        ),
        const GestionFormSection(title: 'Dirección'),
        GestionFormRow(label: 'Dirección', child: GestionTextField(controller: direccion)),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Provincia',
              child: GestionSearchField<String>(
                value: provinciaId,
                hint: 'Selecciona provincia',
                options: provincias
                    .map((ProvinciaEntity p) => GestionOption<String>(p.id, p.nombre))
                    .toList(growable: false),
                onChanged: onProvincia,
              ),
            ),
            GestionFormRow(
              label: 'Localidad',
              child: GestionSearchField<String>(
                value: localidadId,
                hint: provinciaId == null ? 'Selecciona provincia primero' : 'Selecciona localidad',
                enabled: provinciaId != null && localidades.isNotEmpty,
                options: localidades
                    .map((LocalidadEntity l) => GestionOption<String>(l.id, l.nombre))
                    .toList(growable: false),
                onChanged: onLocalidad,
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(label: 'C.P.', child: GestionTextField(controller: codigoPostal)),
            const SizedBox.shrink(),
          ],
        ),
        const GestionFormSection(title: 'Contacto'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Teléfono',
              child: GestionTextField(controller: telefono, keyboardType: TextInputType.phone),
            ),
            GestionFormRow(
              label: 'Email',
              child: GestionTextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                validator: (String? v) =>
                    v != null && v.trim().isNotEmpty && !v.contains('@') ? 'Email no válido' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
