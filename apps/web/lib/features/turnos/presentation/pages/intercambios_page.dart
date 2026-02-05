import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/intercambios_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/intercambios_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/intercambios_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de intercambios de turnos
class IntercambiosPage extends StatelessWidget {
  const IntercambiosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<IntercambiosBloc>(
        create: (_) => getIt<IntercambiosBloc>()
          ..add(const IntercambiosLoadRequested()),
        child: const _IntercambiosView(),
      ),
    );
  }
}

/// Vista privada de intercambios
class _IntercambiosView extends StatelessWidget {
  const _IntercambiosView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: IntercambiosTable(),
    );
  }
}
