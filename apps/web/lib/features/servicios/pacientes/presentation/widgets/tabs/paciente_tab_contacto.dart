import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/form/paciente_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sección de contacto y dirección del formulario de paciente
class PacienteTabContacto extends StatelessWidget {
  const PacienteTabContacto({
    required this.data,
    required this.provincias,
    required this.localidadesFiltradas,
    required this.onProvinciaChanged,
    required this.onChanged,
    super.key,
  });

  final PacienteFormData data;
  final List<ProvinciaEntity> provincias;
  final List<LocalidadEntity> localidadesFiltradas;
  final ValueChanged<String?> onProvinciaChanged;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  static final List<TextInputFormatter> _upper = <TextInputFormatter>[PacienteUpperCaseFormatter()];

  static String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      final bool valid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value);
      if (!valid) {
        return 'Email no válido';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Contacto'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Tel. móvil',
              child: GestionTextField(
                controller: data.telefonoMovil,
                hint: '+34 600 000 000',
                keyboardType: TextInputType.phone,
              ),
            ),
            GestionFormRow(
              label: 'Tel. fijo',
              child: GestionTextField(
                controller: data.telefonoFijo,
                hint: '+34 900 000 000',
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Email',
              child: GestionTextField(
                controller: data.email,
                hint: 'ejemplo@correo.com',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
        const GestionFormSection(title: 'Domicilio y recogida'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Provincia',
              child: GestionSearchField<String>(
                value: data.provinciaId,
                hint: 'Buscar provincia…',
                options: provincias.map((ProvinciaEntity p) => GestionOption<String>(p.id, p.nombre)).toList(),
                onChanged: onProvinciaChanged,
              ),
            ),
            GestionFormRow(
              label: 'Localidad',
              child: GestionSearchField<String>(
                value: data.localidadId,
                enabled: data.provinciaId != null,
                hint: data.provinciaId == null ? 'Selecciona provincia primero' : 'Buscar localidad…',
                options: localidadesFiltradas
                    .map((LocalidadEntity l) => GestionOption<String>(l.id, l.nombre))
                    .toList(),
                onChanged: (String? v) {
                  data.localidadId = v;
                  onChanged();
                },
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Domicilio',
          required: true,
          multiline: true,
          child: GestionTextField(
            controller: data.domicilioDireccion,
            hint: 'CALLE, NÚMERO, PISO, PUERTA, CIUDAD, CÓDIGO POSTAL',
            maxLines: 2,
            inputFormatters: _upper,
            validator: (String? v) =>
                (v == null || v.trim().isEmpty) ? 'La dirección es obligatoria' : null,
          ),
        ),
        GestionFormRow(
          label: 'Recogida',
          multiline: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: GestionTextField(
                  controller: data.recogidaDireccion,
                  hint: 'CALLE, NÚMERO, PISO, PUERTA, INSTRUCCIONES ESPECIALES',
                  maxLines: 2,
                  inputFormatters: _upper,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Copiar de domicilio',
                icon: const Icon(Icons.content_copy, size: 16),
                color: AppColors.primary,
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  data.recogidaDireccion.text = data.domicilioDireccion.text;
                  onChanged();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
