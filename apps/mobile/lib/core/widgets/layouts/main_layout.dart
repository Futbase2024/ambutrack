import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../theme/app_colors.dart';

/// Layout principal de AmbuTrack Mobile
///
/// Proporciona AppBar con Drawer de navegación y logout
class MainLayout extends StatelessWidget {
  const MainLayout({
    required this.child,
    required this.isHomePage,
    required this.currentLocation,
    super.key,
  });

  final Widget child;
  final bool isHomePage;
  final String currentLocation;

  String _getPageTitle() {
    debugPrint('📍 [MainLayout] Obteniendo título para: $currentLocation');
    switch (currentLocation) {
      case '/':
        return 'AmbuTrack';
      case '/registro-horario':
        return 'Registro Horario';
      case '/checklist-ambulancia':
        return 'Checklist Ambulancia';
      case '/partes-diarios':
        return 'Partes Diarios';
      case '/incidencias':
        return 'Incidencias';
      case '/perfil':
        return 'Mi Perfil';
      default:
        return 'AmbuTrack';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('📍 [MainLayout] Build - Ubicación: $currentLocation, isHomePage: $isHomePage');

    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        actions: <Widget>[
          // Botón de logout rápido
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      drawer: isHomePage ? _buildDrawer(context) : null,
      body: SafeArea(child: child),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const SizedBox.shrink();
          }

          final user = state.user;

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Header con datos del usuario
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          _getInitials(user.nombreCompleto ?? user.email),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                accountName: Text(
                  user.nombreCompleto ?? 'Usuario',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                accountEmail: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(user.email),
                    if (user.rol != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.rol!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Navegación
              _buildDrawerItem(
                context,
                icon: Icons.dashboard,
                title: 'Dashboard',
                route: '/',
                isSelected: currentLocation == '/',
              ),
              _buildDrawerItem(
                context,
                icon: Icons.schedule,
                title: 'Registro Horario',
                route: '/registro-horario',
                isSelected: currentLocation == '/registro-horario',
              ),
              _buildDrawerItem(
                context,
                icon: Icons.checklist,
                title: 'Checklist Ambulancia',
                route: '/checklist-ambulancia',
                isSelected: currentLocation == '/checklist-ambulancia',
              ),
              _buildDrawerItem(
                context,
                icon: Icons.assignment,
                title: 'Partes Diarios',
                route: '/partes-diarios',
                isSelected: currentLocation == '/partes-diarios',
              ),
              _buildDrawerItem(
                context,
                icon: Icons.warning_amber,
                title: 'Incidencias',
                route: '/incidencias',
                isSelected: currentLocation == '/incidencias',
              ),
              const Divider(),
              _buildDrawerItem(
                context,
                icon: Icons.person,
                title: 'Mi Perfil',
                route: '/perfil',
                isSelected: currentLocation == '/perfil',
              ),
              const Divider(),

              // Logout
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context); // Cerrar drawer
                  _showLogoutDialog(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
      onTap: () {
        Navigator.pop(context); // Cerrar drawer
        context.go(route);
      },
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
