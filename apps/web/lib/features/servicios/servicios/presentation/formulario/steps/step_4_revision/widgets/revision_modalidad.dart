import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../../core/theme/app_colors.dart';
import '../../../models/modalidad_servicio.dart';
import 'revision_section_header.dart';

/// Sección de revisión de modalidad del servicio
///
/// Muestra la configuración de recurrencia del Step 2
class RevisionModalidad extends StatelessWidget {
  const RevisionModalidad({
    required this.modalidad,
    this.diasSemana = const <int>[],
    this.intervaloSemanas,
    this.diasMes = const <int>[],
    super.key,
  });

  final ModalidadServicio modalidad;
  final List<int> diasSemana;
  final int? intervaloSemanas;
  final List<int> diasMes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const RevisionSectionHeader(
          titulo: 'Modalidad del Servicio',
          icono: Icons.event_repeat,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 16),

        _buildContenido(context),
      ],
    );
  }

  Widget _buildContenido(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.event, size: 18, color: AppColors.textSecondaryLight),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Tipo: ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    TextSpan(
                      text: _getModalidadNombre(modalidad),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Días de la semana (para semanal y semanas alternas)
        if (modalidad == ModalidadServicio.semanal || modalidad == ModalidadServicio.semanasAlternas) ...<Widget>[
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const Icon(Icons.today, size: 18, color: AppColors.textSecondaryLight),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Días de la semana: ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      TextSpan(
                        text: _getDiasSemanaText(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        // Intervalo de semanas (para semanas alternas)
        if (modalidad == ModalidadServicio.semanasAlternas) ...<Widget>[
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const Icon(Icons.calendar_view_week, size: 18, color: AppColors.textSecondaryLight),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Intervalo: ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      TextSpan(
                        text: 'Cada ${intervaloSemanas ?? 2} semanas',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        // Días del mes (para mensual)
        if (modalidad == ModalidadServicio.mensual) ...<Widget>[
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const Icon(Icons.calendar_month, size: 18, color: AppColors.textSecondaryLight),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Días del mes: ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      TextSpan(
                        text: diasMes.join(', '),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _getModalidadNombre(ModalidadServicio modalidad) {
    switch (modalidad) {
      case ModalidadServicio.unico:
        return 'Servicio Único';
      case ModalidadServicio.diario:
        return 'Diario';
      case ModalidadServicio.semanal:
        return 'Recurrente Semanal';
      case ModalidadServicio.semanasAlternas:
        return 'Semanas Alternas';
      case ModalidadServicio.diasAlternos:
        return 'Días Alternos';
      case ModalidadServicio.mensual:
        return 'Mensual';
      case ModalidadServicio.especifico:
        return 'Fechas Específicas';
    }
  }

  String _getDiasSemanaText() {
    if (diasSemana.isEmpty) {
      return 'Ninguno';
    }

    const List<String> nombres = <String>[
      'Lunes',    // 0
      'Martes',   // 1
      'Miércoles', // 2
      'Jueves',   // 3
      'Viernes',  // 4
      'Sábado',   // 5
      'Domingo',  // 6
    ];

    // ✅ Usar índices 0-6 directamente (sin restar 1)
    final List<String> seleccionados = diasSemana
        .where((int dia) => dia >= 0 && dia < nombres.length) // Validar rango
        .map((int dia) => nombres[dia])
        .toList();

    return seleccionados.isNotEmpty ? seleccionados.join(', ') : 'Ninguno';
  }
}
