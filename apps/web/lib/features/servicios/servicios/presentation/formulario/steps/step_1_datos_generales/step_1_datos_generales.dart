import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/steps/step_1_datos_generales/widgets/detalles_medicos_widget.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/steps/step_1_datos_generales/widgets/fechas_tratamiento_widget.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/steps/step_1_datos_generales/widgets/observaciones_field_widget.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/steps/step_1_datos_generales/widgets/paciente_selector_widget.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/steps/step_1_datos_generales/widgets/tipo_servicio_config_widget.dart';
import 'package:flutter/material.dart';

/// Paso 1: Datos Generales del Servicio
class Step1DatosGenerales extends StatelessWidget {
  const Step1DatosGenerales({
    super.key,
    required this.formKey,
    required this.pacienteSeleccionado,
    required this.pacientes,
    required this.loadingPacientes,
    required this.facultativoSeleccionado,
    required this.facultativos,
    required this.loadingFacultativos,
    required this.motivoTrasladoSeleccionado,
    required this.motivosTraslado,
    required this.loadingMotivosTraslado,
    required this.fechaInicioTratamiento,
    required this.fechaFinTratamiento,
    required this.horaEnCentro,
    required this.centroHospitalario,
    required this.centrosHospitalarios,
    required this.movilidad,
    required this.acompanantes,
    required this.tipoAmbulancia,
    required this.tiposVehiculo,
    required this.loadingTiposVehiculo,
    required this.requiereOxigeno,
    required this.requiereMedico,
    required this.requiereDue,
    required this.requiereAyudante,
    required this.observacionesGenerales,
    required this.observacionesMedicas,
    required this.onPacienteChanged,
    required this.onFacultativoChanged,
    required this.onMotivoTrasladoChanged,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onHoraEnCentroChanged,
    required this.onCentroHospitalarioChanged,
    required this.onMovilidadChanged,
    required this.onAcompanantesChanged,
    required this.onTipoAmbulanciaChanged,
    required this.onRequiereOxigenoChanged,
    required this.onRequiereMedicoChanged,
    required this.onRequiereDueChanged,
    required this.onRequiereAyudanteChanged,
    required this.onObservacionesGeneralesChanged,
    required this.onObservacionesMedicasChanged,
    this.pacienteReadOnly = false,
  });

  final GlobalKey<FormState> formKey;
  final PacienteEntity? pacienteSeleccionado;
  final List<PacienteEntity> pacientes;
  final bool loadingPacientes;
  final FacultativoEntity? facultativoSeleccionado;
  final List<FacultativoEntity> facultativos;
  final bool loadingFacultativos;
  final MotivoTrasladoEntity? motivoTrasladoSeleccionado;
  final List<MotivoTrasladoEntity> motivosTraslado;
  final bool loadingMotivosTraslado;
  final DateTime? fechaInicioTratamiento;
  final DateTime? fechaFinTratamiento;
  final TimeOfDay? horaEnCentro;
  final CentroHospitalarioEntity? centroHospitalario;
  final List<CentroHospitalarioEntity> centrosHospitalarios;
  final String movilidad;
  final int acompanantes;
  final String? tipoAmbulancia;
  final List<TipoVehiculoEntity> tiposVehiculo;
  final bool loadingTiposVehiculo;
  final bool requiereOxigeno;
  final bool requiereMedico;
  final bool requiereDue;
  final bool requiereAyudante;
  final String? observacionesGenerales;
  final String observacionesMedicas;
  final ValueChanged<PacienteEntity?> onPacienteChanged;
  final ValueChanged<FacultativoEntity?> onFacultativoChanged;
  final ValueChanged<MotivoTrasladoEntity?> onMotivoTrasladoChanged;
  final ValueChanged<DateTime?> onFechaInicioChanged;
  final ValueChanged<DateTime?> onFechaFinChanged;
  final ValueChanged<TimeOfDay?> onHoraEnCentroChanged;
  final ValueChanged<CentroHospitalarioEntity?> onCentroHospitalarioChanged;
  final ValueChanged<String> onMovilidadChanged;
  final ValueChanged<int> onAcompanantesChanged;
  final ValueChanged<String?> onTipoAmbulanciaChanged;
  final ValueChanged<bool> onRequiereOxigenoChanged;
  final ValueChanged<bool> onRequiereMedicoChanged;
  final ValueChanged<bool> onRequiereDueChanged;
  final ValueChanged<bool> onRequiereAyudanteChanged;
  final ValueChanged<String?> onObservacionesGeneralesChanged;
  final ValueChanged<String?> onObservacionesMedicasChanged;
  final bool pacienteReadOnly;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Layout en 2 columnas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Columna izquierda: Datos del paciente y servicio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    PacienteSelectorWidget(
                      paciente: pacienteSeleccionado,
                      pacientes: pacientes,
                      loading: loadingPacientes,
                      onChanged: onPacienteChanged,
                      readOnly: pacienteReadOnly,
                    ),
                    const SizedBox(height: 12),
                    TipoServicioConfigWidget(
                      motivoSeleccionado: motivoTrasladoSeleccionado,
                      motivos: motivosTraslado,
                      loading: loadingMotivosTraslado,
                      onChanged: onMotivoTrasladoChanged,
                    ),
                    const SizedBox(height: 12),
                    FechasTratamientoWidget(
                      fechaInicio: fechaInicioTratamiento,
                      fechaFin: fechaFinTratamiento,
                      horaEnCentro: horaEnCentro,
                      centroHospitalario: centroHospitalario,
                      centrosHospitalarios: centrosHospitalarios,
                      onFechaInicioChanged: onFechaInicioChanged,
                      onFechaFinChanged: onFechaFinChanged,
                      onHoraEnCentroChanged: onHoraEnCentroChanged,
                      onCentroHospitalarioChanged: onCentroHospitalarioChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Columna derecha: Detalles médicos
              Expanded(
                child: DetallesMedicosWidget(
                  facultativoSeleccionado: facultativoSeleccionado,
                  facultativos: facultativos,
                  loadingFacultativos: loadingFacultativos,
                  movilidad: movilidad,
                  acompanantes: acompanantes,
                  tipoAmbulancia: tipoAmbulancia,
                  tiposVehiculo: tiposVehiculo,
                  loadingTiposVehiculo: loadingTiposVehiculo,
                  requiereOxigeno: requiereOxigeno,
                  requiereMedico: requiereMedico,
                  requiereDue: requiereDue,
                  requiereAyudante: requiereAyudante,
                  onFacultativoChanged: onFacultativoChanged,
                  onMovilidadChanged: onMovilidadChanged,
                  onAcompanantesChanged: onAcompanantesChanged,
                  onTipoAmbulanciaChanged: onTipoAmbulanciaChanged,
                  onRequiereOxigenoChanged: onRequiereOxigenoChanged,
                  onRequiereMedicoChanged: onRequiereMedicoChanged,
                  onRequiereDueChanged: onRequiereDueChanged,
                  onRequiereAyudanteChanged: onRequiereAyudanteChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Observaciones Generales
          ObservacionesFieldWidget(
            label: 'Observaciones Generales',
            hint: 'Describe detalles importantes del servicio...',
            value: observacionesGenerales,
            onChanged: onObservacionesGeneralesChanged,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Observaciones Médicas
          ObservacionesFieldWidget(
            label: 'Observaciones Médicas',
            hint: 'Información médica relevante (alergias, precauciones, etc.)...',
            value: observacionesMedicas,
            onChanged: onObservacionesMedicasChanged,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
