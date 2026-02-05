import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Página principal de AmbuTrack - Dashboard integral de gestión de ambulancias
///
/// Esta página se renderiza dentro del MainLayout, por lo que NO incluye
/// su propio Scaffold ni AppBar.
class HomePageIntegral extends StatefulWidget {
  const HomePageIntegral({super.key});

  @override
  State<HomePageIntegral> createState() => _HomePageIntegralState();
}

class _HomePageIntegralState extends State<HomePageIntegral> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Contenido principal del dashboard
        const SafeArea(
          child: _DashboardTab(),
        ),
        // FloatingActionButton posicionado manualmente
        Positioned(
          right: 16,
          bottom: 16,
          child: _buildFloatingActionButton(),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO(team): Acción rápida general
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

/// Dashboard general con resumen de servicios
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header de bienvenida
          _WelcomeHeader(),
          SizedBox(height: 24),

          // Resumen operacional
          _OperationalSummaryCard(),
          SizedBox(height: 16),

          // Estadísticas del día
          _DailyStatsCard(),
          SizedBox(height: 16),

          // Estado de la flota
          _FleetStatusCard(),
          SizedBox(height: 16),

          // Próximas actividades
          _UpcomingActivitiesCard(),
        ],
      ),
    );
  }
}

/// Header de bienvenida
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '¡Bienvenido al Centro de Control AmbuTrack!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Gestión integral: Transporte programado y servicios de urgencias',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: <Widget>[
              Icon(
                Icons.access_time,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Sistema operativo las 24 horas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              _StatusBadge(text: 'Operativo', color: AppColors.secondary),
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
  const _OperationalSummaryCard();

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
            const Row(
              children: <Widget>[
                Expanded(
                  child: _ServiceSummaryItem(
                    title: 'Transporte Programado',
                    active: '12',
                    completed: '28',
                    color: AppColors.secondary,
                    icon: Icons.schedule,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _ServiceSummaryItem(
                    title: 'Servicios Urgencias',
                    active: '3',
                    completed: '15',
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
  const _DailyStatsCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Estadísticas del Día',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatItem(
                    title: 'Total Servicios',
                    value: '43',
                    color: AppColors.primary,
                    icon: Icons.medical_services,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    title: 'Completados',
                    value: '38',
                    color: AppColors.success,
                    icon: Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    title: 'En Proceso',
                    value: '5',
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
  const _FleetStatusCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.local_hospital,
                  color: AppColors.secondary,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Estado de la Flota',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                _StatusBadge(text: '8 Disponibles', color: AppColors.secondary),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _FleetItem(
                    type: 'Urgencias',
                    available: 3,
                    total: 5,
                    color: AppColors.emergency,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _FleetItem(
                    type: 'Programado',
                    available: 5,
                    total: 8,
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
    final double percentage = available / total;

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