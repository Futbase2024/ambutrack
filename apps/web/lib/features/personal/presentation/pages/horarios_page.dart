import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/cuadrante_view.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Cuadrante del Personal
class HorariosPage extends StatelessWidget {
  const HorariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<CuadranteBloc>(
            create: (_) => getIt<CuadranteBloc>(),
          ),
          BlocProvider<TurnosBloc>(
            create: (_) => getIt<TurnosBloc>(),
          ),
        ],
        child: const CuadranteView(),
      ),
    );
  }
}
