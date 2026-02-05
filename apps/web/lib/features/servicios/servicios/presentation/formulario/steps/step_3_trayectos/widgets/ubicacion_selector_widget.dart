import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/tipo_ubicacion.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Selector de ubicación (origen/destino)
class UbicacionSelectorWidget extends StatelessWidget {
  const UbicacionSelectorWidget({
    required this.label,
    required this.tipoUbicacion,
    required this.domicilio,
    required this.centroNombre,
    required this.loadingCentros,
    required this.centrosHospitalarios,
    required this.centrosDropdownItems,
    required this.pacienteNombreCompleto,
    required this.onTipoChanged,
    required this.onDomicilioChanged,
    required this.onCentroChanged,
    super.key,
  });

  final String label;
  final TipoUbicacion tipoUbicacion;
  final String? domicilio;
  final String? centroNombre;
  final bool loadingCentros;
  final List<CentroHospitalarioEntity> centrosHospitalarios;
  final List<AppSearchableDropdownItem<CentroHospitalarioEntity>> centrosDropdownItems;
  final String? pacienteNombreCompleto;
  final void Function(TipoUbicacion) onTipoChanged;
  final void Function(String?) onDomicilioChanged;
  final void Function(String?) onCentroChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Etiqueta y botones en la misma línea
        Row(
          children: <Widget>[
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(width: 8),
            // Botones de tipo (compactos)
            _UbicacionOptionButton(
              icon: Icons.home,
              tooltip: 'Domicilio paciente',
              isSelected: tipoUbicacion == TipoUbicacion.domicilioPaciente,
              onTap: () => onTipoChanged(TipoUbicacion.domicilioPaciente),
            ),
            const SizedBox(width: 4),
            _UbicacionOptionButton(
              icon: Icons.location_on,
              tooltip: 'Otro domicilio',
              isSelected: tipoUbicacion == TipoUbicacion.otroDomicilio,
              onTap: () => onTipoChanged(TipoUbicacion.otroDomicilio),
            ),
            const SizedBox(width: 4),
            _UbicacionOptionButton(
              icon: Icons.local_hospital,
              tooltip: 'Centro hospitalario',
              isSelected: tipoUbicacion == TipoUbicacion.centroHospitalario,
              onTap: () => onTipoChanged(TipoUbicacion.centroHospitalario),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Campo dinámico según tipo
        _buildDynamicField(context),
      ],
    );
  }

  Widget _buildDynamicField(BuildContext context) {
    // Domicilio paciente
    if (tipoUbicacion == TipoUbicacion.domicilioPaciente) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                pacienteNombreCompleto != null ? 'Domicilio de $pacienteNombreCompleto' : 'Domicilio del paciente',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Otro domicilio
    if (tipoUbicacion == TipoUbicacion.otroDomicilio) {
      return TextFormField(
        initialValue: domicilio,
        decoration: InputDecoration(
          hintText: 'Escribe la dirección',
          prefixIcon: const Icon(Icons.edit_location, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          isDense: true,
        ),
        style: GoogleFonts.inter(fontSize: 13),
        onChanged: onDomicilioChanged,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Ingresa la dirección';
          }
          return null;
        },
      );
    }

    // Centro hospitalario
    if (tipoUbicacion == TipoUbicacion.centroHospitalario) {
      if (loadingCentros) {
        return Container(
          height: 48,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: const Row(
            children: <Widget>[
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Cargando...', style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      }

      return AppSearchableDropdown<CentroHospitalarioEntity>(
        value: centroNombre != null
            ? centrosHospitalarios.firstWhere(
                (CentroHospitalarioEntity c) => c.nombre == centroNombre,
                orElse: () => centrosHospitalarios.first,
              )
            : null,
        items: centrosDropdownItems,
        onChanged: (CentroHospitalarioEntity? centro) {
          onCentroChanged(centro?.nombre);
        },
        hint: centrosHospitalarios.isEmpty ? 'Sin centros' : 'Buscar centro...',
        prefixIcon: Icons.local_hospital,
        enabled: centrosHospitalarios.isNotEmpty,
      );
    }

    return const SizedBox.shrink();
  }
}

/// Botón compacto de opción de ubicación
class _UbicacionOptionButton extends StatelessWidget {
  const _UbicacionOptionButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.gray300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : AppColors.gray400,
            size: 18,
          ),
        ),
      ),
    );
  }
}
