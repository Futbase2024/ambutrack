import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
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
import '../widgets/parte_pdf_boton.dart';

/// Parte diario: resumen de la jornada del trabajador (fichajes, servicios
/// realizados y km) para el día elegido.
class PartesDiariosPage extends StatelessWidget {
  const PartesDiariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthState auth = context.read<AuthBloc>().state;
    final TPersonalEntity? personal = auth is AuthAuthenticated ? auth.personal : null;
    final String? personalId = personal?.id;

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
                child: _ParteDiarioView(personal: personal!),
              ),
      ),
    );
  }
}

class _ParteDiarioView extends StatelessWidget {
  const _ParteDiarioView({required this.personal});

  final TPersonalEntity personal;

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
                        PartePdfBoton(
                          personalId: personal.id,
                          personalNombre: personal.nombreCompleto,
                          dia: state.dia,
                          empresaId: personal.empresaId,
                        ),
                        const SizedBox(height: 16),
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
