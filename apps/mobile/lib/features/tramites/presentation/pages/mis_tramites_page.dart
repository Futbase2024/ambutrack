import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/ausencias_bloc.dart';
import '../bloc/ausencias_event.dart';
import '../bloc/ausencias_state.dart';
import '../bloc/vacaciones_bloc.dart';
import '../bloc/vacaciones_event.dart';
import '../bloc/vacaciones_state.dart';
import '../widgets/lista/tramite_item.dart';
import '../widgets/lista/tramites_lista.dart';

/// Historial de trámites del usuario, separado en vacaciones y ausencias
class MisTramitesPage extends StatefulWidget {
  const MisTramitesPage({super.key});

  @override
  State<MisTramitesPage> createState() => _MisTramitesPageState();
}

class _MisTramitesPageState extends State<MisTramitesPage> {
  @override
  void initState() {
    super.initState();
    // Si algún bloc no tiene la lista cargada (p. ej. tras abrir un formulario), recargar
    if (context.read<VacacionesBloc>().state is! VacacionesLoaded) {
      _recargarVacaciones();
    }
    if (context.read<AusenciasBloc>().state is! AusenciasLoaded) {
      _recargarAusencias();
    }
  }

  String? get _personalId {
    final AuthState authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.personal?.id : null;
  }

  Future<void> _recargarVacaciones() async {
    final String? id = _personalId;
    if (id != null) {
      context.read<VacacionesBloc>().add(VacacionesLoadByPersonalRequested(id));
    }
  }

  Future<void> _recargarAusencias() async {
    final String? id = _personalId;
    if (id != null) {
      context.read<AusenciasBloc>().add(AusenciasLoadByPersonalRequested(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final VacacionesState vacaciones = context.watch<VacacionesBloc>().state;
    final AusenciasState ausencias = context.watch<AusenciasBloc>().state;
    final int nVacaciones = vacaciones is VacacionesLoaded ? vacaciones.vacaciones.length : 0;
    final int nAusencias = ausencias is AusenciasLoaded ? ausencias.ausencias.length : 0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          title: const Text('Mis trámites'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
            labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            tabs: <Widget>[
              Tab(text: nVacaciones > 0 ? 'Vacaciones ($nVacaciones)' : 'Vacaciones'),
              Tab(text: nAusencias > 0 ? 'Ausencias ($nAusencias)' : 'Ausencias'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: <Widget>[
              _VacacionesTab(state: vacaciones, onRefresh: _recargarVacaciones),
              _AusenciasTab(state: ausencias, onRefresh: _recargarAusencias),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pestaña de vacaciones
class _VacacionesTab extends StatelessWidget {
  const _VacacionesTab({required this.state, required this.onRefresh});

  final VacacionesState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final VacacionesState s = state;
    final bool cargado = s is VacacionesLoaded;

    return TramitesLista(
      cargando: !cargado && s is! VacacionesError,
      error: s is VacacionesError ? s.message : null,
      pendientes: cargado ? s.pendientes.map(TramiteItem.vacacion).toList() : const <TramiteItem>[],
      aprobados: cargado ? s.aprobadas.map(TramiteItem.vacacion).toList() : const <TramiteItem>[],
      rechazados: cargado ? s.rechazadas.map(TramiteItem.vacacion).toList() : const <TramiteItem>[],
      textoVacio: 'Cuando solicites vacaciones aparecerán aquí con su estado.',
      onRefresh: onRefresh,
    );
  }
}

/// Pestaña de ausencias (bajas, permisos…)
class _AusenciasTab extends StatelessWidget {
  const _AusenciasTab({required this.state, required this.onRefresh});

  final AusenciasState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final AusenciasState s = state;
    final bool cargado = s is AusenciasLoaded;
    List<TramiteItem> mapear(List<AusenciaEntity> lista) =>
        lista.map((a) => TramiteItem.ausencia(a, cargado ? s.tiposAusencia : const <TipoAusenciaEntity>[])).toList();

    return TramitesLista(
      cargando: !cargado && s is! AusenciasError,
      error: s is AusenciasError ? s.message : null,
      pendientes: cargado ? mapear(s.pendientes) : const <TramiteItem>[],
      aprobados: cargado ? mapear(s.aprobadas) : const <TramiteItem>[],
      rechazados: cargado ? mapear(s.rechazadas) : const <TramiteItem>[],
      textoVacio: 'Cuando solicites una baja, un permiso u otra ausencia aparecerá aquí.',
      onRefresh: onRefresh,
    );
  }
}
