import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab 4: Emergencias
class PacienteTabEmergencia extends StatelessWidget {
  const PacienteTabEmergencia({
    super.key,
    required this.emergencia1NombreController,
    required this.emergencia1TelefonoController,
    required this.emergencia1RelacionController,
    required this.emergencia2NombreController,
    required this.emergencia2TelefonoController,
    required this.emergencia2RelacionController,
  });

  final TextEditingController emergencia1NombreController;
  final TextEditingController emergencia1TelefonoController;
  final TextEditingController emergencia1RelacionController;
  final TextEditingController emergencia2NombreController;
  final TextEditingController emergencia2TelefonoController;
  final TextEditingController emergencia2RelacionController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Información inicial
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: <Widget>[
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: Text(
                    'Personas a contactar en caso de emergencia. Al menos un contacto es recomendable.',
                    style: TextStyle(
                      fontSize: AppSizes.fontSmall,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.spacingLarge),

          // SECCIÓN: Contacto de Emergencia 1
          const _SectionHeader(title: 'Contacto de Emergencia 1'),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: emergencia1NombreController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nombre Completo',
              hintText: 'Nombre del contacto de emergencia',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: AppSizes.spacing),

          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: emergencia1TelefonoController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: '+34 600 000 000',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: emergencia1RelacionController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Relación',
                    hintText: 'Esposo/a, Hijo/a, Hermano/a...',
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spacingXl),

          // SECCIÓN: Contacto de Emergencia 2
          const _SectionHeader(title: 'Contacto de Emergencia 2 (Opcional)'),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: emergencia2NombreController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nombre Completo',
              hintText: 'Nombre del contacto de emergencia',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: AppSizes.spacing),

          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: emergencia2TelefonoController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: '+34 600 000 000',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: emergencia2RelacionController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Relación',
                    hintText: 'Esposo/a, Hijo/a, Hermano/a...',
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                ),
              ),
            ],
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
