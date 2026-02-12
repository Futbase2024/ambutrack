import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_sizes.dart';
import '../../models/modalidad_servicio.dart';
import '../../models/trayecto_data.dart';
import 'widgets/revision_datos_generales.dart';
import 'widgets/revision_modalidad.dart';
import 'widgets/revision_trayectos.dart';

/// Step 4: Revisión Final
///
/// Muestra un resumen completo de todos los datos capturados
/// en los steps anteriores antes de crear/editar el servicio.
///
/// División en dos tarjetas simétricas:
/// - Tarjeta 1: Paciente + Servicio
/// - Tarjeta 2: Modalidad + Trayectos
class Step4Revision extends StatelessWidget {
  const Step4Revision({
    required this.paciente,
    required this.motivoTraslado,
    required this.fechaInicio,
    this.fechaFin,
    this.observaciones,
    required this.modalidad,
    this.diasSemana = const <int>[],
    this.intervaloSemanas,
    this.diasMes = const <int>[],
    required this.trayectos,
    this.localidades = const <LocalidadEntity>[],
    this.isEditMode = false,
    super.key,
  });

  // Datos generales (Step 1)
  final PacienteEntity? paciente;
  final MotivoTrasladoEntity? motivoTraslado;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String? observaciones;

  // Modalidad (Step 2)
  final ModalidadServicio modalidad;
  final List<int> diasSemana;
  final int? intervaloSemanas;
  final List<int> diasMes;

  // Trayectos (Step 3)
  final List<TrayectoData> trayectos;

  // Datos maestros
  final List<LocalidadEntity> localidades;

  // Modo edición
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildHeader(),
        const SizedBox(height: 12),
        _buildContenido(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.primary.withValues(alpha: 0.1),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.fact_check, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEditMode
                  ? 'Revisión Final - Verifica los datos antes de editar'
                  : 'Revisión Final - Verifica los datos antes de crear',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenido() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Tarjeta 1: Paciente + Servicio
          Expanded(
            child: _buildTarjeta(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RevisionDatosGenerales(
                    paciente: paciente,
                    motivoTraslado: motivoTraslado,
                    fechaInicio: fechaInicio,
                    fechaFin: fechaFin,
                    observaciones: observaciones,
                    localidades: localidades,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Tarjeta 2: Modalidad + Trayectos
          Expanded(
            child: _buildTarjeta(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RevisionModalidad(
                    modalidad: modalidad,
                    diasSemana: diasSemana,
                    intervaloSemanas: intervaloSemanas,
                    diasMes: diasMes,
                  ),
                  const SizedBox(height: 24),
                  RevisionTrayectos(trayectos: trayectos),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjeta({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray300, width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gray400.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
