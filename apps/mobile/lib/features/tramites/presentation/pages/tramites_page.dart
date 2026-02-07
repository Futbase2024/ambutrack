import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/ausencias_bloc.dart';
import '../bloc/ausencias_event.dart';
import '../bloc/ausencias_state.dart';
import '../bloc/vacaciones_bloc.dart';
import '../bloc/vacaciones_event.dart';
import '../bloc/vacaciones_state.dart';
import 'mis_tramites_page.dart';
import 'solicitar_ausencia_page.dart';
import 'solicitar_vacaciones_page.dart';

/// Pantalla principal del módulo de trámites.
/// Muestra resumen estadístico y opciones para solicitar trámites.
class TramitesPage extends StatelessWidget {
  const TramitesPage({super.key});

  static const routeName = '/tramites';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VacacionesBloc>(
          create: (_) => getIt<VacacionesBloc>(),
        ),
        BlocProvider<AusenciasBloc>(
          create: (_) => getIt<AusenciasBloc>(),
        ),
      ],
      child: const _TramitesView(),
    );
  }
}

class _TramitesView extends StatefulWidget {
  const _TramitesView();

  @override
  State<_TramitesView> createState() => _TramitesViewState();
}

class _TramitesViewState extends State<_TramitesView> {
  @override
  void initState() {
    super.initState();
    _loadTramites();
  }

  void _loadTramites() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.personal != null) {
      final personalId = authState.personal!.id;

      // Cargar vacaciones del personal autenticado
      context.read<VacacionesBloc>().add(
            VacacionesLoadByPersonalRequested(personalId),
          );

      // Cargar ausencias del personal autenticado
      context.read<AusenciasBloc>().add(
            AusenciasLoadByPersonalRequested(personalId),
          );

      // Cargar tipos de ausencias
      context.read<AusenciasBloc>().add(
            const TiposAusenciaLoadRequested(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Trámites'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _loadTramites();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen estadístico compacto
                const _ResumenWidget(),

                const SizedBox(height: 24),

                // Título de sección
                Text(
                  'Solicitar Trámite',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                // Cuadrícula de trámites
                _buildTramitesGrid(context),

                const SizedBox(height: 24),

                // Botón ver todos mis trámites
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: context.read<VacacionesBloc>(),
                              ),
                              BlocProvider.value(
                                value: context.read<AusenciasBloc>(),
                              ),
                            ],
                            child: const MisTramitesPage(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_rounded),
                    label: const Text('Ver todos mis trámites'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  Widget _buildTramitesGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildTramiteCard(
          context: context,
          emoji: '🏖️',
          title: 'Vacaciones',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<VacacionesBloc>(),
                  child: const SolicitarVacacionesPage(),
                ),
              ),
            );
          },
        ),
        _buildTramiteCard(
          context: context,
          emoji: '🏥',
          title: 'Baja Médica',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AusenciasBloc>(),
                  child: const SolicitarAusenciaPage(
                    tipoPreseleccionado: 'baja_medica',
                  ),
                ),
              ),
            );
          },
        ),
        _buildTramiteCard(
          context: context,
          emoji: '👤',
          title: 'Permiso Personal',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AusenciasBloc>(),
                  child: const SolicitarAusenciaPage(
                    tipoPreseleccionado: 'permiso_personal',
                  ),
                ),
              ),
            );
          },
        ),
        _buildTramiteCard(
          context: context,
          emoji: '📅',
          title: 'Otras Ausencias',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AusenciasBloc>(),
                  child: const SolicitarAusenciaPage(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Tarjeta individual de trámite
  Widget _buildTramiteCard({
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
}

/// Widget de resumen estadístico compacto.
class _ResumenWidget extends StatelessWidget {
  const _ResumenWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacacionesBloc, VacacionesState>(
      builder: (context, vacacionesState) {
        return BlocBuilder<AusenciasBloc, AusenciasState>(
          builder: (context, ausenciasState) {
            // Calcular estadísticas
            final pendientesVacaciones = vacacionesState is VacacionesLoaded
                ? vacacionesState.pendientes.length
                : 0;
            final aprobadasVacaciones = vacacionesState is VacacionesLoaded
                ? vacacionesState.aprobadas.length
                : 0;
            final rechazadasVacaciones = vacacionesState is VacacionesLoaded
                ? vacacionesState.rechazadas.length
                : 0;

            final pendientesAusencias = ausenciasState is AusenciasLoaded
                ? ausenciasState.pendientes.length
                : 0;
            final aprobadasAusencias = ausenciasState is AusenciasLoaded
                ? ausenciasState.aprobadas.length
                : 0;
            final rechazadasAusencias = ausenciasState is AusenciasLoaded
                ? ausenciasState.rechazadas.length
                : 0;

            final pendientes = pendientesVacaciones + pendientesAusencias;
            final aprobadas = aprobadasVacaciones + aprobadasAusencias;
            final rechazadas = rechazadasVacaciones + rechazadasAusencias;

            return Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Pendientes',
                    value: '$pendientes',
                    color: AppColors.warning,
                    emoji: '⏳',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Aprobadas',
                    value: '$aprobadas',
                    color: AppColors.success,
                    emoji: '✅',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Rechazadas',
                    value: '$rechazadas',
                    color: AppColors.error,
                    emoji: '❌',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Tarjeta de estadística minimalista.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.emoji,
  });

  final String label;
  final String value;
  final Color color;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            // Emoji
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),

            // Valor
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
