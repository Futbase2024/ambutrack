import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab 3: Datos Médicos
class PacienteTabMedico extends StatelessWidget {
  const PacienteTabMedico({
    super.key,
    required this.alergiasController,
    required this.alergiasMedicamentosasController,
    required this.medicacionActualController,
    required this.patologiasPreviasController,
    required this.pesoController,
    required this.grupoSanguineo,
    required this.movilidad,
    required this.onGrupoSanguineoChanged,
    required this.onMovilidadChanged,
  });

  final TextEditingController alergiasController;
  final TextEditingController alergiasMedicamentosasController;
  final TextEditingController medicacionActualController;
  final TextEditingController patologiasPreviasController;
  final TextEditingController pesoController;
  final String? grupoSanguineo;
  final String? movilidad;
  final void Function(String?) onGrupoSanguineoChanged;
  final void Function(String?) onMovilidadChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // SECCIÓN: Alergias
          const _SectionHeader(title: 'Alergias'),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: alergiasController,
            textInputAction: TextInputAction.newline,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Alergias',
              hintText: 'Alergias conocidas (polen, ácaros, alimentos, etc.)',
              prefixIcon: Icon(Icons.warning_amber),
            ),
          ),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: alergiasMedicamentosasController,
            textInputAction: TextInputAction.newline,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Alergias Medicamentosas',
              hintText: 'Alergias a medicamentos (penicilina, aspirina, etc.)',
              prefixIcon: Icon(Icons.medical_services),
            ),
          ),

          const SizedBox(height: AppSizes.spacingLarge),

          // SECCIÓN: Medicación y Patologías
          const _SectionHeader(title: 'Medicación y Patologías'),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: medicacionActualController,
            textInputAction: TextInputAction.newline,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Medicación Actual',
              hintText: 'Medicamentos que toma actualmente (nombre, dosis, frecuencia)',
              prefixIcon: Icon(Icons.medication),
            ),
          ),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: patologiasPreviasController,
            textInputAction: TextInputAction.newline,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Patologías Previas',
              hintText: 'Enfermedades crónicas, intervenciones quirúrgicas, etc.',
              prefixIcon: Icon(Icons.medical_information),
            ),
          ),

          const SizedBox(height: AppSizes.spacingLarge),

          // SECCIÓN: Datos Clínicos
          const _SectionHeader(title: 'Datos Clínicos'),
          const SizedBox(height: AppSizes.spacing),

          Row(
            children: <Widget>[
              Expanded(
                child: AppDropdown<String>(
                  value: grupoSanguineo,
                  label: 'Grupo Sanguíneo',
                  hint: 'Selecciona grupo',
                  prefixIcon: Icons.bloodtype,
                  items: const <AppDropdownItem<String>>[
                    AppDropdownItem<String>(
                      value: 'A+',
                      label: 'A+',
                      icon: Icons.bloodtype,
                      iconColor: AppColors.error,
                    ),
                    AppDropdownItem<String>(
                      value: 'A-',
                      label: 'A-',
                      icon: Icons.bloodtype,
                      iconColor: AppColors.error,
                    ),
                    AppDropdownItem<String>(
                      value: 'B+',
                      label: 'B+',
                      icon: Icons.bloodtype,
                      iconColor: AppColors.warning,
                    ),
                    AppDropdownItem<String>(
                      value: 'B-',
                      label: 'B-',
                      icon: Icons.bloodtype,
                      iconColor: AppColors.warning,
                    ),
                    AppDropdownItem<String>(
                      value: 'AB+',
                      label: 'AB+',
                      icon: Icons.bloodtype,
                      iconColor: AppColors.secondary,
                    ),
                    AppDropdownItem<String>(
                      value: 'AB-',
                      label: 'AB-',
                      icon: Icons.bloodtype,
                      iconColor: AppColors.secondary,
                    ),
                    AppDropdownItem<String>(
                      value: 'O+',
                      label: 'O+',
                      icon: Icons.bloodtype,
                      iconColor: AppColors.primary,
                    ),
                    AppDropdownItem<String>(
                      value: 'O-',
                      label: 'O-',
                      icon: Icons.bloodtype,
                      iconColor: AppColors.primary,
                    ),
                  ],
                  onChanged: onGrupoSanguineoChanged,
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                child: TextFormField(
                  controller: pesoController,
                  textInputAction: TextInputAction.next,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    hintText: '70.5',
                    prefixIcon: Icon(Icons.monitor_weight),
                    suffixText: 'kg',
                  ),
                  validator: (String? value) {
                    if (value != null && value.isNotEmpty) {
                      final double? peso = double.tryParse(value);
                      if (peso == null || peso <= 0 || peso > 500) {
                        return 'Peso no válido (0-500 kg)';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spacing),

          AppDropdown<String>(
            value: movilidad,
            label: 'Movilidad',
            hint: 'Selecciona nivel de movilidad',
            prefixIcon: Icons.accessible,
            items: const <AppDropdownItem<String>>[
              AppDropdownItem<String>(
                value: 'AUTONOMO',
                label: 'Autónomo',
                icon: Icons.directions_walk,
                iconColor: AppColors.success,
              ),
              AppDropdownItem<String>(
                value: 'SILLA_RUEDAS',
                label: 'Silla de Ruedas',
                icon: Icons.wheelchair_pickup,
                iconColor: AppColors.warning,
              ),
              AppDropdownItem<String>(
                value: 'CAMILLA',
                label: 'Camilla',
                icon: Icons.airline_seat_flat,
                iconColor: AppColors.error,
              ),
              AppDropdownItem<String>(
                value: 'ASISTENCIA',
                label: 'Necesita Asistencia',
                icon: Icons.accessibility_new,
                iconColor: AppColors.secondary,
              ),
            ],
            onChanged: onMovilidadChanged,
          ),

          const SizedBox(height: AppSizes.spacingLarge),
        ],
      ),
    );
  }
}

/// Widget de encabezado de sección
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  static const EdgeInsets _sectionPadding = EdgeInsets.symmetric(
    vertical: AppSizes.paddingSmall,
    horizontal: AppSizes.paddingMedium,
  );

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _sectionPadding,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: const Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 3,
          ),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontMedium,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
