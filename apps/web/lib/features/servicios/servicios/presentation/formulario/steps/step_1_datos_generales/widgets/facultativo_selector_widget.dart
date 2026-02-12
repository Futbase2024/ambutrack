import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget para seleccionar el facultativo que prescribe el traslado
class FacultativoSelectorWidget extends StatelessWidget {
  const FacultativoSelectorWidget({
    super.key,
    required this.facultativo,
    required this.facultativos,
    required this.loading,
    required this.onChanged,
  });

  final FacultativoEntity? facultativo;
  final List<FacultativoEntity> facultativos;
  final bool loading;
  final ValueChanged<FacultativoEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Facultativo que Prescribe',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        AppSearchableDropdown<FacultativoEntity>(
          value: facultativo,
          label: 'Facultativo *',
          hint: 'Buscar por nombre, apellidos o nº colegiado',
          prefixIcon: Icons.medical_information,
          searchHint: 'Escribe para buscar...',
          enabled: !loading,
          items: facultativos
              .map(
                (FacultativoEntity f) => AppSearchableDropdownItem<FacultativoEntity>(
                  value: f,
                  label: '${f.nombre} ${f.apellidos}${f.numColegiado != null ? ' (Col: ${f.numColegiado})' : ''}',
                  icon: Icons.person,
                  iconColor: f.activo ? AppColors.primary : AppColors.textSecondaryLight,
                ),
              )
              .toList(),
          onChanged: onChanged,
          displayStringForOption: (FacultativoEntity f) =>
              '${f.nombre} ${f.apellidos}${f.numColegiado != null ? ' - Col: ${f.numColegiado}' : ''}',
        ),
      ],
    );
  }
}
