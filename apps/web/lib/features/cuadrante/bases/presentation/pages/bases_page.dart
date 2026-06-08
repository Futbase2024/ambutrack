import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bloc.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/base_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/bases_filters.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/bases_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BasesPage extends StatelessWidget {
  const BasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<BasesBloc>.value(
        value: getIt<BasesBloc>(),
        child: const _BasesView(),
      ),
    );
  }
}

class _BasesView extends StatefulWidget {
  const _BasesView();

  @override
  State<_BasesView> createState() => _BasesViewState();
}

class _BasesViewState extends State<_BasesView> {
  BasesFilterData _filterData = const BasesFilterData();

  @override
  void initState() {
    super.initState();
    final BasesBloc bloc = context.read<BasesBloc>();
    if (bloc.state is BasesInitial) {
      bloc.add(const BasesLoadRequested());
    }
  }

  void _onFilterChanged(BasesFilterData data) {
    setState(() => _filterData = data);
  }

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
            BlocBuilder<BasesBloc, BasesState>(
              builder: (BuildContext context, BasesState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.location_city,
                    title: 'Gestión de Bases',
                    subtitle: 'Administra las bases y centros del sistema',
                    addButtonLabel: 'Nueva Base',
                    stats: _buildHeaderStats(state),
                    extra: BasesFilters(onFilterChanged: _onFilterChanged),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacing),
            Expanded(
              child: BasesTable(filterData: _filterData),
            ),
          ],
        ),
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(BasesState state) {
    if (state is! BasesLoaded) {
      return const <HeaderStat>[
        HeaderStat(value: '-', icon: Icons.location_city),
        HeaderStat(value: '-', icon: Icons.check_circle),
        HeaderStat(value: '-', icon: Icons.cancel),
      ];
    }

    final List<BaseCentroEntity> bases = state.bases;

    return <HeaderStat>[
      HeaderStat(
        value: bases.length.toString(),
        icon: Icons.location_city,
      ),
      HeaderStat(
        value: bases.where((BaseCentroEntity b) => b.activo).length.toString(),
        icon: Icons.check_circle,
      ),
      HeaderStat(
        value: bases.where((BaseCentroEntity b) => !b.activo).length.toString(),
        icon: Icons.cancel,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<BasesBloc>.value(
        value: context.read<BasesBloc>(),
        child: const BaseFormDialog(),
      ),
    );
  }
}
