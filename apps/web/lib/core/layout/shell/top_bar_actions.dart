import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_bloc.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_state.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_bloc.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_state.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/widgets/notificaciones_panel.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Botón compacto de la barra superior (32x32)
class TopBarIconButton extends StatelessWidget {
  const TopBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = AppColors.gray600,
    this.badge,
    this.badgeColor = AppColors.error,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;
  final int? badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: AppColors.gray100,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              Icon(icon, size: 19, color: color),
              if (badge != null && badge! > 0)
                Positioned(
                  top: 3,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      badge! > 9 ? '9+' : '$badge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Notificaciones + alertas críticas de caducidad (mismo panel que antes)
class TopBarNotificaciones extends StatelessWidget {
  const TopBarNotificaciones({super.key});

  void _abrirPanel(BuildContext context) {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final Offset pos = box.localToGlobal(Offset.zero);
    final NotificacionBloc notifBloc = context.read<NotificacionBloc>();
    final StockEquipamientoBloc stockBloc = context.read<StockEquipamientoBloc>();
    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext ctx) => Stack(
        children: <Widget>[
          Positioned(
            left: pos.dx - 380 + box.size.width,
            top: pos.dy + box.size.height + 6,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 380,
                height: 500,
                child: MultiBlocProvider(
                  providers: <BlocProvider<dynamic>>[
                    BlocProvider<NotificacionBloc>.value(value: notifBloc),
                    BlocProvider<StockEquipamientoBloc>.value(value: stockBloc),
                  ],
                  child: const NotificacionesPanel(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertasCaducidadBloc, AlertasCaducidadState>(
      builder: (BuildContext context, AlertasCaducidadState alertas) {
        final int criticas = alertas.maybeWhen(
          loaded: (List<AlertaCaducidadEntity> a, _, _, _, _) =>
              a.where((AlertaCaducidadEntity x) => x.esCritica == true).length,
          orElse: () => 0,
        );
        return BlocBuilder<NotificacionBloc, NotificacionState>(
          builder: (BuildContext context, NotificacionState notif) {
            final int noLeidas = notif.whenOrNull(loaded: (List<NotificacionEntity> _, int c) => c) ?? 0;
            return Builder(
              builder: (BuildContext btnContext) => TopBarIconButton(
                icon: criticas > 0 ? Icons.warning_amber_rounded : Icons.notifications_none,
                color: criticas > 0 ? AppColors.warning : AppColors.gray600,
                tooltip: 'Notificaciones y alertas',
                badge: noLeidas + criticas,
                badgeColor: criticas > 0 ? AppColors.warning : AppColors.error,
                onTap: () => _abrirPanel(btnContext),
              ),
            );
          },
        );
      },
    );
  }
}

/// Avatar con iniciales + menú de usuario (perfil, configuración, cerrar sesión)
class TopBarUsuario extends StatelessWidget {
  const TopBarUsuario({super.key});

  static String _iniciales(String nombre) {
    final List<String> p = nombre.trim().split(RegExp(r'\s+')).where((String s) => s.isNotEmpty).toList();
    if (p.isEmpty) {
      return '?';
    }
    return (p.length == 1 ? p.first.substring(0, 1) : '${p[0][0]}${p[1][0]}').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState state) {
        final String nombre = state is AuthAuthenticated
            ? (state.user.displayName ?? state.user.email.split('@').first)
            : 'Usuario';
        final String email = state is AuthAuthenticated ? state.user.email : '';
        return PopupMenuButton<String>(
          tooltip: nombre,
          offset: const Offset(0, 40),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.gray200),
          ),
          onSelected: (String v) {
            if (v == '/logout') {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go('/login');
            } else {
              context.go(v);
            }
          },
          itemBuilder: (BuildContext _) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              enabled: false,
              height: 44,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                  Text(email, style: const TextStyle(fontSize: 11.5, color: AppColors.gray500)),
                ],
              ),
            ),
            const PopupMenuDivider(height: 1),
            const _UserMenuItem(value: '/perfil', icon: Icons.person_outline, label: 'Mi perfil'),
            const _UserMenuItem(value: '/configuracion', icon: Icons.settings_outlined, label: 'Configuración'),
            const PopupMenuDivider(height: 1),
            const _UserMenuItem(value: '/logout', icon: Icons.logout, label: 'Cerrar sesión', danger: true),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _iniciales(nombre),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.expand_more, size: 16, color: AppColors.gray500),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UserMenuItem extends PopupMenuItem<String> {
  const _UserMenuItem({
    required String super.value,
    required this.icon,
    required this.label,
    this.danger = false,
  }) : super(height: 38, child: null);

  final IconData icon;
  final String label;
  final bool danger;

  @override
  Widget? get child => Row(
        children: <Widget>[
          Icon(icon, size: 17, color: danger ? AppColors.error : AppColors.gray600),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 13, color: danger ? AppColors.error : AppColors.gray800)),
        ],
      );
}
