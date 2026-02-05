import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/servicios/domain/entities/configuracion_modalidad.dart';
import 'package:ambutrack_web/features/servicios/utils/recurrence_utils.dart';
import 'package:ambutrack_web/features/servicios/utils/time_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Grilla de horarios en modo EXPANDIDO (con fecha de fin definida)
/// Muestra todas las fechas específicas generadas por la recurrencia
class ScheduleGridExpandido extends StatefulWidget {
  const ScheduleGridExpandido({
    required this.configuracion,
    required this.diasProgramados,
    required this.onDiasProgramadosChanged,
    required this.tiempoEsperaCita,
    required this.tieneVuelta,
    super.key,
  });

  final ConfiguracionModalidad configuracion;
  final List<DiaProgramado> diasProgramados;
  final void Function(List<DiaProgramado>) onDiasProgramadosChanged;
  final int tiempoEsperaCita;
  final bool tieneVuelta;

  @override
  State<ScheduleGridExpandido> createState() => _ScheduleGridExpandidoState();
}

class _ScheduleGridExpandidoState extends State<ScheduleGridExpandido> {
  @override
  void initState() {
    super.initState();
    // Si no hay días programados, generar automáticamente según recurrencia
    if (widget.diasProgramados.isEmpty) {
      _generarDiasIniciales();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Info de total de días
        _buildStatsBar(),
        const SizedBox(height: AppSizes.spacing),

        // Tabla de horarios
        _buildTable(),
        const SizedBox(height: AppSizes.spacing),

        // Acciones masivas
        _buildBulkActions(),
      ],
    );
  }

  Widget _buildStatsBar() {
    final int totalDias = widget.diasProgramados.length;
    final int diasHabilitados = widget.diasProgramados
        .where((DiaProgramado d) => d.habilitado)
        .length;
    final int diasDeshabilitados = totalDias - diasHabilitados;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          _buildStatChip(
            icon: Icons.calendar_month,
            label: 'Total',
            value: totalDias.toString(),
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.spacing),
          _buildStatChip(
            icon: Icons.check_circle_outline,
            label: 'Habilitados',
            value: diasHabilitados.toString(),
            color: AppColors.success,
          ),
          const SizedBox(width: AppSizes.spacing),
          _buildStatChip(
            icon: Icons.cancel_outlined,
            label: 'Deshabilitados',
            value: diasDeshabilitados.toString(),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSmall,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSmall,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        children: <Widget>[
          // Header
          _buildTableHeader(),

          // Rows (scrollable si hay muchos)
          if (widget.diasProgramados.isEmpty)
            _buildEmptyState()
          else
            SizedBox(
              height: 400, // Altura máxima para scroll
              child: ListView.builder(
                itemCount: widget.diasProgramados.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildTableRow(
                    index: index,
                    dia: widget.diasProgramados[index],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: const BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusSmall),
          topRight: Radius.circular(AppSizes.radiusSmall),
        ),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 40), // Checkbox
          Expanded(
            flex: 2,
            child: _buildHeaderCell('Fecha'),
          ),
          Expanded(
            child: _buildHeaderCell('Día'),
          ),
          Expanded(
            child: _buildHeaderCell('Recogida'),
          ),
          Expanded(
            child: _buildHeaderCell('Cita'),
          ),
          if (widget.tieneVuelta)
            Expanded(
              child: _buildHeaderCell('Vuelta'),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: AppSizes.fontSmall,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildTableRow({
    required int index,
    required DiaProgramado dia,
  }) {
    final bool isDeshabilitado = !dia.habilitado;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: isDeshabilitado ? AppColors.gray100.withValues(alpha: 0.5) : null,
        border: const Border(
          top: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Checkbox habilitado/deshabilitado
          Checkbox(
            value: dia.habilitado,
            onChanged: (bool? value) {
              _toggleHabilitado(index, value ?? true);
            },
            activeColor: AppColors.success,
          ),

          // Fecha
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd/MM/yyyy', 'es').format(dia.fecha),
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w500,
                color: isDeshabilitado
                    ? AppColors.textSecondaryLight
                    : AppColors.textPrimaryLight,
                decoration: isDeshabilitado ? TextDecoration.lineThrough : null,
              ),
            ),
          ),

          // Día de la semana
          Expanded(
            child: Text(
              dia.nombreDiaSemana,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),

          // Hora recogida (auto-calculada, no editable)
          Expanded(
            child: _buildTimeDisplay(dia.horaRecogida, isDeshabilitado: isDeshabilitado),
          ),

          // Hora cita (editable si habilitado)
          Expanded(
            child: isDeshabilitado
                ? _buildTimeDisplay(dia.horaCita, isDeshabilitado: true)
                : _buildTimeField(
                    value: dia.horaCita,
                    onChanged: (String newTime) {
                      _updateHoraCita(index, newTime);
                    },
                  ),
          ),

          // Hora vuelta (auto-calculada, no editable)
          if (widget.tieneVuelta)
            Expanded(
              child: _buildTimeDisplay(
                dia.horaVuelta ?? '--:--',
                isDeshabilitado: isDeshabilitado,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(String time, {required bool isDeshabilitado}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        time,
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontMedium,
          fontWeight: FontWeight.w500,
          color: isDeshabilitado
              ? AppColors.gray400
              : AppColors.textSecondaryLight,
          decoration: isDeshabilitado ? TextDecoration.lineThrough : null,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimeField({
    required String value,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        hintText: 'HH:mm',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSmall,
          vertical: AppSizes.spacingSmall,
        ),
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
        isDense: true,
      ),
      style: GoogleFonts.inter(
        fontSize: AppSizes.fontMedium,
        color: AppColors.textPrimaryLight,
      ),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.datetime,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[0-9:]')),
        LengthLimitingTextInputFormatter(5),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.event_busy,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'No hay días programados',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMedium,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Verifica la configuración de recurrencia',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActions() {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _habilitarTodos,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Habilitar Todos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              side: const BorderSide(color: AppColors.success),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _deshabilitarTodos,
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Deshabilitar Todos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _aplicarHorarioATodos,
            icon: const Icon(Icons.schedule, size: 18),
            label: const Text('Aplicar Horario a Todos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  void _generarDiasIniciales() {
    final DateTime fechaInicio = widget.configuracion.fechaInicio;
    final DateTime? fechaFin = widget.configuracion.fechaFin;

    if (fechaFin == null) {
      return;
    }

    List<DateTime> fechas = <DateTime>[];

    switch (widget.configuracion.tipoRecurrencia) {
      case TipoRecurrencia.unico:
        fechas = <DateTime>[fechaInicio];
        break;

      case TipoRecurrencia.diario:
        fechas = RecurrenceUtils.generarFechasDiarias(
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
        );
        break;

      case TipoRecurrencia.semanal:
        fechas = RecurrenceUtils.generarFechasSemanales(
          diasSemana: widget.configuracion.diasSemana ?? <int>[],
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
        );
        break;

      case TipoRecurrencia.diasAlternos:
        fechas = RecurrenceUtils.generarFechasDiasAlternos(
          intervaloDias: widget.configuracion.intervaloDias ?? 2,
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
        );
        break;

      case TipoRecurrencia.fechasEspecificas:
        fechas = widget.configuracion.fechasEspecificas ?? <DateTime>[];
        break;

      case TipoRecurrencia.mensual:
        fechas = RecurrenceUtils.generarFechasMensuales(
          diasMes: widget.configuracion.diasMes ?? <int>[],
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
        );
        break;
    }

    final List<DiaProgramado> nuevosDias = fechas.map((DateTime fecha) {
      final Map<String, String?> horarios = TimeCalculator.calcularHorarios(
        horaCita: '09:00', // Hora por defecto
        tiempoEsperaMinutos: widget.tiempoEsperaCita,
        tieneVuelta: widget.tieneVuelta,
      );

      return DiaProgramado(
        fecha: fecha,
        diaSemana: RecurrenceUtils.obtenerDiaSemana(fecha),
        horaRecogida: horarios['hora_recogida']!,
        horaCita: horarios['hora_cita']!,
        horaVuelta: horarios['hora_vuelta'],
      );
    }).toList();

    widget.onDiasProgramadosChanged(nuevosDias);
  }

  void _toggleHabilitado(int index, bool habilitado) {
    final List<DiaProgramado> nuevosDias = List<DiaProgramado>.from(
      widget.diasProgramados,
    );

    final DiaProgramado actual = nuevosDias[index];

    nuevosDias[index] = DiaProgramado(
      fecha: actual.fecha,
      diaSemana: actual.diaSemana,
      horaRecogida: actual.horaRecogida,
      horaCita: actual.horaCita,
      horaVuelta: actual.horaVuelta,
      habilitado: habilitado,
    );

    widget.onDiasProgramadosChanged(nuevosDias);
  }

  void _updateHoraCita(int index, String newHoraCita) {
    // Validar formato HH:mm
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(newHoraCita)) {
      return;
    }

    final List<DiaProgramado> nuevosDias = List<DiaProgramado>.from(
      widget.diasProgramados,
    );

    final DiaProgramado actual = nuevosDias[index];

    // Calcular horarios automáticamente
    final Map<String, String?> horariosCalculados = TimeCalculator.calcularHorarios(
      horaCita: newHoraCita,
      tiempoEsperaMinutos: widget.tiempoEsperaCita,
      tieneVuelta: widget.tieneVuelta,
    );

    nuevosDias[index] = DiaProgramado(
      fecha: actual.fecha,
      diaSemana: actual.diaSemana,
      horaRecogida: horariosCalculados['hora_recogida']!,
      horaCita: horariosCalculados['hora_cita']!,
      horaVuelta: horariosCalculados['hora_vuelta'],
      habilitado: actual.habilitado,
    );

    widget.onDiasProgramadosChanged(nuevosDias);
  }

  void _habilitarTodos() {
    final List<DiaProgramado> nuevosDias = widget.diasProgramados
        .map(
          (DiaProgramado dia) => DiaProgramado(
            fecha: dia.fecha,
            diaSemana: dia.diaSemana,
            horaRecogida: dia.horaRecogida,
            horaCita: dia.horaCita,
            horaVuelta: dia.horaVuelta,
          ),
        )
        .toList();

    widget.onDiasProgramadosChanged(nuevosDias);
  }

  void _deshabilitarTodos() {
    final List<DiaProgramado> nuevosDias = widget.diasProgramados
        .map(
          (DiaProgramado dia) => DiaProgramado(
            fecha: dia.fecha,
            diaSemana: dia.diaSemana,
            horaRecogida: dia.horaRecogida,
            horaCita: dia.horaCita,
            horaVuelta: dia.horaVuelta,
            habilitado: false,
          ),
        )
        .toList();

    widget.onDiasProgramadosChanged(nuevosDias);
  }

  void _aplicarHorarioATodos() {
    if (widget.diasProgramados.isEmpty) {
      return;
    }

    // Usar el horario del primer día habilitado como referencia
    final DiaProgramado referencia = widget.diasProgramados.firstWhere(
      (DiaProgramado d) => d.habilitado,
      orElse: () => widget.diasProgramados.first,
    );

    final List<DiaProgramado> nuevosDias = widget.diasProgramados
        .map(
          (DiaProgramado dia) => DiaProgramado(
            fecha: dia.fecha,
            diaSemana: dia.diaSemana,
            horaRecogida: referencia.horaRecogida,
            horaCita: referencia.horaCita,
            horaVuelta: referencia.horaVuelta,
            habilitado: dia.habilitado,
          ),
        )
        .toList();

    widget.onDiasProgramadosChanged(nuevosDias);
  }
}
