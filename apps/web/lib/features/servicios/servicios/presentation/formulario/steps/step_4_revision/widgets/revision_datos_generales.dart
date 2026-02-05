import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../../../../core/theme/app_colors.dart';
import 'revision_section_header.dart';

/// Sección de revisión de paciente y servicio
///
/// Muestra los datos generales del Step 1 en formato read-only
class RevisionDatosGenerales extends StatelessWidget {
  const RevisionDatosGenerales({
    required this.paciente,
    this.motivoTraslado,
    this.fechaInicio,
    this.fechaFin,
    this.observaciones,
    this.localidades = const <LocalidadEntity>[],
    super.key,
  });

  final PacienteEntity? paciente;
  final MotivoTrasladoEntity? motivoTraslado;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String? observaciones;
  final List<LocalidadEntity> localidades;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSeccionPaciente(),
        const SizedBox(height: 24),
        _buildSeccionServicio(),
      ],
    );
  }

  Widget _buildSeccionPaciente() {
    if (paciente == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const RevisionSectionHeader(
            titulo: 'Datos del Paciente',
            icono: Icons.person,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay paciente seleccionado',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.error,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    // Construir dirección completa
    final List<String> direccionParts = <String>[];
    if (paciente!.domicilioDireccion != null && paciente!.domicilioDireccion!.isNotEmpty) {
      direccionParts.add(paciente!.domicilioDireccion!);
    }
    if (paciente!.domicilioPiso != null && paciente!.domicilioPiso!.isNotEmpty) {
      direccionParts.add('Piso ${paciente!.domicilioPiso}');
    }
    if (paciente!.domicilioPuerta != null && paciente!.domicilioPuerta!.isNotEmpty) {
      direccionParts.add('Puerta ${paciente!.domicilioPuerta}');
    }

    final String direccionCompleta = direccionParts.isNotEmpty
        ? direccionParts.join(', ')
        : 'Domicilio no especificado';

    final String localidadNombre = _getLocalidadNombre(paciente!.localidadId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const RevisionSectionHeader(
          titulo: 'Datos del Paciente',
          icono: Icons.person,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 16),

        // Nombre y documento
        Text(
          paciente!.nombreCompleto,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            Text(
              '${paciente!.tipoDocumento}: ${paciente!.documento}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${paciente!.edad} años',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Información de contacto
        RevisionItemCompacto(
          icono: Icons.phone,
          label: 'Teléfono',
          valor: paciente!.telefonoMovil ?? paciente!.telefonoFijo ?? 'Sin teléfono',
        ),
        if (paciente!.email != null && paciente!.email!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          RevisionItemCompacto(
            icono: Icons.email,
            label: 'Email',
            valor: paciente!.email!,
          ),
        ],

        const SizedBox(height: 12),

        // Dirección del domicilio
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.home, size: 20, color: AppColors.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Domicilio',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    direccionCompleta,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textPrimaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    localidadNombre,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeccionServicio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const RevisionSectionHeader(
          titulo: 'Información del Servicio',
          icono: Icons.medical_services,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),

        RevisionItemCompacto(
          icono: Icons.category,
          label: 'Tipo de Servicio',
          valor: motivoTraslado?.nombre ?? 'No seleccionado',
        ),
        const SizedBox(height: 10),
        RevisionItemCompacto(
          icono: Icons.calendar_today,
          label: 'Periodo',
          valor: fechaInicio != null
              ? fechaFin != null
                  ? '${DateFormat('dd/MM/yy').format(fechaInicio!)} - ${DateFormat('dd/MM/yy').format(fechaFin!)}'
                  : 'Desde ${DateFormat('dd/MM/yy').format(fechaInicio!)}'
              : 'No definido',
        ),
        if (observaciones != null && observaciones!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.notes, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Observaciones',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      observaciones!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _getLocalidadNombre(String? localidadId) {
    if (localidadId == null || localidadId.isEmpty) {
      return 'Localidad no especificada';
    }

    final LocalidadEntity? localidad = localidades.cast<LocalidadEntity?>().firstWhere(
      (LocalidadEntity? loc) => loc?.id == localidadId,
      orElse: () => null,
    );

    return localidad?.nombre ?? 'Localidad ID: $localidadId';
  }
}
