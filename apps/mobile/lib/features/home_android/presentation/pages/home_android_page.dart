import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading/app_skeleton.dart';
import '../../../../core/widgets/menu/app_menu.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../registro_horario/presentation/bloc/registro_horario_bloc.dart';
import '../../../registro_horario/presentation/bloc/registro_horario_event.dart';
import '../../../registro_horario/presentation/bloc/registro_horario_state.dart';
import '../widgets/alertas_caducidad_section.dart';
import '../widgets/home_menu.dart';
import '../widgets/home_proximo_servicio.dart';
import '../widgets/home_turno_resumen.dart';
import '../widgets/home_user_header.dart';

/// Página Home de AmbuTrack Mobile
///
/// Dashboard principal para personal de campo.
class HomeAndroidPage extends StatefulWidget {
  const HomeAndroidPage({super.key});

  @override
  State<HomeAndroidPage> createState() => _HomeAndroidPageState();
}

class _HomeAndroidPageState extends State<HomeAndroidPage> with WidgetsBindingObserver {
  /// Se incrementa en cada refresco para recargar los servicios
  int _refreshCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarEstadoTurno();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🏠 [HomeAndroidPage] App resumed, recargando datos...');
      _refrescar();
    }
  }

  void _cargarEstadoTurno() {
    debugPrint('🏠 [HomeAndroidPage] Cargando estado del turno...');
    context.read<RegistroHorarioBloc>().add(const ObtenerContextoTurno());
  }

  void _refrescar() {
    _cargarEstadoTurno();
    if (mounted) {
      setState(() => _refreshCount++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthInitial || authState is AuthLoading) {
            return const _HomeSkeleton();
          }

          if (authState is! AuthAuthenticated) {
            return const Center(child: Text('No autenticado'));
          }

          return BlocBuilder<RegistroHorarioBloc, RegistroHorarioState>(
            builder: (context, registroState) {
              return RefreshIndicator(
                onRefresh: () async {
                  debugPrint('🏠 [HomeAndroidPage] Pull-to-refresh activado');
                  _refrescar();
                  await Future<void>.delayed(const Duration(milliseconds: 500));
                },
                color: AppColors.primary,
                child: _HomeContenido(
                  authState: authState,
                  turno: _DatosTurno.desde(registroState),
                  refreshCount: _refreshCount,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Datos del turno extraídos del estado del RegistroHorarioBloc
class _DatosTurno {
  const _DatosTurno({required this.activo, this.entrada, this.matricula});

  factory _DatosTurno.desde(RegistroHorarioState state) {
    final (EstadoFichaje? estado, RegistroHorarioEntity? ultimo, String? matricula) = switch (state) {
      RegistroHorarioLoadedWithContext() => (state.estadoActual, state.ultimoRegistro, state.vehiculo?.matricula),
      RegistroHorarioLoaded() => (state.estadoActual, state.ultimoRegistro, null),
      _ => (null, null, null),
    };
    final bool activo = estado == EstadoFichaje.dentro;
    return _DatosTurno(
      activo: activo,
      entrada: activo && ultimo?.tipo == 'entrada' ? ultimo?.fechaHora : null,
      matricula: matricula,
    );
  }

  final bool activo;
  final DateTime? entrada;
  final String? matricula;
}

/// Contenido desplazable de la home
class _HomeContenido extends StatelessWidget {
  const _HomeContenido({required this.authState, required this.turno, required this.refreshCount});

  final AuthAuthenticated authState;
  final _DatosTurno turno;
  final int refreshCount;

  @override
  Widget build(BuildContext context) {
    final String idConductor = authState.personal?.id ?? authState.user.id;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        HomeUserHeader(user: authState.user, personal: authState.personal, turnoActivo: turno.activo),
        const SizedBox(height: 16),
        // Alertas de caducidad: no ocupa espacio, abre un diálogo si hay avisos
        const AlertasCaducidadHomeSection(),
        if (turno.activo) ...<Widget>[
          HomeTurnoResumen(entrada: turno.entrada, matricula: turno.matricula),
          const SizedBox(height: 28),
          const AppMenuSeccion('Próximo servicio'),
          HomeProximoServicio(key: ValueKey<int>(refreshCount), idConductor: idConductor),
        ],
        const SizedBox(height: 28),
        HomeMenu(turnoActivo: turno.activo),
      ],
    );
  }
}

/// Esqueleto de la home mientras se verifica la sesión
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: const <Widget>[
        AppSkeleton(height: 140, radius: 20),
        SizedBox(height: 28),
        AppSkeleton(width: 110, height: 12),
        SizedBox(height: 10),
        AppSkeleton(height: 150, radius: 16),
        SizedBox(height: 28),
        AppSkeleton(width: 90, height: 12),
        SizedBox(height: 10),
        AppSkeleton(height: 220, radius: 16),
      ],
    );
  }
}
