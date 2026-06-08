import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
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
class _CategoriasVehiculoView extends StatefulWidget {
  const _CategoriasVehiculoView();

  @override
  State<_CategoriasVehiculoView> createState() => _CategoriasVehiculoViewState();
}

class _CategoriasVehiculoViewState extends State<_CategoriasVehiculoView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<CategoriaVehiculoBloc, CategoriaVehiculoState>(
        builder: (BuildContext context, CategoriaVehiculoState state) {
          if (state is CategoriaVehiculoLoading) {
            return const Center(
              child: AppLoadingIndicator(message: 'Cargando categorías de vehículo...'),
            );
          }

          if (state is CategoriaVehiculoError) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingXl),
                margin: const EdgeInsets.all(AppSizes.paddingXl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  border: Border.all(color: AppColors.error),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: AppSizes.spacing),
                    const Text(
                      'Error al cargar categorías de vehículo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingXl,
              AppSizes.paddingXl,
              AppSizes.paddingXl,
              AppSizes.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.category_outlined,
                    title: 'Gestión de Categorías de Vehículo',
                    subtitle: 'Administra las categorías de vehículo disponibles en el sistema',
                    addButtonLabel: 'Nueva Categoría',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                    extra: SizedBox(
                      width: 250,
                      child: CategoriaVehiculoSearchField(
                        searchQuery: _searchQuery,
                        onSearchChanged: (String query) {
                          setState(() => _searchQuery = query);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing),
                Expanded(
                  child: CategoriaVehiculoTable(searchQuery: _searchQuery),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
