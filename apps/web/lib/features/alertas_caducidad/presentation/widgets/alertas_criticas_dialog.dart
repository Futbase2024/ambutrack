import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_bloc.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_event.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/widgets/alertas_dialogo_inicial.dart' show AlertasDialogoInicial;
import 'package:ambutrack_web/features/alertas_caducidad/presentation/widgets/alertas_vencidas_hoy_dialog.dart' show AlertasVencidasHoyDialog;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'alerta_critica_card.dart';
import 'alerta_detalle_dialog.dart';

/// Diálogo principal de alertas críticas con acciones por item.
///
/// Reemplaza a [AlertasDialogoInicial] y [AlertasVencidasHoyDialog].
/// Cada alerta se muestra como una tarjeta diferenciada con acciones:
/// - "Ver": abre un sub-diálogo con el detalle completo de esa alerta
/// - "Visto": marca la alerta como vista (no vuelve a salir hoy)
class AlertasCriticasDialog extends StatefulWidget {
  const AlertasCriticasDialog({
    required this.alertas,
    super.key,
  });

  final List<AlertaCaducidadEntity> alertas;

  @override
  State<AlertasCriticasDialog> createState() => _AlertasCriticasDialogState();
}

class _AlertasCriticasDialogState extends State<AlertasCriticasDialog> {
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

  void _verDetalle(AlertaCaducidadEntity alerta) {
    showAlertaDetalleDialog(
      context: context,
      alerta: alerta,
      onMarcarVisto: () => _marcarVisto(alerta),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Container(
        width: 560,
        constraints: const BoxConstraints(maxHeight: 640),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AlertasCriticasHeader(cantidad: _alertas.length),
            const Divider(height: 1, color: AppColors.gray200),
            Flexible(
              child: _AlertasLista(
                alertas: _alertas,
                onVer: _verDetalle,
                onMarcarVisto: _marcarVisto,
              ),
            ),
            if (_alertas.isNotEmpty) ...<Widget>[
              const Divider(height: 1, color: AppColors.gray200),
              AlertasCriticasFooter(onMarcarTodoVisto: _marcarTodoVisto),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lista scrollable de tarjetas de alertas
class _AlertasLista extends StatelessWidget {
  const _AlertasLista({
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
          child: AlertaCriticaCard(
            key: ValueKey<String>(alertas[index].id),
            alerta: alertas[index],
            onVer: () => onVer(alertas[index]),
            onMarcarVisto: () => onMarcarVisto(alertas[index]),
          ),
        );
      },
    );
  }
}

/// Header del diálogo con indicador de urgencia
class AlertasCriticasHeader extends StatelessWidget {
  const AlertasCriticasHeader({required this.cantidad, super.key});

  final int cantidad;

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
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.emergency.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: AppSizes.iconXl,
              color: AppColors.emergency,
            ),
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  cantidad == 1
                      ? '1 alerta requiere atención'
                      : '$cantidad alertas requieren atención',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMedium,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Documentos y elementos que caducan pronto',
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

/// Footer con botón de cerrar y marcar todo visto
class AlertasCriticasFooter extends StatelessWidget {
  const AlertasCriticasFooter({required this.onMarcarTodoVisto, super.key});

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
                padding: const EdgeInsets.symmetric(vertical: AppSizes.padding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.close, size: AppSizes.iconMedium),
              label: Text(
                'Cerrar',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
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
                padding: const EdgeInsets.symmetric(vertical: AppSizes.padding),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.done_all, size: AppSizes.iconMedium),
              label: Text(
                'Marcar todo visto',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
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
