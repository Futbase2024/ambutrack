import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'helpers/alerta_helpers.dart';

/// Tarjeta individual de alerta crítica con acciones Ver y Visto
class AlertaCriticaCard extends StatelessWidget {
  const AlertaCriticaCard({
    required this.alerta,
    required this.onVer,
    required this.onMarcarVisto,
    super.key,
  });

  final AlertaCaducidadEntity alerta;
  final VoidCallback onVer;
  final VoidCallback onMarcarVisto;

  @override
  Widget build(BuildContext context) {
    final Color severityColor = getDiasRestantesColor(alerta.diasRestantes);
    final AlertaTipoConfig tipoConfig = getAlertaTipoConfig(alerta.tipo);
    final String diasTexto = getDiasRestantesText(alerta.diasRestantes);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.3),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            _SeverityBar(color: severityColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AlertaTopRow(
                      tipoConfig: tipoConfig,
                      severityColor: severityColor,
                      diasTexto: diasTexto,
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    AlertaEntityInfo(alerta: alerta),
                    const SizedBox(height: AppSizes.spacing),
                    AlertaActionsRow(
                      onVer: onVer,
                      onMarcarVisto: onMarcarVisto,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra lateral de color según severidad
class _SeverityBar extends StatelessWidget {
  const _SeverityBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusMedium),
          bottomLeft: Radius.circular(AppSizes.radiusMedium),
        ),
      ),
    );
  }
}

/// Fila superior con icono de tipo y badge de días
class AlertaTopRow extends StatelessWidget {
  const AlertaTopRow({
    required this.tipoConfig,
    required this.severityColor,
    required this.diasTexto,
    super.key,
  });

  final AlertaTipoConfig tipoConfig;
  final Color severityColor;
  final String diasTexto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.spacingSmall),
          decoration: BoxDecoration(
            color: tipoConfig.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Icon(
            tipoConfig.icon,
            size: AppSizes.iconMedium,
            color: tipoConfig.color,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Flexible(
          child: Text(
            tipoConfig.label,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
              color: tipoConfig.color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        AlertaDiasBadge(
          color: severityColor,
          texto: diasTexto,
        ),
      ],
    );
  }
}

/// Badge de días restantes con color de urgencia
class AlertaDiasBadge extends StatelessWidget {
  const AlertaDiasBadge({
    required this.color,
    required this.texto,
    super.key,
  });

  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        texto,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Información de entidad (nombre y fecha de caducidad)
class AlertaEntityInfo extends StatelessWidget {
  const AlertaEntityInfo({required this.alerta, super.key});

  final AlertaCaducidadEntity alerta;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          alerta.entidadNombre,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'Caduca: ${DateFormat('dd/MM/yyyy').format(alerta.fechaCaducidad)}',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }
}

/// Fila de acciones Ver y Visto
class AlertaActionsRow extends StatelessWidget {
  const AlertaActionsRow({
    required this.onVer,
    required this.onMarcarVisto,
    super.key,
  });

  final VoidCallback onVer;
  final VoidCallback onMarcarVisto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        AlertaActionButton(
          icon: Icons.open_in_new,
          label: 'Ver',
          color: AppColors.info,
          onPressed: onVer,
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        AlertaActionButton(
          icon: Icons.visibility_off_outlined,
          label: 'Visto',
          color: AppColors.warning,
          onPressed: onMarcarVisto,
        ),
      ],
    );
  }
}

/// Botón de acción compacto reutilizable
class AlertaActionButton extends StatelessWidget {
  const AlertaActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingSmall,
          vertical: 6,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15),
          const SizedBox(width: AppSizes.spacingXs),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
