import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/tipo_ubicacion.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/trayecto_data.dart';
import 'package:flutter/material.dart';

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
              const Expanded(child: GestionFormSection(title: 'Trayectos del servicio', first: true)),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton.icon(
                  onPressed: _agregarTrayecto,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar trayecto'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.gray300),
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Define el origen, destino y horario de cada trayecto',
              style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
            ),
          ),

          // Lista de trayectos
          ...List<Widget>.generate(widget.trayectos.length, (int index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: const Center(
                child: Text(
                  'Agrega al menos un trayecto',
                  style: TextStyle(fontSize: 13, color: AppColors.gray600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
