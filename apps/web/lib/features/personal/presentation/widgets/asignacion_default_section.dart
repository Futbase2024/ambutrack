import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_fields.dart';
import 'package:flutter/material.dart';

/// Sección de "Asignación por defecto" en el formulario de Personal.
///
/// Permite configurar los valores por defecto que se pre-rellenarán
/// al crear turnos para esta persona en "Horarios y turnos".
class AsignacionDefaultSection extends StatelessWidget {
  const AsignacionDefaultSection({
    super.key,
    required this.contratoAsignadoId,
    required this.baseId,
    required this.dotacionId,
    required this.vehiculoId,
    required this.contratos,
    required this.bases,
    required this.dotaciones,
    required this.vehiculos,
    required this.onContratoChanged,
    required this.onBaseChanged,
    required this.onDotacionChanged,
    required this.onVehiculoChanged,
  });

  final String? contratoAsignadoId;
  final String? baseId;
  final String? dotacionId;
  final String? vehiculoId;

  final List<ContratoEntity> contratos;
  final List<BaseCentroEntity> bases;
  final List<DotacionEntity> dotaciones;
  final List<VehiculoEntity> vehiculos;

  final ValueChanged<String?> onContratoChanged;
  final ValueChanged<String?> onBaseChanged;
  final ValueChanged<String?> onDotacionChanged;
  final ValueChanged<String?> onVehiculoChanged;

  static String _vehiculoLabel(VehiculoEntity v) => '${v.matricula} - ${v.marca} ${v.modelo}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Asignación por defecto (turnos)'),
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Estos valores se pre-rellenarán al crear turnos para esta persona',
            style: GestionFormStyle.hint,
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Contrato',
                  child: PersonalFkField(
                    value: contratoAsignadoId,
                    hint: 'Opcional',
                    options: contratos
                        .map(
                          (ContratoEntity c) =>
                              GestionOption<String>(c.id, '${c.tipoContrato ?? c.codigo} (${c.codigo})'),
                        )
                        .toList(),
                    onChanged: onContratoChanged,
                  ),
                ),
                GestionFormRow(
                  label: 'Dotación',
                  child: PersonalFkField(
                    value: dotacionId,
                    hint: 'Opcional',
                    options: dotaciones.map((DotacionEntity d) => GestionOption<String>(d.id, d.nombre)).toList(),
                    onChanged: onDotacionChanged,
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Base',
                  child: PersonalFkField(
                    value: baseId,
                    hint: 'Opcional',
                    options: bases.map((BaseCentroEntity b) => GestionOption<String>(b.id, b.nombre)).toList(),
                    onChanged: onBaseChanged,
                  ),
                ),
                GestionFormRow(
                  label: 'Vehículo',
                  child: GestionSearchField<String>(
                    value: vehiculoId,
                    hint: 'Buscar vehículo (opcional)',
                    options: vehiculos
                        .map((VehiculoEntity v) => GestionOption<String>(v.id, _vehiculoLabel(v)))
                        .toList(),
                    onChanged: onVehiculoChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
