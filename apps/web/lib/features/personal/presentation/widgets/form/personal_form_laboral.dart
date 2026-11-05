import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/domain/entities/empresa_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/puesto_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/tipo_contrato_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_data.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_fields.dart';
import 'package:flutter/material.dart';

/// Secciones "Datos laborales" y "Acceso" del formulario de Personal
class PersonalFormLaboral extends StatelessWidget {
  const PersonalFormLaboral({required this.data, required this.onChanged, super.key});

  final PersonalFormData data;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  static final DateTime _first = DateTime(1950);

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Datos laborales'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Empresa',
                  child: PersonalFkField(
                    value: data.empresaIdFk,
                    hint: 'Seleccionar empresa',
                    options: data.empresas
                        .map((EmpresaEntity e) => GestionOption<String>(e.id, e.nombre))
                        .toList(),
                    onChanged: (String? v) => _set(() => data.empresaIdFk = v),
                  ),
                ),
                GestionFormRow(
                  label: 'Puesto',
                  child: PersonalFkField(
                    value: data.puestoId,
                    hint: 'Seleccionar puesto',
                    options: data.puestos
                        .map((PuestoEntity p) => GestionOption<String>(p.id, p.nombre))
                        .toList(),
                    onChanged: (String? v) => _set(() => data.puestoId = v),
                  ),
                ),
                GestionFormRow(
                  label: 'Tipo contrato',
                  child: PersonalFkField(
                    value: data.contratoId,
                    hint: 'Seleccionar tipo de contrato',
                    options: data.contratos
                        .map((TipoContratoEntity c) => GestionOption<String>(c.id, c.nombre))
                        .toList(),
                    onChanged: (String? v) => _set(() => data.contratoId = v),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Fecha alta',
                  child: GestionDateField(
                    value: data.fechaAlta,
                    firstDate: _first,
                    onChanged: (DateTime? v) => _set(() => data.fechaAlta = v),
                  ),
                ),
                GestionFormRow(
                  label: 'F. antigüedad',
                  child: GestionDateField(
                    value: data.dataAnti,
                    firstDate: _first,
                    onChanged: (DateTime? v) => _set(() => data.dataAnti = v),
                  ),
                ),
                GestionFormRow(
                  label: 'TES',
                  child: GestionSwitchField(
                    value: data.tesSiNo,
                    text: 'Técnico en Emergencias Sanitarias',
                    onChanged: (bool v) => _set(() => data.tesSiNo = v),
                  ),
                ),
              ],
            ),
          ],
        ),
        const GestionFormSection(title: 'Acceso'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Usuario',
              child: GestionTextField(controller: data.usuario, hint: 'Nombre de usuario'),
            ),
            const SizedBox.shrink(),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Contraseña web',
              child: PersonalPasswordField(controller: data.pwdWeb),
            ),
            GestionFormRow(
              label: 'Contraseña',
              child: PersonalPasswordField(controller: data.pwd),
            ),
          ],
        ),
      ],
    );
  }
}
