import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotacion_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotaciones_filters.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/dotaciones_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de gestión de Dotaciones
class DotacionesPage extends StatelessWidget {
  const DotacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<DotacionesBloc>.value(
        value: getIt<DotacionesBloc>(),
        child: const _DotacionesView(),
      ),
    );
  }
}

class _DotacionesView extends StatefulWidget {
  const _DotacionesView();

  @override
  State<_DotacionesView> createState() => _DotacionesViewState();
}

class _DotacionesViewState extends State<_DotacionesView> {
  DateTime? _pageStartTime;
  DotacionesFilterData _filterData = const DotacionesFilterData();

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ DotacionesPage: Inicio de carga de página');

    final DotacionesBloc bloc = context.read<DotacionesBloc>();
    if (bloc.state is DotacionesInitial) {
      debugPrint('🚀 DotacionesPage: Primera carga, solicitando dotaciones...');
      bloc.add(const DotacionesLoadRequested());
    } else if (bloc.state is DotacionesLoaded) {
      final DotacionesLoaded loadedState = bloc.state as DotacionesLoaded;
      debugPrint(
        '⚡ DotacionesPage: Datos ya cargados '
        '(${loadedState.dotaciones.length} dotaciones), '
        'reutilizando estado del BLoC',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageStartTime != null) {
          final Duration elapsed =
              DateTime.now().difference(_pageStartTime!);
          debugPrint(
            '⏱️ Tiempo total de carga (caché): ${elapsed.inMilliseconds}ms',
          );
          _pageStartTime = null;
        }
      });
    }
  }

  void _onFilterChanged(DotacionesFilterData filterData) {
    setState(() => _filterData = filterData);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DotacionesBloc, DotacionesState>(
      listener: (BuildContext context, DotacionesState state) {
        if (state is DotacionesLoaded && _pageStartTime != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageStartTime != null) {
              final Duration elapsed =
                  DateTime.now().difference(_pageStartTime!);
              debugPrint(
                '⏱️ Tiempo total de carga: ${elapsed.inMilliseconds}ms',
              );
              _pageStartTime = null;
            }
          });
        }
      },
      child: Scaffold(
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
              BlocBuilder<DotacionesBloc, DotacionesState>(
                builder: (BuildContext context, DotacionesState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.assignment,
                      title: 'Gestión de Dotaciones',
                      subtitle: 'Administra las dotaciones del sistema',
                      addButtonLabel: 'Nueva Dotación',
                      stats: _buildHeaderStats(state),
                      onAdd: _showCreateDialog,
                      extra: DotacionesFilters(
                        onFilterChanged: _onFilterChanged,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              Expanded(
                child: DotacionesTable(filterData: _filterData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(DotacionesState state) {
    String total = '-';
    String activas = '-';
    String inactivas = '-';

    if (state is DotacionesLoaded) {
      total = state.dotaciones.length.toString();
      activas = state.dotaciones
          .where((DotacionEntity d) => d.activo)
          .length
          .toString();
      inactivas = state.dotaciones
          .where((DotacionEntity d) => !d.activo)
          .length
          .toString();
    }

    return <HeaderStat>[
      HeaderStat(value: total, icon: Icons.assignment),
      HeaderStat(value: activas, icon: Icons.check_circle),
      HeaderStat(value: inactivas, icon: Icons.cancel),
    ];
  }

  Future<void> _showCreateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) =>
          BlocProvider<DotacionesBloc>.value(
            value: context.read<DotacionesBloc>(),
            child: const DotacionFormDialog(),
          ),
    );
  }
}
