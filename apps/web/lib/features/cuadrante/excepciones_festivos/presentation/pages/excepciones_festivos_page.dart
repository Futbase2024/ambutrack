import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/excepcion_festivo_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/excepciones_festivos_filters.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/excepciones_festivos_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de Excepciones y Festivos del Cuadrante
class ExcepcionesFestivosPage extends StatelessWidget {
  const ExcepcionesFestivosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ExcepcionesFestivosBloc>.value(
        value: getIt<ExcepcionesFestivosBloc>(),
        child: const _ExcepcionesFestivosView(),
      ),
    );
  }
}

class _ExcepcionesFestivosView extends StatefulWidget {
  const _ExcepcionesFestivosView();

  @override
  State<_ExcepcionesFestivosView> createState() =>
      _ExcepcionesFestivosViewState();
}

class _ExcepcionesFestivosViewState extends State<_ExcepcionesFestivosView> {
  DateTime? _pageStartTime;
  ExcepcionesFestivosFilterData _filterData =
      const ExcepcionesFestivosFilterData();

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ ExcepcionesFestivosPage: Inicio de carga de página');

    final ExcepcionesFestivosBloc bloc =
        context.read<ExcepcionesFestivosBloc>();
    if (bloc.state is ExcepcionesFestivosInitial) {
      debugPrint(
        '🚀 ExcepcionesFestivosPage: Primera carga, solicitando datos...',
      );
      bloc.add(const ExcepcionesFestivosLoadRequested());
    } else if (bloc.state is ExcepcionesFestivosLoaded) {
      final ExcepcionesFestivosLoaded loadedState =
          bloc.state as ExcepcionesFestivosLoaded;
      debugPrint(
        '⚡ ExcepcionesFestivosPage: Datos ya cargados '
        '(${loadedState.items.length} items), '
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

  void _onFilterChanged(ExcepcionesFestivosFilterData filterData) {
    setState(() => _filterData = filterData);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExcepcionesFestivosBloc, ExcepcionesFestivosState>(
      listener: (BuildContext context, ExcepcionesFestivosState state) {
        if (state is ExcepcionesFestivosLoaded && _pageStartTime != null) {
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
              BlocBuilder<ExcepcionesFestivosBloc, ExcepcionesFestivosState>(
                builder: (BuildContext context,
                    ExcepcionesFestivosState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.event_busy,
                      title: 'Excepciones y Festivos',
                      subtitle:
                          'Gestión de días festivos y excepciones del cuadrante',
                      addButtonLabel: 'Nueva Excepción/Festivo',
                      stats: _buildHeaderStats(state),
                      onAdd: _showCreateDialog,
                      extra: ExcepcionesFestivosFilters(
                        onFilterChanged: _onFilterChanged,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              Expanded(
                child: ExcepcionesFestivosTable(filterData: _filterData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(ExcepcionesFestivosState state) {
    String total = '-';
    String activos = '-';
    String anuales = '-';

    if (state is ExcepcionesFestivosLoaded) {
      total = state.items.length.toString();
      activos = state.items
          .where((ExcepcionFestivoEntity e) => e.activo)
          .length
          .toString();
      anuales = state.items
          .where((ExcepcionFestivoEntity e) => e.repetirAnualmente)
          .length
          .toString();
    }

    return <HeaderStat>[
      HeaderStat(value: total, icon: Icons.event_busy),
      HeaderStat(value: activos, icon: Icons.check_circle),
      HeaderStat(value: anuales, icon: Icons.autorenew),
    ];
  }

  Future<void> _showCreateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) =>
          BlocProvider<ExcepcionesFestivosBloc>.value(
            value: context.read<ExcepcionesFestivosBloc>(),
            child: const ExcepcionFestivoFormDialog(),
          ),
    );
  }
}
