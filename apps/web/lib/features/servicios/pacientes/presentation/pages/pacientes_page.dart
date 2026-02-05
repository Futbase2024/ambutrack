import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_bloc.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_event.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_state.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/paciente_form_dialog.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/pacientes_filters.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/pacientes_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de pacientes
class PacientesPage extends StatelessWidget {
  const PacientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<PacientesBloc>.value(
        value: getIt<PacientesBloc>(),
        child: const _PacientesView(),
      ),
    );
  }
}

/// Vista principal de pacientes con filtros
class _PacientesView extends StatefulWidget {
  const _PacientesView();

  @override
  State<_PacientesView> createState() => _PacientesViewState();
}

class _PacientesViewState extends State<_PacientesView> {
  DateTime? _pageStartTime;

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ PacientesPage: Inicio de carga de página');

    // Solo cargar si está en estado inicial
    final PacientesBloc bloc = context.read<PacientesBloc>();
    if (bloc.state is PacientesInitial) {
      debugPrint('🚀 PacientesPage: Primera carga, solicitando pacientes...');
      bloc.add(const PacientesLoadRequested());
    } else if (bloc.state is PacientesLoaded) {
      final PacientesLoaded loadedState = bloc.state as PacientesLoaded;
      debugPrint('⚡ PacientesPage: Datos ya cargados (${loadedState.pacientes.length} pacientes), reutilizando estado del BLoC');

      // Medir tiempo de renderizado cuando reutiliza datos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageStartTime != null) {
          final Duration elapsed = DateTime.now().difference(_pageStartTime!);
          debugPrint('⏱️ Tiempo total de carga de página (con datos en caché): ${elapsed.inMilliseconds}ms');
          _pageStartTime = null;
        }
      });
    }
  }

  void _onFilterChanged(PacientesFilterData filterData) {
    // El filtrado ahora se maneja dentro de PacientesTable
    debugPrint('🔍 Filtros aplicados: searchText=${filterData.searchText}');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PacientesBloc, PacientesState>(
      listener: (BuildContext context, PacientesState state) {
        // Medir tiempo cuando se completa la carga inicial
        if (state is PacientesLoaded && _pageStartTime != null) {
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
              BlocBuilder<PacientesBloc, PacientesState>(
                builder: (BuildContext context, PacientesState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.people_outline,
                      title: 'Gestión de Pacientes',
                      subtitle: 'Administra los pacientes del sistema',
                      addButtonLabel: 'Agregar Paciente',
                      stats: _buildHeaderStats(state),
                      onAdd: _showAddPacienteDialog,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spacingXl),

              // Tabla ocupa el espacio restante
              Expanded(
                child: PacientesTable(onFilterChanged: _onFilterChanged),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddPacienteDialog() async {
    debugPrint('=== Botón Agregar Paciente presionado ===');
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return BlocProvider<PacientesBloc>.value(
            value: context.read<PacientesBloc>(),
            child: const PacienteFormDialog(),
          );
        },
      );

      debugPrint('Diálogo cerrado');
    } catch (e, stack) {
      debugPrint('Error en showDialog: $e');
      debugPrint('Stack: $stack');
    }
  }

  List<HeaderStat> _buildHeaderStats(PacientesState state) {
    String total = '-';
    String activos = '-';
    String registradosHoy = '-';
    String pendientes = '-';

    if (state is PacientesLoaded) {
      total = state.pacientes.length.toString();
      activos = state.pacientes.where((PacienteEntity p) => p.activo).length.toString();

      // Pacientes registrados hoy
      final DateTime hoy = DateTime.now();
      final DateTime inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
      registradosHoy = state.pacientes
          .where((PacienteEntity p) => p.createdAt != null && p.createdAt!.isAfter(inicioHoy))
          .length
          .toString();

      // Pacientes pendientes de completar datos (sin dirección o teléfono)
      pendientes = state.pacientes
          .where((PacienteEntity p) =>
              (p.domicilioDireccion == null || p.domicilioDireccion!.isEmpty) ||
              ((p.telefonoMovil == null || p.telefonoMovil!.isEmpty) &&
               (p.telefonoFijo == null || p.telefonoFijo!.isEmpty)))
          .length
          .toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.people,
      ),
      HeaderStat(
        value: activos,
        icon: Icons.check_circle,
      ),
      HeaderStat(
        value: registradosHoy,
        icon: Icons.today,
      ),
      HeaderStat(
        value: pendientes,
        icon: Icons.warning_amber,
      ),
    ];
  }
}
