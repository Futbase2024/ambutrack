import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/form/contrato_form_sections.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/form/contrato_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ContratoTextField(
          controller: codigoController,
          label: 'Código del Contrato',
          hint: 'Ej: AYT2024',
          icon: Icons.tag,
          enabled: !isViewOnly,
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'El código es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.spacing),
        AppDropdown<String>(
          value: selectedHospitalId,
          label: 'Centro Hospitalario',
          hint: 'Selecciona un hospital',
          prefixIcon: Icons.local_hospital,
          enabled: !isViewOnly,
          items: hospitales.map((CentroHospitalarioEntity hospital) {
            return AppDropdownItem<String>(
              value: hospital.id,
              label: hospital.nombre,
              icon: Icons.local_hospital,
              iconColor: AppColors.primary,
            );
          }).toList(),
          onChanged: onHospitalChanged,
        ),
        const SizedBox(height: AppSizes.spacing),
        AppDropdown<String>(
          value: tipoContrato,
          label: 'Tipo de Contrato',
          hint: 'Selecciona el tipo',
          prefixIcon: Icons.category,
          enabled: !isViewOnly,
          items: kTiposContrato.map((String tipo) {
            return AppDropdownItem<String>(value: tipo, label: tipo);
          }).toList(),
          onChanged: onTipoChanged,
        ),
        const SizedBox(height: AppSizes.spacing),
        ContratoFechasRow(
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
          enabled: !isViewOnly,
          onFechaInicioChanged: onFechaInicioChanged,
          onFechaFinChanged: onFechaFinChanged,
        ),
        const SizedBox(height: AppSizes.spacing),
        ContratoTextField(
          controller: importeController,
          label: 'Importe Mensual (€)',
          hint: 'Ej: 5000.00',
          icon: Icons.euro,
          enabled: !isViewOnly,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        ContratoTextField(
          controller: descripcionController,
          label: 'Descripción',
          hint: 'Descripción del contrato',
          icon: Icons.description,
          enabled: !isViewOnly,
          maxLines: 3,
        ),
        const SizedBox(height: AppSizes.spacing),
        if (!isViewOnly) ContratoActivoCheckbox(value: activo, onChanged: onActivoChanged),
      ],
    );
  }
}
