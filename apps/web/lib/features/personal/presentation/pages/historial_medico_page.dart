import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/historial_medico_form_dialog.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/historial_medico_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Historial Médico del Personal
class HistorialMedicoPage extends StatelessWidget {
  const HistorialMedicoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<HistorialMedicoBloc>.value(
        value: getIt<HistorialMedicoBloc>(),
        child: const _HistorialMedicoView(),
      ),
    );
  }
}

/// Vista principal de historial médico
class _HistorialMedicoView extends StatefulWidget {
  const _HistorialMedicoView();

  @override
  State<_HistorialMedicoView> createState() => _HistorialMedicoViewState();
}

class _HistorialMedicoViewState extends State<_HistorialMedicoView> {
  DateTime? _pageStartTime;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ HistorialMedicoPage: Inicio de carga de página');

    // Solo cargar si está en estado inicial
    final HistorialMedicoBloc bloc = context.read<HistorialMedicoBloc>();
    if (bloc.state is HistorialMedicoInitial) {
      debugPrint('🚀 HistorialMedicoPage: Primera carga, solicitando historial médico...');
      bloc.add(const HistorialMedicoLoadRequested());
    } else if (bloc.state is HistorialMedicoLoaded) {
      final HistorialMedicoLoaded loadedState = bloc.state as HistorialMedicoLoaded;
      debugPrint('⚡ HistorialMedicoPage: Datos ya cargados (${loadedState.items.length} registros), reutilizando estado del BLoC');

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
    return BlocListener<HistorialMedicoBloc, HistorialMedicoState>(
      listener: (BuildContext context, HistorialMedicoState state) {
        if (state is HistorialMedicoLoaded && _pageStartTime != null) {
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
              BlocBuilder<HistorialMedicoBloc, HistorialMedicoState>(
                builder: (BuildContext context, HistorialMedicoState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.medical_services_outlined,
                      title: 'Historial Médico',
                      subtitle: 'Reconocimientos médicos del personal',
                      addButtonLabel: 'Nuevo Reconocimiento',
                      stats: _buildHeaderStats(state),
                      onAdd: _showAddReconocimientoDialog,
                      extra: SizedBox(
                        width: 300,
                        child: HistorialMedicoSearchField(
                          searchQuery: _searchQuery,
                          onSearchChanged: (String query) {
                            setState(() { _searchQuery = query; });
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSizes.spacingXl),

              // Tabla de historial médico
              Expanded(child: HistorialMedicoTable(searchQuery: _searchQuery)),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye estadísticas para el header
  List<HeaderStat> _buildHeaderStats(HistorialMedicoState state) {
    String total = '-';
    String aptos = '-';
    String proximosACaducar = '-';
    String caducados = '-';

    if (state is HistorialMedicoLoaded) {
      final DateTime ahora = DateTime.now();
      final DateTime limiteAlerta = ahora.add(const Duration(days: 30));

      total = state.items.length.toString();

      // Reconocimientos aptos (vigentes)
      aptos = state.items.where((HistorialMedicoEntity item) {
        return item.activo &&
            item.aptitud == 'apto' &&
            item.fechaCaducidad.isAfter(ahora);
      }).length.toString();

      // Próximos a caducar (menos de 30 días)
      proximosACaducar = state.items.where((HistorialMedicoEntity item) {
        return item.activo &&
            item.fechaCaducidad.isAfter(ahora) &&
            item.fechaCaducidad.isBefore(limiteAlerta);
      }).length.toString();

      // Caducados
      caducados = state.items.where((HistorialMedicoEntity item) {
        return item.activo && item.fechaCaducidad.isBefore(ahora);
      }).length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.assignment_outlined,
      ),
      HeaderStat(
        value: aptos,
        icon: Icons.check_circle_outline,
      ),
      HeaderStat(
        value: proximosACaducar,
        icon: Icons.warning_amber_outlined,
      ),
      HeaderStat(
        value: caducados,
        icon: Icons.cancel_outlined,
      ),
    ];
  }

  /// Muestra el diálogo para crear un nuevo reconocimiento médico
  Future<void> _showAddReconocimientoDialog() async {
    debugPrint('=== Botón Nuevo Reconocimiento presionado ===');

    // Capturar el BLoC antes de mostrar el diálogo
    final HistorialMedicoBloc historialBloc = context.read<HistorialMedicoBloc>();

    if (mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return BlocProvider<HistorialMedicoBloc>.value(
            value: historialBloc,
            child: const HistorialMedicoFormDialog(),
          );
        },
      );
    }
  }
}
