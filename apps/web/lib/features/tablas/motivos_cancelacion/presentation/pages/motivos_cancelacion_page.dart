import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_bloc.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_state.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/widgets/motivo_cancelacion_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/widgets/motivo_cancelacion_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de motivos de cancelación
class MotivosCancelacionPage extends StatelessWidget {
  const MotivosCancelacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<MotivoCancelacionBloc>(
        create: (BuildContext context) =>
            getIt<MotivoCancelacionBloc>()..add(const MotivoCancelacionLoadRequested()),
        child: const _MotivosCancelacionView(),
      ),
    );
  }
}

/// Vista principal de motivos de cancelación
class _MotivosCancelacionView extends StatefulWidget {
  const _MotivosCancelacionView();

  @override
  State<_MotivosCancelacionView> createState() => _MotivosCancelacionViewState();
}

class _MotivosCancelacionViewState extends State<_MotivosCancelacionView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<MotivoCancelacionBloc, MotivoCancelacionState>(
        builder: (BuildContext context, MotivoCancelacionState state) {
          if (state is MotivoCancelacionLoading) {
            return const Center(
              child: AppLoadingIndicator(message: 'Cargando motivos de cancelación...'),
            );
          }

          if (state is MotivoCancelacionError) {
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
                      'Error al cargar motivos de cancelación',
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
                    icon: Icons.cancel_outlined,
                    title: 'Gestión de Motivos de Cancelación',
                    subtitle: 'Administra los motivos de cancelación disponibles en el sistema',
                    addButtonLabel: 'Nuevo Motivo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                    extra: MotivoCancelacionSearchField(
                      searchQuery: _searchQuery,
                      onSearchChanged: (String query) {
                        setState(() => _searchQuery = query);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing),
                Expanded(
                  child: MotivoCancelacionTable(searchQuery: _searchQuery),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(MotivoCancelacionState state) {
    String total = '-';

    if (state is MotivoCancelacionLoaded) {
      total = state.motivos.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.cancel_outlined,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<MotivoCancelacionBloc>.value(
        value: context.read<MotivoCancelacionBloc>(),
        child: const MotivoCancelacionFormDialog(),
      ),
    );
  }
}
