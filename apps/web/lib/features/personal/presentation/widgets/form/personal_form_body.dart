import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_servicio.dart';
import 'package:ambutrack_web/features/personal/domain/entities/poblacion_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_data.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Secciones "Datos personales", "Contacto" y "Dirección" del formulario de Personal
class PersonalFormBody extends StatelessWidget {
  const PersonalFormBody({
    required this.data,
    required this.onChanged,
    required this.onProvinciaChanged,
    super.key,
  });

  final PersonalFormData data;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;
  final ValueChanged<String?> onProvinciaChanged;

  static final DateTime _first = DateTime(1950);

  static String? _requerido(String? value) =>
      (value == null || value.isEmpty) ? 'Este campo es obligatorio' : null;

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
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Nombre',
                  required: true,
                  child: GestionTextField(
                    controller: data.nombre,
                    hint: 'Ej: JUAN',
                    validator: _requerido,
                    inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
                  ),
                ),
                GestionFormRow(
                  label: 'DNI/NIE',
                  child: GestionTextField(controller: data.dni, hint: 'Ej: 12345678A'),
                ),
                GestionFormRow(
                  label: 'F. nacimiento',
                  child: GestionDateField(
                    value: data.fechaNacimiento,
                    firstDate: _first,
                    onChanged: (DateTime? v) => _set(() => data.fechaNacimiento = v),
                  ),
                ),
                GestionFormRow(
                  label: 'Cat. laboral',
                  child: PersonalFkField(
                    value: data.categoriaIdFk,
                    hint: 'Seleccionar categoría',
                    options: data.categoriasPersonal
                        .map((CategoriaPersonalEntity c) => GestionOption<String>(c.id, c.categoria))
                        .toList(),
                    onChanged: (String? v) => _set(() => data.categoriaIdFk = v),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Apellidos',
                  required: true,
                  child: GestionTextField(
                    controller: data.apellidos,
                    hint: 'Ej: GARCÍA PÉREZ',
                    validator: _requerido,
                    inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
                  ),
                ),
                GestionFormRow(
                  label: 'NASS',
                  child: GestionTextField(
                    controller: data.nass,
                    hint: 'Nº Seguridad Social',
                    keyboardType: TextInputType.number,
                  ),
                ),
                GestionFormRow(
                  label: 'Fecha inicio',
                  child: GestionDateField(
                    value: data.fechaInicio,
                    firstDate: _first,
                    onChanged: (DateTime? v) => _set(() => data.fechaInicio = v),
                  ),
                ),
                GestionFormRow(
                  label: 'Cat. servicio',
                  child: GestionDropdownField<CategoriaServicio>(
                    value: data.categoriaServicio,
                    options: CategoriaServicio.values
                        .map(
                          (CategoriaServicio c) => GestionOption<CategoriaServicio>(
                            c,
                            c.nombre,
                            color: c == CategoriaServicio.urgencias ? AppColors.emergency : AppColors.info,
                          ),
                        )
                        .toList(),
                    onChanged: (CategoriaServicio? v) {
                      if (v != null) {
                        _set(() => data.categoriaServicio = v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        const GestionFormSection(title: 'Contacto'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Email',
                  child: GestionTextField(
                    controller: data.email,
                    hint: 'ejemplo@correo.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                GestionFormRow(
                  label: 'Móvil',
                  child: GestionTextField(
                    controller: data.movil,
                    hint: '+34 600 000 000',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            GestionFormRow(
              label: 'Teléfono fijo',
              child: GestionTextField(
                controller: data.telefono,
                hint: '+34 912 345 678',
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Dirección'),
        GestionFormRow(
          label: 'Dirección',
          child: GestionTextField(controller: data.direccion, hint: 'Calle, número, piso'),
        ),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Provincia',
                  child: PersonalFkField(
                    value: data.provinciaId,
                    hint: 'Seleccionar provincia',
                    options: data.provincias
                        .map((ProvinciaEntity p) => GestionOption<String>(p.id, p.nombre))
                        .toList(),
                    onChanged: onProvinciaChanged,
                  ),
                ),
                GestionFormRow(
                  label: 'Código postal',
                  child: GestionTextField(
                    controller: data.codigoPostal,
                    hint: '28001',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            GestionFormRow(
              label: 'Población',
              child: PersonalFkField(
                value: data.poblacionId,
                enabled: data.provinciaId != null,
                hint: data.provinciaId == null ? 'Primero elige provincia' : 'Seleccionar población',
                options: data.poblaciones
                    .map((PoblacionEntity p) => GestionOption<String>(p.id, p.nombre))
                    .toList(),
                onChanged: (String? v) => _set(() => data.poblacionId = v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
