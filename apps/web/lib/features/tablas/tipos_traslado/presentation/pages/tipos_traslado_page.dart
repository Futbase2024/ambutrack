import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_state.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/widgets/tipo_traslado_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/widgets/tipo_traslado_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de tipos de traslado
class TiposTrasladoPage extends StatelessWidget {
  const TiposTrasladoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<TipoTrasladoBloc>(
        create: (BuildContext context) =>
            getIt<TipoTrasladoBloc>()..add(const TipoTrasladoLoadRequested()),
        child: const _TiposTrasladoView(),
      ),
    );
  }
}

/// Vista principal de tipos de traslado
class _TiposTrasladoView extends StatefulWidget {
  const _TiposTrasladoView();

  @override
  State<_TiposTrasladoView> createState() => _TiposTrasladoViewState();
}

class _TiposTrasladoViewState extends State<_TiposTrasladoView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<TipoTrasladoBloc, TipoTrasladoState>(
        builder: (BuildContext context, TipoTrasladoState state) {
          if (state is TipoTrasladoLoading) {
            return const Center(
              child: AppLoadingIndicator(message: 'Cargando tipos de traslado...'),
            );
          }

          if (state is TipoTrasladoError) {
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
                      'Error al cargar tipos de traslado',
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
                    icon: Icons.swap_horiz,
                    title: 'Gestión de Tipos de Traslado',
                    subtitle: 'Administra los tipos de traslado disponibles en el sistema',
                    addButtonLabel: 'Nuevo Tipo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                    extra: TipoTrasladoSearchField(
                      searchQuery: _searchQuery,
                      onSearchChanged: (String query) {
                        setState(() => _searchQuery = query);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing),
                Expanded(
                  child: TipoTrasladoTable(searchQuery: _searchQuery),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(TipoTrasladoState state) {
    String total = '-';

    if (state is TipoTrasladoLoaded) {
      total = state.tipos.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.swap_horiz,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<TipoTrasladoBloc>.value(
        value: context.read<TipoTrasladoBloc>(),
        child: const TipoTrasladoFormDialog(),
      ),
    );
  }
}
