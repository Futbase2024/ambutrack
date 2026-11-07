import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/administracion/configuracion/presentation/widgets/configuracion_content.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Configuración General (solo lectura).
///
/// No existe almacenamiento de configuración global en BD; se muestran los
/// parámetros que sí existen (app, flavor, backend, sesión, empresa, rol).
/// Propuesta de persistencia: `docs/plans/administracion_configuracion.md`.
class ConfiguracionGeneralPage extends StatelessWidget {
  const ConfiguracionGeneralPage({this.title = 'Configuración General', super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: GestionFrame(
          toolbar: GestionToolbar(
            title: title,
            icon: Icons.settings,
            groups: const <List<GestionToolbarAction>>[],
            trailing: const GestionToolbarBadge(
              label: 'Solo lectura',
              color: AppColors.gray600,
              icon: Icons.lock_outline,
            ),
          ),
          contentPadding: EdgeInsets.zero,
          content: BlocBuilder<AuthBloc, AuthState>(
            builder: (BuildContext context, AuthState state) => ConfiguracionContent(
              user: state is AuthAuthenticated ? state.user : null,
            ),
          ),
          statusBar: const GestionStatusBar(
            items: <String>[
              'Parámetros de solo lectura',
              'Sin tabla de configuración global (ver docs/plans/administracion_configuracion.md)',
            ],
          ),
        ),
      ),
    );
  }
}
