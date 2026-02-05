import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_bloc.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_event.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de AmbuTrack - Dashboard de gestión de ambulancias
///
/// Presenta una interfaz específica para el sector de ambulancias y emergencias médicas,
/// con navegación rápida a las funcionalidades principales del sistema.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (BuildContext context) => getIt<HomeBloc>()..add(const HomeStarted()),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('AmbuTrack'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // TODO(team): Implementar notificaciones
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {
                  // TODO(team): Implementar perfil de usuario
                },
              ),
            ],
          ),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header de bienvenida
                _WelcomeHeader(),
                SizedBox(height: 24),

                // Estado de emergencias activas
                _ActiveEmergenciesCard(),
                SizedBox(height: 16),

                // Acciones rápidas
                _QuickActionsGrid(),
                SizedBox(height: 16),

                // Estadísticas del día
                _DailyStatsCard(),
                SizedBox(height: 16),

                // Ambulancias disponibles
                _AvailableAmbulancesCard(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // TODO(team): Nueva emergencia
            },
            child: const Icon(Icons.add_call),
          ),
        ),
      ),
    );
  }
}

/// Header de bienvenida con información del usuario
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '¡Bienvenido al Centro de Control!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestión integral de ambulancias y emergencias médicas',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              const Icon(
                Icons.access_time,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Última actualización: ${TimeOfDay.now().format(context)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card que muestra las emergencias activas
class _ActiveEmergenciesCard extends StatelessWidget {
  const _ActiveEmergenciesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.emergency.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    color: AppColors.emergency,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Emergencias Activas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gray400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: AppColors.success.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No hay emergencias activas',
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Grid de acciones rápidas
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: const <Widget>[
            _QuickActionCard(
              title: 'Nueva Emergencia',
              icon: Icons.add_call,
              color: AppColors.emergency,
            ),
            _QuickActionCard(
              title: 'Ver Ambulancias',
              icon: Icons.local_hospital,
              color: AppColors.primary,
            ),
            _QuickActionCard(
              title: 'Historial',
              icon: Icons.history,
              color: AppColors.secondary,
            ),
            _QuickActionCard(
              title: 'Reportes',
              icon: Icons.assessment,
              color: AppColors.info,
            ),
          ],
        ),
      ],
    );
  }
}

/// Card individual de acción rápida
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO(team): Implementar navegación
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de estadísticas del día
class _DailyStatsCard extends StatelessWidget {
  const _DailyStatsCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        String total = '-';
        String disponibles = '-';
        String mantenimiento = '-';

        if (state is HomeLoaded) {
          total = state.totalVehiculos.toString();
          disponibles = state.vehiculosEnServicio.toString();
          mantenimiento = state.vehiculosMantenimiento.toString();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Estado de la Flota',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _StatItem(
                        title: 'Total',
                        value: total,
                        color: AppColors.primary,
                        icon: Icons.directions_car,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        title: 'Disponibles',
                        value: disponibles,
                        color: AppColors.success,
                        icon: Icons.check_circle,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        title: 'Mantenimiento',
                        value: mantenimiento,
                        color: AppColors.warning,
                        icon: Icons.build,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget individual de estadística
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Card de ambulancias disponibles
class _AvailableAmbulancesCard extends StatelessWidget {
  const _AvailableAmbulancesCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        List<VehiculoEntity> disponibles = <VehiculoEntity>[];
        int total = 0;

        if (state is HomeLoaded) {
          disponibles = state.vehiculosDisponibles;
          total = state.totalVehiculos;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.local_hospital,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ambulancias Disponibles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: disponibles.isNotEmpty ? AppColors.secondary : AppColors.gray400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${disponibles.length}/$total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state is HomeLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (disponibles.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.local_hospital_outlined,
                            size: 48,
                            color: AppColors.gray400,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No hay ambulancias disponibles',
                            style: TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...disponibles.take(5).map((VehiculoEntity vehiculo) {
                    return _AmbulanceItem(
                      id: vehiculo.matricula,
                      location: vehiculo.ubicacionActual ?? 'Sin ubicación',
                      status: 'Disponible',
                      crew: '${vehiculo.marca} ${vehiculo.modelo}',
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget para mostrar información de una ambulancia
class _AmbulanceItem extends StatelessWidget {
  const _AmbulanceItem({
    required this.id,
    required this.location,
    required this.status,
    required this.crew,
  });

  final String id;
  final String location;
  final String status;
  final String crew;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_hospital,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
                Text(
                  crew,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}