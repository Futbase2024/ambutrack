import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/modalidad_servicio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Widget del Paso 2: Configuración de Modalidad y Recurrencia
class Step2Modalidad extends StatefulWidget {
  const Step2Modalidad({
    required this.formKey,
    required this.modalidad,
    required this.diasSemanaSeleccionados,
    required this.diasMesSeleccionados,
    required this.intervaloSemanas,
    required this.intervaloDias,
    required this.fechasEspecificas,
    required this.onModalidadChanged,
    required this.onDiasSemanaChanged,
    required this.onDiasMesChanged,
    required this.onIntervaloSemanasChanged,
    required this.onIntervaloDiasChanged,
    required this.onFechasEspecificasChanged,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final ModalidadServicio modalidad;
  final Set<int> diasSemanaSeleccionados;
  final Set<int> diasMesSeleccionados;
  final int intervaloSemanas;
  final int intervaloDias;
  final List<DateTime> fechasEspecificas;
  final void Function(ModalidadServicio) onModalidadChanged;
  final void Function(Set<int>) onDiasSemanaChanged;
  final void Function(Set<int>) onDiasMesChanged;
  final void Function(int) onIntervaloSemanasChanged;
  final void Function(int) onIntervaloDiasChanged;
  final void Function(List<DateTime>) onFechasEspecificasChanged;

  @override
  State<Step2Modalidad> createState() => _Step2ModalidadState();
}

class _Step2ModalidadState extends State<Step2Modalidad> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ModalidadSelector(
            modalidad: widget.modalidad,
            onModalidadChanged: widget.onModalidadChanged,
          ),
          const SizedBox(height: 16),
          _ModalidadConfigContainer(
            modalidad: widget.modalidad,
            diasSemanaSeleccionados: widget.diasSemanaSeleccionados,
            diasMesSeleccionados: widget.diasMesSeleccionados,
            intervaloSemanas: widget.intervaloSemanas,
            intervaloDias: widget.intervaloDias,
            fechasEspecificas: widget.fechasEspecificas,
            onDiasSemanaChanged: widget.onDiasSemanaChanged,
            onDiasMesChanged: widget.onDiasMesChanged,
            onIntervaloSemanasChanged: widget.onIntervaloSemanasChanged,
            onIntervaloDiasChanged: widget.onIntervaloDiasChanged,
            onFechasEspecificasChanged: widget.onFechasEspecificasChanged,
          ),
        ],
      ),
    );
  }
}

/// Selector de tipo de modalidad (grid 2x3)
class _ModalidadSelector extends StatelessWidget {
  const _ModalidadSelector({
    required this.modalidad,
    required this.onModalidadChanged,
  });

  final ModalidadServicio modalidad;
  final void Function(ModalidadServicio) onModalidadChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tipo de Recurrencia *',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: <Widget>[
            // FILA 1: Serv. Único, Diario, Semanal
            Row(
              children: <Widget>[
                Expanded(
                  child: _ModalidadCard(
                    modalidad: ModalidadServicio.unico,
                    icon: Icons.event_note,
                    titulo: 'Serv. Único',
                    descripcion: 'Una sola fecha',
                    isSelected: modalidad == ModalidadServicio.unico,
                    onTap: () => onModalidadChanged(ModalidadServicio.unico),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModalidadCard(
                    modalidad: ModalidadServicio.diario,
                    icon: Icons.today,
                    titulo: 'Diario',
                    descripcion: 'Todos los días',
                    isSelected: modalidad == ModalidadServicio.diario,
                    onTap: () => onModalidadChanged(ModalidadServicio.diario),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModalidadCard(
                    modalidad: ModalidadServicio.semanal,
                    icon: Icons.calendar_view_week,
                    titulo: 'Semanal',
                    descripcion: 'Días fijos',
                    isSelected: modalidad == ModalidadServicio.semanal,
                    onTap: () => onModalidadChanged(ModalidadServicio.semanal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // FILA 2: Días Alternos, Fechas Específicas, Mensual
            Row(
              children: <Widget>[
                Expanded(
                  child: _ModalidadCard(
                    modalidad: ModalidadServicio.diasAlternos,
                    icon: Icons.sync_alt,
                    titulo: 'Días Alternos',
                    descripcion: 'Cada N días',
                    isSelected: modalidad == ModalidadServicio.diasAlternos,
                    onTap: () => onModalidadChanged(ModalidadServicio.diasAlternos),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModalidadCard(
                    modalidad: ModalidadServicio.especifico,
                    icon: Icons.date_range,
                    titulo: 'Fechas Específicas',
                    descripcion: 'Fechas concretas',
                    isSelected: modalidad == ModalidadServicio.especifico,
                    onTap: () => onModalidadChanged(ModalidadServicio.especifico),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModalidadCard(
                    modalidad: ModalidadServicio.mensual,
                    icon: Icons.calendar_month,
                    titulo: 'Mensual',
                    descripcion: 'Días del mes',
                    isSelected: modalidad == ModalidadServicio.mensual,
                    onTap: () => onModalidadChanged(ModalidadServicio.mensual),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Card individual de modalidad
class _ModalidadCard extends StatelessWidget {
  const _ModalidadCard({
    required this.modalidad,
    required this.icon,
    required this.titulo,
    required this.descripcion,
    required this.isSelected,
    required this.onTap,
  });

  final ModalidadServicio modalidad;
  final IconData icon;
  final String titulo;
  final String descripcion;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 26,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    titulo,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    descripcion,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenedor de configuración específica según modalidad
class _ModalidadConfigContainer extends StatelessWidget {
  const _ModalidadConfigContainer({
    required this.modalidad,
    required this.diasSemanaSeleccionados,
    required this.diasMesSeleccionados,
    required this.intervaloSemanas,
    required this.intervaloDias,
    required this.fechasEspecificas,
    required this.onDiasSemanaChanged,
    required this.onDiasMesChanged,
    required this.onIntervaloSemanasChanged,
    required this.onIntervaloDiasChanged,
    required this.onFechasEspecificasChanged,
  });

  final ModalidadServicio modalidad;
  final Set<int> diasSemanaSeleccionados;
  final Set<int> diasMesSeleccionados;
  final int intervaloSemanas;
  final int intervaloDias;
  final List<DateTime> fechasEspecificas;
  final void Function(Set<int>) onDiasSemanaChanged;
  final void Function(Set<int>) onDiasMesChanged;
  final void Function(int) onIntervaloSemanasChanged;
  final void Function(int) onIntervaloDiasChanged;
  final void Function(List<DateTime>) onFechasEspecificasChanged;

  @override
  Widget build(BuildContext context) {
    switch (modalidad) {
      case ModalidadServicio.unico:
        return const _ConfigUnico();
      case ModalidadServicio.diario:
        return const _ConfigDiario();
      case ModalidadServicio.semanal:
        return _ConfigSemanal(
          diasSeleccionados: diasSemanaSeleccionados,
          onDiasChanged: onDiasSemanaChanged,
        );
      case ModalidadServicio.semanasAlternas:
        return _ConfigSemanasAlternas(
          intervaloSemanas: intervaloSemanas,
          diasSeleccionados: diasSemanaSeleccionados,
          onIntervaloChanged: onIntervaloSemanasChanged,
          onDiasChanged: onDiasSemanaChanged,
        );
      case ModalidadServicio.diasAlternos:
        return _ConfigDiasAlternos(
          intervaloDias: intervaloDias,
          onIntervaloChanged: onIntervaloDiasChanged,
        );
      case ModalidadServicio.mensual:
        return _ConfigMensual(
          diasSeleccionados: diasMesSeleccionados,
          onDiasChanged: onDiasMesChanged,
        );
      case ModalidadServicio.especifico:
        return _ConfigEspecifico(
          fechasSeleccionadas: fechasEspecificas,
          onFechasChanged: onFechasEspecificasChanged,
        );
    }
  }
}

/// Configuración: Servicio Único
class _ConfigUnico extends StatelessWidget {
  const _ConfigUnico();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline, color: AppColors.info, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'El servicio se creará solo para la fecha de inicio del tratamiento',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }
}

/// Configuración: Servicio Diario
class _ConfigDiario extends StatelessWidget {
  const _ConfigDiario();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'El servicio se repetirá todos los días durante el periodo de tratamiento',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }
}

/// Configuración: Servicio Semanal
class _ConfigSemanal extends StatelessWidget {
  const _ConfigSemanal({
    required this.diasSeleccionados,
    required this.onDiasChanged,
  });

  final Set<int> diasSeleccionados;
  final void Function(Set<int>) onDiasChanged;

  static const List<String> _diasSemana = <String>['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Selecciona los días de la semana',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacing),
        Wrap(
          spacing: AppSizes.spacingSmall,
          children: List<Widget>.generate(7, (int index) {
            final bool isSelected = diasSeleccionados.contains(index + 1);
            return _DiaSemanaBadge(
              label: _diasSemana[index],
              isSelected: isSelected,
              onTap: () {
                final Set<int> newDias = Set<int>.from(diasSeleccionados);
                if (isSelected) {
                  newDias.remove(index + 1);
                } else {
                  newDias.add(index + 1);
                }
                onDiasChanged(newDias);
              },
            );
          }),
        ),
        if (diasSeleccionados.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.spacingSmall),
            child: Text(
              'Selecciona al menos un día',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

/// Badge de día de la semana
class _DiaSemanaBadge extends StatelessWidget {
  const _DiaSemanaBadge({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

/// Configuración: Semanas Alternas
class _ConfigSemanasAlternas extends StatelessWidget {
  const _ConfigSemanasAlternas({
    required this.intervaloSemanas,
    required this.diasSeleccionados,
    required this.onIntervaloChanged,
    required this.onDiasChanged,
  });

  final int intervaloSemanas;
  final Set<int> diasSeleccionados;
  final void Function(int) onIntervaloChanged;
  final void Function(Set<int>) onDiasChanged;

  static const List<String> _diasSemana = <String>['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Intervalo de semanas',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        _IntervaloCounter(
          value: intervaloSemanas,
          label: 'semanas',
          minValue: 2,
          example: 'Semana 1, ${1 + intervaloSemanas}, ${1 + intervaloSemanas * 2}...',
          onDecrement: () => onIntervaloChanged(intervaloSemanas - 1),
          onIncrement: () => onIntervaloChanged(intervaloSemanas + 1),
        ),
        const SizedBox(height: 12),
        Text(
          'Días de la semana',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: List<Widget>.generate(7, (int index) {
            final bool isSelected = diasSeleccionados.contains(index + 1);
            return _DiaSemanaBadge(
              label: _diasSemana[index],
              isSelected: isSelected,
              onTap: () {
                final Set<int> newDias = Set<int>.from(diasSeleccionados);
                if (isSelected) {
                  newDias.remove(index + 1);
                } else {
                  newDias.add(index + 1);
                }
                onDiasChanged(newDias);
              },
            );
          }),
        ),
      ],
    );
  }
}

/// Configuración: Días Alternos
class _ConfigDiasAlternos extends StatelessWidget {
  const _ConfigDiasAlternos({
    required this.intervaloDias,
    required this.onIntervaloChanged,
  });

  final int intervaloDias;
  final void Function(int) onIntervaloChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Intervalo de días',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        _IntervaloCounter(
          value: intervaloDias,
          label: 'días',
          minValue: 2,
          example: 'Día 1, ${1 + intervaloDias}, ${1 + intervaloDias * 2}...',
          onDecrement: () => onIntervaloChanged(intervaloDias - 1),
          onIncrement: () => onIntervaloChanged(intervaloDias + 1),
        ),
      ],
    );
  }
}

/// Widget contador de intervalo (reutilizable)
class _IntervaloCounter extends StatelessWidget {
  const _IntervaloCounter({
    required this.value,
    required this.label,
    required this.minValue,
    required this.example,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final String label;
  final int minValue;
  final String example;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 24),
          color: value > minValue ? AppColors.error : AppColors.gray400,
          onPressed: value > minValue ? onDecrement : null,
          padding: const EdgeInsets.all(8),
        ),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Cada $value $label',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '(ej: $example)',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 24),
          color: AppColors.success,
          onPressed: onIncrement,
          padding: const EdgeInsets.all(8),
        ),
      ],
    );
  }
}

/// Configuración: Mensual
class _ConfigMensual extends StatelessWidget {
  const _ConfigMensual({
    required this.diasSeleccionados,
    required this.onDiasChanged,
  });

  final Set<int> diasSeleccionados;
  final void Function(Set<int>) onDiasChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Selecciona los días del mes',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 31,
          itemBuilder: (BuildContext context, int index) {
            final int dia = index + 1;
            final bool isSelected = diasSeleccionados.contains(dia);
            return _DiaMesBadge(
              dia: dia,
              isSelected: isSelected,
              onTap: () {
                final Set<int> newDias = Set<int>.from(diasSeleccionados);
                if (isSelected) {
                  newDias.remove(dia);
                } else {
                  newDias.add(dia);
                }
                onDiasChanged(newDias);
              },
            );
          },
        ),
      ],
    );
  }
}

/// Badge de día del mes
class _DiaMesBadge extends StatelessWidget {
  const _DiaMesBadge({
    required this.dia,
    required this.isSelected,
    required this.onTap,
  });

  final int dia;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            dia.toString(),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

/// Configuración: Fechas Específicas
class _ConfigEspecifico extends StatelessWidget {
  const _ConfigEspecifico({
    required this.fechasSeleccionadas,
    required this.onFechasChanged,
  });

  final List<DateTime> fechasSeleccionadas;
  final void Function(List<DateTime>) onFechasChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Fechas seleccionadas (${fechasSeleccionadas.length})',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
            AppButton(
              label: 'Agregar Fecha',
              icon: Icons.add,
              variant: AppButtonVariant.text,
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  final List<DateTime> newFechas = List<DateTime>.from(fechasSeleccionadas)..add(picked);
                  onFechasChanged(newFechas);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (fechasSeleccionadas.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.warning_amber, color: AppColors.warning, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Agrega al menos una fecha específica para el servicio',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimaryLight),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fechasSeleccionadas.map((DateTime fecha) {
              return Chip(
                label: Text(
                  DateFormat('dd/MM/yyyy').format(fecha),
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  final List<DateTime> newFechas = List<DateTime>.from(fechasSeleccionadas)..remove(fecha);
                  onFechasChanged(newFechas);
                },
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              );
            }).toList(),
          ),
      ],
    );
  }
}
