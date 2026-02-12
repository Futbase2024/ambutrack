import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../registro_horario/presentation/bloc/registro_horario_bloc.dart';
import '../../../registro_horario/presentation/bloc/registro_horario_event.dart';
import '../../../registro_horario/presentation/bloc/registro_horario_state.dart';

/// Página Home de AmbuTrack Mobile
///
/// Dashboard principal para personal de campo.
class HomeAndroidPage extends StatefulWidget {
  const HomeAndroidPage({super.key});

  @override
  State<HomeAndroidPage> createState() => _HomeAndroidPageState();
}

class _HomeAndroidPageState extends State<HomeAndroidPage> {
  @override
  void initState() {
    super.initState();
    // Cargar el estado del turno al iniciar
    context.read<RegistroHorarioBloc>().add(const CargarRegistrosHorario());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // Mostrar loading si está verificando
          if (authState is AuthInitial || authState is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Si no está autenticado
          if (authState is! AuthAuthenticated) {
            return const Center(
              child: Text('No autenticado'),
            );
          }

          final user = authState.user;
          final personal = authState.personal;

          return BlocBuilder<RegistroHorarioBloc, RegistroHorarioState>(
            builder: (context, registroState) {
              // Determinar si el turno está activo
              final bool turnoActivo = registroState is RegistroHorarioLoaded &&
                  registroState.estadoActual == EstadoFichaje.dentro;

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
                    _buildFunctionalityGrid(context, turnoActivo),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Cuadrícula de funcionalidades principales
  Widget _buildFunctionalityGrid(BuildContext context, bool turnoActivo) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, // 2 columnas
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        // 1. Turno - SIEMPRE activo
        _buildFunctionalityCard(
          context: context,
          iconPath: 'lib/assets/images/reolj.png',
          title: 'Turno',
          enabled: true,
          isActive: turnoActivo,
          onTap: () {
            context.push('/registro-horario');
          },
        ),
        // 2. Servicios - Requiere turno activo
        _buildFunctionalityCard(
          context: context,
          iconPath: 'lib/assets/images/hospital.png',
          title: 'Servicios',
          enabled: turnoActivo,
          onTap: () {
            if (turnoActivo) {
              context.push('/servicios');
            }
          },
        ),
        // 3. Trámites - Requiere turno activo
        _buildFunctionalityCard(
          context: context,
          iconPath: 'lib/assets/images/documento.png',
          title: 'Trámites',
          enabled: turnoActivo,
          onTap: () {
            if (turnoActivo) {
              context.push('/tramites');
            }
          },
        ),
        // 4. Vehículo - Requiere turno activo
        _buildFunctionalityCard(
          context: context,
          iconPath: 'lib/assets/images/ambazul.png',
          title: 'Vehículo',
          enabled: turnoActivo,
          onTap: () {
            if (turnoActivo) {
              context.push('/vehiculo');
            }
          },
        ),
        // 5. Vestuario - Requiere turno activo
        _buildFunctionalityCard(
          context: context,
          iconPath: 'lib/assets/images/maletin.png',
          title: 'Vestuario',
          enabled: turnoActivo,
          onTap: () {
            if (turnoActivo) {
              context.push('/vestuario');
            }
          },
        ),
      ],
    );
  }

  /// Tarjeta individual de funcionalidad
  Widget _buildFunctionalityCard({
    required BuildContext context,
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    bool enabled = true,
    bool isActive = false,
  }) {
    // Colores según el estado
    final Color cardColor;
    final Color textColor;
    final double opacity;

    if (!enabled) {
      // Deshabilitado: gris claro con opacidad
      cardColor = Colors.grey[300]!;
      textColor = Colors.grey[500]!;
      opacity = 0.5;
    } else if (isActive) {
      // Activo: verde con fondo
      cardColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
      opacity = 1.0;
    } else {
      // Normal: gris claro
      cardColor = Colors.grey[100]!;
      textColor = Colors.grey[800]!;
      opacity = 1.0;
    }

    return Opacity(
      opacity: opacity,
      child: Card(
        elevation: enabled ? 2 : 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isActive
              ? BorderSide(color: AppColors.success, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Icono - 70% del espacio
                Expanded(
                  flex: 70,
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // El icono ocupará el 70% del espacio disponible
                        final iconSize = constraints.maxHeight * 0.7;
                        return SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: ColorFiltered(
                            colorFilter: !enabled
                                ? const ColorFilter.mode(
                                    Colors.grey,
                                    BlendMode.saturation,
                                  )
                                : const ColorFilter.mode(
                                    Colors.transparent,
                                    BlendMode.multiply,
                                  ),
                            child: Image.asset(
                              iconPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Título - 30% del espacio
                Expanded(
                  flex: 30,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.0,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
