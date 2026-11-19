import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/dialogs.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/repositories/vestuario_repository_impl.dart';
import '../cubit/vestuario_cubit.dart';
import '../cubit/vestuario_state.dart';
import '../widgets/mis_prendas_tab.dart';
import '../widgets/mis_tallas_tab.dart';
import '../widgets/solicitud_form_sheet.dart';
import '../widgets/solicitudes_tab.dart';

/// "Mi vestuario": prendas entregadas, solicitudes y tallas del trabajador
class VestuarioPage extends StatelessWidget {
  const VestuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthState auth = context.read<AuthBloc>().state;
    final String? idPersonal = auth is AuthAuthenticated ? auth.personal?.id : null;
    if (idPersonal == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text('No hay sesión activa'))),
      );
    }
    return BlocProvider<VestuarioCubit>(
      create: (_) => VestuarioCubit(VestuarioRepositoryImpl(), idPersonal: idPersonal)..cargar(),
      child: const _VestuarioView(),
    );
  }
}

class _VestuarioView extends StatelessWidget {
  const _VestuarioView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: const Text('Mi vestuario', style: TextStyle(fontWeight: FontWeight.w600)),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(text: 'Mis prendas'),
              _TabSolicitudes(),
              Tab(text: 'Mis tallas'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _solicitar(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Solicitar'),
        ),
        body: const SafeArea(child: _Contenido()),
      ),
    );
  }
}

/// Pestaña con contador de solicitudes abiertas
class _TabSolicitudes extends StatelessWidget {
  const _TabSolicitudes();

  @override
  Widget build(BuildContext context) {
    final int abiertas = context.select<VestuarioCubit, int>((VestuarioCubit c) => c.state.solicitudesAbiertas);
    return Tab(
      child: abiertas == 0
          ? const Text('Solicitudes')
          : Badge(label: Text('$abiertas'), offset: const Offset(14, -6), child: const Text('Solicitudes')),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    final VestuarioCubit cubit = context.read<VestuarioCubit>();
    return BlocBuilder<VestuarioCubit, VestuarioState>(
      builder: (BuildContext context, VestuarioState state) {
        switch (state.status) {
          case VestuarioStatus.cargando:
            return const Center(child: CircularProgressIndicator());
          case VestuarioStatus.error:
            return _ErrorVestuario(mensaje: state.error, onReintentar: cubit.cargar);
          case VestuarioStatus.listo:
            return TabBarView(
              children: <Widget>[
                MisPrendasTab(
                  state: state,
                  onRefrescar: cubit.cargar,
                  onAccion: (VestuarioEntity p, TipoSolicitudVestuario t) => _solicitar(context, tipo: t, prenda: p),
                ),
                SolicitudesTab(
                  state: state,
                  onRefrescar: cubit.cargar,
                  onCancelar: (SolicitudVestuarioEntity s) => _cancelar(context, s),
                ),
                MisTallasTab(
                  idPersonal: cubit.idPersonal,
                  tallas: state.tallas,
                  guardando: state.guardando,
                  onGuardar: (TallasPersonalEntity t) => _guardarTallas(context, t),
                ),
              ],
            );
        }
      },
    );
  }
}

class _ErrorVestuario extends StatelessWidget {
  const _ErrorVestuario({required this.mensaje, required this.onReintentar});

  final String? mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('No se pudo cargar tu vestuario.\n${mensaje ?? ''}', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Acciones =====

Future<void> _solicitar(BuildContext context, {TipoSolicitudVestuario? tipo, VestuarioEntity? prenda}) async {
  final VestuarioCubit cubit = context.read<VestuarioCubit>();
  if (cubit.state.status != VestuarioStatus.listo) {
    return;
  }
  final NuevaSolicitudVestuario? datos = await showSolicitudFormSheet(
    context,
    state: cubit.state,
    tipo: tipo ?? TipoSolicitudVestuario.nueva,
    prendaActual: prenda,
  );
  if (datos == null || !context.mounted) {
    return;
  }
  final String? error = await cubit.solicitar(datos);
  if (!context.mounted) {
    return;
  }
  await _resultado(
    context,
    error: error,
    exito: 'Solicitud enviada. Almacén la revisará y te avisaremos con una notificación.',
  );
  if (error == null && context.mounted) {
    DefaultTabController.of(context).animateTo(1);
  }
}

Future<void> _cancelar(BuildContext context, SolicitudVestuarioEntity solicitud) async {
  final VestuarioCubit cubit = context.read<VestuarioCubit>();
  final bool? ok = await showProfessionalConfirmDialog(
    context,
    title: '¿Cancelar solicitud?',
    message: 'Se cancelará tu solicitud de ${solicitud.prenda}.',
    confirmLabel: 'Cancelar solicitud',
    cancelLabel: 'Volver',
    icon: Icons.warning_amber_rounded,
    iconColor: AppColors.warning,
  );
  if (!(ok ?? false) || !context.mounted) {
    return;
  }
  final String? error = await cubit.cancelar(solicitud.id);
  if (context.mounted) {
    await _resultado(context, error: error, exito: 'Solicitud cancelada.');
  }
}

Future<void> _guardarTallas(BuildContext context, TallasPersonalEntity tallas) async {
  final String? error = await context.read<VestuarioCubit>().guardarTallas(tallas);
  if (context.mounted) {
    await _resultado(context, error: error, exito: 'Tus tallas se han guardado.');
  }
}

Future<void> _resultado(BuildContext context, {required String? error, required String exito}) {
  return showProfessionalResultDialog(
    context,
    title: error == null ? 'Hecho' : 'No se pudo completar',
    message: error ?? exito,
    icon: error == null ? Icons.check_circle_outline : Icons.error_outline,
    iconColor: error == null ? AppColors.success : AppColors.error,
  );
}
