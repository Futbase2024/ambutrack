import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Tipos de contrato disponibles
const List<String> kTiposContrato = <String>[
  'URGENCIAS',
  'PROGRAMADO',
  'MIXTO',
  'EVENTOS',
  'TRASLADOS',
];

/// Campos del formulario de contrato
class ContratoFormFields extends StatelessWidget {
  const ContratoFormFields({
    super.key,
    required this.isViewOnly,
    required this.isLoadingHospitales,
    required this.codigoController,
    required this.importeController,
    required this.descripcionController,
    required this.hospitales,
    required this.selectedHospitalId,
    required this.tipoContrato,
    required this.fechaInicio,
    required this.fechaFin,
    required this.activo,
    required this.onHospitalChanged,
    required this.onTipoChanged,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onActivoChanged,
  });

  final bool isViewOnly;
  final bool isLoadingHospitales;
  final TextEditingController codigoController;
  final TextEditingController importeController;
  final TextEditingController descripcionController;
  final List<CentroHospitalarioEntity> hospitales;
  final String? selectedHospitalId;
  final String? tipoContrato;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final bool activo;
  final ValueChanged<String?> onHospitalChanged;
  final ValueChanged<String?> onTipoChanged;
  final ValueChanged<DateTime?> onFechaInicioChanged;
  final ValueChanged<DateTime?> onFechaFinChanged;
  final ValueChanged<bool> onActivoChanged;

  List<GestionOption<String>> get _tipos => <String>{
        ...kTiposContrato,
        if (tipoContrato != null) tipoContrato!,
      }.map((String t) => GestionOption<String>(t, t)).toList();

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isViewOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Contrato', first: true),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Código',
              required: true,
              child: GestionTextField(
                controller: codigoController,
                hint: 'Ej: AYT2024',
                enabled: enabled,
                validator: (String? value) =>
                    (value == null || value.trim().isEmpty) ? 'El código es obligatorio' : null,
              ),
            ),
            GestionFormRow(
              label: 'Tipo',
              child: GestionDropdownField<String>(
                value: tipoContrato,
                options: _tipos,
                enabled: enabled,
                hint: 'Selecciona el tipo',
                onChanged: onTipoChanged,
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Hospital',
          required: true,
          child: GestionSearchField<String>(
            value: selectedHospitalId,
            required: true,
            enabled: enabled,
            loading: isLoadingHospitales,
            hint: 'Selecciona un hospital',
            options: hospitales
                .map(
                  (CentroHospitalarioEntity h) =>
                      GestionOption<String>(h.id, h.nombre, color: AppColors.primary),
                )
                .toList(),
            onChanged: onHospitalChanged,
          ),
        ),
        const GestionFormSection(title: 'Vigencia e importe'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Fecha inicio',
                  required: true,
                  child: IgnorePointer(
                    ignoring: !enabled,
                    child: GestionDateField(
                      value: fechaInicio,
                      required: true,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2050),
                      onChanged: onFechaInicioChanged,
                    ),
                  ),
                ),
                GestionFormRow(
                  label: 'Importe/mes',
                  child: GestionMoneyField(controller: importeController, enabled: enabled),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Fecha fin',
                  child: IgnorePointer(
                    ignoring: !enabled,
                    child: _FechaFinField(
                      fechaInicio: fechaInicio,
                      fechaFin: fechaFin,
                      onChanged: onFechaFinChanged,
                    ),
                  ),
                ),
                if (enabled)
                  GestionFormRow(
                    label: 'Estado',
                    child: GestionCheckField(value: activo, text: 'Contrato activo', onChanged: onActivoChanged),
                  ),
              ],
            ),
          ],
        ),
        GestionFormRow(
          label: 'Descripción',
          multiline: true,
          child: GestionTextField(
            controller: descripcionController,
            hint: 'Descripción del contrato',
            enabled: enabled,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}

/// Fecha fin opcional, validada contra la fecha de inicio
class _FechaFinField extends StatelessWidget {
  const _FechaFinField({required this.fechaInicio, required this.fechaFin, required this.onChanged});

  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestionDateField(
          value: fechaFin,
          firstDate: DateTime(2020),
          lastDate: DateTime(2050),
          onChanged: onChanged,
        ),
        FormField<DateTime>(
          validator: (_) => fechaFin != null && fechaInicio != null && fechaFin!.isBefore(fechaInicio!)
              ? 'Debe ser posterior a inicio'
              : null,
          builder: (FormFieldState<DateTime> state) => state.hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, left: 10),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(fontSize: 11, color: AppColors.error),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
