import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimiento_form_dialog.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimiento_table_v4.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimientos_filters.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Mantenimiento Preventivo
class MantenimientoPreventivoPageV2 extends StatelessWidget {
  const MantenimientoPreventivoPageV2({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VehiculosBloc>(
            create: (BuildContext context) => getIt<VehiculosBloc>()..add(const VehiculosLoadRequested()),
          ),
          BlocProvider<MantenimientoBloc>(
            create: (BuildContext context) => getIt<MantenimientoBloc>()..add(const MantenimientoLoadRequested()),
          ),
        ],
        child: const _MantenimientoPreventivoView(),
      ),
    );
  }
}

/// Vista principal de Mantenimiento Preventivo
class _MantenimientoPreventivoView extends StatefulWidget {
  const _MantenimientoPreventivoView();

  @override
  State<_MantenimientoPreventivoView> createState() => _MantenimientoPreventivoViewState();
}

class _MantenimientoPreventivoViewState extends State<_MantenimientoPreventivoView> {
  DateTime? _pageStartTime;
  MantenimientosFilterData _filterData = const MantenimientosFilterData();

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ MantenimientoPreventivoPage: Inicio de carga de página');
  }

  void _onFilterChanged(MantenimientosFilterData filterData) {
    setState(() {
      _filterData = filterData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiculosBloc, VehiculosState>(
      listener: (BuildContext context, VehiculosState state) {
        // Medir tiempo cuando se completa la carga
        if (state is VehiculosLoaded && _pageStartTime != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageStartTime != null) {
              final Duration elapsed = DateTime.now().difference(_pageStartTime!);
              debugPrint('⏱️ Tiempo total de carga de página: ${elapsed.inMilliseconds}ms');
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
                      icon: Icons.build_circle,
                      title: 'Mantenimiento Preventivo',
                      subtitle: 'Programación y seguimiento de mantenimientos',
                      addButtonLabel: 'Programar Mantenimiento',
                      stats: _buildHeaderStats(state),
                      extra: MantenimientosFilters(onFilterChanged: _onFilterChanged),
                      onAdd: _showAddMantenimientoDialog,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spacingXl),

              // Tabla ocupa el espacio restante
              Expanded(
                child: MantenimientoTableV4(filterData: _filterData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddMantenimientoDialog() async {
    debugPrint('=== Botón Programar Mantenimiento presionado ===');
    try {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<VehiculosBloc>.value(
                value: context.read<VehiculosBloc>(),
              ),
              BlocProvider<MantenimientoBloc>.value(
                value: context.read<MantenimientoBloc>(),
              ),
            ],
            child: const MantenimientoFormDialog(),
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
    String alDia = '-';
    String proximos = '-';
    String vencidos = '-';

    if (state is VehiculosLoaded) {
      // Filtrar solo vehículos con mantenimiento programado
      final List<VehiculoEntity> vehiculosConMantenimiento = state.vehiculos
          .where((VehiculoEntity v) => v.proximoMantenimiento != null || v.ultimoMantenimiento != null)
          .toList();

      total = vehiculosConMantenimiento.length.toString();

      int alDiaCount = 0;
      int proximosCount = 0;
      int vencidosCount = 0;

      for (final VehiculoEntity vehiculo in vehiculosConMantenimiento) {
        final String estadoLabel = _getEstadoLabel(vehiculo);
        if (estadoLabel == 'Al Día') {
          alDiaCount++;
        } else if (estadoLabel == 'Próximo') {
          proximosCount++;
        } else if (estadoLabel == 'Vencido') {
          vencidosCount++;
        }
      }

      alDia = alDiaCount.toString();
      proximos = proximosCount.toString();
      vencidos = vencidosCount.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.directions_car,
      ),
      HeaderStat(
        value: alDia,
        icon: Icons.check_circle,
      ),
      HeaderStat(
        value: proximos,
        icon: Icons.warning,
      ),
      HeaderStat(
        value: vencidos,
        icon: Icons.error,
      ),
    ];
  }

  String _getEstadoLabel(VehiculoEntity vehiculo) {
    if (vehiculo.proximoMantenimiento == null) {
      return 'Sin Programar';
    }

    final DateTime hoy = DateTime.now();
    final DateTime proximo = vehiculo.proximoMantenimiento!;
    final int diasRestantes = proximo.difference(hoy).inDays;

    if (diasRestantes < 0) {
      return 'Vencido';
    } else if (diasRestantes <= 7) {
      return 'Próximo';
    } else {
      return 'Al Día';
    }
  }
}
