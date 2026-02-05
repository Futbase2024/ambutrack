import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/tipo_ubicacion.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/trayecto_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/trayecto_card_widget.dart';

/// Widget del Paso 3: Configuración de Trayectos
class Step3Trayectos extends StatefulWidget {
  const Step3Trayectos({
    required this.formKey,
    required this.trayectos,
    required this.centrosHospitalarios,
    required this.centrosDropdownItems,
    required this.loadingCentros,
    required this.pacienteNombreCompleto,
    required this.onTrayectosChanged,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final List<TrayectoData> trayectos;
  final List<CentroHospitalarioEntity> centrosHospitalarios;
  final List<AppSearchableDropdownItem<CentroHospitalarioEntity>> centrosDropdownItems;
  final bool loadingCentros;
  final String? pacienteNombreCompleto;
  final void Function(List<TrayectoData>) onTrayectosChanged;

  @override
  State<Step3Trayectos> createState() => _Step3TrayectosState();
}

class _Step3TrayectosState extends State<Step3Trayectos> {
  void _agregarTrayecto() {
    final List<TrayectoData> newTrayectos = List<TrayectoData>.from(widget.trayectos)..add(TrayectoData());
    widget.onTrayectosChanged(newTrayectos);
  }

  void _eliminarTrayecto(int index) {
    final List<TrayectoData> newTrayectos = List<TrayectoData>.from(widget.trayectos)..removeAt(index);
    widget.onTrayectosChanged(newTrayectos);
  }

  void _updateTrayecto(int index, TrayectoData trayecto) {
    final List<TrayectoData> newTrayectos = List<TrayectoData>.from(widget.trayectos);
    newTrayectos[index] = trayecto;
    widget.onTrayectosChanged(newTrayectos);
  }

  /// Aplica el centro hospitalario seleccionado a todos los trayectos
  void _aplicarCentroATodos(String centroNombre) {
    debugPrint('🔄 _aplicarCentroATodos llamado con centro: $centroNombre');
    debugPrint('🔄 Total de trayectos: ${widget.trayectos.length}');

    final List<TrayectoData> newTrayectos = List<TrayectoData>.from(widget.trayectos);
    int trayectosModificados = 0;

    for (int i = 0; i < newTrayectos.length; i++) {
      final TrayectoData trayecto = newTrayectos[i];
      bool modificado = false;

      // Aplicar centro en origen si el tipo es centroHospitalario
      if (trayecto.tipoOrigen == TipoUbicacion.centroHospitalario) {
        debugPrint('🔄 Trayecto $i: Aplicando centro en ORIGEN');
        newTrayectos[i] = TrayectoData(
          tipoOrigen: trayecto.tipoOrigen,
          tipoDestino: trayecto.tipoDestino,
          origenDomicilio: trayecto.origenDomicilio,
          origenCentro: centroNombre,
          destinoDomicilio: trayecto.destinoDomicilio,
          destinoCentro: trayecto.destinoCentro,
          hora: trayecto.hora,
          horaController: trayecto.horaController,
        );
        modificado = true;
      }

      // Aplicar centro en destino si el tipo es centroHospitalario
      if (trayecto.tipoDestino == TipoUbicacion.centroHospitalario) {
        debugPrint('🔄 Trayecto $i: Aplicando centro en DESTINO');
        newTrayectos[i] = TrayectoData(
          tipoOrigen: newTrayectos[i].tipoOrigen,
          tipoDestino: newTrayectos[i].tipoDestino,
          origenDomicilio: newTrayectos[i].origenDomicilio,
          origenCentro: newTrayectos[i].origenCentro,
          destinoDomicilio: newTrayectos[i].destinoDomicilio,
          destinoCentro: centroNombre,
          hora: newTrayectos[i].hora,
          horaController: newTrayectos[i].horaController,
        );
        modificado = true;
      }

      if (modificado) {
        trayectosModificados++;
      }
    }

    debugPrint('🔄 ✅ Total de trayectos modificados: $trayectosModificados');
    widget.onTrayectosChanged(newTrayectos);
    debugPrint('🔄 ✅ Estado actualizado');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Trayectos del Servicio',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      'Define el origen, destino y horario de cada trayecto',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                onPressed: _agregarTrayecto,
                label: 'Agregar Trayecto',
                icon: Icons.add,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingLarge),

          // Lista de trayectos
          ...List<Widget>.generate(widget.trayectos.length, (int index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacing),
              child: TrayectoCardWidget(
                index: index,
                trayecto: widget.trayectos[index],
                loadingCentros: widget.loadingCentros,
                centrosHospitalarios: widget.centrosHospitalarios,
                centrosDropdownItems: widget.centrosDropdownItems,
                pacienteNombreCompleto: widget.pacienteNombreCompleto,
                canDelete: widget.trayectos.length > 1,
                onDelete: () => _eliminarTrayecto(index),
                onUpdate: (TrayectoData trayecto) => _updateTrayecto(index, trayecto),
                onAplicarCentroATodos: _aplicarCentroATodos,
              ),
            );
          }),

          if (widget.trayectos.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingXl),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  'Agrega al menos un trayecto',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
