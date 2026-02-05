import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tab 5: Administrativo
class PacienteTabAdministrativo extends StatelessWidget {
  const PacienteTabAdministrativo({
    super.key,
    required this.mutuaAseguradoraController,
    required this.numPolizaController,
    required this.observacionesController,
    required this.consentimientoInformado,
    required this.consentimientoInformadoFecha,
    required this.consentimientoRgpd,
    required this.consentimientoRgpdFecha,
    required this.onConsentimientoInformadoChanged,
    required this.onConsentimientoRgpdChanged,
  });

  final TextEditingController mutuaAseguradoraController;
  final TextEditingController numPolizaController;
  final TextEditingController observacionesController;
  final bool consentimientoInformado;
  final DateTime? consentimientoInformadoFecha;
  final bool consentimientoRgpd;
  final DateTime? consentimientoRgpdFecha;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool?) onConsentimientoInformadoChanged;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool?) onConsentimientoRgpdChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // SECCIÓN: Datos de Aseguradora
          const _SectionHeader(title: 'Datos de Aseguradora'),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: mutuaAseguradoraController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Mutua Aseguradora',
              hintText: 'Nombre de la compañía de seguros',
              prefixIcon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: numPolizaController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Número de Póliza',
              hintText: 'Número de póliza del seguro',
              prefixIcon: Icon(Icons.receipt_long),
            ),
          ),

          const SizedBox(height: AppSizes.spacingLarge),

          // SECCIÓN: Observaciones
          const _SectionHeader(title: 'Observaciones'),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: observacionesController,
            textInputAction: TextInputAction.newline,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Observaciones Generales',
              hintText: 'Información adicional relevante sobre el paciente',
              prefixIcon: Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: AppSizes.spacingLarge),

          // SECCIÓN: Consentimientos RGPD
          const _SectionHeader(title: 'Consentimientos RGPD'),
          const SizedBox(height: AppSizes.spacing),

          // Info sobre consentimientos
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: <Widget>[
                Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: Text(
                    'Los consentimientos son obligatorios según la normativa RGPD para el tratamiento de datos médicos.',
                    style: TextStyle(
                      fontSize: AppSizes.fontSmall,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.spacing),

          // Consentimiento Informado
          _ConsentCheckbox(
            label: 'Consentimiento Informado',
            description: 'El paciente ha firmado el consentimiento informado para el tratamiento médico.',
            value: consentimientoInformado,
            fecha: consentimientoInformadoFecha,
            onChanged: onConsentimientoInformadoChanged,
          ),

          const SizedBox(height: AppSizes.spacing),

          // Consentimiento RGPD
          _ConsentCheckbox(
            label: 'Consentimiento RGPD',
            description: 'El paciente ha autorizado el tratamiento de sus datos personales según el RGPD.',
            value: consentimientoRgpd,
            fecha: consentimientoRgpdFecha,
            onChanged: onConsentimientoRgpdChanged,
          ),

          const SizedBox(height: AppSizes.spacingLarge),
        ],
      ),
    );
  }
}

/// Widget de checkbox de consentimiento con fecha
class _ConsentCheckbox extends StatelessWidget {
  const _ConsentCheckbox({
    required this.label,
    required this.description,
    required this.value,
    required this.fecha,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final DateTime? fecha;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: value ? AppColors.success.withValues(alpha: 0.05) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: value ? AppColors.success : AppColors.gray300,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CheckboxListTile(
            title: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w600,
                color: value ? AppColors.success : AppColors.textPrimaryLight,
              ),
            ),
            subtitle: Text(
              description,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                color: AppColors.textSecondaryLight,
              ),
            ),
            value: value,
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.success,
          ),
          if (value && fecha != null) ...<Widget>[
            const Divider(height: AppSizes.spacing),
            Row(
              children: <Widget>[
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondaryLight),
                const SizedBox(width: AppSizes.spacingSmall),
                Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(fecha!)}',
                  style: const TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: AppColors.textSecondaryLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
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
