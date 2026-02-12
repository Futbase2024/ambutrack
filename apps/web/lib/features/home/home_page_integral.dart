import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_bloc.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_event.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de AmbuTrack - Dashboard integral de gestión de ambulancias
///
/// Esta página se renderiza dentro del MainLayout, por lo que NO incluye
/// su propio Scaffold ni AppBar.
class HomePageIntegral extends StatelessWidget {
  const HomePageIntegral({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (BuildContext context) => getIt<HomeBloc>()..add(const HomeStarted()),
      child: const SafeArea(
        child: _DashboardTab(),
      ),
    );
  }
}

/// Dashboard general con resumen de servicios
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        // Mostrar loading profesional mientras carga
        if (state is HomeLoading) {
          return const Center(
            child: AppLoadingIndicator(
              message: 'Cargando dashboard...',
              size: 100,
            ),
          );
        }

        if (state is HomeError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al cargar el dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondaryLight),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(const HomeRefreshed());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is HomeLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header de bienvenida
                _WelcomeHeader(isConnected: state.isConnected),
                const SizedBox(height: 24),

                // Resumen operacional
                _OperationalSummaryCard(
                  programadosActivos: state.serviciosProgramadosActivos,
                  programadosCompletados: state.serviciosProgramadosCompletados,
                  urgenciasActivos: state.serviciosUrgenciasActivos,
                  urgenciasCompletados: state.serviciosUrgenciasCompletados,
                ),
                const SizedBox(height: 16),

                // Estadísticas del día
                _DailyStatsCard(
                  totalServicios: state.serviciosTotalesDia,
                  completados: state.serviciosCompletadosDia,
                  enProceso: state.serviciosEnProceso,
                ),
                const SizedBox(height: 16),

                // Estado de la flota
                _FleetStatusCard(
                  urgenciasDisponibles: state.vehiculosUrgenciasDisponibles,
                  urgenciasTotal: state.vehiculosUrgenciasTotal,
                  programadosDisponibles: state.vehiculosProgramadosDisponibles,
                  programadosTotal: state.vehiculosProgramadosTotal,
                ),
                const SizedBox(height: 16),

                // Próximas actividades
                const _UpcomingActivitiesCard(),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Header de bienvenida
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.isConnected});

  final bool isConnected;

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
            '¡Bienvenido al Centro de Control AmbuTrack!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gestión integral: Transporte programado y servicios de urgencias',
            style: TextStyle(
              color: Colors.white,
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
              const Text(
                'Sistema operativo las 24 horas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              _StatusBadge(
                text: isConnected ? 'Operativo' : 'Sin conexión',
                color: isConnected ? AppColors.secondary : AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Badge de estado
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Resumen operacional
class _OperationalSummaryCard extends StatelessWidget {
  const _OperationalSummaryCard({
    required this.programadosActivos,
    required this.programadosCompletados,
    required this.urgenciasActivos,
    required this.urgenciasCompletados,
  });

  final int programadosActivos;
  final int programadosCompletados;
  final int urgenciasActivos;
  final int urgenciasCompletados;

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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Resumen Operacional',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ServiceSummaryItem(
                    title: 'Transporte Programado',
                    active: programadosActivos.toString(),
                    completed: programadosCompletados.toString(),
                    color: AppColors.secondary,
                    icon: Icons.schedule,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ServiceSummaryItem(
                    title: 'Servicios Urgencias',
                    active: urgenciasActivos.toString(),
                    completed: urgenciasCompletados.toString(),
                    color: AppColors.emergency,
                    icon: Icons.emergency,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Item de resumen de servicios
class _ServiceSummaryItem extends StatelessWidget {
  const _ServiceSummaryItem({
    required this.title,
    required this.active,
    required this.completed,
    required this.color,
    required this.icon,
  });

  final String title;
  final String active;
  final String completed;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _MetricItem('Activos', active, color),
              _MetricItem('Completados', completed, AppColors.success),
            ],
          ),
        ],
      ),
    );
  }
}

/// Item de métrica
class _MetricItem extends StatelessWidget {
  const _MetricItem(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

/// Estadísticas diarias
class _DailyStatsCard extends StatelessWidget {
  const _DailyStatsCard({
    required this.totalServicios,
    required this.completados,
    required this.enProceso,
  });

  final int totalServicios;
  final int completados;
  final int enProceso;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Estadísticas del Día',
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
                    title: 'Total Servicios',
                    value: totalServicios.toString(),
                    color: AppColors.primary,
                    icon: Icons.medical_services,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    title: 'Completados',
                    value: completados.toString(),
                    color: AppColors.success,
                    icon: Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    title: 'En Proceso',
                    value: enProceso.toString(),
                    color: AppColors.warning,
                    icon: Icons.pending,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Item de estadística
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

/// Estado de la flota
class _FleetStatusCard extends StatelessWidget {
  const _FleetStatusCard({
    required this.urgenciasDisponibles,
    required this.urgenciasTotal,
    required this.programadosDisponibles,
    required this.programadosTotal,
  });

  final int urgenciasDisponibles;
  final int urgenciasTotal;
  final int programadosDisponibles;
  final int programadosTotal;

  @override
  Widget build(BuildContext context) {
    final int totalDisponibles = urgenciasDisponibles + programadosDisponibles;

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
                  'Estado de la Flota',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _StatusBadge(
                  text: '$totalDisponibles Disponibles',
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _FleetItem(
                    type: 'Urgencias',
                    available: urgenciasDisponibles,
                    total: urgenciasTotal,
                    color: AppColors.emergency,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FleetItem(
                    type: 'Programado',
                    available: programadosDisponibles,
                    total: programadosTotal,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Item de flota
class _FleetItem extends StatelessWidget {
  const _FleetItem({
    required this.type,
    required this.available,
    required this.total,
    required this.color,
  });

  final String type;
  final int available;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? available / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            type,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$available/$total',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percentage * 100).toInt()}% disponible',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Próximas actividades
class _UpcomingActivitiesCard extends StatelessWidget {
  const _UpcomingActivitiesCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Próximas Actividades',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _ActivityItem(
              time: '09:30',
              title: 'Traslado a Diálisis',
              subtitle: 'Paciente: María González - AMB-003',
              type: 'scheduled',
            ),
            _ActivityItem(
              time: '10:15',
              title: 'Revisión Ambulancia',
              subtitle: 'AMB-001 - Mantenimiento programado',
              type: 'maintenance',
            ),
            _ActivityItem(
              time: '11:00',
              title: 'Ruta Colectiva Centro',
              subtitle: '4 pacientes - Consultas médicas',
              type: 'collective',
            ),
          ],
        ),
      ),
    );
  }
}

/// Item de actividad
class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  final String time;
  final String title;
  final String subtitle;
  final String type;

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    IconData typeIcon;

    switch (type) {
      case 'scheduled':
        typeColor = AppColors.secondary;
        typeIcon = Icons.schedule;
        break;
      case 'maintenance':
        typeColor = AppColors.warning;
        typeIcon = Icons.build;
        break;
      case 'collective':
        typeColor = AppColors.info;
        typeIcon = Icons.groups;
        break;
      default:
        typeColor = AppColors.gray500;
        typeIcon = Icons.event;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              typeIcon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: typeColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
