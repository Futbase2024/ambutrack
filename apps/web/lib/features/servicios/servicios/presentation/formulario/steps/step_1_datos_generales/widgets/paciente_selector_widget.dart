import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Widget selector de paciente con búsqueda
///
/// Si [readOnly] es true, solo muestra el nombre del paciente como texto de solo lectura.
/// Esto se usa cuando el servicio se crea desde la página de pacientes.
class PacienteSelectorWidget extends StatelessWidget {
  const PacienteSelectorWidget({
    super.key,
    required this.paciente,
    required this.pacientes,
    required this.loading,
    required this.onChanged,
    this.readOnly = false,
  });

  final PacienteEntity? paciente;
  final List<PacienteEntity> pacientes;
  final bool loading;
  final ValueChanged<PacienteEntity?> onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return GestionFormRow(
      label: 'Paciente',
      required: true,
      child: readOnly && paciente != null
          ? GestionFormReadOnly(
              value: '${paciente!.nombreCompleto}'
                  '${paciente!.documento.isNotEmpty ? '  ·  ${paciente!.tipoDocumento}: ${paciente!.documento}' : ''}',
            )
          : GestionSearchField<PacienteEntity>(
              value: paciente,
              hint: 'Buscar por nombre, DNI o tarjeta sanitaria',
              loading: loading,
              options: pacientes
                  .map(
                    (PacienteEntity p) => GestionOption<PacienteEntity>(
                      p,
                      '${p.nombreCompleto}${p.documento.isNotEmpty ? ' (${p.documento})' : ''}',
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
    );
  }
}
