import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sección de "Asignación por Defecto" en el formulario de Personal.
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionTitle('Asignación por Defecto (Turnos)'),
        const SizedBox(height: 4),
        Text(
          'Estos valores se pre-rellenarán al crear turnos para esta persona',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontXs,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        Row(
          children: <Widget>[
            Expanded(child: _buildContratoDropdown()),
            const SizedBox(width: AppSizes.spacing),
            Expanded(child: _buildBaseDropdown()),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        Row(
          children: <Widget>[
            Expanded(child: _buildDotacionDropdown()),
            const SizedBox(width: AppSizes.spacing),
            Expanded(child: _buildVehiculoDropdown()),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: AppSizes.fontMedium,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildContratoDropdown() {
    return AppDropdown<String?>(
      value: contratoAsignadoId,
      label: 'Contrato / Cliente',
      hint: 'Seleccionar contrato (opcional)',
      prefixIcon: Icons.description_outlined,
      items: contratos
          .map(
            (ContratoEntity c) => AppDropdownItem<String?>(
              value: c.id,
              label: '${c.tipoContrato ?? c.codigo} (${c.codigo})',
              icon: Icons.description_outlined,
            ),
          )
          .toList(),
      onChanged: onContratoChanged,
    );
  }

  Widget _buildBaseDropdown() {
    return AppDropdown<String?>(
      value: baseId,
      label: 'Base',
      hint: 'Seleccionar base (opcional)',
      prefixIcon: Icons.home_work_outlined,
      items: bases
          .map(
            (BaseCentroEntity b) => AppDropdownItem<String?>(
              value: b.id,
              label: b.nombre,
              icon: Icons.home_work_outlined,
            ),
          )
          .toList(),
      onChanged: onBaseChanged,
    );
  }

  Widget _buildDotacionDropdown() {
    return AppDropdown<String?>(
      value: dotacionId,
      label: 'Dotación',
      hint: 'Seleccionar dotación (opcional)',
      prefixIcon: Icons.groups_outlined,
      items: dotaciones
          .map(
            (DotacionEntity d) => AppDropdownItem<String?>(
              value: d.id,
              label: d.nombre,
              icon: Icons.groups_outlined,
            ),
          )
          .toList(),
      onChanged: onDotacionChanged,
    );
  }

  Widget _buildVehiculoDropdown() {
    return AppSearchableDropdown<VehiculoEntity>(
      value: _selectedVehiculo,
      label: 'Vehículo',
      hint: 'Buscar vehículo (opcional)...',
      prefixIcon: Icons.local_shipping_outlined,
      items: vehiculos
          .map(
            (VehiculoEntity v) => AppSearchableDropdownItem<VehiculoEntity>(
              value: v,
              label: _vehiculoLabel(v),
              icon: Icons.local_shipping_outlined,
            ),
          )
          .toList(),
      onChanged: (VehiculoEntity? value) {
        onVehiculoChanged(value?.id);
      },
      displayStringForOption: _vehiculoLabel,
    );
  }

  VehiculoEntity? get _selectedVehiculo {
    if (vehiculoId == null) {
      return null;
    }
    try {
      return vehiculos.firstWhere(
        (VehiculoEntity v) => v.id == vehiculoId,
      );
    } catch (_) {
      return null;
    }
  }

  String _vehiculoLabel(VehiculoEntity v) {
    return '${v.matricula} - ${v.marca} ${v.modelo}';
  }
}
