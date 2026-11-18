import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/vehiculo_asignado/vehiculo_asignado_bloc.dart';
import '../bloc/vehiculo_asignado/vehiculo_asignado_event.dart';
import '../bloc/vehiculo_asignado/vehiculo_asignado_state.dart';
import '../widgets/vehiculo_header_card.dart';
import '../../../../core/widgets/menu/app_menu.dart';

/// Página principal de gestión de vehículos
///
/// Menú con acceso a:
/// - Reportar incidencias del vehículo
/// - Checklists de ambulancia (Pre-Servicio, Post-Servicio, Mensual)
/// - Control de caducidades
/// - Historial de revisiones
class VehiculoPage extends StatelessWidget {
  const VehiculoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Si no está autenticado, redirigir
        if (authState is! AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Crear el bloc con el personalId si existe, sino con userId
        final userId = authState.personal?.id ?? authState.user.id;
        debugPrint('🔑 Creando VehiculoAsignadoBloc con userId: $userId');
        debugPrint('🔑 Personal ID: ${authState.personal?.id}');
        debugPrint('🔑 User ID: ${authState.user.id}');

        return BlocProvider(
          create: (context) => VehiculoAsignadoBloc(userId: userId)
            ..add(const LoadVehiculoAsignado()),
          child: const _VehiculoPageContent(),
        );
      },
    );
  }
}

class _VehiculoPageContent extends StatelessWidget {
  const _VehiculoPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mi Vehículo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => _refrescar(context),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refrescar(context),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: <Widget>[
              BlocBuilder<VehiculoAsignadoBloc, VehiculoAsignadoState>(
                builder: (BuildContext context, VehiculoAsignadoState state) =>
                    VehiculoHeaderCard(state: state),
              ),
              const SizedBox(height: 28),
              const AppMenuSeccion('REVISIÓN Y CONTROL'),
              AppMenuGrupo(
                opciones: <AppMenuOpcion>[
                  AppMenuOpcion(
                    icon: Icons.checklist_rounded,
                    color: AppColors.secondary,
                    titulo: 'Checklists',
                    descripcion: 'Revisión pre-servicio, post-servicio y mensual',
                    onTap: () => context.push('/checklist-ambulancia'),
                  ),
                  AppMenuOpcion(
                    icon: Icons.medical_services_outlined,
                    color: AppColors.primary,
                    titulo: 'Equipamiento',
                    descripcion: 'Dotación y documentación del vehículo',
                    onTap: () => context.push('/vehiculo/equipamiento'),
                  ),
                  AppMenuOpcion(
                    icon: Icons.event_available_outlined,
                    color: AppColors.warning,
                    titulo: 'Caducidades',
                    descripcion: 'Material caducado o próximo a caducar',
                    onTap: () => context.push('/vehiculo/caducidades'),
                  ),
                  AppMenuOpcion(
                    icon: Icons.history_rounded,
                    color: AppColors.info,
                    titulo: 'Historial',
                    descripcion: 'Revisiones e incidencias anteriores',
                    onTap: () => context.push('/vehiculo/historial'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const AppMenuSeccion('INCIDENCIAS'),
              AppMenuGrupo(
                opciones: <AppMenuOpcion>[
                  AppMenuOpcion(
                    icon: Icons.report_problem_outlined,
                    color: AppColors.error,
                    titulo: 'Reportar incidencia',
                    descripcion: 'Comunica una avería, daño o falta de material',
                    onTap: () => context.push('/vehiculo/reportar-incidencia'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refrescar(BuildContext context) {
    context.read<VehiculoAsignadoBloc>().add(const RefreshVehiculoAsignado());
  }
}
