import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Widget para seleccionar fechas de tratamiento y hora en centro
class FechasTratamientoWidget extends StatefulWidget {
  const FechasTratamientoWidget({
    super.key,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horaEnCentro,
    required this.centroHospitalario,
    required this.centrosHospitalarios,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onHoraEnCentroChanged,
    required this.onCentroHospitalarioChanged,
  });

  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final TimeOfDay? horaEnCentro;
  final CentroHospitalarioEntity? centroHospitalario;
  final List<CentroHospitalarioEntity> centrosHospitalarios;
  final ValueChanged<DateTime?> onFechaInicioChanged;
  final ValueChanged<DateTime?> onFechaFinChanged;
  final ValueChanged<TimeOfDay?> onHoraEnCentroChanged;
  final ValueChanged<CentroHospitalarioEntity?> onCentroHospitalarioChanged;

  @override
  State<FechasTratamientoWidget> createState() => _FechasTratamientoWidgetState();
}

class _FechasTratamientoWidgetState extends State<FechasTratamientoWidget> {
  late TextEditingController _horaController;

  @override
  void initState() {
    super.initState();
    // Inicializar controlador con valor existente si hay
    _horaController = TextEditingController(
      text: widget.horaEnCentro != null
          ? '${widget.horaEnCentro!.hour.toString().padLeft(2, '0')}:${widget.horaEnCentro!.minute.toString().padLeft(2, '0')}'
          : '',
    );
  }

  @override
  void didUpdateWidget(FechasTratamientoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar el controlador si cambia horaEnCentro desde el padre
    if (widget.horaEnCentro != oldWidget.horaEnCentro) {
      _horaController.text = widget.horaEnCentro != null
          ? '${widget.horaEnCentro!.hour.toString().padLeft(2, '0')}:${widget.horaEnCentro!.minute.toString().padLeft(2, '0')}'
          : '';
    }
  }

  @override
  void dispose() {
    _horaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestionFormRow(
          label: 'Fecha inicio',
          required: true,
          child: _FechaField(
            fecha: widget.fechaInicio,
            hint: 'dd/mm/aaaa',
            onTap: () => _selectFechaInicio(context),
          ),
        ),
        GestionFormRow(
          label: 'Fecha fin',
          child: _FechaField(
            fecha: widget.fechaFin,
            hint: 'Sin fecha de fin (indefinido)',
            onTap: () => _selectFechaFin(context),
            onClear: () => widget.onFechaFinChanged(null),
          ),
        ),
        GestionFormRow(
          label: 'Hora en centro',
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 140,
              child: _HoraEnCentroField(
                controller: _horaController,
                onHoraEnCentroChanged: widget.onHoraEnCentroChanged,
              ),
            ),
          ),
        ),
        GestionFormRow(
          label: 'Centro destino',
          child: GestionSearchField<CentroHospitalarioEntity>(
            value: widget.centroHospitalario,
            hint: 'Buscar centro hospitalario…',
            options: widget.centrosHospitalarios
                .map(
                  (CentroHospitalarioEntity centro) =>
                      GestionOption<CentroHospitalarioEntity>(centro, centro.nombre),
                )
                .toList(),
            onChanged: widget.onCentroHospitalarioChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _selectFechaInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.fechaInicio ?? DateTime.now(),
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
      widget.onFechaInicioChanged(picked);
      // Si fin es anterior a inicio, limpiar
      if (widget.fechaFin != null && widget.fechaFin!.isBefore(picked)) {
        widget.onFechaFinChanged(null);
      }
    }
  }

  Future<void> _selectFechaFin(BuildContext context) async {
    if (widget.fechaInicio == null) {
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
      initialDate: widget.fechaFin ?? widget.fechaInicio!.add(const Duration(days: 30)),
      firstDate: widget.fechaInicio!,
      lastDate: widget.fechaInicio!.add(const Duration(days: 365)),
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
      widget.onFechaFinChanged(picked);
    }
  }
}

class _FechaField extends StatelessWidget {
  const _FechaField({
    required this.fecha,
    required this.hint,
    required this.onTap,
    this.onClear,
  });

  final DateTime? fecha;
  final String hint;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        isEmpty: fecha == null,
        decoration: GestionFormStyle.decoration(
          hint: hint,
          suffix: fecha != null && onClear != null
              ? IconButton(
                  icon: const Icon(Icons.close, size: 15),
                  color: AppColors.gray500,
                  tooltip: 'Quitar fecha de fin',
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.gray500),
        ),
        child: Text(
          fecha != null ? DateFormat('dd/MM/yyyy').format(fecha!) : '',
          style: GestionFormStyle.text,
        ),
      ),
    );
  }
}

/// Campo de hora en centro (formato HHMM con autoformato a HH:MM)
class _HoraEnCentroField extends StatelessWidget {
  const _HoraEnCentroField({
    required this.controller,
    required this.onHoraEnCentroChanged,
  });

  final TextEditingController controller;
  final ValueChanged<TimeOfDay?> onHoraEnCentroChanged;

  void _onChanged(String value) {
    final String cleaned = value.replaceAll(RegExp('[^0-9:]'), '');

    if (cleaned.contains(':') && cleaned.length >= 5) {
      if (cleaned.length > 5) {
        controller.text = cleaned.substring(0, 5);
        controller.selection = TextSelection.fromPosition(
          const TextPosition(offset: 5),
        );
      }
      return;
    }

    if (!cleaned.contains(':') && cleaned.length > 4) {
      controller.text = cleaned.substring(0, 4);
      controller.selection = TextSelection.fromPosition(
        const TextPosition(offset: 4),
      );
      return;
    }

    if (cleaned.length == 4 && !cleaned.contains(':')) {
      final String horas = cleaned.substring(0, 2);
      final String minutos = cleaned.substring(2, 4);
      final int h = int.tryParse(horas) ?? 0;
      final int m = int.tryParse(minutos) ?? 0;

      if (h >= 0 && h < 24 && m >= 0 && m < 60) {
        onHoraEnCentroChanged(TimeOfDay(hour: h, minute: m));
        controller.text = '$horas:$minutos';
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    }
  }

  String? _validator(String? value) {
    // Campo opcional, solo validar si tiene valor
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.contains(':')) {
      final List<String> parts = value.split(':');
      if (parts.length != 2 || parts[0].length != 2 || parts[1].length != 2) {
        return 'Formato: HHMM';
      }
      final int? h = int.tryParse(parts[0]);
      final int? m = int.tryParse(parts[1]);
      if (h == null || m == null || h < 0 || h >= 24 || m < 0 || m >= 60) {
        return 'Hora inválida';
      }
      return null;
    }

    if (value.length != 4) {
      return 'Formato: HHMM';
    }

    final int? h = int.tryParse(value.substring(0, 2));
    final int? m = int.tryParse(value.substring(2, 4));
    if (h == null || m == null || h < 0 || h >= 24 || m < 0 || m >= 60) {
      return 'Hora inválida';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: GestionFormStyle.text,
      decoration: GestionFormStyle.decoration(
        hint: 'HHMM',
        suffix: const Icon(Icons.schedule, size: 16, color: AppColors.gray500),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[0-9:]')),
        LengthLimitingTextInputFormatter(5),
      ],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: _onChanged,
      validator: _validator,
    );
  }
}
