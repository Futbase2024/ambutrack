import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Panel inferior con tabs de trayectos
class TrayectosPanel extends StatefulWidget {
  const TrayectosPanel({
    this.servicioId,
    super.key,
  });

  final String? servicioId;

  @override
  State<TrayectosPanel> createState() => _TrayectosPanelState();
}

class _TrayectosPanelState extends State<TrayectosPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.gray200),
              ),
            ),
            child: const Row(
              children: <Widget>[
                Icon(
                  Icons.alt_route,
                  size: 20,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSizes.spacingSmall),
                Text(
                  'TRAYECTOS',
                  style: TextStyle(
                    fontSize: AppSizes.fontMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.gray200),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondaryLight,
              indicatorColor: AppColors.primary,
              labelStyle: const TextStyle(
                fontSize: AppSizes.fontSmall,
                fontWeight: FontWeight.w600,
              ),
              tabs: const <Tab>[
                Tab(text: 'Trayectos Activos'),
                Tab(text: 'Histórico de Trayectos'),
                Tab(text: 'Todos los Trayectos'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: widget.servicioId == null
                ? _buildEmptyState()
                : TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      _TrayectosActivosTab(servicioId: widget.servicioId!),
                      _HistoricoTrayectosTab(servicioId: widget.servicioId!),
                      _TodosTrayectosTab(servicioId: widget.servicioId!),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Selecciona un servicio para ver sus trayectos',
        style: TextStyle(
          fontSize: AppSizes.fontSmall,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

/// Tab con trayectos activos
class _TrayectosActivosTab extends StatelessWidget {
  const _TrayectosActivosTab({required this.servicioId});

  final String servicioId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      children: <Widget>[
        _buildTrayectoCard(
          fecha: '16/12/2024',
          hora: '08:00',
          origen: 'Calle Mayor, 15',
          destino: 'Hospital Central',
          conductor: 'Juan García',
          vehiculo: 'AMB-001',
          estado: 'En curso',
          estadoColor: AppColors.warning,
        ),
        _buildTrayectoCard(
          fecha: '18/12/2024',
          hora: '08:00',
          origen: 'Calle Mayor, 15',
          destino: 'Hospital Central',
          conductor: 'María López',
          vehiculo: 'AMB-002',
          estado: 'Programado',
          estadoColor: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildTrayectoCard({
    required String fecha,
    required String hora,
    required String origen,
    required String destino,
    required String conductor,
    required String vehiculo,
    required String estado,
    required Color estadoColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Cabecera con fecha y estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '$fecha - $hora',
                style: const TextStyle(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: estadoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),

          // Origen - Destino
          Row(
            children: <Widget>[
              const Icon(Icons.location_on, size: 16, color: AppColors.success),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  origen,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              const Icon(Icons.flag, size: 16, color: AppColors.error),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  destino,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spacingSmall),
          const Divider(),
          const SizedBox(height: AppSizes.spacingSmall),

          // Conductor y vehículo
          Row(
            children: <Widget>[
              const Icon(Icons.person, size: 16, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                conductor,
                style: const TextStyle(
                  fontSize: AppSizes.fontSmall,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              const Icon(Icons.directions_car, size: 16, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                vehiculo,
                style: const TextStyle(
                  fontSize: AppSizes.fontSmall,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tab con histórico de trayectos
class _HistoricoTrayectosTab extends StatelessWidget {
  const _HistoricoTrayectosTab({required this.servicioId});

  final String servicioId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      children: <Widget>[
        _buildTrayectoHistoricoItem(
          fecha: '13/12/2024',
          hora: '08:00',
          conductor: 'Pedro Martínez',
          estado: 'Completado',
          estadoColor: AppColors.success,
        ),
        _buildTrayectoHistoricoItem(
          fecha: '11/12/2024',
          hora: '08:00',
          conductor: 'Ana Sánchez',
          estado: 'Completado',
          estadoColor: AppColors.success,
        ),
        _buildTrayectoHistoricoItem(
          fecha: '09/12/2024',
          hora: '08:00',
          conductor: 'Juan García',
          estado: 'Completado',
          estadoColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildTrayectoHistoricoItem({
    required String fecha,
    required String hora,
    required String conductor,
    required String estado,
    required Color estadoColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing),
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$fecha - $hora',
                  style: const TextStyle(
                    fontSize: AppSizes.fontSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  conductor,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: estadoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              estado,
              style: TextStyle(
                fontSize: AppSizes.fontSmall,
                color: estadoColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab con todos los trayectos
class _TodosTrayectosTab extends StatelessWidget {
  const _TodosTrayectosTab({required this.servicioId});

  final String servicioId;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Vista de todos los trayectos (activos + históricos)',
        style: TextStyle(
          fontSize: AppSizes.fontSmall,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
