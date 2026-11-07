import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_bloc.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_event.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/widgets/notificacion_tipo_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Muestra un diálogo con todas las notificaciones pendientes (no leídas).
///
/// Cada notificación tiene acciones:
/// - "Visto": marca como leída individualmente
/// - "Ver": marca como leída y navega a la página correspondiente
Future<void> showNotificacionesPendientesDialog({
  required BuildContext context,
  required List<NotificacionEntity> notificaciones,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => _NotificacionesPendientesContent(
      notificaciones: notificaciones,
    ),
  );
}

/// Contenido del diálogo de notificaciones pendientes
class _NotificacionesPendientesContent extends StatefulWidget {
  const _NotificacionesPendientesContent({required this.notificaciones});

  final List<NotificacionEntity> notificaciones;

  @override
  State<_NotificacionesPendientesContent> createState() =>
      _NotificacionesPendientesContentState();
}

class _NotificacionesPendientesContentState
    extends State<_NotificacionesPendientesContent> {
  late List<NotificacionEntity> _pendientes;

  @override
  void initState() {
    super.initState();
    _pendientes = List<NotificacionEntity>.from(widget.notificaciones);
  }

  void _marcarVisto(NotificacionEntity notificacion) {
    context.read<NotificacionBloc>().add(
          NotificacionEvent.marcarComoLeida(notificacion.id),
        );
    setState(() {
      _pendientes.removeWhere((NotificacionEntity n) => n.id == notificacion.id);
    });
    if (_pendientes.isEmpty && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _marcarTodoVisto() {
    for (final NotificacionEntity n in _pendientes) {
      context.read<NotificacionBloc>().add(
            NotificacionEvent.marcarComoLeida(n.id),
          );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 560),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            _PendientesHeader(cantidad: _pendientes.length),
            const Divider(height: 1, color: AppColors.gray200),
            Flexible(
              child: _PendientesLista(
                pendientes: _pendientes,
                onVisto: _marcarVisto,
              ),
            ),
            if (_pendientes.isNotEmpty) ...<Widget>[
              const Divider(height: 1, color: AppColors.gray200),
              _PendientesFooter(onMarcarTodoVisto: _marcarTodoVisto),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header del diálogo
class _PendientesHeader extends StatelessWidget {
  const _PendientesHeader({required this.cantidad});

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
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              size: AppSizes.iconLarge,
              color: AppColors.primary,
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
                      ? '1 notificación pendiente'
                      : '$cantidad notificaciones pendientes',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMedium,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tienes avisos sin revisar',
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

/// Lista scrollable de notificaciones pendientes
class _PendientesLista extends StatelessWidget {
  const _PendientesLista({
    required this.pendientes,
    required this.onVisto,
  });

  final List<NotificacionEntity> pendientes;
  final void Function(NotificacionEntity) onVisto;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppSizes.padding),
      itemCount: pendientes.length,
      itemBuilder: (BuildContext context, int index) {
        final NotificacionEntity notif = pendientes[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < pendientes.length - 1 ? AppSizes.spacing : 0,
          ),
          child: _NotificacionPendienteCard(
            key: ValueKey<String>(notif.id),
            notificacion: notif,
            onVisto: () => onVisto(notif),
          ),
        );
      },
    );
  }
}

/// Tarjeta individual de notificación pendiente
class _NotificacionPendienteCard extends StatelessWidget {
  const _NotificacionPendienteCard({
    required this.notificacion,
    required this.onVisto,
    super.key,
  });

  final NotificacionEntity notificacion;
  final VoidCallback onVisto;

  @override
  Widget build(BuildContext context) {
    final NotificacionTipoConfig config = getNotificacionTipoConfig(notificacion.tipo);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: config.color,
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
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(AppSizes.spacingSmall),
                          decoration: BoxDecoration(
                            color: config.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Icon(
                            config.icon,
                            size: AppSizes.iconMedium,
                            color: config.color,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacingSmall),
                        Flexible(
                          child: Text(
                            config.label,
                            style: GoogleFonts.inter(
                              fontSize: AppSizes.fontXs,
                              fontWeight: FontWeight.w600,
                              color: config.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      notificacion.titulo,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notificacion.mensaje.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        notificacion.mensaje,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.gray600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSizes.spacing),
                    Row(
                      children: <Widget>[
                        TextButton(
                          onPressed: onVisto,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.spacingSmall,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              side: BorderSide(
                                color: AppColors.warning.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(Icons.visibility_off_outlined, size: 15),
                              const SizedBox(width: AppSizes.spacingXs),
                              Text(
                                'Visto',
                                style: GoogleFonts.inter(
                                  fontSize: AppSizes.fontXs,
                                  fontWeight: FontWeight.w600,
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
            ),
          ],
        ),
      ),
    );
  }
}

/// Footer con botones Cerrar y Marcar todo visto
class _PendientesFooter extends StatelessWidget {
  const _PendientesFooter({required this.onMarcarTodoVisto});

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
                backgroundColor: AppColors.primary,
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
