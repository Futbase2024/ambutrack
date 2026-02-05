import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/menu/presentation/widgets/app_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppBar personalizado con menú integrado para AmbuTrack
///
/// Proporciona un AppBar con el menú de navegación integrado que se adapta
/// a diferentes tamaños de pantalla y mantiene la funcionalidad de tabs.
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
    double height = 120; // Altura para dos filas: título (60) + menú (60)
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Material(
      child: SafeArea(
        bottom: false,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color.fromRGBO(30, 64, 175, 0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Primera fila: Título e iconos de acción
              SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: <Widget>[
                      // Hamburger menu solo en móvil
                      if (!isWideScreen) ...<Widget>[
                        IconButton(
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: AppColors.backgroundLight,
                            size: 24,
                          ),
                          onPressed: () {
                            // TODO(team): Implementar drawer móvil
                          },
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Título centrado con indicador de flavor
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                title ?? F.title,
                                style: GoogleFonts.inter(
                                  fontSize: isWideScreen ? 20 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.backgroundLight,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (F.appFlavor == Flavor.dev) ...<Widget>[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: const <BoxShadow>[
                                      BoxShadow(
                                        color: Color.fromRGBO(251, 191, 36, 0.4),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'DEV',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.backgroundDark,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Sección derecha: Configuración + Notificaciones + Usuario
                      if (isWideScreen) ...<Widget>[
                        _buildConfigurationButton(context),
                        const SizedBox(width: 12),
                        _buildNotificationButton(context),
                        const SizedBox(width: 12),
                        _buildUserButton(context, isWideScreen),
                      ] else ...<Widget>[
                        _buildNotificationButton(context),
                        const SizedBox(width: 8),
                        _buildUserButton(context, isWideScreen),
                      ],
                    ],
                  ),
                ),
              ),

              // Segunda fila: Menú de navegación (solo en pantallas grandes)
              if (isWideScreen)
                SizedBox(
                  height: 60,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.backgroundLight.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: const AppMenu(),
                  ),
                ),

              // TabBar si existe
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }

  /// Botón de configuración
  Widget _buildConfigurationButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          context.go('/configuracion');
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.backgroundLight.withValues(alpha: 0.2),
            ),
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: AppColors.backgroundLight,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Botón de notificaciones
  Widget _buildNotificationButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          // TODO(team): Implementar panel de notificaciones
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: AppColors.backgroundLight.withValues(alpha: 0.2),
                    ),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.backgroundLight,
                size: 20,
              ),
            ),
            // Badge de notificaciones
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: AppColors.emergency,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.backgroundLight,
                    width: 1.5,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color.fromRGBO(220, 38, 38, 0.4),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '3',
                  style: GoogleFonts.inter(
                    color: AppColors.backgroundLight,
                    fontSize: 9,
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
            elevation: 16.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
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
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondaryLight,
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
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.0),
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
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: '/configuracion/cuenta',
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.manage_accounts_outlined,
                        color: AppColors.info,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Configuración de Cuenta',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimaryLight,
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
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.emergency.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.0),
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
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: AppColors.backgroundLight.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.backgroundLight,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
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
                          color: AppColors.backgroundLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.backgroundLight,
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