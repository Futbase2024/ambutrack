import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Página de Perfil de Usuario
///
/// Muestra información del usuario autenticado y opciones de configuración.
class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  void _showLogoutConfirmation(BuildContext context) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Mostrar loading si está cargando
            if (state is AuthLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Si no está autenticado, mostrar mensaje
            if (state is! AuthAuthenticated) {
              return const Center(
                child: Text('No has iniciado sesión'),
              );
            }

            final user = state.user;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                // Avatar y nombre
                Center(
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(
                                _getInitials(user.nombreCompleto ?? user.email),
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.nombreCompleto ?? 'Usuario',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      if (user.rol != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.rol!.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Información
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Información',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: user.email,
                        ),
                        if (user.nombreCompleto != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.person,
                            label: 'Nombre',
                            value: user.nombreCompleto!,
                          ),
                        ],
                        if (user.rol != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.badge,
                            label: 'Rol',
                            value: user.rol!,
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.fingerprint,
                          label: 'ID',
                          value: user.id.substring(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Opciones
                Card(
                  child: Column(
                    children: <Widget>[
                      _buildOption(
                        icon: Icons.schedule,
                        title: 'Mis Horarios',
                        onTap: () {
                          // TODO: Ver horarios
                        },
                      ),
                      const Divider(height: 1),
                      _buildOption(
                        icon: Icons.history,
                        title: 'Historial de Servicios',
                        onTap: () {
                          // TODO: Ver historial
                        },
                      ),
                      const Divider(height: 1),
                      _buildOption(
                        icon: Icons.settings,
                        title: 'Configuración',
                        onTap: () {
                          // TODO: Abrir configuración
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cerrar sesión
                Card(
                  child: _buildOption(
                    icon: Icons.logout,
                    title: 'Cerrar Sesión',
                    textColor: AppColors.error,
                    onTap: () => _showLogoutConfirmation(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: AppColors.textSecondaryLight),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
