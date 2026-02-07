import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Página Home de AmbuTrack Mobile
///
/// Dashboard principal para personal de campo.
class HomeAndroidPage extends StatelessWidget {
  const HomeAndroidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Mostrar loading si está verificando
            if (state is AuthInitial || state is AuthLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Si no está autenticado
            if (state is! AuthAuthenticated) {
              return const Center(
                child: Text('No autenticado'),
              );
            }

            final user = state.user;
            final personal = state.personal;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta del usuario
                  _buildUserCard(user, personal),

                  const SizedBox(height: 24),

                  // Título de sección
                  Text(
                    'Funcionalidades',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cuadrícula de botones de funcionalidades
                  _buildFunctionalityGrid(context),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
    );
  }

  /// Cuadrícula de funcionalidades principales
  Widget _buildFunctionalityGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildFunctionalityCard(
          context: context,
          emoji: '⏰',
          title: 'Registro Horario',
          onTap: () {
            context.push('/registro-horario');
          },
        ),
        _buildFunctionalityCard(
          context: context,
          emoji: '🚑',
          title: 'Servicios',
          onTap: () {
            context.push('/servicios');
          },
        ),
        _buildFunctionalityCard(
          context: context,
          emoji: '📄',
          title: 'Trámites',
          onTap: () {
            context.push('/tramites');
          },
        ),
        _buildFunctionalityCard(
          context: context,
          emoji: '➕',
          title: 'Más',
          onTap: () {
            // TODO: Mostrar más opciones
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Más funciones - Próximamente'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Tarjeta individual de funcionalidad
  Widget _buildFunctionalityCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Icono - 80% del espacio
              Expanded(
                flex: 80,
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // El icono ocupará el 70% del espacio disponible
                      final iconSize = constraints.maxHeight * 0.7;
                      return FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          emoji,
                          style: TextStyle(
                            fontSize: iconSize,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Título - 20% del espacio
              Expanded(
                flex: 20,
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tarjeta con información del usuario
  Widget _buildUserCard(user, personal) {
    // Usar datos de tpersonal si están disponibles, sino usar datos de auth
    final nombreCompleto = personal?.nombreCompleto ?? user.nombreCompleto ?? 'Usuario';
    final categoria = personal?.categoria;
    final dni = personal?.dni;

    return Card(
      elevation: 1,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                nombreCompleto.isNotEmpty
                    ? nombreCompleto[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre completo
                  Text(
                    nombreCompleto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Categoría/DNI
                  if (categoria != null || dni != null)
                    Text(
                      [
                        if (categoria != null) _getCategoriaDisplay(categoria),
                        if (dni != null) 'DNI: $dni',
                      ].join(' • '),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      _getRolDisplay(user.rol),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formatea la categoría del personal para mostrar de forma legible
  String _getCategoriaDisplay(String? categoria) {
    if (categoria == null || categoria.isEmpty) {
      return 'Sin categoría';
    }
    return categoria;
  }

  /// Formatea el rol del usuario para mostrar de forma legible
  String _getRolDisplay(String? rol) {
    if (rol == null || rol.isEmpty) {
      return 'Sin puesto asignado';
    }

    switch (rol.toLowerCase()) {
      case 'tecnico':
      case 'tes':
        return 'Técnico en Emergencias Sanitarias';
      case 'conductor':
        return 'Conductor de Ambulancia';
      case 'admin':
      case 'administrador':
        return 'Administrador';
      case 'enfermero':
        return 'Enfermero/a';
      case 'medico':
        return 'Médico/a';
      default:
        return rol;
    }
  }
}
