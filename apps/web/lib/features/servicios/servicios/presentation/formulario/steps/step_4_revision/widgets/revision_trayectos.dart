import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/theme/app_sizes.dart';
import '../../../models/trayecto_data.dart';
import 'revision_section_header.dart';

/// Sección de revisión de trayectos
///
/// Muestra la lista de trayectos configurados en el Step 3
class RevisionTrayectos extends StatelessWidget {
  const RevisionTrayectos({
    required this.trayectos,
    super.key,
  });

  final List<TrayectoData> trayectos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RevisionSectionHeader(
          titulo: 'Trayectos',
          icono: Icons.route,
          color: AppColors.info,
          subtitle: '${trayectos.length} configurado${trayectos.length != 1 ? 's' : ''}',
        ),
        const SizedBox(height: 16),

        if (trayectos.isEmpty)
          _buildEmpty()
        else
          _buildTrayectos(context),
      ],
    );
  }

  Widget _buildEmpty() {
    return Text(
      'No hay trayectos configurados',
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondaryLight,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildTrayectos(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List<Widget>.generate(
        trayectos.length,
        (int index) {
          final TrayectoData trayecto = trayectos[index];
          return Container(
            margin: EdgeInsets.only(
              bottom: index < trayectos.length - 1 ? 10 : 0,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSizes.radius),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildTrayectoHeader(context, index, trayecto),
                const SizedBox(height: 10),
                _buildTrayectoRuta(trayecto),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrayectoHeader(BuildContext context, int index, TrayectoData trayecto) {
    return Row(
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.info,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Trayecto ${index + 1}',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        if (trayecto.hora != null) ...<Widget>[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.access_time, size: 16, color: AppColors.warning),
                const SizedBox(width: 6),
                Text(
                  trayecto.hora!.format(context),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrayectoRuta(TrayectoData trayecto) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'ORIGEN',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                trayecto.origenDisplay ?? 'Sin origen',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, size: 20, color: AppColors.info),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'DESTINO',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                trayecto.destinoDisplay ?? 'Sin destino',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
