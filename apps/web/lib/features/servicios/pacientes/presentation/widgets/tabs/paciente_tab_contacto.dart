import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab 2: Contacto y Dirección
class PacienteTabContacto extends StatelessWidget {
  const PacienteTabContacto({
    super.key,
    required this.telefonoMovilController,
    required this.telefonoFijoController,
    required this.emailController,
    required this.provincias,
    required this.localidadesFiltradas,
    required this.provinciaId,
    required this.localidadId,
    required this.domicilioDireccionController,
    required this.recogidaDireccionController,
    required this.onProvinciaChanged,
    required this.onLocalidadChanged,
    required this.onCopiarDireccion,
  });

  final TextEditingController telefonoMovilController;
  final TextEditingController telefonoFijoController;
  final TextEditingController emailController;
  final List<ProvinciaEntity> provincias;
  final List<LocalidadEntity> localidadesFiltradas;
  final String? provinciaId;
  final String? localidadId;
  final TextEditingController domicilioDireccionController;
  final TextEditingController recogidaDireccionController;
  final void Function(String?) onProvinciaChanged;
  final void Function(String?) onLocalidadChanged;
  final VoidCallback onCopiarDireccion;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // SECCIÓN: Contacto
          const _SectionHeader(title: 'Contacto'),
          const SizedBox(height: AppSizes.spacing),

          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: telefonoMovilController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono Móvil',
                    hintText: '+34 600 000 000',
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                child: TextFormField(
                  controller: telefonoFijoController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono Fijo',
                    hintText: '+34 900 000 000',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: emailController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'ejemplo@correo.com',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (String? value) {
              if (value != null && value.isNotEmpty) {
                final bool emailValid = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                ).hasMatch(value);
                if (!emailValid) {
                  return 'Email no válido';
                }
              }
              return null;
            },
          ),

          const SizedBox(height: AppSizes.spacingLarge),

          // SECCIÓN: Domicilio del Paciente
          const _SectionHeader(title: 'Domicilio del Paciente'),
          const SizedBox(height: AppSizes.spacing),

          // Provincia y Localidad
          Row(
            children: <Widget>[
              Expanded(
                child: AppSearchableDropdown<ProvinciaEntity>(
                  value: provincias.where((ProvinciaEntity p) => p.id == provinciaId).firstOrNull,
                  label: 'Provincia *',
                  hint: 'Buscar provincia...',
                  searchHint: 'Escribe para buscar...',
                  prefixIcon: Icons.map,
                  items: provincias
                      .map(
                        (ProvinciaEntity p) => AppSearchableDropdownItem<ProvinciaEntity>(
                          value: p,
                          label: p.nombre,
                          icon: Icons.location_city,
                          iconColor: AppColors.primary,
                        ),
                      )
                      .toList(),
                  onChanged: (ProvinciaEntity? value) {
                    onProvinciaChanged(value?.id);
                  },
                  displayStringForOption: (ProvinciaEntity p) => p.nombre,
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                child: AppSearchableDropdown<LocalidadEntity>(
                  value: localidadesFiltradas.where((LocalidadEntity l) => l.id == localidadId).firstOrNull,
                  label: 'Localidad *',
                  hint: provinciaId == null ? 'Selecciona provincia primero' : 'Buscar localidad...',
                  searchHint: 'Escribe para buscar...',
                  prefixIcon: Icons.location_on,
                  enabled: provinciaId != null,
                  items: localidadesFiltradas
                      .map(
                        (LocalidadEntity l) => AppSearchableDropdownItem<LocalidadEntity>(
                          value: l,
                          label: l.nombre,
                          icon: Icons.place,
                          iconColor: AppColors.secondary,
                        ),
                      )
                      .toList(),
                  onChanged: (LocalidadEntity? value) {
                    onLocalidadChanged(value?.id);
                  },
                  displayStringForOption: (LocalidadEntity l) => l.nombre,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: domicilioDireccionController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.characters,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Dirección *',
              hintText: 'CALLE, NÚMERO, PISO, PUERTA, CIUDAD, CÓDIGO POSTAL',
              prefixIcon: Icon(Icons.home),
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'La dirección es obligatoria';
              }
              return null;
            },
            onChanged: (String value) {
              final int cursorPos = domicilioDireccionController.selection.baseOffset;
              domicilioDireccionController.value = TextEditingValue(
                text: value.toUpperCase(),
                selection: TextSelection.collapsed(offset: cursorPos),
              );
            },
          ),

          const SizedBox(height: AppSizes.spacingLarge),

          // SECCIÓN: Dirección de Recogida
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const _SectionHeader(title: 'Dirección de Recogida'),
              TextButton.icon(
                onPressed: onCopiarDireccion,
                icon: const Icon(Icons.content_copy, size: 18),
                label: const Text('Copiar de domicilio'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),

          TextFormField(
            controller: recogidaDireccionController,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.characters,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Dirección de Recogida',
              hintText: 'CALLE, NÚMERO, PISO, PUERTA, INSTRUCCIONES ESPECIALES',
              prefixIcon: Icon(Icons.location_on),
            ),
            onChanged: (String value) {
              final int cursorPos = recogidaDireccionController.selection.baseOffset;
              recogidaDireccionController.value = TextEditingValue(
                text: value.toUpperCase(),
                selection: TextSelection.collapsed(offset: cursorPos),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Widget de encabezado de sección
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: AppSizes.fontMedium,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
    );
  }
}
