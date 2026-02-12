import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/headers/page_header.dart';
import '../bloc/usuarios_bloc.dart';
import '../bloc/usuarios_event.dart';
import '../bloc/usuarios_state.dart';
import '../widgets/usuario_form_dialog.dart';
import '../widgets/usuario_table.dart';

/// Página principal de gestión de usuarios
class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<UsuariosBloc>(
        create: (_) => GetIt.instance<UsuariosBloc>()
          ..add(const UsuariosLoadAllRequested()),
        child: const _UsuariosView(),
      ),
    );
  }
}

/// Vista interna de la página de usuarios
class _UsuariosView extends StatelessWidget {
  const _UsuariosView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          children: <Widget>[
            // Header con estadísticas
            BlocBuilder<UsuariosBloc, UsuariosState>(
              builder: (BuildContext context, UsuariosState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.people_outline,
                    title: 'Gestión de Usuarios',
                    subtitle: 'Administración de usuarios del sistema',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                    addButtonLabel: 'Nuevo Usuario',
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),
            // Tabla de usuarios
            const Expanded(child: UsuarioTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header basadas en el estado
  List<HeaderStat> _buildHeaderStats(UsuariosState state) {
    if (state is! UsuariosLoaded) {
      return <HeaderStat>[
        const HeaderStat(
          value: '-',
          icon: Icons.people,
          color: AppColors.primary,
        ),
        const HeaderStat(
          value: '-',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
        const HeaderStat(
          value: '-',
          icon: Icons.cancel_outlined,
          color: AppColors.error,
        ),
      ];
    }

    final int total = state.usuarios.length;
    final int activos = state.usuarios.where((UserEntity u) => u.activo == true).length;
    final int inactivos = total - activos;

    return <HeaderStat>[
      HeaderStat(
        value: total.toString(),
        icon: Icons.people,
        color: AppColors.primary,
      ),
      HeaderStat(
        value: activos.toString(),
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
      HeaderStat(
        value: inactivos.toString(),
        icon: Icons.cancel_outlined,
        color: AppColors.error,
      ),
    ];
  }

  /// Muestra el diálogo para crear un nuevo usuario
  void _showCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider<UsuariosBloc>.value(
        value: context.read<UsuariosBloc>(),
        child: const UsuarioFormDialog(),
      ),
    );
  }
}
