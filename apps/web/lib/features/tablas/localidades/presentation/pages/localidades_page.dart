import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_bloc.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_event.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_state.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/localidad_filters.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/localidad_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/widgets/localidad_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de localidades
class LocalidadesPage extends StatelessWidget {
  const LocalidadesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<LocalidadBloc>(
        create: (BuildContext context) => getIt<LocalidadBloc>()..add(const LocalidadLoadAllRequested()),
        child: const _LocalidadesView(),
      ),
    );
  }
}

/// Vista principal de localidades
class _LocalidadesView extends StatefulWidget {
  const _LocalidadesView();

  @override
  State<_LocalidadesView> createState() => _LocalidadesViewState();
}

class _LocalidadesViewState extends State<_LocalidadesView> {
  String _searchQuery = '';
  LocalidadFilterData _filterData = const LocalidadFilterData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<LocalidadBloc, LocalidadState>(
        builder: (BuildContext context, LocalidadState state) {
          if (state is LocalidadLoading) {
            return const Center(
              child: AppLoadingIndicator(message: 'Cargando localidades...'),
            );
          }

          if (state is LocalidadError) {
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
                      'Error al cargar localidades',
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
                    icon: Icons.location_city,
                    title: 'Gestión de Localidades',
                    subtitle: 'Administra las localidades y poblaciones del sistema',
                    addButtonLabel: 'Nueva Localidad',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                    extra: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        LocalidadFilters(
                          onFiltersChanged: (LocalidadFilterData filterData) {
                            setState(() => _filterData = filterData);
                          },
                        ),
                        const SizedBox(width: AppSizes.spacing),
                        SizedBox(
                          width: 250,
                          child: LocalidadSearchField(
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
                  child: LocalidadTable(
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

  List<HeaderStat> _buildHeaderStats(LocalidadState state) {
    String total = '-';

    if (state is LocalidadLoaded) {
      total = state.localidades.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.location_city,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<LocalidadBloc>.value(
        value: context.read<LocalidadBloc>(),
        child: const LocalidadFormDialog(),
      ),
    );
  }
}
