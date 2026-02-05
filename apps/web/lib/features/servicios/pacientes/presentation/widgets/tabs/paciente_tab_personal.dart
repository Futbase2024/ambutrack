import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tab 1: Datos Personales del Paciente
class PacienteTabPersonal extends StatelessWidget {
  const PacienteTabPersonal({
    super.key,
    required this.nombreController,
    required this.primerApellidoController,
    required this.segundoApellidoController,
    required this.documentoController,
    required this.seguridadSocialController,
    required this.numHistoriaController,
    required this.profesionController,
    required this.tipoDocumento,
    required this.sexo,
    required this.fechaNacimiento,
    required this.paisOrigen,
    required this.onTipoDocumentoChanged,
    required this.onSexoChanged,
    required this.onFechaNacimientoChanged,
    required this.onPaisOrigenChanged,
  });

  final TextEditingController nombreController;
  final TextEditingController primerApellidoController;
  final TextEditingController segundoApellidoController;
  final TextEditingController documentoController;
  final TextEditingController seguridadSocialController;
  final TextEditingController numHistoriaController;
  final TextEditingController profesionController;
  final String tipoDocumento;
  final String sexo;
  final DateTime? fechaNacimiento;
  final String paisOrigen;
  final ValueChanged<String?> onTipoDocumentoChanged;
  final ValueChanged<String?> onSexoChanged;
  final ValueChanged<DateTime?> onFechaNacimientoChanged;
  final ValueChanged<String?> onPaisOrigenChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Sección: Datos Personales
          const _SectionHeader(title: 'Datos Personales'),
          const SizedBox(height: AppSizes.spacing),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: nombreController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'JUAN',
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                  onChanged: (String value) {
                    final int cursorPos = nombreController.selection.baseOffset;
                    nombreController.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(offset: cursorPos),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                child: TextFormField(
                  controller: primerApellidoController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Primer Apellido *',
                    hintText: 'GARCÍA',
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El primer apellido es obligatorio';
                    }
                    return null;
                  },
                  onChanged: (String value) {
                    final int cursorPos = primerApellidoController.selection.baseOffset;
                    primerApellidoController.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(offset: cursorPos),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          TextFormField(
            controller: segundoApellidoController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Segundo Apellido',
              hintText: 'LÓPEZ',
            ),
            onChanged: (String value) {
              final int cursorPos = segundoApellidoController.selection.baseOffset;
              segundoApellidoController.value = TextEditingValue(
                text: value.toUpperCase(),
                selection: TextSelection.collapsed(offset: cursorPos),
              );
            },
          ),
          const SizedBox(height: AppSizes.spacing),

          // Sección: Documento
          const _SectionHeader(title: 'Documento de Identidad'),
          const SizedBox(height: AppSizes.spacing),
          Row(
            children: <Widget>[
              SizedBox(
                width: 150,
                child: AppDropdown<String>(
                  value: tipoDocumento,
                  label: 'Tipo',
                  items: const <AppDropdownItem<String>>[
                    AppDropdownItem<String>(value: 'DNI', label: 'DNI'),
                    AppDropdownItem<String>(value: 'NIE', label: 'NIE'),
                    AppDropdownItem<String>(value: 'PASAPORTE', label: 'Pasaporte'),
                    AppDropdownItem<String>(value: 'OTROS', label: 'Otros'),
                  ],
                  onChanged: onTipoDocumentoChanged,
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                child: TextFormField(
                  controller: documentoController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Número de Documento',
                    hintText: '12345678A',
                  ),
                  onChanged: (String value) {
                    final int cursorPos = documentoController.selection.baseOffset;
                    documentoController.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(offset: cursorPos),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: seguridadSocialController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Nº Seguridad Social',
                    hintText: '281234567890',
                  ),
                  onChanged: (String value) {
                    final int cursorPos = seguridadSocialController.selection.baseOffset;
                    seguridadSocialController.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(offset: cursorPos),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                child: TextFormField(
                  controller: numHistoriaController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Nº Historia Clínica',
                    hintText: 'HC-12345',
                  ),
                  onChanged: (String value) {
                    final int cursorPos = numHistoriaController.selection.baseOffset;
                    numHistoriaController.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(offset: cursorPos),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),

          // Sección: Demografía
          const _SectionHeader(title: 'Datos Demográficos'),
          const SizedBox(height: AppSizes.spacing),
          Row(
            children: <Widget>[
              SizedBox(
                width: 150,
                child: AppDropdown<String>(
                  value: sexo,
                  label: 'Sexo',
                  items: const <AppDropdownItem<String>>[
                    AppDropdownItem<String>(
                      value: 'HOMBRE',
                      label: 'Hombre',
                      icon: Icons.male,
                      iconColor: AppColors.primary,
                    ),
                    AppDropdownItem<String>(
                      value: 'MUJER',
                      label: 'Mujer',
                      icon: Icons.female,
                      iconColor: AppColors.secondary,
                    ),
                  ],
                  onChanged: onSexoChanged,
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                child: InkWell(
                  onTap: () => _selectFechaNacimiento(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha de Nacimiento',
                      hintText: 'dd/mm/yyyy (01/01/2000 si vacío)',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                    ),
                    child: Text(
                      fechaNacimiento != null
                          ? DateFormat('dd/MM/yyyy').format(fechaNacimiento!)
                          : '',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          Row(
            children: <Widget>[
              Expanded(
                child: AppDropdown<String>(
                  value: paisOrigen,
                  label: 'País de Origen',
                  items: const <AppDropdownItem<String>>[
                    AppDropdownItem<String>(value: 'España', label: 'España'),
                    AppDropdownItem<String>(value: 'Francia', label: 'Francia'),
                    AppDropdownItem<String>(value: 'Portugal', label: 'Portugal'),
                    AppDropdownItem<String>(value: 'Italia', label: 'Italia'),
                    AppDropdownItem<String>(value: 'Marruecos', label: 'Marruecos'),
                    AppDropdownItem<String>(value: 'Otro', label: 'Otro'),
                  ],
                  onChanged: onPaisOrigenChanged,
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                child: TextFormField(
                  controller: profesionController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Profesión',
                    hintText: 'Médico, Ingeniero, etc.',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectFechaNacimiento(BuildContext context) async {
    debugPrint('🗓️ Abriendo DatePicker...');

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaNacimiento ?? DateTime(1950),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    debugPrint('🗓️ DatePicker cerrado. Fecha seleccionada: $picked');

    if (picked != null) {
      debugPrint('✅ Fecha válida, llamando callback...');
      onFechaNacimientoChanged(picked);
    } else {
      debugPrint('❌ No se seleccionó fecha (cancelado o cerrado)');
    }
  }
}

/// Header de sección
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.paddingSmall,
        horizontal: AppSizes.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: const Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 4,
          ),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
