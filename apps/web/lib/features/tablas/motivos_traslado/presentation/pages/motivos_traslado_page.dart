import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_state.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/widgets/motivo_traslado_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/widgets/motivo_traslado_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de motivos de traslado
class MotivosTrasladoPage extends StatelessWidget {
  const MotivosTrasladoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<MotivoTrasladoBloc>(
        create: (BuildContext context) => getIt<MotivoTrasladoBloc>()..add(const MotivoTrasladoLoadAllRequested()),
        child: const _MotivosTrasladoView(),
      ),
    );
  }
}

/// Vista principal de motivos de traslado
class _MotivosTrasladoView extends StatefulWidget {
  const _MotivosTrasladoView();

  @override
  State<_MotivosTrasladoView> createState() => _MotivosTrasladoViewState();
}

class _MotivosTrasladoViewState extends State<_MotivosTrasladoView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<MotivoTrasladoBloc, MotivoTrasladoState>(
        builder: (BuildContext context, MotivoTrasladoState state) {
          if (state is MotivoTrasladoLoading) {
            return const Center(
              child: AppLoadingIndicator(message: 'Cargando motivos de traslado...'),
            );
          }

          if (state is MotivoTrasladoError) {
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
                      'Error al cargar motivos de traslado',
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
                    icon: Icons.transfer_within_a_station,
                    title: 'Gestión de Motivos de Traslado',
                    subtitle: 'Administra los motivos de traslado disponibles en el sistema',
                    addButtonLabel: 'Nuevo Motivo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                    extra: MotivoTrasladoSearchField(
                      searchQuery: _searchQuery,
                      onSearchChanged: (String query) {
                        setState(() => _searchQuery = query);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing),
                Expanded(
                  child: MotivoTrasladoTable(searchQuery: _searchQuery),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(MotivoTrasladoState state) {
    String total = '-';

    if (state is MotivoTrasladoLoaded) {
      total = state.motivos.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.transfer_within_a_station,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<MotivoTrasladoBloc>.value(
        value: context.read<MotivoTrasladoBloc>(),
        child: const MotivoTrasladoFormDialog(),
      ),
    );
  }
}
