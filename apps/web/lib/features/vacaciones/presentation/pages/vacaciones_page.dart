import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_bloc.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_event.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_state.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/calendario_vacaciones_widget.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/vacacion_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de gestión de Vacaciones
class VacacionesPage extends StatelessWidget {
  const VacacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<VacacionesBloc>.value(
        value: getIt<VacacionesBloc>(),
        child: const _VacacionesView(),
      ),
    );
  }
}

/// Vista interna de la página de Vacaciones
class _VacacionesView extends StatefulWidget {
  const _VacacionesView();

  @override
  State<_VacacionesView> createState() => _VacacionesViewState();
}

class _VacacionesViewState extends State<_VacacionesView> {
  @override
  void initState() {
    super.initState();

    // Solo cargar si está en estado inicial
    final VacacionesBloc bloc = context.read<VacacionesBloc>();
    if (bloc.state is VacacionesInitial) {
      final int currentYear = DateTime.now().year;
      bloc.add(VacacionesLoadByYearRequested(currentYear));
    }
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
              // Header con estadísticas
              BlocBuilder<VacacionesBloc, VacacionesState>(
                builder: (BuildContext context, VacacionesState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.beach_access,
                      title: 'Vacaciones',
                      subtitle: 'Gestión de vacaciones anuales del personal',
                      addButtonLabel: 'Nuevas Vacaciones',
                      stats: _buildHeaderStats(state),
                      onAdd: _showAddVacacionDialog,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spacingXl),

              // Contenido principal - Calendario siempre montado para preservar estado
              const Expanded(
                child: CalendarioVacacionesWidget(),
              ),
            ],
          ),
        ),
    );
  }

  List<HeaderStat> _buildHeaderStats(VacacionesState state) {
    String total = '-';
    String pendientes = '-';
    String aprobadas = '-';
    String diasTotales = '-';

    if (state is VacacionesLoaded) {
      total = state.vacaciones.length.toString();
      pendientes = state.vacaciones
          .where((VacacionesEntity v) => v.estado == 'pendiente')
          .length
          .toString();
      aprobadas = state.vacaciones
          .where((VacacionesEntity v) => v.estado == 'aprobada')
          .length
          .toString();
      diasTotales = state.vacaciones
          .fold<int>(0, (int sum, VacacionesEntity v) => sum + v.diasSolicitados)
          .toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.beach_access,
      ),
      HeaderStat(
        value: pendientes,
        icon: Icons.schedule,
      ),
      HeaderStat(
        value: aprobadas,
        icon: Icons.check_circle,
      ),
      HeaderStat(
        value: diasTotales,
        icon: Icons.calendar_today,
      ),
    ];
  }

  Future<void> _showAddVacacionDialog() async {
    debugPrint('=== Botón Agregar Vacación presionado ===');
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<VacacionesBloc>.value(
          value: context.read<VacacionesBloc>(),
          child: const VacacionFormDialog(),
        );
      },
    );
  }
}
