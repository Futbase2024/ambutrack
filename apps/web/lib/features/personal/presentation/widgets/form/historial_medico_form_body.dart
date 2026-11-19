import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';

/// Campos del formulario de reconocimiento médico
class HistorialMedicoFormBody extends StatelessWidget {
  const HistorialMedicoFormBody({
    required this.personalList,
    required this.personal,
    required this.fechaReconocimiento,
    required this.fechaCaducidad,
    required this.aptitud,
    required this.activo,
    required this.centroMedico,
    required this.nombreMedico,
    required this.observaciones,
    required this.restricciones,
    required this.documento,
    required this.onPersonalChanged,
    required this.onFechaReconocimientoChanged,
    required this.onFechaCaducidadChanged,
    required this.onAptitudChanged,
    required this.onActivoChanged,
    super.key,
  });

  final List<PersonalEntity> personalList;
  final PersonalEntity? personal;
  final DateTime? fechaReconocimiento;
  final DateTime? fechaCaducidad;
  final String aptitud;
  final bool activo;
  final TextEditingController centroMedico;
  final TextEditingController nombreMedico;
  final TextEditingController observaciones;
  final TextEditingController restricciones;

  /// Selector de documento adjunto
  final Widget documento;

  final ValueChanged<String?> onPersonalChanged;
  final ValueChanged<DateTime?> onFechaReconocimientoChanged;
  final ValueChanged<DateTime?> onFechaCaducidadChanged;
  final ValueChanged<String> onAptitudChanged;
  final ValueChanged<bool> onActivoChanged;

  static const List<GestionOption<String>> _aptitudes = <GestionOption<String>>[
    GestionOption<String>(AptitudMedica.apto, 'Apto', color: AppColors.success),
    GestionOption<String>(AptitudMedica.aptoConRestricciones, 'Apto con restricciones', color: AppColors.warning),
    GestionOption<String>(AptitudMedica.noApto, 'No apto', color: AppColors.error),
  ];

  String? _validarRestricciones(String? value) {
    if (aptitud == AptitudMedica.aptoConRestricciones && (value == null || value.isEmpty)) {
      return 'Las restricciones son requeridas para "Apto con restricciones"';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Personal', first: true),
        GestionFormRow(
          label: 'Empleado',
          required: true,
          child: GestionSearchField<String>(
            value: personal?.id,
            required: true,
            hint: 'Buscar por nombre o DNI',
            options: personalList
                .map(
                  (PersonalEntity p) => GestionOption<String>(
                    p.id,
                    '${p.nombreCompleto} - ${p.dni}',
                    color: AppColors.primary,
                  ),
                )
                .toList(),
            onChanged: onPersonalChanged,
          ),
        ),
        const GestionFormSection(title: 'Reconocimiento'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Fecha recon.',
                  required: true,
                  child: GestionDateField(
                    value: fechaReconocimiento,
                    required: true,
                    lastDate: DateTime.now(),
                    onChanged: onFechaReconocimientoChanged,
                  ),
                ),
                GestionFormRow(
                  label: 'Aptitud',
                  required: true,
                  child: GestionDropdownField<String>(
                    value: aptitud,
                    options: _aptitudes,
                    required: true,
                    onChanged: (String? v) {
                      if (v != null) {
                        onAptitudChanged(v);
                      }
                    },
                  ),
                ),
                GestionFormRow(
                  label: 'Centro médico',
                  child: GestionTextField(controller: centroMedico, hint: 'Nombre del centro médico'),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Caducidad',
                  required: true,
                  child: GestionDateField(
                    // Se recrea si la caducidad se sugiere desde la fecha de reconocimiento
                    key: ValueKey<DateTime?>(fechaCaducidad),
                    value: fechaCaducidad,
                    required: true,
                    firstDate: fechaReconocimiento ?? DateTime.now(),
                    onChanged: onFechaCaducidadChanged,
                  ),
                ),
                GestionFormRow(
                  label: 'Estado',
                  child: GestionSwitchField(
                    value: activo,
                    text: activo ? 'Activo' : 'Inactivo',
                    onChanged: onActivoChanged,
                  ),
                ),
                GestionFormRow(
                  label: 'Médico',
                  child: GestionTextField(controller: nombreMedico, hint: 'Nombre del médico'),
                ),
              ],
            ),
          ],
        ),
        if (aptitud == AptitudMedica.aptoConRestricciones)
          GestionFormRow(
            label: 'Restricciones',
            required: true,
            multiline: true,
            child: GestionTextField(
              controller: restricciones,
              maxLines: 3,
              hint: 'Describa las restricciones médicas',
              validator: _validarRestricciones,
            ),
          ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(
            controller: observaciones,
            maxLines: 3,
            hint: 'Observaciones del reconocimiento',
          ),
        ),
        const GestionFormSection(title: 'Documentación'),
        GestionFormRow(label: 'Documento', child: documento),
      ],
    );
  }
}
