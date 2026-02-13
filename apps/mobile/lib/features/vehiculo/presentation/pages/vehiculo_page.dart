import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/vehiculo_asignado/vehiculo_asignado_bloc.dart';
import '../bloc/vehiculo_asignado/vehiculo_asignado_event.dart';
import '../bloc/vehiculo_asignado/vehiculo_asignado_state.dart';

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
      backgroundColor: Colors.grey[50],
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
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<VehiculoAsignadoBloc>()
                  .add(const RefreshVehiculoAsignado());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildVehiculoHeader(context),
              const SizedBox(height: 24),
              _buildMenuGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Header con información del vehículo asignado
  Widget _buildVehiculoHeader(BuildContext context) {
    return BlocBuilder<VehiculoAsignadoBloc, VehiculoAsignadoState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_car,
                  size: 40,
                  color: _getIconColor(state),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehículo Asignado',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildVehiculoInfo(state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye la información del vehículo según el estado
  Widget _buildVehiculoInfo(VehiculoAsignadoState state) {
    return switch (state) {
      VehiculoAsignadoLoading() => const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
          ],
        ),
      VehiculoAsignadoLoaded(:final vehiculo) => Text(
          vehiculo.matricula,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
      VehiculoAsignadoEmpty() => const Text(
          'Sin asignación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.gray600,
          ),
        ),
      VehiculoAsignadoError() => const Text(
          'Error al cargar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.error,
          ),
        ),
      _ => const Text(
          'Cargando...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
    };
  }

  /// Obtiene el color del icono según el estado
  Color _getIconColor(VehiculoAsignadoState state) {
    return switch (state) {
      VehiculoAsignadoLoaded() => AppColors.primary,
      VehiculoAsignadoEmpty() => AppColors.gray400,
      VehiculoAsignadoError() => AppColors.error,
      _ => AppColors.primary,
    };
  }

  /// Grid 2x2 con las opciones del menú
  Widget _buildMenuGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0, // Cuadrados como en home
      children: [
        _buildMenuCard(
          context: context,
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.error,
          title: 'Reportar\nIncidencia',
          onTap: () => context.push('/vehiculo/reportar-incidencia'),
        ),
        _buildMenuCard(
          context: context,
          icon: Icons.checklist_rounded,
          iconColor: AppColors.success,
          title: 'Checklists',
          onTap: () => context.push('/checklist-ambulancia'),
        ),
        _buildMenuCard(
          context: context,
          icon: Icons.event_available_rounded,
          iconColor: AppColors.warning,
          title: 'Caducidades',
          onTap: () => context.push('/vehiculo/caducidades'),
        ),
        _buildMenuCard(
          context: context,
          icon: Icons.history_rounded,
          iconColor: AppColors.info,
          title: 'Historial',
          onTap: () => context.push('/vehiculo/historial'),
        ),
      ],
    );
  }

  /// Card individual del menú - Estilo de Home Page
  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
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
              // Icono - 70% del espacio
              Expanded(
                flex: 70,
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // El icono ocupará el 70% del espacio disponible
                      final iconSize = constraints.maxHeight * 0.7;
                      return Icon(
                        icon,
                        size: iconSize,
                        color: iconColor,
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
                        color: Colors.grey[800],
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
    );
  }
}
