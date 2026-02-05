import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Resultado del diálogo de cancelación
class CancelarTrasladoResult {
  const CancelarTrasladoResult({
    required this.confirmado,
    this.motivoCancelacion,
  });

  final bool confirmado;
  final String? motivoCancelacion;
}

/// Diálogo de confirmación para cancelar un traslado
class CancelarTrasladoDialog extends StatefulWidget {
  const CancelarTrasladoDialog({
    required this.pacienteNombre,
    required this.horaProgramada,
    required this.origen,
    required this.destino,
    super.key,
  });

  final String pacienteNombre;
  final DateTime? horaProgramada;
  final String origen;
  final String destino;

  /// Muestra el diálogo y retorna el resultado
  static Future<CancelarTrasladoResult?> show({
    required BuildContext context,
    required String pacienteNombre,
    required DateTime? horaProgramada,
    required String origen,
    required String destino,
  }) async {
    return showDialog<CancelarTrasladoResult?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CancelarTrasladoDialog(
          pacienteNombre: pacienteNombre,
          horaProgramada: horaProgramada,
          origen: origen,
          destino: destino,
        );
      },
    );
  }

  @override
  State<CancelarTrasladoDialog> createState() => _CancelarTrasladoDialogState();
}

class _CancelarTrasladoDialogState extends State<CancelarTrasladoDialog> {
  final TextEditingController _motivoController = TextEditingController();
  String? _motivoSeleccionado;

  // Motivos predefinidos comunes
  static const List<String> _motivosPredefinidos = <String>[
    'Paciente no disponible',
    'Cancelado por el hospital',
    'Cambio de cita médica',
    'Paciente hospitalizado',
    'Error de programación',
    'Condiciones climáticas',
    'Otro motivo',
  ];

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String horaFormateada = widget.horaProgramada != null
        ? DateFormat('HH:mm').format(widget.horaProgramada!)
        : 'Sin programar';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header de advertencia
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: const BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radius),
                  topRight: Radius.circular(AppSizes.radius),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Cancelar Traslado',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Esta acción no se puede deshacer',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
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
                  // Info del traslado a cancelar
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Paciente
                        Row(
                          children: <Widget>[
                            const Icon(Icons.person, size: 16, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.pacienteNombre.isNotEmpty
                                    ? widget.pacienteNombre.toUpperCase()
                                    : 'SIN PACIENTE',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                horaFormateada,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        // Ruta
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'ORIGEN',
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 14),
                                    child: Text(
                                      widget.origen.isNotEmpty ? widget.origen : 'No especificado',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward, size: 14, color: AppColors.gray400),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        'DESTINO',
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 14),
                                    child: Text(
                                      widget.destino.isNotEmpty ? widget.destino : 'No especificado',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing),

                  // Motivo de cancelación
                  Text(
                    'Motivo de cancelación (opcional):',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Chips de motivos predefinidos
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _motivosPredefinidos.map((String motivo) {
                      final bool seleccionado = _motivoSeleccionado == motivo;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (seleccionado) {
                              _motivoSeleccionado = null;
                            } else {
                              _motivoSeleccionado = motivo;
                              if (motivo != 'Otro motivo') {
                                _motivoController.clear();
                              }
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: seleccionado
                                ? AppColors.error.withValues(alpha: 0.1)
                                : AppColors.gray100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: seleccionado
                                  ? AppColors.error
                                  : AppColors.gray300,
                            ),
                          ),
                          child: Text(
                            motivo,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w500,
                              color: seleccionado ? AppColors.error : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Campo de texto para "Otro motivo"
                  if (_motivoSeleccionado == 'Otro motivo') ...<Widget>[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _motivoController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Especifique el motivo...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(12),
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
                          borderSide: const BorderSide(color: AppColors.error, width: 2),
                        ),
                      ),
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ],
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
                      'No, mantener',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _confirmarCancelacion,
                    icon: const Icon(Icons.cancel, size: 16),
                    label: Text(
                      'Sí, cancelar traslado',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
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

  void _confirmarCancelacion() {
    String? motivoFinal;

    if (_motivoSeleccionado != null) {
      if (_motivoSeleccionado == 'Otro motivo') {
        motivoFinal = _motivoController.text.trim().isNotEmpty
            ? _motivoController.text.trim()
            : 'Otro motivo';
      } else {
        motivoFinal = _motivoSeleccionado;
      }
    }

    Navigator.of(context).pop(
      CancelarTrasladoResult(
        confirmado: true,
        motivoCancelacion: motivoFinal,
      ),
    );
  }
}
