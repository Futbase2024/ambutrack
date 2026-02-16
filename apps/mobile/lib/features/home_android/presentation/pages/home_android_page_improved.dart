import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../registro_horario/presentation/bloc/registro_horario_bloc.dart';
import '../../../registro_horario/presentation/bloc/registro_horario_event.dart';
import '../../../registro_horario/presentation/bloc/registro_horario_state.dart';
import '../widgets/functionalities_grid.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/user_profile_card.dart';

/// Página Home de AmbuTrack Mobile - Diseño Mejorado
///
/// Versión mejorada del dashboard principal con:
/// - AppBar profesional con notificaciones
/// - Tarjeta de usuario con avatar
/// - Banner de alertas de caducidad
/// - Grid de funcionalidades con estados dinámicos
/// - Pull-to-refresh
/// - SafeArea implementado
class HomeAndroidPageImproved extends StatefulWidget {
  const HomeAndroidPageImproved({super.key});

  @override
  State<HomeAndroidPageImproved> createState() => _HomeAndroidPageImprovedState();
}

class _HomeAndroidPageImprovedState extends State<HomeAndroidPageImproved>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarEstadoTurno();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🏠 [HomeImproved] App resumed, recargando estado del turno...');
      _cargarEstadoTurno();
    }
  }

  void _cargarEstadoTurno() {
    debugPrint('🏠 [HomeImproved] Cargando estado del turno...');
    context.read<RegistroHorarioBloc>().add(const ObtenerContextoTurno());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: HomeAppBar(
        onMenuPressed: _openMenu,
        onNotificationsPressed: _openNotifications,
        hasUnreadNotifications: true,
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthInitial || authState is AuthLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (authState is! AuthAuthenticated) {
              return const Center(
                child: Text('No autenticado'),
              );
            }

            final user = authState.user;
            final personal = authState.personal;

            return BlocBuilder<RegistroHorarioBloc, RegistroHorarioState>(
              builder: (context, registroState) {
                final turnoActivo =
                    (registroState is RegistroHorarioLoaded &&
                        registroState.estadoActual == EstadoFichaje.dentro) ||
                        (registroState is RegistroHorarioLoadedWithContext &&
                            registroState.estadoActual == EstadoFichaje.dentro);

                debugPrint('🏠 [HomeImproved] Estado del turno: turnoActivo=$turnoActivo');

                return RefreshIndicator(
                  onRefresh: () async {
                    debugPrint('🏠 [HomeImproved] Pull-to-refresh activado');
                    _cargarEstadoTurno();
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título de sección
                        _buildSectionTitle('Panel Principal'),

                        const SizedBox(height: 16),

                        // Tarjeta del usuario
                        UserProfileCard(
                          nombre: personal?.nombreCompleto ?? user.nombreCompleto ?? 'Usuario',
                          categoria: personal?.categoria,
                          dni: personal?.dni,
                          onTap: () => _navigateToProfile(context),
                        ),

                        const SizedBox(height: 24),

                        // Banner de alertas (condicional)
                        // TODO: Implementar lógica para mostrar alertas
                        // const AlertsBanner(
                        //   alertCount: 2,
                        //   onPressed: _openAlerts,
                        // ),

                        const SizedBox(height: 24),

                        // Grid de funcionalidades
                        FunctionalitiesGrid(
                          isShiftActive: turnoActivo,
                          // TODO: Obtener contador real de servicios pendientes
                          pendingServicesCount: 3,
                          // TODO: Obtener matrícula del vehículo asignado
                          vehiclePlate: 'A-12',
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.gray600,
        letterSpacing: 1.0,
      ),
    );
  }

  void _openMenu() {
    // TODO: Implementar menú lateral
    debugPrint('🏠 [HomeImproved] Menú abierto');
  }

  void _openNotifications() {
    // TODO: Implementar navegación a notificaciones
    debugPrint('🏠 [HomeImproved] Notificaciones abiertas');
  }

  void _navigateToProfile(BuildContext context) {
    GoRouter.of(context).push('/perfil');
  }
}
