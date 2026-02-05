import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_bloc.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_event.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_state.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/ausencia_form_dialog.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/calendario_ausencias_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Ausencias
class AusenciasPage extends StatelessWidget {
  const AusenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<AusenciasBloc>.value(
        value: getIt<AusenciasBloc>(),
        child: const _AusenciasView(),
      ),
    );
  }
}

/// Vista principal de ausencias
class _AusenciasView extends StatefulWidget {
  const _AusenciasView();

  @override
  State<_AusenciasView> createState() => _AusenciasViewState();
}

class _AusenciasViewState extends State<_AusenciasView> {
  DateTime? _pageStartTime;

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ AusenciasPage: Inicio de carga de página');

    // Solo cargar si está en estado inicial
    final AusenciasBloc bloc = context.read<AusenciasBloc>();
    if (bloc.state is AusenciasInitial) {
      debugPrint('🚀 AusenciasPage: Primera carga, solicitando ausencias...');
      bloc.add(const AusenciasLoadRequested());
    } else if (bloc.state is AusenciasLoaded) {
      final AusenciasLoaded loadedState = bloc.state as AusenciasLoaded;
      debugPrint('⚡ AusenciasPage: Datos ya cargados (${loadedState.ausencias.length} ausencias), reutilizando estado del BLoC');

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
    return BlocListener<AusenciasBloc, AusenciasState>(
      listener: (BuildContext context, AusenciasState state) {
        if (state is AusenciasLoaded && _pageStartTime != null) {
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
              BlocBuilder<AusenciasBloc, AusenciasState>(
                builder: (BuildContext context, AusenciasState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.event_busy,
                      title: 'Ausencias',
                      subtitle: 'Gestión de ausencias y permisos del personal',
                      addButtonLabel: 'Nueva Ausencia',
                      stats: _buildHeaderStats(state),
                      onAdd: _showAddAusenciaDialog,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spacingXl),

              // Contenido principal - Calendario siempre montado para preservar estado
              const Expanded(
                child: CalendarioAusenciasWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(AusenciasState state) {
    String total = '-';
    String pendientes = '-';
    String aprobadas = '-';
    String diasTotales = '-';

    if (state is AusenciasLoaded) {
      total = state.ausencias.length.toString();
      pendientes = state.ausencias
          .where((AusenciaEntity a) => a.estado == EstadoAusencia.pendiente)
          .length
          .toString();
      aprobadas = state.ausencias
          .where((AusenciaEntity a) => a.estado == EstadoAusencia.aprobada)
          .length
          .toString();
      diasTotales = state.ausencias
          .fold<int>(0, (int sum, AusenciaEntity a) => sum + a.diasAusencia)
          .toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.event_busy,
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

  Future<void> _showAddAusenciaDialog() async {
    debugPrint('=== Botón Agregar Ausencia presionado ===');

    // Capturar el BLoC antes de mostrar el diálogo
    final AusenciasBloc ausenciasBloc = context.read<AusenciasBloc>();

    if (mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return BlocProvider<AusenciasBloc>.value(
            value: ausenciasBloc,
            child: const AusenciaFormDialog(),
          );
        },
      );
    }
  }
}
