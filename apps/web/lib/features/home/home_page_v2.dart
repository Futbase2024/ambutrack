import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_bloc.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_event.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_state.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/agenda_pendiente_form_dialog.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/agenda_pendientes_popup_dialog.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/widgets/alertas_proximas_banner.dart';
import 'package:ambutrack_web/features/auth/data/mappers/user_mapper.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart'
    as app_auth;
import 'package:ambutrack_web/features/home/presentation/bloc/home_bloc.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_event.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_state.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/dashboard_charts.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/dashboard_stats_cards.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimientos_proximos_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Banner de alertas próximas a vencer (mañana)
                      AlertasProximasBanner(),

                      // Tarjetas de estadísticas KPI — 30% del viewport
                      Flexible(flex: 3, child: _StatsCardsSection()),

                      // Gráficas profesionales — 70% del viewport
                      Flexible(flex: 7, child: _ChartsSection()),
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

/// Sección de tarjetas de estadísticas (incluye Pendientes Hoy)
///
/// Envuelve el contenido con un BlocListener que muestra automáticamente
/// un popup de pendientes cuando se carga la primera vez con datos.
class _StatsCardsSection extends StatelessWidget {
  const _StatsCardsSection();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AgendaPendienteBloc>(
      create: (BuildContext context) => getIt<AgendaPendienteBloc>()
        ..add(AgendaPendienteLoadHoyRequested(
          empresaId: _getEmpresaId(context),
        )),
      child: const _StatsCardsWithPopupListener(),
    );
  }

  String _getEmpresaId(BuildContext context) {
    final app_auth.AuthState authState = context.read<AuthBloc>().state;
    if (authState is app_auth.AuthAuthenticated) {
      return authState.user.empresaId ??
          '00000000-0000-0000-0000-000000000001';
    }
    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      return UserMapper.fromSupabaseUser(currentUser).empresaId ??
          '00000000-0000-0000-0000-000000000001';
    }
    return '00000000-0000-0000-0000-000000000001';
  }
}

/// Wrapper que escucha el estado de AgendaPendienteBloc y muestra
/// el popup de pendientes la primera vez que se cargan datos.
class _StatsCardsWithPopupListener extends StatefulWidget {
  const _StatsCardsWithPopupListener();

  @override
  State<_StatsCardsWithPopupListener> createState() =>
      _StatsCardsWithPopupListenerState();
}

class _StatsCardsWithPopupListenerState
    extends State<_StatsCardsWithPopupListener> {
  bool _popupShown = false;
  bool _popupMantenimientoShown = false;
  List<MantenimientoEntity> _mantenimientosPendientes =
      const <MantenimientoEntity>[];

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (HomeState previous, HomeState current) {
        // Solo en la primera carga y si hay mantenimientos que requieren atención
        if (_popupMantenimientoShown) {
          return false;
        }
        if (current is! HomeLoaded) {
          return false;
        }
        return previous is! HomeLoaded &&
            current.mantenimientosProximosOVencidos.isNotEmpty;
      },
      listener: (BuildContext context, HomeState state) {
        if (state is HomeLoaded &&
            state.mantenimientosProximosOVencidos.isNotEmpty) {
          _mantenimientosPendientes = state.mantenimientosProximosOVencidos;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _intentarMostrarMantenimiento();
          });
        }
      },
      child: BlocListener<AgendaPendienteBloc, AgendaPendienteState>(
        listenWhen: (AgendaPendienteState previous, AgendaPendienteState current) {
          // Solo mostrar popup en la primera carga con pendientes
          if (_popupShown) {
            return false;
          }
          if (current is! AgendaPendienteLoaded) {
            return false;
          }
          if (current.pendientesHoy.isEmpty) {
            return false;
          }

          // Detectar primera carga: el estado anterior no era loaded
          final bool wasNotLoaded = previous is! AgendaPendienteLoaded;
          return wasNotLoaded;
        },
        listener: (BuildContext context, AgendaPendienteState state) {
          if (state is AgendaPendienteLoaded && state.pendientesHoy.isNotEmpty) {
            _popupShown = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              final String userId = _getUserId(context);
              showAgendaPendientesPopupDialog(
                context: context,
                pendientes: state.pendientesHoy,
                userId: userId,
              ).whenComplete(() {
                if (mounted) {
                  setState(() => _popupShown = false);
                  // Tras cerrar agenda, mostrar el de mantenimiento si quedó pendiente
                  _intentarMostrarMantenimiento();
                }
              });
            });
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (BuildContext context, HomeState state) {
            return BlocBuilder<AgendaPendienteBloc, AgendaPendienteState>(
              builder:
                  (BuildContext context, AgendaPendienteState agendaState) {
                int serviciosActivos = 0;
                int disponibles = 0;
                int personalActivo = 0;
                int pendientesHoy = 0;
                int mantenimientosProgramados = 0;
                int mantenimientosEnProceso = 0;
                int mantenimientosCompletados = 0;

                if (state is HomeLoaded) {
                  serviciosActivos = state.totalServicios;
                  disponibles = state.vehiculosEnServicio;
                  // TODO(team): Obtener personal activo del estado cuando esté disponible
                  personalActivo = 82;
                  mantenimientosProgramados = state.mantenimientosProgramados;
                  mantenimientosEnProceso = state.mantenimientosEnProceso;
                  mantenimientosCompletados = state.mantenimientosCompletados;
                }

                if (agendaState is AgendaPendienteLoaded) {
                  pendientesHoy = agendaState.pendientesHoy.length;
                }

                return DashboardStatsCards(
                  serviciosActivos: serviciosActivos,
                  disponibles: disponibles,
                  mantenimientosProgramados: mantenimientosProgramados,
                  mantenimientosEnProceso: mantenimientosEnProceso,
                  mantenimientosCompletados: mantenimientosCompletados,
                  personalActivo: personalActivo,
                  pendientesHoy: pendientesHoy,
                  onAddPendiente: () {
                    showAgendaPendienteFormDialog(
                      context: context,
                      empresaId: _getEmpresaId(context),
                    );
                  },
                  onTapServicios: () => context.go('/servicios/planificar'),
                  onTapVehiculos: () => context.go('/vehiculos'),
                  onTapMantenimiento: () =>
                      context.go('/flota/mantenimiento-preventivo'),
                  onAddMantenimiento: () =>
                      context.go('/flota/mantenimiento-preventivo'),
                  onTapPersonal: () => context.go('/personal'),
                  onTapAgenda: () => context.go('/servicios/agenda-pendientes'),
                  incidenciasAbiertas: 0,
                  onTapIncidencias: () =>
                      context.go('/administracion/incidencias'),
                  onAddIncidencia: () =>
                      context.go('/administracion/incidencias'),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Muestra el popup de mantenimientos próximos/vencidos si no hay otro popup
  /// activo. Si el popup de agenda está abierto, espera a que cierre
  /// (se reintenta desde su `whenComplete`) para no apilar diálogos.
  void _intentarMostrarMantenimiento() {
    if (_popupMantenimientoShown || _popupShown) {
      return;
    }
    if (_mantenimientosPendientes.isEmpty) {
      return;
    }
    _popupMantenimientoShown = true;
    final List<MantenimientoEntity> lista = _mantenimientosPendientes;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showMantenimientosProximosPopupDialog(
        context: context,
        mantenimientos: lista,
        userId: _getUserId(context),
      ).whenComplete(() {
        if (mounted) {
          setState(() {
            _mantenimientosPendientes = const <MantenimientoEntity>[];
            _popupMantenimientoShown = false;
          });
        }
      });
    });
  }

  String _getEmpresaId(BuildContext context) {
    final app_auth.AuthState authState = context.read<AuthBloc>().state;
    if (authState is app_auth.AuthAuthenticated) {
      return authState.user.empresaId ??
          '00000000-0000-0000-0000-000000000001';
    }
    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      return UserMapper.fromSupabaseUser(currentUser).empresaId ??
          '00000000-0000-0000-0000-000000000001';
    }
    return '00000000-0000-0000-0000-000000000001';
  }

  String _getUserId(BuildContext context) {
    final app_auth.AuthState authState = context.read<AuthBloc>().state;
    if (authState is app_auth.AuthAuthenticated) {
      return authState.user.uid;
    }
    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      return currentUser.id;
    }
    return '';
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
