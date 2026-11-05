import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_bloc.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_event.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/gestion/usuarios_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Página de gestión de usuarios (layout tipo programa de gestión)
class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<UsuariosBloc>(
        create: (_) => GetIt.instance<UsuariosBloc>()..add(const UsuariosLoadAllRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: UsuariosGestionView(),
        ),
      ),
    );
  }
}
