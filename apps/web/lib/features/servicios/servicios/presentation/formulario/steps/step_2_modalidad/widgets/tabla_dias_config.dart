import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../domain/entities/configuracion_dia.dart';

/// Widget reutilizable para mostrar y editar la configuración de días
/// Se usa en: Semanal, Días Alternos, Fechas Específicas y Mensual
class TablaDiasConfig extends StatefulWidget {
  const TablaDiasConfig({
    required this.dias,
    required this.mostrarColumnaVuelta,
    required this.onDiaChanged,
    this.onEliminar,
    this.titulo,
    this.horaEnCentro,
    this.mostrarBotonCopiar = true,
    super.key,
  });

  /// Lista de días a mostrar
  final List<ConfiguracionDia> dias;

  /// Si se deben mostrar las columnas de Vuelta (false si motivoTraslado.vuelta = false)
  final bool mostrarColumnaVuelta;

  /// Callback cuando cambia un día
  final void Function(int index, ConfiguracionDia nuevaConfig) onDiaChanged;

  /// Callback para eliminar (solo para fechas específicas)
  final void Function(int index)? onEliminar;

  /// Título opcional de la tabla
  final String? titulo;

  /// Hora en centro del Paso 1 (para autocompletar al marcar Ida)
  final TimeOfDay? horaEnCentro;

  /// Si se debe mostrar el botón "Copiar a..." (solo para Semanal)
  final bool mostrarBotonCopiar;

  @override
  State<TablaDiasConfig> createState() => _TablaDiasConfigState();
}

class _TablaDiasConfigState extends State<TablaDiasConfig> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.titulo != null) ...<Widget>[
          Text(
            widget.titulo!,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray300),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Column(
            children: <Widget>[
              // Header
              _buildHeader(),
              // Filas
              ...List<Widget>.generate(
                widget.dias.length,
                (int index) => _buildRow(context, index),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye el header de la tabla
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(color: AppColors.gray300),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Columna: Día/Fecha
          Expanded(
            flex: 2,
            child: _buildHeaderCell('Día'),
          ),
          // Columna: Ida
          SizedBox(
            width: 50,
            child: _buildHeaderCell('Ida', centered: true),
          ),
          // Columna: H.Ida
          SizedBox(
            width: 80,
            child: _buildHeaderCell('H.Ida', centered: true),
          ),
          // Columna: Tiempo
          SizedBox(
            width: 90,
            child: _buildHeaderCell('Tiempo', centered: true),
          ),
          // Columnas: Vuelta y H.Vuelta (condicionales)
          if (widget.mostrarColumnaVuelta) ...<Widget>[
            SizedBox(
              width: 60,
              child: _buildHeaderCell('Vuelta', centered: true),
            ),
            SizedBox(
              width: 85,
              child: _buildHeaderCell('H.Vuelta', centered: true),
            ),
          ],
          // Columna: Copiar (si mostrarBotonCopiar)
          if (widget.mostrarBotonCopiar)
            const SizedBox(
              width: 50,
              child: SizedBox.shrink(),
            ),
          // Columna: Acciones (si hay onEliminar)
          if (widget.onEliminar != null)
            const SizedBox(
              width: 50,
              child: SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, {bool centered = false}) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      textAlign: centered ? TextAlign.center : TextAlign.left,
    );
  }

  /// Construye una fila de la tabla
  Widget _buildRow(BuildContext context, int index) {
    final ConfiguracionDia dia = widget.dias[index];
    final bool isEnabled = dia.ida;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : AppColors.surfaceLight,
        border: index < widget.dias.length - 1
            ? const Border(bottom: BorderSide(color: AppColors.gray200))
            : null,
      ),
      child: Row(
        children: <Widget>[
          // Día/Fecha
          Expanded(
            flex: 2,
            child: Text(
              dia.label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isEnabled
                    ? AppColors.textPrimaryLight
                    : AppColors.textSecondaryLight,
                fontWeight: isEnabled ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),

          // Checkbox Ida
          SizedBox(
            width: 50,
            child: Center(
              child: Checkbox(
                value: dia.ida,
                onChanged: (bool? value) {
                  if (value != null) {
                    // Si marca Ida y hay hora en centro del Paso 1, autocompletar
                    if (value && widget.horaEnCentro != null && dia.horaIda == null) {
                      widget.onDiaChanged(
                        index,
                        dia.copyWith(ida: value, horaIda: widget.horaEnCentro),
                      );
                    } else {
                      widget.onDiaChanged(index, dia.copyWith(ida: value));
                    }
                  }
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

          // H.Ida (editable si ida=true)
          SizedBox(
            width: 80,
            child: isEnabled
                ? _buildTimeField(
                    context: context,
                    value: dia.horaIda,
                    onChanged: (TimeOfDay? newTime) {
                      widget.onDiaChanged(index, dia.copyWith(horaIda: newTime));
                    },
                  )
                : const Center(child: Text('-', style: TextStyle(color: AppColors.textSecondaryLight))),
          ),

          // Tiempo (solo lectura)
          SizedBox(
            width: 90,
            child: Center(
              child: Text(
                isEnabled ? '${dia.tiempoEspera} min' : '-',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isEnabled
                      ? AppColors.textSecondaryLight
                      : AppColors.gray400,
                ),
              ),
            ),
          ),

          // Vuelta y H.Vuelta (condicionales)
          if (widget.mostrarColumnaVuelta) ...<Widget>[
            // Checkbox Vuelta
            SizedBox(
              width: 60,
              child: Center(
                child: Checkbox(
                  value: dia.vuelta,
                  onChanged: isEnabled
                      ? (bool? value) {
                          if (value != null) {
                            widget.onDiaChanged(index, dia.copyWith(vuelta: value));
                          }
                        }
                      : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),

            // H.Vuelta (calculada automáticamente)
            SizedBox(
              width: 85,
              child: Center(
                child: Text(
                  isEnabled && dia.vuelta && dia.horaVueltaCalculada != null
                      ? _formatTimeOfDay(dia.horaVueltaCalculada!)
                      : '-',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],

          // Botón Copiar (solo si mostrarBotonCopiar y el día tiene configuración)
          if (widget.mostrarBotonCopiar)
            SizedBox(
              width: 50,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.copy_all, size: 18),
                  color: isEnabled ? AppColors.primary : AppColors.gray400,
                  onPressed: isEnabled ? () => _showCopyDialog(context, index) : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: isEnabled ? 'Copiar a otros días' : null,
                ),
              ),
            ),

          // Botón Eliminar (solo para fechas específicas)
          if (widget.onEliminar != null)
            SizedBox(
              width: 50,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.error,
                  onPressed: () => widget.onEliminar!(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construye el campo de hora editable
  Widget _buildTimeField({
    required BuildContext context,
    required TimeOfDay? value,
    required void Function(TimeOfDay?) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: value ?? const TimeOfDay(hour: 10, minute: 0),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            value != null ? _formatTimeOfDay(value) : '--:--',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: value != null
                  ? AppColors.textPrimaryLight
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Formatea TimeOfDay a string HH:mm
  String _formatTimeOfDay(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Muestra diálogo para seleccionar días destino para copiar configuración
  Future<void> _showCopyDialog(BuildContext context, int sourceIndex) async {
    final ConfiguracionDia sourceDia = widget.dias[sourceIndex];

    // Lista de días destino posibles (todos excepto el día origen)
    final List<int> targetIndices = List<int>.generate(
      widget.dias.length,
      (int i) => i,
    ).where((int i) => i != sourceIndex).toList();

    // Set para trackear qué días están seleccionados
    final Set<int> selectedIndices = <int>{};

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Header profesional
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingXl,
                        vertical: AppSizes.paddingLarge,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppSizes.radiusLarge),
                          topRight: Radius.circular(AppSizes.radiusLarge),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.copy_all,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: AppSizes.spacingMedium),
                          Expanded(
                            child: Text(
                              'Copiar configuración de ${sourceDia.label}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            iconSize: 24,
                            tooltip: 'Cerrar',
                          ),
                        ],
                      ),
                    ),

                    // Contenido
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.paddingXl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Sección "Se copiará"
                            Container(
                              padding: const EdgeInsets.all(AppSizes.paddingMedium),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.info_outline,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: AppSizes.spacingSmall),
                                      Text(
                                        'Se copiará:',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.spacing),
                                  _buildInfoRow(
                                    icon: sourceDia.ida ? Icons.check_circle : Icons.cancel,
                                    iconColor: sourceDia.ida ? AppColors.success : AppColors.error,
                                    label: 'Ida:',
                                    value: sourceDia.ida ? 'Sí' : 'No',
                                  ),
                                  if (sourceDia.horaIda != null) ...<Widget>[
                                    const SizedBox(height: AppSizes.spacingSmall),
                                    _buildInfoRow(
                                      icon: Icons.schedule,
                                      iconColor: AppColors.info,
                                      label: 'Hora Ida:',
                                      value: _formatTimeOfDay(sourceDia.horaIda!),
                                    ),
                                  ],
                                  const SizedBox(height: AppSizes.spacingSmall),
                                  _buildInfoRow(
                                    icon: sourceDia.vuelta ? Icons.check_circle : Icons.cancel,
                                    iconColor: sourceDia.vuelta ? AppColors.success : AppColors.error,
                                    label: 'Vuelta:',
                                    value: sourceDia.vuelta ? 'Sí' : 'No',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacingLarge),

                            // Sección "Seleccionar días destino"
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.calendar_month,
                                  size: 20,
                                  color: AppColors.textPrimaryLight,
                                ),
                                const SizedBox(width: AppSizes.spacingSmall),
                                Text(
                                  'Selecciona los días destino:',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.spacing),

                            // Lista de checkboxes mejorada
                            Container(
                              constraints: const BoxConstraints(maxHeight: 280),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.gray300),
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: targetIndices.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: AppColors.gray200,
                                ),
                                itemBuilder: (BuildContext context, int i) {
                                  final int targetIndex = targetIndices[i];
                                  final ConfiguracionDia targetDia = widget.dias[targetIndex];
                                  final bool isSelected = selectedIndices.contains(targetIndex);

                                  return Material(
                                    color: isSelected
                                        ? AppColors.primary.withValues(alpha: 0.08)
                                        : Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setDialogState(() {
                                          if (isSelected) {
                                            selectedIndices.remove(targetIndex);
                                          } else {
                                            selectedIndices.add(targetIndex);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSizes.paddingMedium,
                                          vertical: AppSizes.paddingSmall,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Checkbox(
                                              value: isSelected,
                                              onChanged: (bool? value) {
                                                setDialogState(() {
                                                  if (value == true) {
                                                    selectedIndices.add(targetIndex);
                                                  } else {
                                                    selectedIndices.remove(targetIndex);
                                                  }
                                                });
                                              },
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              activeColor: AppColors.primary,
                                            ),
                                            const SizedBox(width: AppSizes.spacing),
                                            Expanded(
                                              child: Text(
                                                targetDia.label,
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : AppColors.textPrimaryLight,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer con botones
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingXl),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppSizes.radiusLarge),
                          bottomRight: Radius.circular(AppSizes.radiusLarge),
                        ),
                        border: Border(
                          top: BorderSide(color: AppColors.gray200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingLarge,
                                vertical: AppSizes.paddingMedium,
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing),
                          ElevatedButton.icon(
                            onPressed: selectedIndices.isEmpty
                                ? null
                                : () {
                                    // Aplicar la copia
                                    _applyCopy(sourceIndex, selectedIndices.toList());
                                    Navigator.of(dialogContext).pop();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.gray300,
                              disabledForegroundColor: AppColors.gray500,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingLarge,
                                vertical: AppSizes.paddingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              ),
                            ),
                            icon: const Icon(Icons.copy_all, size: 18),
                            label: Text(
                              selectedIndices.isEmpty
                                  ? 'Copiar (0)'
                                  : 'Copiar (${selectedIndices.length})',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Widget helper para mostrar una fila de información con icono
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  /// Aplica la copia de configuración desde el día origen a los días destino
  void _applyCopy(int sourceIndex, List<int> targetIndices) {
    final ConfiguracionDia sourceDia = widget.dias[sourceIndex];

    for (final int targetIndex in targetIndices) {
      final ConfiguracionDia targetDia = widget.dias[targetIndex];

      // Copiar configuración manteniendo el resto de propiedades del día destino
      final ConfiguracionDia updatedDia = targetDia.copyWith(
        ida: sourceDia.ida,
        horaIda: sourceDia.horaIda,
        vuelta: sourceDia.vuelta,
        // tiempoEspera se mantiene del targetDia (es global por motivo de traslado)
      );

      widget.onDiaChanged(targetIndex, updatedDia);
    }
  }
}
