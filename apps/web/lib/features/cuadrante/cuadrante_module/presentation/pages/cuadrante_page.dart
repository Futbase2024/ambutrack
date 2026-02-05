import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_event.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/cuadrante_view.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal del cuadrante de personal
class CuadrantePage extends StatelessWidget {
  const CuadrantePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<CuadranteBloc>(
            create: (BuildContext context) => getIt<CuadranteBloc>()
              ..add(const CuadranteLoadRequested()),
          ),
          BlocProvider<TurnosBloc>(
            create: (BuildContext context) => getIt<TurnosBloc>(),
          ),
        ],
        child: const CuadranteView(),
      ),
    );
  }
}
