import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget configuración de tipo de servicio
class TipoServicioConfigWidget extends StatelessWidget {
  const TipoServicioConfigWidget({
    super.key,
    required this.motivoSeleccionado,
    required this.motivos,
    required this.loading,
    required this.onChanged,
  });

  final MotivoTrasladoEntity? motivoSeleccionado;
  final List<MotivoTrasladoEntity> motivos;
  final bool loading;
  final ValueChanged<MotivoTrasladoEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tipo de Servicio *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        if (loading)
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: const Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: AppSizes.spacingSmall),
                Text('Cargando tipos de servicio...'),
              ],
            ),
          )
        else
          AppSearchableDropdown<MotivoTrasladoEntity>(
            value: motivoSeleccionado,
            items: motivos
                .map(
                  (MotivoTrasladoEntity motivo) => AppSearchableDropdownItem<MotivoTrasladoEntity>(
                    value: motivo,
                    label: motivo.nombre,
                    icon: Icons.medical_services,
                    iconColor: AppColors.secondary,
                  ),
                )
                .toList(),
            onChanged: onChanged,
            hint: motivos.isEmpty ? 'No hay tipos de servicio disponibles' : 'Buscar tipo de servicio...',
            prefixIcon: Icons.medical_services,
            enabled: motivos.isNotEmpty,
          ),
      ],
    );
  }
}
