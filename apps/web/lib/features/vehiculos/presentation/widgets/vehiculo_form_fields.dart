import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/forms/app_text_field.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/vehiculo_estado_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Campos del formulario de vehículo organizados por secciones
class VehiculoFormFields extends StatelessWidget {
  const VehiculoFormFields({
    super.key,
    required this.matriculaController,
    required this.tipoController,
    required this.marcaController,
    required this.modeloController,
    required this.anioController,
    required this.capacidadController,
    required this.kmActualController,
    required this.ubicacionController,
    required this.observacionesController,
    required this.estadoSeleccionado,
    required this.onEstadoChanged,
  });

  final TextEditingController matriculaController;
  final TextEditingController tipoController;
  final TextEditingController marcaController;
  final TextEditingController modeloController;
  final TextEditingController anioController;
  final TextEditingController capacidadController;
  final TextEditingController kmActualController;
  final TextEditingController ubicacionController;
  final TextEditingController observacionesController;
  final VehiculoEstado estadoSeleccionado;
  final void Function(VehiculoEstado?) onEstadoChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Sección: Información básica
        const _SectionTitle(title: 'Información Básica'),
        const SizedBox(height: 16),

        Row(
          children: <Widget>[
            Expanded(
              child: AppTextField(
                controller: matriculaController,
                label: 'Matrícula *',
                hint: 'Ej: 1234-ABC',
                icon: Icons.badge,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'La matrícula es obligatoria';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: tipoController,
                label: 'Tipo de Vehículo *',
                hint: 'Ej: Ambulancia Básica',
                icon: Icons.category,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'El tipo es obligatorio';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: <Widget>[
            Expanded(
              child: AppTextField(
                controller: marcaController,
                label: 'Marca *',
                hint: 'Ej: Ford',
                icon: Icons.business,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'La marca es obligatoria';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: modeloController,
                label: 'Modelo *',
                hint: 'Ej: Transit',
                icon: Icons.directions_car,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'El modelo es obligatorio';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: <Widget>[
            Expanded(
              child: AppTextField(
                controller: anioController,
                label: 'Año *',
                hint: 'Ej: 2023',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'El año es obligatorio';
                  }
                  final int? anio = int.tryParse(value);
                  if (anio == null || anio < 1900 || anio > DateTime.now().year + 1) {
                    return 'Año inválido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: capacidadController,
                label: 'Capacidad (personas)',
                hint: 'Ej: 4',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Estado
        const _SectionTitle(title: 'Estado del Vehículo'),
        const SizedBox(height: 16),

        VehiculoEstadoSelector(
          estadoSeleccionado: estadoSeleccionado,
          onChanged: onEstadoChanged,
        ),

        const SizedBox(height: 24),

        // Sección: Detalles operativos
        const _SectionTitle(title: 'Detalles Operativos'),
        const SizedBox(height: 16),

        Row(
          children: <Widget>[
            Expanded(
              child: AppTextField(
                controller: kmActualController,
                label: 'Kilómetros Actuales',
                hint: 'Ej: 50000',
                icon: Icons.speed,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: ubicacionController,
                label: 'Ubicación Actual',
                hint: 'Ej: Base Central',
                icon: Icons.location_on,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        AppTextField(
          controller: observacionesController,
          label: 'Observaciones',
          hint: 'Información adicional del vehículo',
          icon: Icons.note,
          maxLines: 3,
        ),
      ],
    );
  }
}

/// Título de sección del formulario
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
