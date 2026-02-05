import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Paciente',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        // Si readOnly, mostrar solo el nombre del paciente (no editable)
        if (readOnly && paciente != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        paciente!.nombreCompleto,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      if (paciente!.documento.isNotEmpty)
                        Text(
                          '${paciente!.tipoDocumento}: ${paciente!.documento}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingSmall,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Text(
                    'Pre-seleccionado',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          )
        // Si NO readOnly, mostrar dropdown de búsqueda normal
        else
          AppSearchableDropdown<PacienteEntity>(
            value: paciente,
            label: 'Paciente *',
            hint: 'Buscar por nombre, DNI o tarjeta sanitaria',
            prefixIcon: Icons.person,
            searchHint: 'Escribe para buscar...',
            enabled: !loading,
            items: pacientes
                .map(
                  (PacienteEntity p) => AppSearchableDropdownItem<PacienteEntity>(
                    value: p,
                    label: '${p.nombreCompleto}${p.documento.isNotEmpty ? ' (${p.documento})' : ''}',
                    icon: Icons.person,
                    iconColor: AppColors.primary,
                  ),
                )
                .toList(),
            onChanged: onChanged,
            displayStringForOption: (PacienteEntity p) =>
                '${p.nombreCompleto}${p.documento.isNotEmpty ? ' - ${p.tipoDocumento}: ${p.documento}' : ''}',
          ),
      ],
    );
  }
}
