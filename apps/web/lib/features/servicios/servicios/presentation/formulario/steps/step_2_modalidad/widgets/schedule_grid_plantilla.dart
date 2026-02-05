import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/servicios/domain/entities/configuracion_modalidad.dart';
import 'package:ambutrack_web/features/servicios/utils/recurrence_utils.dart';
import 'package:ambutrack_web/features/servicios/utils/time_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Grilla de horarios en modo PLANTILLA (sin fecha de fin)
/// Muestra una plantilla de horarios que se repetirá indefinidamente
class ScheduleGridPlantilla extends StatefulWidget {
  const ScheduleGridPlantilla({
    required this.configuracion,
    required this.plantillaHorarios,
    required this.onPlantillaHorariosChanged,
    required this.tiempoEsperaCita,
    required this.tieneVuelta,
    super.key,
  });

  final ConfiguracionModalidad configuracion;
  final List<PlantillaHorario> plantillaHorarios;
  final void Function(List<PlantillaHorario>) onPlantillaHorariosChanged;
  final int tiempoEsperaCita;
  final bool tieneVuelta;

  @override
  State<ScheduleGridPlantilla> createState() => _ScheduleGridPlantillaState();
}

class _ScheduleGridPlantillaState extends State<ScheduleGridPlantilla> {
  @override
  void initState() {
    super.initState();
    // Si no hay plantillas, generar automáticamente según tipo de recurrencia
    if (widget.plantillaHorarios.isEmpty) {
      _generarPlantillaInicial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Tabla de horarios
        _buildTable(),
        const SizedBox(height: AppSizes.spacing),

        // Botón agregar horario
        _buildAddButton(),
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

          // Rows
          if (widget.plantillaHorarios.isEmpty)
            _buildEmptyState()
          else
            ...widget.plantillaHorarios.asMap().entries.map(
                  (MapEntry<int, PlantillaHorario> entry) => _buildTableRow(
                    index: entry.key,
                    plantilla: entry.value,
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
          Expanded(
            flex: 2,
            child: _buildHeaderCell('Día/Etiqueta'),
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
          const SizedBox(width: 40), // Espacio para botón eliminar
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
    required PlantillaHorario plantilla,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Etiqueta
          Expanded(
            flex: 2,
            child: Text(
              plantilla.etiqueta,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),

          // Hora recogida (auto-calculada, no editable)
          Expanded(
            child: _buildTimeDisplay(plantilla.horaRecogida),
          ),

          // Hora cita (editable)
          Expanded(
            child: _buildTimeField(
              value: plantilla.horaCita,
              onChanged: (String newTime) {
                _updateHoraCita(index, newTime);
              },
            ),
          ),

          // Hora vuelta (auto-calculada, no editable)
          if (widget.tieneVuelta)
            Expanded(
              child: _buildTimeDisplay(plantilla.horaVuelta ?? '--:--'),
            ),

          // Botón eliminar
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.error,
            onPressed: () => _removeRow(index),
            tooltip: 'Eliminar horario',
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(String time) {
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
          color: AppColors.textSecondaryLight,
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
            Icons.schedule,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'No hay horarios programados',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMedium,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Haz clic en "Agregar Horario" para comenzar',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addNewRow,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Agregar Horario'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.paddingMedium,
          ),
        ),
      ),
    );
  }

  void _generarPlantillaInicial() {
    final List<PlantillaHorario> nuevasPlantillas = <PlantillaHorario>[];

    switch (widget.configuracion.tipoRecurrencia) {
      case TipoRecurrencia.unico:
        // Para único, una sola entrada sin día específico
        nuevasPlantillas.add(
          PlantillaHorario(
            etiqueta: 'Día único',
            horaRecogida: '08:30',
            horaCita: '09:00',
            horaVuelta: widget.tieneVuelta ? '10:00' : null,
          ),
        );
        break;

      case TipoRecurrencia.diario:
        // Para diario, una entrada "Todos los días"
        nuevasPlantillas.add(
          PlantillaHorario(
            etiqueta: 'Todos los días',
            horaRecogida: '08:30',
            horaCita: '09:00',
            horaVuelta: widget.tieneVuelta ? '10:00' : null,
          ),
        );
        break;

      case TipoRecurrencia.semanal:
        // Para semanal, una entrada por cada día seleccionado
        final List<int> diasSemana = widget.configuracion.diasSemana ?? <int>[];
        for (final int dia in diasSemana) {
          nuevasPlantillas.add(
            PlantillaHorario(
              diaSemana: dia,
              etiqueta: RecurrenceUtils.obtenerNombreDiaSemana(dia),
              horaRecogida: '08:30',
              horaCita: '09:00',
              horaVuelta: widget.tieneVuelta ? '10:00' : null,
            ),
          );
        }
        break;

      case TipoRecurrencia.diasAlternos:
        // Para días alternos, una entrada genérica
        final int intervalo = widget.configuracion.intervaloDias ?? 2;
        nuevasPlantillas.add(
          PlantillaHorario(
            etiqueta: 'Cada $intervalo días',
            horaRecogida: '08:30',
            horaCita: '09:00',
            horaVuelta: widget.tieneVuelta ? '10:00' : null,
          ),
        );
        break;

      case TipoRecurrencia.fechasEspecificas:
        // Para fechas específicas, no se usa plantilla
        // (siempre se mostrará grilla expandida)
        break;

      case TipoRecurrencia.mensual:
        // Para mensual, una entrada por cada día del mes seleccionado
        final List<int> diasMes = widget.configuracion.diasMes ?? <int>[];
        for (final int dia in diasMes) {
          final String etiqueta = dia == 32 ? 'Último día' : 'Día $dia';
          nuevasPlantillas.add(
            PlantillaHorario(
              diaMes: dia,
              etiqueta: etiqueta,
              horaRecogida: '08:30',
              horaCita: '09:00',
              horaVuelta: widget.tieneVuelta ? '10:00' : null,
            ),
          );
        }
        break;
    }

    widget.onPlantillaHorariosChanged(nuevasPlantillas);
  }

  void _addNewRow() {
    final List<PlantillaHorario> nuevasPlantillas = List<PlantillaHorario>.from(
      widget.plantillaHorarios,
    )..add(
      PlantillaHorario(
        etiqueta: 'Nuevo horario',
        horaRecogida: '08:30',
        horaCita: '09:00',
        horaVuelta: widget.tieneVuelta ? '10:00' : null,
      ),
    );

    widget.onPlantillaHorariosChanged(nuevasPlantillas);
  }

  void _removeRow(int index) {
    final List<PlantillaHorario> nuevasPlantillas = List<PlantillaHorario>.from(
      widget.plantillaHorarios,
    )..removeAt(index);
    widget.onPlantillaHorariosChanged(nuevasPlantillas);
  }

  void _updateHoraCita(int index, String newHoraCita) {
    // Validar formato HH:mm
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(newHoraCita)) {
      return;
    }

    final List<PlantillaHorario> nuevasPlantillas = List<PlantillaHorario>.from(
      widget.plantillaHorarios,
    );

    final PlantillaHorario actual = nuevasPlantillas[index];

    // Calcular horarios automáticamente
    final Map<String, String?> horariosCalculados = TimeCalculator.calcularHorarios(
      horaCita: newHoraCita,
      tiempoEsperaMinutos: widget.tiempoEsperaCita,
      tieneVuelta: widget.tieneVuelta,
    );

    nuevasPlantillas[index] = PlantillaHorario(
      diaSemana: actual.diaSemana,
      diaMes: actual.diaMes,
      etiqueta: actual.etiqueta,
      horaRecogida: horariosCalculados['hora_recogida']!,
      horaCita: horariosCalculados['hora_cita']!,
      horaVuelta: horariosCalculados['hora_vuelta'],
    );

    widget.onPlantillaHorariosChanged(nuevasPlantillas);
  }
}
