import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_state.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/widgets/categoria_vehiculo_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/widgets/categoria_vehiculo_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de categorías de vehículo
class CategoriasVehiculoPage extends StatelessWidget {
  const CategoriasVehiculoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<CategoriaVehiculoBloc>(
        create: (BuildContext context) => getIt<CategoriaVehiculoBloc>()..add(const CategoriaVehiculoLoadAllRequested()),
        child: const _CategoriasVehiculoView(),
      ),
    );
  }
}

/// Vista principal de categorías de vehículo
class _CategoriasVehiculoView extends StatelessWidget {
  const _CategoriasVehiculoView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // PageHeader con estadísticas
            BlocBuilder<CategoriaVehiculoBloc, CategoriaVehiculoState>(
              builder: (BuildContext context, CategoriaVehiculoState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.category_outlined,
                    title: 'Gestión de Categorías de Vehículo',
                    subtitle: 'Administra las categorías de vehículo disponibles en el sistema',
                    addButtonLabel: 'Nueva Categoría',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: CategoriaVehiculoTable()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(CategoriaVehiculoState state) {
    String total = '-';

    if (state is CategoriaVehiculoLoaded) {
      total = state.categorias.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.category_outlined,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<CategoriaVehiculoBloc>.value(
        value: context.read<CategoriaVehiculoBloc>(),
        child: const CategoriaVehiculoFormDialog(),
      ),
    );
  }
}
