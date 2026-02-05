import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_state.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/itv_revision_form_dialog.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/itv_revisiones_filters.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/itv_revisiones_table_v4.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de ITV y Revisiones
class ItvRevisionesPage extends StatelessWidget {
  const ItvRevisionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VehiculosBloc>(
            create: (BuildContext context) => getIt<VehiculosBloc>()..add(const VehiculosLoadRequested()),
          ),
          BlocProvider<ItvRevisionBloc>(
            create: (BuildContext context) => getIt<ItvRevisionBloc>()..add(const ItvRevisionLoadRequested()),
          ),
        ],
        child: const _ItvRevisionesView(),
      ),
    );
  }
}

class _ItvRevisionesView extends StatefulWidget {
  const _ItvRevisionesView();

  @override
  State<_ItvRevisionesView> createState() => _ItvRevisionesViewState();
}

class _ItvRevisionesViewState extends State<_ItvRevisionesView> {
  void _onFilterChanged(ItvRevisionesFilterData filterData) {
    // Los filtros se manejan dentro de la tabla
    debugPrint('🔍 Filtros aplicados en ITV y Revisiones');
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
            BlocBuilder<ItvRevisionBloc, ItvRevisionState>(
              builder: (BuildContext context, ItvRevisionState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.fact_check,
                    title: 'ITV y Revisiones',
                    subtitle: 'Inspecciones técnicas y revisiones de vehículos',
                    addButtonLabel: 'Programar ITV/Revisión',
                    stats: _buildHeaderStats(state),
                    onAdd: _showAddItvRevisionDialog,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            Expanded(
              child: ItvRevisionesTableV4(onFilterChanged: _onFilterChanged),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddItvRevisionDialog() async {
    debugPrint('=== Botón Programar ITV/Revisión presionado ===');
    try {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<VehiculosBloc>.value(
                value: context.read<VehiculosBloc>(),
              ),
              BlocProvider<ItvRevisionBloc>.value(
                value: context.read<ItvRevisionBloc>(),
              ),
            ],
            child: const ItvRevisionFormDialog(),
          );
        },
      );

      debugPrint('Diálogo cerrado');
    } catch (e, stack) {
      debugPrint('Error en showDialog: $e');
      debugPrint('Stack: $stack');
    }
  }

  List<HeaderStat> _buildHeaderStats(ItvRevisionState state) {
    String total = '-';
    String favorables = '-';
    String desfavorables = '-';
    String negativos = '-';

    if (state is ItvRevisionLoaded) {
      total = state.itvRevisiones.length.toString();
      favorables = state.itvRevisiones
          .where((ItvRevisionEntity i) => i.resultado == ResultadoItvRevision.favorable)
          .length
          .toString();
      desfavorables = state.itvRevisiones
          .where((ItvRevisionEntity i) => i.resultado == ResultadoItvRevision.desfavorable)
          .length
          .toString();
      negativos = state.itvRevisiones
          .where((ItvRevisionEntity i) => i.resultado == ResultadoItvRevision.negativo)
          .length
          .toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.fact_check,
      ),
      HeaderStat(
        value: favorables,
        icon: Icons.check_circle,
      ),
      HeaderStat(
        value: desfavorables,
        icon: Icons.warning,
      ),
      HeaderStat(
        value: negativos,
        icon: Icons.error,
      ),
    ];
  }
}
