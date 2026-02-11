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
/// - Checklist mensual (protocolo A2)
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
      childAspectRatio: 1.1,
      children: [
        _buildMenuCard(
          emoji: '⚠️',
          title: 'Reportar Incidencia',
          subtitle: 'Problemas del vehículo',
          onTap: () => context.push('/vehiculo/reportar-incidencia'),
        ),
        _buildMenuCard(
          emoji: '✅',
          title: 'Checklist Mensual',
          subtitle: 'Protocolo A2',
          onTap: () => context.push('/vehiculo/checklist'),
        ),
        _buildMenuCard(
          emoji: '📅',
          title: 'Caducidades',
          subtitle: 'Material sanitario',
          onTap: () => context.push('/vehiculo/caducidades'),
        ),
        _buildMenuCard(
          emoji: '📋',
          title: 'Historial',
          subtitle: 'Revisiones previas',
          onTap: () => context.push('/vehiculo/historial'),
        ),
      ],
    );
  }

  /// Card individual del menú con emoji y título
  Widget _buildMenuCard({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gray200,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji ocupa 80% del espacio visual
              Expanded(
                flex: 8,
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              // Título y subtítulo
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.gray600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
