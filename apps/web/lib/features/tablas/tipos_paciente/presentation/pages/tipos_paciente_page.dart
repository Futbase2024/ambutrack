import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_state.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/widgets/tipo_paciente_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/widgets/tipo_paciente_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de tipos de paciente
class TiposPacientePage extends StatelessWidget {
  const TiposPacientePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<TipoPacienteBloc>(
        create: (BuildContext context) => getIt<TipoPacienteBloc>()..add(const TipoPacienteLoadRequested()),
        child: const _TiposPacienteView(),
      ),
    );
  }
}

/// Vista principal de tipos de paciente
class _TiposPacienteView extends StatefulWidget {
  const _TiposPacienteView();

  @override
  State<_TiposPacienteView> createState() => _TiposPacienteViewState();
}

class _TiposPacienteViewState extends State<_TiposPacienteView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<TipoPacienteBloc, TipoPacienteState>(
        builder: (BuildContext context, TipoPacienteState state) {
          if (state is TipoPacienteLoading) {
            return const Center(
              child: AppLoadingIndicator(message: 'Cargando tipos de paciente...'),
            );
          }

          if (state is TipoPacienteError) {
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
                      'Error al cargar tipos de paciente',
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
                    icon: Icons.personal_injury,
                    title: 'Gestión de Tipos de Paciente',
                    subtitle: 'Administra los tipos de paciente disponibles en el sistema',
                    addButtonLabel: 'Nuevo Tipo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                    extra: SizedBox(
                      width: 250,
                      child: TipoPacienteSearchField(
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
                  child: TipoPacienteTable(searchQuery: _searchQuery),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(TipoPacienteState state) {
    String total = '-';

    if (state is TipoPacienteLoaded) {
      total = state.tiposPaciente.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.personal_injury,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<TipoPacienteBloc>.value(
        value: context.read<TipoPacienteBloc>(),
        child: const TipoPacienteFormDialog(),
      ),
    );
  }
}
