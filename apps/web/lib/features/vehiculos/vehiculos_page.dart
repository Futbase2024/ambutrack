import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/lang/app_strings.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/vehiculo_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/vehiculos_filters.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/vehiculos_table_v4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VehiculosPage extends StatelessWidget {
  const VehiculosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<VehiculosBloc>.value(
        value: getIt<VehiculosBloc>(),
        child: const _VehiculosView(),
      ),
    );
  }
}

class _VehiculosView extends StatefulWidget {
  const _VehiculosView();

  @override
  State<_VehiculosView> createState() => _VehiculosViewState();
}

class _VehiculosViewState extends State<_VehiculosView> {
  DateTime? _pageStartTime;
  VehiculosFilterData _filterData = const VehiculosFilterData();

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ VehiculosPage: Inicio de carga de página');

    final VehiculosBloc bloc = context.read<VehiculosBloc>();
    if (bloc.state is VehiculosInitial) {
      debugPrint('🚀 VehiculosPage: Primera carga, solicitando vehículos...');
      bloc.add(const VehiculosLoadRequested());
    } else if (bloc.state is VehiculosLoaded) {
      final VehiculosLoaded loadedState = bloc.state as VehiculosLoaded;
      debugPrint('⚡ VehiculosPage: Datos ya cargados (${loadedState.vehiculos.length} vehículos), reutilizando estado del BLoC');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageStartTime != null) {
          final Duration elapsed = DateTime.now().difference(_pageStartTime!);
          debugPrint('⏱️ Tiempo total de carga de página (con datos en caché): ${elapsed.inMilliseconds}ms');
          _pageStartTime = null;
        }
      });
    }
  }

  void _onFilterChanged(VehiculosFilterData filterData) {
    setState(() {
      _filterData = filterData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiculosBloc, VehiculosState>(
      listener: (BuildContext context, VehiculosState state) {
        if (state is VehiculosLoaded && _pageStartTime != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageStartTime != null) {
              final Duration elapsed = DateTime.now().difference(_pageStartTime!);
              debugPrint('⏱️ Tiempo total de carga de página (primera vez): ${elapsed.inMilliseconds}ms');
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
              BlocBuilder<VehiculosBloc, VehiculosState>(
                builder: (BuildContext context, VehiculosState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.directions_car,
                      title: AppStrings.vehiculosTitulo,
                      subtitle: AppStrings.vehiculosSubtitulo,
                      addButtonLabel: AppStrings.vehiculosAgregar,
                      stats: _buildHeaderStats(state),
                      onAdd: _showAddVehiculoDialog,
                      extra: VehiculosFilters(onFilterChanged: _onFilterChanged),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              Expanded(
                child: VehiculosTableV4(filterData: _filterData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddVehiculoDialog() async {
    debugPrint('=== Botón Agregar Vehículo presionado ===');
    try {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return BlocProvider<VehiculosBloc>.value(
            value: context.read<VehiculosBloc>(),
            child: const VehiculoFormDialog(),
          );
        },
      );

      debugPrint('Diálogo cerrado');
    } catch (e, stack) {
      debugPrint('Error en showDialog: $e');
      debugPrint('Stack: $stack');
    }
  }

  List<HeaderStat> _buildHeaderStats(VehiculosState state) {
    String total = '-';
    String disponibles = '-';
    String enServicio = '-';
    String mantenimiento = '-';

    if (state is VehiculosLoaded) {
      total = state.total.toString();
      disponibles = state.disponibles.toString();
      enServicio = state.enServicio.toString();
      mantenimiento = state.mantenimiento.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.directions_car,
      ),
      HeaderStat(
        value: disponibles,
        icon: Icons.check_circle,
      ),
      HeaderStat(
        value: enServicio,
        icon: Icons.local_shipping,
      ),
      HeaderStat(
        value: mantenimiento,
        icon: Icons.build,
      ),
    ];
  }
}
