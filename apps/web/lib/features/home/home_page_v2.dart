import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_bloc.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_event.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_state.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/agenda_pendientes_popup_dialog.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/widgets/alertas_proximas_banner.dart';
import 'package:ambutrack_web/features/auth/data/mappers/user_mapper.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart'
    as app_auth;
import 'package:ambutrack_web/features/home/presentation/bloc/home_bloc.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_event.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_state.dart';
import 'package:ambutrack_web/features/home/presentation/config/dashboard_role_config.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/role_dashboard_builder.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/role_dashboard_charts.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimientos_proximos_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Página principal de AmbuTrack — Dashboard por rol.
///
/// Muestra cards y gráficas personalizadas según el rol del usuario.
/// Los popups de agenda y mantenimiento solo se muestran si el rol
/// tiene esas cards en su configuración.
class HomePageV2 extends StatelessWidget {
  const HomePageV2({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (BuildContext context) =>
          getIt<HomeBloc>()..add(const HomeStarted()),
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
                return _ErrorView(
                  message: state.message,
                  onRetry: () =>
                      context.read<HomeBloc>().add(const HomeStarted()),
                );
              }

              if (state is HomeLoaded) {
                final UserRole role = _getCurrentRole(context);
                final bool hasCharts =
                    DashboardRoleConfig.chartsForRole(role).isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const AlertasProximasBanner(),
                      Flexible(
                        flex: hasCharts ? 3 : 5,
                        child: _RoleStatsSection(role: role),
                      ),
                      if (hasCharts)
                        Flexible(
                          flex: 7,
                          child: _RoleChartsSection(role: role),
                        ),
                    ],
                  ),
                );
              }

              return const Center(child: Text('Estado desconocido'));
            },
          ),
        ),
      ),
    );
  }

  UserRole _getCurrentRole(BuildContext context) {
    final app_auth.AuthState authState = context.read<AuthBloc>().state;
    if (authState is app_auth.AuthAuthenticated) {
      return UserRole.fromString(authState.user.rol);
    }
    return UserRole.operador;
  }
}

/// Sección de tarjetas KPI con popups de agenda y mantenimiento.
///
/// Solo muestra el popup de agenda si el rol tiene la card
/// `DashboardCardType.agendaPendientes`, y el de mantenimiento
/// si tiene `DashboardCardType.mantenimiento`.
class _RoleStatsSection extends StatelessWidget {
  const _RoleStatsSection({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AgendaPendienteBloc>(
      create: (BuildContext context) => getIt<AgendaPendienteBloc>()
        ..add(AgendaPendienteLoadHoyRequested(
          empresaId: _getEmpresaId(context),
        )),
      child: _RoleStatsWithPopups(role: role),
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

/// Wrapper que coordina los popups de agenda y mantenimiento.
class _RoleStatsWithPopups extends StatefulWidget {
  const _RoleStatsWithPopups({required this.role});

  final UserRole role;

  @override
  State<_RoleStatsWithPopups> createState() => _RoleStatsWithPopupsState();
}

class _RoleStatsWithPopupsState extends State<_RoleStatsWithPopups> {
  bool _agendaPopupShown = false;
  bool _mantenimientoPopupShown = false;
  List<MantenimientoEntity> _mantenimientosPendientes =
      const <MantenimientoEntity>[];

  @override
  Widget build(BuildContext context) {
    return _buildMantenimientoListener(
      child: _buildAgendaListener(
        child: _buildContent(),
      ),
    );
  }

  /// Contenido principal: lee ambos blocs y construye las cards.
  Widget _buildContent() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        return BlocBuilder<AgendaPendienteBloc, AgendaPendienteState>(
          builder: (BuildContext context, AgendaPendienteState agendaState) {
            int pendientesHoy = 0;
            if (agendaState is AgendaPendienteLoaded) {
              pendientesHoy = agendaState.pendientesHoy.length;
            }

            if (state is! HomeLoaded) {
              return const SizedBox.shrink();
            }

            return RoleDashboardBuilder(
              role: widget.role,
              homeState: state,
              pendientesHoy: pendientesHoy,
            );
          },
        );
      },
    );
  }

  /// Listener de mantenimientos próximos (solo si el rol tiene la card).
  Widget _buildMantenimientoListener({required Widget child}) {
    if (!DashboardRoleConfig.hasMantenimientoPopup(widget.role)) {
      return child;
    }

    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (HomeState previous, HomeState current) {
        // Repoblar en cualquier HomeLoaded con mantenimientos (no solo en la
        // 1ª transición): si la 1ª emisión venía vacía (getAll tardó/falló) y
        // una posterior trae datos, el popup debe poder mostrarse.
        if (_mantenimientoPopupShown) {
          return false;
        }
        if (current is! HomeLoaded) {
          return false;
        }
        return current.mantenimientosProximosOVencidos.isNotEmpty;
      },
      listener: (BuildContext context, HomeState state) {
        if (state is HomeLoaded &&
            state.mantenimientosProximosOVencidos.isNotEmpty) {
          _mantenimientosPendientes = state.mantenimientosProximosOVencidos;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _showMantenimientoPopup();
          });
        }
      },
      child: child,
    );
  }

  /// Listener de agenda pendientes (solo si el rol tiene la card).
  Widget _buildAgendaListener({required Widget child}) {
    if (!DashboardRoleConfig.hasAgendaPopup(widget.role)) {
      return child;
    }

    return BlocListener<AgendaPendienteBloc, AgendaPendienteState>(
      listenWhen: (AgendaPendienteState previous, AgendaPendienteState current) {
        if (_agendaPopupShown) {
          return false;
        }
        if (current is! AgendaPendienteLoaded) {
          return false;
        }
        if (current.pendientesHoy.isEmpty) {
          return false;
        }
        return previous is! AgendaPendienteLoaded;
      },
      listener: (BuildContext context, AgendaPendienteState state) {
        if (state is AgendaPendienteLoaded && state.pendientesHoy.isNotEmpty) {
          _agendaPopupShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            showAgendaPendientesPopupDialog(
              context: context,
              pendientes: state.pendientesHoy,
              userId: _getUserId(context),
            ).whenComplete(() {
              if (mounted) {
                setState(() => _agendaPopupShown = false);
                _showMantenimientoPopup();
              }
            });
          });
        }
      },
      child: child,
    );
  }

  void _showMantenimientoPopup() {
    if (_mantenimientoPopupShown || _agendaPopupShown) {
      return;
    }
    if (_mantenimientosPendientes.isEmpty) {
      return;
    }
    _mantenimientoPopupShown = true;

    final List<MantenimientoEntity> lista = _mantenimientosPendientes;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _mantenimientoPopupShown = false;
        return;
      }
      // await del Future<bool>: se resuelve tanto si el popup se abrió y se
      // cerró, como si no se abrió (todo visto hoy). Así el flag siempre se
      // resetea y no queda bloqueado en true para futuras aperturas.
      await showMantenimientosProximosPopupDialog(
        context: context,
        mantenimientos: lista,
        userId: _getUserId(context),
      );
      if (mounted) {
        setState(() {
          _mantenimientosPendientes = const <MantenimientoEntity>[];
          _mantenimientoPopupShown = false;
        });
      } else {
        _mantenimientoPopupShown = false;
      }
    });
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

/// Sección de gráficas filtrada por rol.
class _RoleChartsSection extends StatelessWidget {
  const _RoleChartsSection({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        if (state is! HomeLoaded) {
          return const SizedBox.shrink();
        }
        return RoleDashboardCharts(role: role, homeState: state);
      },
    );
  }
}

/// Vista de error con botón de reintentar.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
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
            message,
            style: const TextStyle(fontSize: 14, color: AppColors.gray600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
