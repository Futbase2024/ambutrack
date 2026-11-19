import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/widgets/gestion/tipo_paciente_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de tipos de paciente (layout tipo programa de gestión)
class TiposPacientePage extends StatelessWidget {
  const TiposPacientePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<TipoPacienteBloc>(
        create: (BuildContext _) => getIt<TipoPacienteBloc>()..add(const TipoPacienteLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: TipoPacienteGestionView(),
        ),
      ),
    );
  }
}
