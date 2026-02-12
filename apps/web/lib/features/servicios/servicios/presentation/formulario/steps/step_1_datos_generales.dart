import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Paso 1: Datos Generales del Servicio
class Step1DatosGenerales extends StatelessWidget {
  const Step1DatosGenerales({
    super.key,
    required this.formKey,
    required this.pacienteSeleccionado,
    required this.motivoTrasladoSeleccionado,
    required this.fechaInicioTratamiento,
    required this.fechaFinTratamiento,
    required this.movilidad,
    required this.acompanantes,
    required this.tipoAmbulancia,
    required this.requiereOxigeno,
    required this.requiereMedico,
    required this.requiereDue,
    required this.requiereAyudante,
    required this.observacionesGenerales,
    required this.observacionesMedicas,
    required this.motivosTraslado,
    required this.tiposVehiculo,
    required this.loadingMotivosTraslado,
    required this.loadingTiposVehiculo,
    required this.onPacienteChanged,
    required this.onMotivoTrasladoChanged,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onMovilidadChanged,
    required this.onAcompanantesChanged,
    required this.onTipoAmbulanciaChanged,
    required this.onRequiereOxigenoChanged,
    required this.onRequiereMedicoChanged,
    required this.onRequiereDueChanged,
    required this.onRequiereAyudanteChanged,
    required this.onObservacionesGeneralesChanged,
    required this.onObservacionesMedicasChanged,
  });

  final GlobalKey<FormState> formKey;
  final PacienteEntity? pacienteSeleccionado;
  final MotivoTrasladoEntity? motivoTrasladoSeleccionado;
  final DateTime? fechaInicioTratamiento;
  final DateTime? fechaFinTratamiento;
  final String movilidad;
  final int acompanantes;
  final String? tipoAmbulancia;
  final bool requiereOxigeno;
  final bool requiereMedico;
  final bool requiereDue;
  final bool requiereAyudante;
  final String? observacionesGenerales;
  final String observacionesMedicas;
  final List<MotivoTrasladoEntity> motivosTraslado;
  final List<TipoVehiculoEntity> tiposVehiculo;
  final bool loadingMotivosTraslado;
  final bool loadingTiposVehiculo;
  final ValueChanged<PacienteEntity?> onPacienteChanged;
  final ValueChanged<MotivoTrasladoEntity?> onMotivoTrasladoChanged;
  final ValueChanged<DateTime?> onFechaInicioChanged;
  final ValueChanged<DateTime?> onFechaFinChanged;
  final ValueChanged<String> onMovilidadChanged;
  final ValueChanged<int> onAcompanantesChanged;
  final ValueChanged<String?> onTipoAmbulanciaChanged;
  final ValueChanged<bool> onRequiereOxigenoChanged;
  final ValueChanged<bool> onRequiereMedicoChanged;
  final ValueChanged<bool> onRequiereDueChanged;
  final ValueChanged<bool> onRequiereAyudanteChanged;
  final ValueChanged<String?> onObservacionesGeneralesChanged;
  final ValueChanged<String?> onObservacionesMedicasChanged;

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
                    _PacienteField(
                      paciente: pacienteSeleccionado,
                      onChanged: onPacienteChanged,
                    ),
                    const SizedBox(height: 12),
                    _TipoServicioField(
                      motivoSeleccionado: motivoTrasladoSeleccionado,
                      motivos: motivosTraslado,
                      loading: loadingMotivosTraslado,
                      onChanged: onMotivoTrasladoChanged,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _FechaField(
                            label: 'Inicio Tratamiento *',
                            fecha: fechaInicioTratamiento,
                            onTap: () => _selectFechaInicio(context),
                            icon: Icons.calendar_today,
                            iconColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FechaFinField(
                            fechaInicio: fechaInicioTratamiento,
                            fechaFin: fechaFinTratamiento,
                            onTap: () => _selectFechaFin(context),
                            onClear: () => onFechaFinChanged(null),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Columna derecha: Detalles médicos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Detalles Médicos',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MovilidadField(
                      value: movilidad,
                      onChanged: onMovilidadChanged,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: _AcompanantesField(
                            value: acompanantes,
                            onChanged: onAcompanantesChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: _TipoAmbulanciaField(
                            value: tipoAmbulancia,
                            tipos: tiposVehiculo,
                            loading: loadingTiposVehiculo,
                            onChanged: onTipoAmbulanciaChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _CheckboxField(
                            label: 'Oxígeno',
                            value: requiereOxigeno,
                            onChanged: (bool? value) => onRequiereOxigenoChanged(value ?? false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CheckboxField(
                            label: 'Médico',
                            value: requiereMedico,
                            onChanged: (bool? value) => onRequiereMedicoChanged(value ?? false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _CheckboxField(
                            label: 'DUE (Enfermero)',
                            value: requiereDue,
                            onChanged: (bool? value) => onRequiereDueChanged(value ?? false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CheckboxField(
                            label: 'Ayudante',
                            value: requiereAyudante,
                            onChanged: (bool? value) => onRequiereAyudanteChanged(value ?? false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Observaciones Generales
          _ObservacionesField(
            label: 'Observaciones Generales',
            hint: 'Describe detalles importantes del servicio...',
            value: observacionesGenerales,
            onChanged: onObservacionesGeneralesChanged,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Observaciones Médicas
          _ObservacionesField(
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

  Future<void> _selectFechaInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaInicioTratamiento ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onFechaInicioChanged(picked);
      // Si fin es anterior a inicio, limpiar
      if (fechaFinTratamiento != null && fechaFinTratamiento!.isBefore(picked)) {
        onFechaFinChanged(null);
      }
    }
  }

  Future<void> _selectFechaFin(BuildContext context) async {
    if (fechaInicioTratamiento == null) {
      unawaited(
        showResultDialog(
          context: context,
          title: 'Fecha de Inicio Requerida',
          message: 'Primero debes seleccionar la fecha de inicio del tratamiento.',
          type: ResultType.warning,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaFinTratamiento ?? fechaInicioTratamiento!.add(const Duration(days: 30)),
      firstDate: fechaInicioTratamiento!,
      lastDate: fechaInicioTratamiento!.add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.secondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onFechaFinChanged(picked);
    }
  }
}

// ============================================================================
// WIDGETS PRIVADOS
// ============================================================================

class _PacienteField extends StatelessWidget {
  const _PacienteField({
    required this.paciente,
    required this.onChanged,
  });

  final PacienteEntity? paciente;
  final ValueChanged<PacienteEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Paciente *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.person, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Text(
                  paciente?.nombreCompleto ?? 'Selecciona un paciente',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: paciente != null
                        ? AppColors.textPrimaryLight
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              if (paciente == null)
                const Icon(Icons.arrow_drop_down, color: AppColors.textSecondaryLight),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipoServicioField extends StatelessWidget {
  const _TipoServicioField({
    required this.motivoSeleccionado,
    required this.motivos,
    required this.loading,
    required this.onChanged,
  });

  final MotivoTrasladoEntity? motivoSeleccionado;
  final List<MotivoTrasladoEntity> motivos;
  final bool loading;
  final ValueChanged<MotivoTrasladoEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tipo de Servicio *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        if (loading)
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: const Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: AppSizes.spacingSmall),
                Text('Cargando tipos de servicio...'),
              ],
            ),
          )
        else
          AppSearchableDropdown<MotivoTrasladoEntity>(
            value: motivoSeleccionado,
            items: motivos
                .map(
                  (MotivoTrasladoEntity motivo) => AppSearchableDropdownItem<MotivoTrasladoEntity>(
                    value: motivo,
                    label: motivo.nombre,
                    icon: Icons.medical_services,
                    iconColor: AppColors.secondary,
                  ),
                )
                .toList(),
            onChanged: onChanged,
            hint: motivos.isEmpty ? 'No hay tipos de servicio disponibles' : 'Buscar tipo de servicio...',
            prefixIcon: Icons.medical_services,
            enabled: motivos.isNotEmpty,
          ),
      ],
    );
  }
}

class _FechaField extends StatelessWidget {
  const _FechaField({
    required this.label,
    required this.fecha,
    required this.onTap,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final DateTime? fecha;
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: Text(
                    fecha != null ? DateFormat('dd/MM/yyyy').format(fecha!) : 'Selecciona fecha',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: fecha != null ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FechaFinField extends StatelessWidget {
  const _FechaFinField({
    required this.fechaInicio,
    required this.fechaFin,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Fin Tratamiento',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Text(
              '(opcional)',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.event, size: 18, color: AppColors.secondary),
                const SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: Text(
                    fechaFin != null
                        ? DateFormat('dd/MM/yyyy').format(fechaFin!)
                        : 'Sin fecha de fin (servicio indefinido)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: fechaFin != null ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                if (fechaFin != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    color: AppColors.error,
                    onPressed: onClear,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Quitar fecha de fin',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MovilidadField extends StatelessWidget {
  const _MovilidadField({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Movilidad *',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimaryLight,
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'sentado',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.chair, size: 16, color: AppColors.info),
                      SizedBox(width: 8),
                      Text('Sentado'),
                    ],
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'silla_ruedas',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.accessible, size: 16, color: AppColors.warning),
                      SizedBox(width: 8),
                      Text('Silla de Ruedas'),
                    ],
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'camilla',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.airline_seat_flat, size: 16, color: AppColors.emergency),
                      SizedBox(width: 8),
                      Text('Camilla'),
                    ],
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'camilla_palas',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.airline_seat_flat_angled, size: 16, color: AppColors.highPriority),
                      SizedBox(width: 8),
                      Text('Camilla de Palas'),
                    ],
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'silla_electrica',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.electric_bolt, size: 16, color: AppColors.secondary),
                      SizedBox(width: 8),
                      Text('Silla Eléctrica'),
                    ],
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'otros',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.more_horiz, size: 16, color: AppColors.textSecondaryLight),
                      SizedBox(width: 8),
                      Text('Otros'),
                    ],
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AcompanantesField extends StatelessWidget {
  const _AcompanantesField({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Acompañantes',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                color: value > 0 ? AppColors.error : AppColors.gray400,
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                padding: const EdgeInsets.all(8),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$value',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                color: AppColors.success,
                onPressed: () => onChanged(value + 1),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipoAmbulanciaField extends StatelessWidget {
  const _TipoAmbulanciaField({
    required this.value,
    required this.tipos,
    required this.loading,
    required this.onChanged,
  });

  final String? value;
  final List<TipoVehiculoEntity> tipos;
  final bool loading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tipo de Ambulancia *',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        if (loading)
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: const Row(
              children: <Widget>[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Cargando...', style: TextStyle(fontSize: 13)),
              ],
            ),
          )
        else
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimaryLight,
                ),
                items: tipos
                    .map(
                      (TipoVehiculoEntity tipo) => DropdownMenuItem<String>(
                        value: tipo.id,
                        child: Text(tipo.nombre),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
      ],
    );
  }
}

class _CheckboxField extends StatelessWidget {
  const _CheckboxField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: value ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: value ? AppColors.primary : AppColors.gray300,
          width: value ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                color: value ? AppColors.primary : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ObservacionesField extends StatelessWidget {
  const _ObservacionesField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final String? value;
  final ValueChanged<String?> onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        TextFormField(
          initialValue: value,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
