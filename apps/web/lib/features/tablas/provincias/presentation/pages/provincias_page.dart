import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_bloc.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_event.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_state.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/provincia_filters.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/provincia_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/widgets/provincia_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de provincias
class ProvinciasPage extends StatelessWidget {
  const ProvinciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ProvinciaBloc>(
        create: (BuildContext context) => getIt<ProvinciaBloc>()..add(const ProvinciaLoadAllRequested()),
        child: const _ProvinciasView(),
      ),
    );
  }
}

/// Vista principal de provincias
class _ProvinciasView extends StatefulWidget {
  const _ProvinciasView();

  @override
  State<_ProvinciasView> createState() => _ProvinciasViewState();
}

class _ProvinciasViewState extends State<_ProvinciasView> {
  String _searchQuery = '';
  ProvinciaFilterData _filterData = const ProvinciaFilterData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<ProvinciaBloc, ProvinciaState>(
        builder: (BuildContext context, ProvinciaState state) {
          if (state is ProvinciaLoading) {
            return const Center(
              child: AppLoadingIndicator(message: 'Cargando provincias...'),
            );
          }

          if (state is ProvinciaError) {
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
                      'Error al cargar provincias',
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
                    icon: Icons.map,
                    title: 'Gestión de Provincias',
                    subtitle: 'Administra las provincias y comunidades autónomas del sistema',
                    addButtonLabel: 'Nueva Provincia',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                    extra: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ProvinciaFilters(
                          onFiltersChanged: (ProvinciaFilterData filterData) {
                            setState(() => _filterData = filterData);
                          },
                        ),
                        const SizedBox(width: AppSizes.spacing),
                        SizedBox(
                          width: 250,
                          child: ProvinciaSearchField(
                            searchQuery: _searchQuery,
                            onSearchChanged: (String query) {
                              setState(() => _searchQuery = query);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing),
                Expanded(
                  child: ProvinciaTable(
                    searchQuery: _searchQuery,
                    filterData: _filterData,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(ProvinciaState state) {
    String total = '-';

    if (state is ProvinciaLoaded) {
      total = state.provincias.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.map,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<ProvinciaBloc>.value(
        value: context.read<ProvinciaBloc>(),
        child: const ProvinciaFormDialog(),
      ),
    );
  }
}
