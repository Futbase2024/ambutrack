import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/vestuario_form_dialog.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/vestuario_table.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Vestuario del Personal
class VestuarioPage extends StatelessWidget {
  const VestuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VestuarioBloc>.value(value: getIt<VestuarioBloc>()),
          BlocProvider<PersonalBloc>.value(value: getIt<PersonalBloc>()),
          BlocProvider<StockVestuarioBloc>.value(value: getIt<StockVestuarioBloc>()),
        ],
        child: const _VestuarioView(),
      ),
    );
  }
}

/// Vista principal de vestuario
class _VestuarioView extends StatefulWidget {
  const _VestuarioView();

  @override
  State<_VestuarioView> createState() => _VestuarioViewState();
}

class _VestuarioViewState extends State<_VestuarioView> {
  DateTime? _pageStartTime;

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ VestuarioPage: Inicio de carga de página');

    // Cargar vestuario si está en estado inicial
    final VestuarioBloc vestuarioBloc = context.read<VestuarioBloc>();
    if (vestuarioBloc.state is VestuarioInitial) {
      debugPrint('🚀 VestuarioPage: Primera carga, solicitando vestuario...');
      vestuarioBloc.add(const VestuarioLoadRequested());
    } else if (vestuarioBloc.state is VestuarioLoaded) {
      final VestuarioLoaded loadedState = vestuarioBloc.state as VestuarioLoaded;
      debugPrint('⚡ VestuarioPage: Datos ya cargados (${loadedState.items.length} registros), reutilizando estado del BLoC');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageStartTime != null) {
          final Duration elapsed = DateTime.now().difference(_pageStartTime!);
          debugPrint('⏱️ Tiempo total de carga de página (con datos en caché): ${elapsed.inMilliseconds}ms');
          _pageStartTime = null;
        }
      });
    }

    // IMPORTANTE: Cargar stock SIEMPRE para poder devolver vestuario al eliminar
    final StockVestuarioBloc stockBloc = context.read<StockVestuarioBloc>();
    if (stockBloc.state is StockVestuarioInitial) {
      debugPrint('📦 VestuarioPage: Cargando stock de vestuario...');
      stockBloc.add(const StockVestuarioLoadRequested());
    } else if (stockBloc.state is StockVestuarioLoaded) {
      final StockVestuarioLoaded loadedState = stockBloc.state as StockVestuarioLoaded;
      debugPrint('📦 VestuarioPage: Stock ya cargado (${loadedState.items.length} items)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VestuarioBloc, VestuarioState>(
      listener: (BuildContext context, VestuarioState state) {
        if (state is VestuarioLoaded && _pageStartTime != null) {
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
              BlocBuilder<VestuarioBloc, VestuarioState>(
                builder: (BuildContext context, VestuarioState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.checkroom_outlined,
                      title: 'Vestuario',
                      subtitle: 'Gestión de vestuario y uniformes del personal',
                      addButtonLabel: 'Agregar Vestuario',
                      stats: _buildHeaderStats(state),
                      onAdd: _showAddVestuarioDialog,
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSizes.spacingXl),

              // Tabla de vestuario
              const Expanded(child: VestuarioTable()),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye estadísticas para el header
  List<HeaderStat> _buildHeaderStats(VestuarioState state) {
    String total = '-';
    String asignado = '-';
    String devuelto = '-';
    String activo = '-';

    if (state is VestuarioLoaded) {
      total = state.items.length.toString();

      // Vestuario asignado (sin devolver)
      asignado = state.items.where((VestuarioEntity item) {
        return item.estaAsignado;
      }).length.toString();

      // Vestuario devuelto
      devuelto = state.items.where((VestuarioEntity item) {
        return item.fueDevuelto;
      }).length.toString();

      // Vestuario activo
      activo = state.items.where((VestuarioEntity item) {
        return item.activo;
      }).length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.inventory_2_outlined,
      ),
      HeaderStat(
        value: asignado,
        icon: Icons.person_outline,
      ),
      HeaderStat(
        value: devuelto,
        icon: Icons.assignment_return_outlined,
      ),
      HeaderStat(
        value: activo,
        icon: Icons.check_circle_outline,
      ),
    ];
  }

  /// Muestra el diálogo para crear nueva asignación de vestuario
  Future<void> _showAddVestuarioDialog() async {
    debugPrint('=== Botón Nueva Asignación presionado ===');

    // Capturar los BLoCs del contexto actual ANTES de showDialog
    final VestuarioBloc vestuarioBloc = context.read<VestuarioBloc>();
    final PersonalBloc personalBloc = context.read<PersonalBloc>();
    final StockVestuarioBloc stockVestuarioBloc = context.read<StockVestuarioBloc>();

    if (mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<VestuarioBloc>.value(value: vestuarioBloc),
              BlocProvider<PersonalBloc>.value(value: personalBloc),
              BlocProvider<StockVestuarioBloc>.value(value: stockVestuarioBloc),
            ],
            child: const VestuarioFormDialog(),
          );
        },
      );
    }
  }
}
