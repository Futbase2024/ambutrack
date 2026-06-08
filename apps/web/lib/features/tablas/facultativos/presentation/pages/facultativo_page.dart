import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_bloc.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_event.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_state.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/facultativo_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/facultativo_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de facultativos
class FacultativoPage extends StatelessWidget {
  const FacultativoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<FacultativoBloc>(
        create: (BuildContext context) => getIt<FacultativoBloc>()..add(const FacultativoLoadAllRequested()),
        child: const _FacultativoView(),
      ),
    );
  }
}

/// Vista principal de facultativos
class _FacultativoView extends StatefulWidget {
  const _FacultativoView();

  @override
  State<_FacultativoView> createState() => _FacultativoViewState();
}

class _FacultativoViewState extends State<_FacultativoView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<FacultativoBloc, FacultativoState>(
        builder: (BuildContext context, FacultativoState state) {
          if (state is FacultativoLoading) {
            return const Center(
              child: AppLoadingIndicator(message: 'Cargando facultativos...'),
            );
          }

          if (state is FacultativoError) {
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
                      'Error al cargar facultativos',
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
                    icon: Icons.medical_services_outlined,
                    title: 'Gestión de Facultativos',
                    subtitle: 'Administra los médicos y personal facultativo del sistema',
                    addButtonLabel: 'Nuevo Facultativo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                    extra: SizedBox(
                      width: 250,
                      child: FacultativoSearchField(
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
                  child: FacultativoTable(searchQuery: _searchQuery),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(FacultativoState state) {
    String total = '-';

    if (state is FacultativoLoaded) {
      total = state.facultativos.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.medical_services_outlined,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<FacultativoBloc>.value(
        value: context.read<FacultativoBloc>(),
        child: const FacultativoFormDialog(),
      ),
    );
  }
}
