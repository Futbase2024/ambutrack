import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Fila de fechas (inicio y fin)
        Row(
          children: <Widget>[
            Expanded(
              child: _FechaField(
                label: 'Inicio Tratamiento *',
                fecha: widget.fechaInicio,
                onTap: () => _selectFechaInicio(context),
                icon: Icons.calendar_today,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FechaFinField(
                fechaInicio: widget.fechaInicio,
                fechaFin: widget.fechaFin,
                onTap: () => _selectFechaFin(context),
                onClear: () => widget.onFechaFinChanged(null),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Campo de hora en centro
        _buildHoraEnCentroField(),
        const SizedBox(height: 12),

        // Campo de centro hospitalario (opcional)
        _buildCentroHospitalarioField(),
      ],
    );
  }

  /// Construye el campo de hora en centro
  Widget _buildHoraEnCentroField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Hora en Centro',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        SizedBox(
          width: 150,
          child: TextFormField(
            controller: _horaController,
            decoration: InputDecoration(
              hintText: 'HHMM',
              prefixIcon: const Icon(Icons.access_time, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9:]')),
              LengthLimitingTextInputFormatter(5),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (String value) {
              final String cleaned = value.replaceAll(RegExp('[^0-9:]'), '');

              if (cleaned.contains(':') && cleaned.length >= 5) {
                if (cleaned.length > 5) {
                  _horaController.text = cleaned.substring(0, 5);
                  _horaController.selection = TextSelection.fromPosition(
                    const TextPosition(offset: 5),
                  );
                }
                return;
              }

              if (!cleaned.contains(':') && cleaned.length > 4) {
                _horaController.text = cleaned.substring(0, 4);
                _horaController.selection = TextSelection.fromPosition(
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
                  widget.onHoraEnCentroChanged(TimeOfDay(hour: h, minute: m));
                  _horaController.text = '$horas:$minutos';
                  _horaController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _horaController.text.length),
                  );
                }
              }
            },
            validator: (String? value) {
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
            },
          ),
        ),
      ],
    );
  }

  /// Construye el campo de centro hospitalario (opcional)
  Widget _buildCentroHospitalarioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Centro Hospitalario',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        AppSearchableDropdown<CentroHospitalarioEntity>(
          value: widget.centroHospitalario,
          label: 'Centro de destino',
          hint: 'Buscar centro hospitalario...',
          prefixIcon: Icons.local_hospital,
          searchHint: 'Escribe para buscar...',
          items: widget.centrosHospitalarios
              .map(
                (CentroHospitalarioEntity centro) => AppSearchableDropdownItem<CentroHospitalarioEntity>(
                  value: centro,
                  label: centro.nombre,
                  icon: Icons.local_hospital,
                  iconColor: AppColors.info,
                ),
              )
              .toList(),
          onChanged: widget.onCentroHospitalarioChanged,
          displayStringForOption: (CentroHospitalarioEntity centro) => centro.nombre,
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
