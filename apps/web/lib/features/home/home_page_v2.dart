import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/agenda_pendientes_hoy_banner.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/widgets/alertas_proximas_banner.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_bloc.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_event.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_state.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/dashboard_charts.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/dashboard_stats_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de AmbuTrack - Dashboard v2
///
/// Diseño con:
/// - Tarjetas de estadísticas KPI con gradientes
/// - Gráficas profesionales con datos reales de Supabase
class HomePageV2 extends StatelessWidget {
  const HomePageV2({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (BuildContext context) => getIt<HomeBloc>()..add(const HomeStarted()),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.gray50,
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (BuildContext context, HomeState state) {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error al cargar datos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<HomeBloc>().add(const HomeStarted());
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (state is HomeLoaded) {
                return const SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Banner de alertas próximas a vencer (mañana)
                      AlertasProximasBanner(),

                      // Banner de pendientes programados para hoy
                      AgendaPendientesHoyBanner(),

                      // Tarjetas de estadísticas KPI
                      _StatsCardsSection(),
                      SizedBox(height: 32),

                      // Gráficas profesionales con datos reales
                      _ChartsSection(),
                    ],
                  ),
                );
              }

              return const Center(
                child: Text('Estado desconocido'),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Sección de tarjetas de estadísticas
class _StatsCardsSection extends StatelessWidget {
  const _StatsCardsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        int serviciosActivos = 0;
        int disponibles = 0;
        int mantenimiento = 0;
        int personalActivo = 0;

        if (state is HomeLoaded) {
          serviciosActivos = state.totalServicios;
          disponibles = state.vehiculosEnServicio;
          mantenimiento = state.vehiculosMantenimiento;
          // TODO(team): Obtener personal activo del estado cuando esté disponible
          personalActivo = 82;
        }

        return DashboardStatsCards(
          serviciosActivos: serviciosActivos,
          disponibles: disponibles,
          enMantenimiento: mantenimiento,
          personalActivo: personalActivo,
        );
      },
    );
  }
}

/// Sección de gráficas con datos reales
class _ChartsSection extends StatelessWidget {
  const _ChartsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        if (state is! HomeLoaded) {
          return const SizedBox.shrink();
        }

        return DashboardCharts(
          totalVehiculos: state.totalVehiculos,
          vehiculosEnServicio: state.vehiculosEnServicio,
          vehiculosMantenimiento: state.vehiculosMantenimiento,
          vehiculosDisponibles: state.vehiculosDisponibles.length,
          serviciosProgramadosActivos: state.serviciosProgramadosActivos,
          serviciosProgramadosCompletados: state.serviciosProgramadosCompletados,
          serviciosUrgenciasActivos: state.serviciosUrgenciasActivos,
          serviciosUrgenciasCompletados: state.serviciosUrgenciasCompletados,
          serviciosTotalesDia: state.serviciosTotalesDia,
          serviciosCompletadosDia: state.serviciosCompletadosDia,
          serviciosEnProceso: state.serviciosEnProceso,
        );
      },
    );
  }
}
