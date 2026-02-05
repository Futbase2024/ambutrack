import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Diálogo para modificar la hora programada de un traslado
class ModificarHoraDialog extends StatefulWidget {
  const ModificarHoraDialog({
    required this.horaActual,
    required this.pacienteNombre,
    super.key,
  });

  final DateTime? horaActual;
  final String pacienteNombre;

  /// Muestra el diálogo y retorna la nueva hora seleccionada o null si se cancela
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime? horaActual,
    required String pacienteNombre,
  }) async {
    return showDialog<DateTime?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ModificarHoraDialog(
          horaActual: horaActual,
          pacienteNombre: pacienteNombre,
        );
      },
    );
  }

  @override
  State<ModificarHoraDialog> createState() => _ModificarHoraDialogState();
}

class _ModificarHoraDialogState extends State<ModificarHoraDialog> {
  late int _horaSeleccionada;
  late int _minutoSeleccionado;

  @override
  void initState() {
    super.initState();
    // Inicializar con la hora actual o las 8:00 por defecto
    _horaSeleccionada = widget.horaActual?.hour ?? 8;
    _minutoSeleccionado = widget.horaActual?.minute ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final String horaActualFormateada = widget.horaActual != null
        ? DateFormat('HH:mm').format(widget.horaActual!)
        : 'Sin programar';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: const BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radius),
                  topRight: Radius.circular(AppSizes.radius),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Modificar Hora',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.pacienteNombre.isNotEmpty
                              ? widget.pacienteNombre.toUpperCase()
                              : 'Traslado',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    splashRadius: 18,
                  ),
                ],
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Hora actual
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.schedule,
                          size: 18,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hora actual:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          horaActualFormateada,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing),

                  // Selector de hora
                  Text(
                    'Nueva hora:',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Selectores de hora y minuto
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Selector de hora
                      _buildSelectorNumerico(
                        valor: _horaSeleccionada,
                        minimo: 0,
                        maximo: 23,
                        label: 'Hora',
                        onChanged: (int valor) {
                          setState(() {
                            _horaSeleccionada = valor;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          ':',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      // Selector de minutos
                      _buildSelectorNumerico(
                        valor: _minutoSeleccionado,
                        minimo: 0,
                        maximo: 59,
                        label: 'Min',
                        step: 5,
                        onChanged: (int valor) {
                          setState(() {
                            _minutoSeleccionado = valor;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing),

                  // Preview de la nueva hora
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingLarge,
                        vertical: AppSizes.paddingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${_horaSeleccionada.toString().padLeft(2, '0')}:${_minutoSeleccionado.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer con botones
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: const BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppSizes.radius),
                  bottomRight: Radius.circular(AppSizes.radius),
                ),
                border: Border(top: BorderSide(color: AppColors.gray200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _confirmarCambio,
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(
                      'Confirmar',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorNumerico({
    required int valor,
    required int minimo,
    required int maximo,
    required String label,
    required ValueChanged<int> onChanged,
    int step = 1,
  }) {
    return Column(
      children: <Widget>[
        // Botón incrementar
        IconButton(
          onPressed: () {
            int nuevoValor = valor + step;
            if (nuevoValor > maximo) {
              nuevoValor = minimo;
            }
            onChanged(nuevoValor);
          },
          icon: const Icon(Icons.keyboard_arrow_up),
          iconSize: 28,
          color: AppColors.primary,
          splashRadius: 20,
        ),
        // Valor actual
        Container(
          width: 70,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            valor.toString().padLeft(2, '0'),
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        // Botón decrementar
        IconButton(
          onPressed: () {
            int nuevoValor = valor - step;
            if (nuevoValor < minimo) {
              nuevoValor = maximo;
            }
            onChanged(nuevoValor);
          },
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 28,
          color: AppColors.primary,
          splashRadius: 20,
        ),
        // Label
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  void _confirmarCambio() {
    // Crear DateTime con la nueva hora
    final DateTime ahora = DateTime.now();
    final DateTime nuevaHora = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      _horaSeleccionada,
      _minutoSeleccionado,
    );

    Navigator.of(context).pop(nuevaHora);
  }
}
