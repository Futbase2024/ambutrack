import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/ausencias_bloc.dart';
import '../bloc/ausencias_event.dart';
import '../bloc/vacaciones_bloc.dart';
import '../bloc/vacaciones_event.dart';
import '../../../../core/widgets/menu/app_menu.dart';
import '../widgets/tramites_resumen.dart';
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
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          title: const Text('Trámites'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async => _loadTramites(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: <Widget>[
              const AppMenuSeccion('Resumen'),
              const TramitesResumen(),
              const SizedBox(height: 28),
              const AppMenuSeccion('Solicitar trámite'),
              AppMenuGrupo(
                opciones: <AppMenuOpcion>[
                  AppMenuOpcion(
                    icon: Icons.beach_access_outlined,
                    color: AppColors.info,
                    titulo: 'Vacaciones',
                    descripcion: 'Solicita días de vacaciones',
                    onTap: () => _abrirVacaciones(context),
                  ),
                  AppMenuOpcion(
                    icon: Icons.local_hospital_outlined,
                    color: AppColors.error,
                    titulo: 'Baja médica',
                    descripcion: 'Comunica una incapacidad temporal',
                    onTap: () => _abrirAusencia(context, tipo: 'baja_medica'),
                  ),
                  AppMenuOpcion(
                    icon: Icons.person_outline_rounded,
                    color: AppColors.secondary,
                    titulo: 'Permiso personal',
                    descripcion: 'Asuntos propios y permisos retribuidos',
                    onTap: () => _abrirAusencia(context, tipo: 'permiso_personal'),
                  ),
                  AppMenuOpcion(
                    icon: Icons.event_busy_outlined,
                    color: AppColors.warning,
                    titulo: 'Otras ausencias',
                    descripcion: 'Cualquier otro tipo de ausencia',
                    onTap: () => _abrirAusencia(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const AppMenuSeccion('Consultar'),
              AppMenuGrupo(
                opciones: <AppMenuOpcion>[
                  AppMenuOpcion(
                    icon: Icons.list_alt_rounded,
                    color: AppColors.primary,
                    titulo: 'Mis trámites',
                    descripcion: 'Historial y estado de tus solicitudes',
                    onTap: () => _abrirMisTramites(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirVacaciones(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<VacacionesBloc>.value(
          value: context.read<VacacionesBloc>(),
          child: const SolicitarVacacionesPage(),
        ),
      ),
    );
  }

  void _abrirAusencia(BuildContext context, {String? tipo}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<AusenciasBloc>.value(
          value: context.read<AusenciasBloc>(),
          child: SolicitarAusenciaPage(tipoPreseleccionado: tipo),
        ),
      ),
    );
  }

  void _abrirMisTramites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<VacacionesBloc>.value(value: context.read<VacacionesBloc>()),
            BlocProvider<AusenciasBloc>.value(value: context.read<AusenciasBloc>()),
          ],
          child: const MisTramitesPage(),
        ),
      ),
    );
  }
}
