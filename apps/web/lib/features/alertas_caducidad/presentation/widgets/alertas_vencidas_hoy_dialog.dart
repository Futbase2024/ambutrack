import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_bloc.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_event.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/widgets/helpers/alerta_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Diálogo profesional de alertas vencidas hoy
///
/// Muestra un popup con todas las alertas cuya fecha de caducidad
/// es hoy o ya pasó. Cada alerta tiene:
/// - "Ver": navega directamente a la página de la entidad
/// - "Visto": marca como visto en BBDD y desaparece del popup
class AlertasVencidasHoyDialog extends StatefulWidget {
  const AlertasVencidasHoyDialog({required this.alertas, super.key});

  final List<AlertaCaducidadEntity> alertas;

  @override
  State<AlertasVencidasHoyDialog> createState() =>
      _AlertasVencidasHoyDialogState();
}

class _AlertasVencidasHoyDialogState extends State<AlertasVencidasHoyDialog> {
  late List<AlertaCaducidadEntity> _alertas;

  @override
  void initState() {
    super.initState();
    _alertas = List<AlertaCaducidadEntity>.from(widget.alertas);
  }

  void _marcarVisto(AlertaCaducidadEntity alerta) {
    context.read<AlertasCaducidadBloc>().add(
          AlertasCaducidadEvent.markAsViewed(
            alertaId: alerta.id,
            tipo: alerta.tipo,
            entidadId: alerta.entidadId,
          ),
        );
    setState(() {
      _alertas.removeWhere((AlertaCaducidadEntity a) => a.id == alerta.id);
    });
    if (_alertas.isEmpty && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _marcarTodoVisto() {
    for (final AlertaCaducidadEntity a in _alertas) {
      context.read<AlertasCaducidadBloc>().add(
            AlertasCaducidadEvent.markAsViewed(
              alertaId: a.id,
              tipo: a.tipo,
              entidadId: a.entidadId,
            ),
          );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _navegar(AlertaCaducidadEntity alerta) => abrirDestinoAlerta(context, alerta);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Container(
        width: 560,
        constraints: const BoxConstraints(maxHeight: 640),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _DialogHeader(vencidas: _alertas.length),
            const Divider(height: 1, color: AppColors.gray200),
            Flexible(
              child: _AlertasCardList(
                alertas: _alertas,
                onVer: _navegar,
                onMarcarVisto: _marcarVisto,
              ),
            ),
            if (_alertas.isNotEmpty) ...<Widget>[
              const Divider(height: 1, color: AppColors.gray200),
              _DialogFooter(
                onMarcarTodoVisto: _marcarTodoVisto,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header del diálogo con indicador de urgencia
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.vencidas});

  final int vencidas;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingXl,
        AppSizes.paddingXl,
        AppSizes.paddingXl,
        AppSizes.padding,
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 32,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  vencidas == 1
                      ? '1 Vencimiento Hoy'
                      : '$vencidas Vencimientos Hoy',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tienes documentos que requieren atención urgente',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer con acción masiva de marcar todo visto y cerrar
class _DialogFooter extends StatelessWidget {
  const _DialogFooter({required this.onMarcarTodoVisto});

  final VoidCallback onMarcarTodoVisto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingXl,
        AppSizes.padding,
        AppSizes.paddingXl,
        AppSizes.paddingXl,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gray700,
                side: const BorderSide(color: AppColors.gray300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.close, size: 18),
              label: Text(
                'Cerrar',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onMarcarTodoVisto,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(
                'Marcar todo visto',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista de tarjetas de alertas
class _AlertasCardList extends StatelessWidget {
  const _AlertasCardList({
    required this.alertas,
    required this.onVer,
    required this.onMarcarVisto,
  });

  final List<AlertaCaducidadEntity> alertas;
  final void Function(AlertaCaducidadEntity) onVer;
  final void Function(AlertaCaducidadEntity) onMarcarVisto;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppSizes.padding),
      itemCount: alertas.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < alertas.length - 1 ? AppSizes.spacing : 0,
          ),
          child: _AlertaCard(
            key: ValueKey<String>(alertas[index].id),
            alerta: alertas[index],
            onVer: onVer,
            onMarcarVisto: onMarcarVisto,
          ),
        );
      },
    );
  }
}

/// Tarjeta individual de alerta con acciones
class _AlertaCard extends StatelessWidget {
  const _AlertaCard({
    required this.alerta,
    required this.onVer,
    required this.onMarcarVisto,
    super.key,
  });

  final AlertaCaducidadEntity alerta;
  final void Function(AlertaCaducidadEntity) onVer;
  final void Function(AlertaCaducidadEntity) onMarcarVisto;

  @override
  Widget build(BuildContext context) {
    final Color severityColor = _getSeverityColor(alerta.diasRestantes);
    final String diasTexto = alerta.diasRestantes > 0
        ? 'Vence en ${alerta.diasRestantes} día${alerta.diasRestantes == 1 ? '' : 's'}'
        : alerta.diasRestantes == 0
            ? 'Vence hoy'
            : 'Vencido hace ${-alerta.diasRestantes} día${-alerta.diasRestantes == 1 ? '' : 's'}';

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
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: severityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusMedium),
                  bottomLeft: Radius.circular(AppSizes.radiusMedium),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildTopRow(context, severityColor, diasTexto),
                    const SizedBox(height: AppSizes.spacingSmall),
                    _buildEntityInfo(),
                    const SizedBox(height: AppSizes.spacing),
                    _buildActions(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(
    BuildContext context,
    Color severityColor,
    String diasTexto,
  ) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTipoColor(alerta.tipo).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Icon(
            _getTipoIcon(alerta.tipo),
            size: 18,
            color: _getTipoColor(alerta.tipo),
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          _getTipoLabel(alerta.tipo),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _getTipoColor(alerta.tipo),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: severityColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            diasTexto,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: severityColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntityInfo() {
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

  Widget _buildActions(BuildContext context) {
    return Row(
      children: <Widget>[
        _ActionButton(
          icon: Icons.open_in_new,
          label: 'Ver',
          color: AppColors.info,
          onPressed: () => onVer(alerta),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        _ActionButton(
          icon: Icons.visibility_off_outlined,
          label: 'Visto',
          color: AppColors.warning,
          onPressed: () => onMarcarVisto(alerta),
        ),
      ],
    );
  }

  Color _getSeverityColor(int diasRestantes) {
    if (diasRestantes <= 0) {
      return AppColors.error;
    }
    if (diasRestantes <= 3) {
      return AppColors.emergency;
    }
    if (diasRestantes <= 7) {
      return AppColors.error;
    }
    return AppColors.warning;
  }

  Color _getTipoColor(AlertaTipo tipo) {
    switch (tipo) {
      case AlertaTipo.seguro:
        return AppColors.info;
      case AlertaTipo.itv:
        return AppColors.warning;
      case AlertaTipo.homologacion:
        return AppColors.secondaryLight;
      case AlertaTipo.revisionTecnica:
        return AppColors.secondary;
      case AlertaTipo.mantenimiento:
        return AppColors.primary;
      case AlertaTipo.revision:
        return AppColors.success;
      case AlertaTipo.equipamiento:
        return AppColors.emergency;
    }
  }

  IconData _getTipoIcon(AlertaTipo tipo) {
    switch (tipo) {
      case AlertaTipo.seguro:
        return Icons.verified_user;
      case AlertaTipo.itv:
        return Icons.build;
      case AlertaTipo.homologacion:
        return Icons.description;
      case AlertaTipo.revisionTecnica:
        return Icons.handyman;
      case AlertaTipo.mantenimiento:
        return Icons.build_circle;
      case AlertaTipo.revision:
        return Icons.miscellaneous_services;
      case AlertaTipo.equipamiento:
        return Icons.medical_services;
    }
  }

  String _getTipoLabel(AlertaTipo tipo) {
    switch (tipo) {
      case AlertaTipo.seguro:
        return 'Seguro';
      case AlertaTipo.itv:
        return 'ITV';
      case AlertaTipo.homologacion:
        return 'Homologación';
      case AlertaTipo.revisionTecnica:
        return 'Revisión Técnica';
      case AlertaTipo.mantenimiento:
        return 'Mantenimiento';
      case AlertaTipo.revision:
        return 'Revisión';
      case AlertaTipo.equipamiento:
        return 'Equipamiento';
    }
  }
}

/// Botón de acción compacto con icono y texto
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
