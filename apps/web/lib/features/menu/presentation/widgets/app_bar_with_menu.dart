import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_bloc.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_state.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/menu/presentation/widgets/app_menu.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_bloc.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_state.dart';
import 'package:ambutrack_web/features/notificaciones/presentation/widgets/notificaciones_panel.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// Decorations constantes para reutilización
const BoxDecoration _kAppBarHeaderDecoration = BoxDecoration(
  color: AppColors.backgroundLight,
  border: Border(
    bottom: BorderSide(
      color: AppColors.gray200,
    ),
  ),
  boxShadow: <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ],
);

/// AppBar personalizado con menú integrado para AmbuTrack
///
/// Proporciona un AppBar moderno con:
/// - Logo/título a la izquierda
/// - Menú de navegación horizontal
/// - Iconos de configuración, notificaciones y perfil a la derecha
class AppBarWithMenu extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWithMenu({
    super.key,
    this.title,
    this.bottom,
  });

  final String? title;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize {
    double height = 64; // Altura del header
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 1024;

    return Material(
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header principal con fondo blanco
            Container(
              height: 64,
              decoration: _kAppBarHeaderDecoration,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: <Widget>[
                    // Logo y título a la izquierda
                    _buildLogoSection(isWideScreen),
                    const SizedBox(width: 32),

                    // Menú de navegación horizontal (solo en desktop)
                    if (isWideScreen)
                      const Expanded(
                        child: AppMenu(),
                      ),

                    // Espaciador
                    if (isWideScreen) const SizedBox(width: 32),

                    // Acciones a la derecha
                    if (isWideScreen) ...<Widget>[
                      _buildConfigurationButton(context),
                      const SizedBox(width: 12),
                      _buildNotificationButton(context),
                      const SizedBox(width: 12),
                      _buildUserButton(context, isWideScreen),
                    ] else ...<Widget>[
                      const Spacer(),
                      _buildNotificationButton(context),
                      const SizedBox(width: 8),
                      _buildUserButton(context, isWideScreen),
                    ],
                  ],
                ),
              ),
            ),

            // TabBar si existe
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }

  /// Sección del logo y título
  Widget _buildLogoSection(bool isWideScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Icono de ambulancia como logo
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // Título de la app
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'AmbuTrack',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
                letterSpacing: -0.5,
              ),
            ),
            if (F.appFlavor == Flavor.dev)
              Text(
                'DEV',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Botón de configuración
  Widget _buildConfigurationButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.go('/configuracion');
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gray200,
            ),
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: AppColors.gray600,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Botón de notificaciones (incluye alertas críticas)
  Widget _buildNotificationButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState authState) {
        if (authState is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<AlertasCaducidadBloc, AlertasCaducidadState>(
          builder: (BuildContext context, AlertasCaducidadState alertasState) {
            int alertasCriticasCount = 0;
            alertasState.maybeWhen(
              loaded: (List<AlertaCaducidadEntity> alertas, _, _, _, _) {
                alertasCriticasCount = alertas.where((AlertaCaducidadEntity a) => a.esCritica == true).length;
              },
              orElse: () {},
            );

            return BlocBuilder<NotificacionBloc, NotificacionState>(
              builder: (BuildContext context, NotificacionState notifState) {
                int conteoNoLeidas = 0;
                notifState.whenOrNull(
                  loaded: (List<NotificacionEntity> notificaciones, int conteo) {
                    conteoNoLeidas = conteo;
                  },
                );

                // Conteo combinado: notificaciones no leídas + alertas críticas
                final int conteoTotal = conteoNoLeidas + alertasCriticasCount;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _mostrarPanelNotificaciones(context);
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.gray100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.gray200,
                            ),
                          ),
                          child: Icon(
                            // Cambiar icono si hay alertas críticas
                            alertasCriticasCount > 0
                                ? Icons.warning_amber_rounded
                                : Icons.notifications_outlined,
                            color: alertasCriticasCount > 0
                                ? AppColors.warning
                                : AppColors.gray600,
                            size: 20,
                          ),
                        ),
                        // Badge combinado
                        if (conteoTotal > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: alertasCriticasCount > 0
                                    ? AppColors.warning
                                    : AppColors.emergency,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.backgroundLight,
                                  width: 1.5,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                conteoTotal > 9 ? '9+' : '$conteoTotal',
                                style: GoogleFonts.inter(
                                  color: AppColors.backgroundLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Muestra el panel de notificaciones como un diálogo
  void _mostrarPanelNotificaciones(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    final Size size = button.size;

    // Capturar los blocs antes de showDialog para pasarlos al nuevo contexto
    final NotificacionBloc notificacionBloc = context.read<NotificacionBloc>();
    final StockEquipamientoBloc stockBloc = context.read<StockEquipamientoBloc>();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return GestureDetector(
          onTap: () => Navigator.of(dialogContext).pop(), // Cerrar al tocar fuera
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero, // Sin padding para posicionamiento absoluto
            child: GestureDetector(
              onTap: () {}, // Evitar que clics dentro cierren el diálogo
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: offset.dx - 380 + size.width,
                    top: offset.dy + size.height + 8,
                    child: Material(
                      elevation: 16,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 380,
                        height: 500,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        // Proporcionar los blocs al diálogo usando BlocProvider.value
                        child: MultiBlocProvider(
                          providers: <BlocProvider<dynamic>>[
                            BlocProvider<NotificacionBloc>.value(value: notificacionBloc),
                            BlocProvider<StockEquipamientoBloc>.value(value: stockBloc),
                          ],
                          child: const NotificacionesPanel(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Botón de usuario con nombre
  Widget _buildUserButton(BuildContext context, bool isWideScreen) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState state) {
        String userName = 'Usuario';
        String userEmail = '';

        if (state is AuthAuthenticated) {
          userName = state.user.displayName ?? state.user.email.split('@').first;
          userEmail = state.user.email;
        }

        return Material(
          color: Colors.transparent,
          child: PopupMenuButton<String>(
            elevation: 16,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.backgroundLight,
            onSelected: (String route) {
              if (route == '/logout') {
                // Ejecutar logout y navegar a login
                context.read<AuthBloc>().add(const AuthLogoutRequested());
                context.go('/login');
              } else {
                context.go(route);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              // Header con info del usuario
              PopupMenuItem<String>(
                enabled: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem<String>(
                value: '/perfil',
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Mi Perfil',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem<String>(
                value: '/logout',
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.emergency.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout_outlined,
                        color: AppColors.emergency,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cerrar Sesión',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gray200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.person,
                      color: AppColors.backgroundLight,
                      size: 18,
                    ),
                  ),
                  if (isWideScreen) ...<Widget>[
                    const SizedBox(width: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        userName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.gray600,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}