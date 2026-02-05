import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/equipamiento_personal_form_dialog.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/equipamiento_personal_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Equipamiento del Personal
class EquipamientoPersonalPage extends StatelessWidget {
  const EquipamientoPersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<EquipamientoPersonalBloc>.value(
        value: getIt<EquipamientoPersonalBloc>(),
        child: const _EquipamientoView(),
      ),
    );
  }
}

/// Vista principal de equipamiento personal
class _EquipamientoView extends StatefulWidget {
  const _EquipamientoView();

  @override
  State<_EquipamientoView> createState() => _EquipamientoViewState();
}

class _EquipamientoViewState extends State<_EquipamientoView> {
  DateTime? _pageStartTime;

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ EquipamientoPersonalPage: Inicio de carga de página');

    // Solo cargar si está en estado inicial
    final EquipamientoPersonalBloc bloc = context.read<EquipamientoPersonalBloc>();
    if (bloc.state is EquipamientoPersonalInitial) {
      debugPrint('🚀 EquipamientoPersonalPage: Primera carga, solicitando equipamiento...');
      bloc.add(const EquipamientoPersonalLoadRequested());
    } else if (bloc.state is EquipamientoPersonalLoaded) {
      final EquipamientoPersonalLoaded loadedState = bloc.state as EquipamientoPersonalLoaded;
      debugPrint('⚡ EquipamientoPersonalPage: Datos ya cargados (${loadedState.items.length} registros), reutilizando estado del BLoC');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageStartTime != null) {
          final Duration elapsed = DateTime.now().difference(_pageStartTime!);
          debugPrint('⏱️ Tiempo total de carga de página (con datos en caché): ${elapsed.inMilliseconds}ms');
          _pageStartTime = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EquipamientoPersonalBloc, EquipamientoPersonalState>(
      listener: (BuildContext context, EquipamientoPersonalState state) {
        if (state is EquipamientoPersonalLoaded && _pageStartTime != null) {
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
              // Header con estadísticas
              BlocBuilder<EquipamientoPersonalBloc, EquipamientoPersonalState>(
                builder: (BuildContext context, EquipamientoPersonalState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.inventory_2_outlined,
                      title: 'Equipamiento Personal',
                      subtitle: 'Gestión de equipamiento, uniformes y material asignado',
                      addButtonLabel: 'Agregar Equipamiento',
                      stats: _buildHeaderStats(state),
                      onAdd: _showAddEquipamientoDialog,
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSizes.spacingXl),

              // Tabla de equipamiento
              const Expanded(child: EquipamientoPersonalTable()),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye estadísticas para el header
  List<HeaderStat> _buildHeaderStats(EquipamientoPersonalState state) {
    String total = '-';
    String asignado = '-';
    String uniformes = '-';
    String epi = '-';

    if (state is EquipamientoPersonalLoaded) {
      total = state.items.length.toString();

      // Equipamiento asignado (sin devolver)
      asignado = state.items.where((EquipamientoPersonalEntity item) {
        return item.estaAsignado;
      }).length.toString();

      // Uniformes
      uniformes = state.items.where((EquipamientoPersonalEntity item) {
        return item.tipoEquipamiento == 'uniforme' && item.activo;
      }).length.toString();

      // EPIs
      epi = state.items.where((EquipamientoPersonalEntity item) {
        return item.tipoEquipamiento == 'epi' && item.activo;
      }).length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.category_outlined,
      ),
      HeaderStat(
        value: asignado,
        icon: Icons.person_outline,
      ),
      HeaderStat(
        value: uniformes,
        icon: Icons.checkroom_outlined,
      ),
      HeaderStat(
        value: epi,
        icon: Icons.verified_user_outlined,
      ),
    ];
  }

  /// Muestra el diálogo para crear nueva asignación de equipamiento
  Future<void> _showAddEquipamientoDialog() async {
    debugPrint('=== Botón Nueva Asignación presionado ===');

    // Capturar el BLoC antes de mostrar el diálogo
    final EquipamientoPersonalBloc equipamientoBloc = context.read<EquipamientoPersonalBloc>();

    if (mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return BlocProvider<EquipamientoPersonalBloc>.value(
            value: equipamientoBloc,
            child: const EquipamientoPersonalFormDialog(),
          );
        },
      );
    }
  }
}
