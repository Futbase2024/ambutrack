import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../registro_horario/domain/repositories/registro_horario_repository.dart';
import '../../../servicios/domain/repositories/traslados_repository.dart';
import '../cubit/parte_diario_cubit.dart';
import '../widgets/parte_diario_widgets.dart';

/// Parte diario: resumen de la jornada del trabajador (fichajes, servicios
/// realizados y km) para el día elegido.
class PartesDiariosPage extends StatelessWidget {
  const PartesDiariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthState auth = context.read<AuthBloc>().state;
    final String? personalId = auth is AuthAuthenticated ? auth.personal?.id : null;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Parte diario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: SafeArea(
        child: personalId == null
            ? const ParteMensaje(
                icon: Icons.person_off_outlined,
                texto: 'Tu usuario no está vinculado a una ficha de personal.',
              )
            : BlocProvider<ParteDiarioCubit>(
                create: (_) => ParteDiarioCubit(
                  trasladosRepository: getIt<TrasladosRepository>(),
                  registroRepository: getIt<RegistroHorarioRepository>(),
                  personalId: personalId,
                )..cargar(),
                child: const _ParteDiarioView(),
              ),
      ),
    );
  }
}

class _ParteDiarioView extends StatelessWidget {
  const _ParteDiarioView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParteDiarioCubit, ParteDiarioState>(
      builder: (BuildContext context, ParteDiarioState state) {
        final ParteDiarioCubit cubit = context.read<ParteDiarioCubit>();
        return Column(
          children: <Widget>[
            ParteDiaSelector(
              dia: state.dia,
              onAnterior: cubit.diaAnterior,
              onSiguiente: cubit.puedeAvanzar ? cubit.diaSiguiente : null,
            ),
            Expanded(
              child: switch (state) {
                ParteDiarioLoading() => const Center(child: CircularProgressIndicator()),
                ParteDiarioError(:final String message) => ParteMensaje(
                    icon: Icons.error_outline,
                    texto: message,
                    onReintentar: cubit.cargar,
                  ),
                ParteDiarioLoaded() => RefreshIndicator(
                    onRefresh: cubit.cargar,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: <Widget>[
                        ParteResumenCard(resumen: state.resumen),
                        const SizedBox(height: 16),
                        ParteFichajesSection(fichajes: state.fichajes),
                        const SizedBox(height: 16),
                        ParteServiciosSection(traslados: state.traslados),
                      ],
                    ),
                  ),
              },
            ),
          ],
        );
      },
    );
  }
}
