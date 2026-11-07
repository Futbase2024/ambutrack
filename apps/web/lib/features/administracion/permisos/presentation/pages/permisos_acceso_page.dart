import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/bloc/permisos_acceso_bloc.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/bloc/permisos_acceso_event.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/widgets/permisos_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Permisos de Acceso (matriz Rol × Módulo, solo lectura)
class PermisosAccesoPage extends StatelessWidget {
  const PermisosAccesoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<PermisosAccesoBloc>(
        create: (BuildContext _) =>
            getIt<PermisosAccesoBloc>()..add(const PermisosAccesoLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: PermisosGestionView(),
        ),
      ),
    );
  }
}
