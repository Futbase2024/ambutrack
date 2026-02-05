import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/plantillas_turnos_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de plantillas de turnos
class PlantillasTurnosPage extends StatelessWidget {
  const PlantillasTurnosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<PlantillasTurnosBloc>(
        create: (_) => getIt<PlantillasTurnosBloc>()
          ..add(const PlantillasTurnosLoadRequested()),
        child: const _PlantillasTurnosView(),
      ),
    );
  }
}

/// Vista privada de plantillas de turnos
class _PlantillasTurnosView extends StatelessWidget {
  const _PlantillasTurnosView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PlantillasTurnosTable(),
    );
  }
}
