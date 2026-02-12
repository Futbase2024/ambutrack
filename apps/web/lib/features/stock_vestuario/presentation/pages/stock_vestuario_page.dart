import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/stock_vestuario_form_dialog.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/stock_vestuario_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Stock de Vestuario
class StockVestuarioPage extends StatelessWidget {
  const StockVestuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<StockVestuarioBloc>.value(
        value: getIt<StockVestuarioBloc>(),
        child: const _StockVestuarioView(),
      ),
    );
  }
}

/// Vista principal de stock de vestuario
class _StockVestuarioView extends StatefulWidget {
  const _StockVestuarioView();

  @override
  State<_StockVestuarioView> createState() => _StockVestuarioViewState();
}

class _StockVestuarioViewState extends State<_StockVestuarioView> {
  DateTime? _pageStartTime;

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ StockVestuarioPage: Inicio de carga de página');

    // Solo cargar si está en estado inicial
    final StockVestuarioBloc bloc = context.read<StockVestuarioBloc>();
    if (bloc.state is StockVestuarioInitial) {
      debugPrint('🚀 StockVestuarioPage: Primera carga, solicitando stock...');
      bloc.add(const StockVestuarioLoadRequested());
    } else if (bloc.state is StockVestuarioLoaded) {
      final StockVestuarioLoaded loadedState = bloc.state as StockVestuarioLoaded;
      debugPrint('⚡ StockVestuarioPage: Datos ya cargados (${loadedState.items.length} registros), reutilizando estado del BLoC');

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
    return BlocListener<StockVestuarioBloc, StockVestuarioState>(
      listener: (BuildContext context, StockVestuarioState state) {
        if (state is StockVestuarioLoaded && _pageStartTime != null) {
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
              BlocBuilder<StockVestuarioBloc, StockVestuarioState>(
                builder: (BuildContext context, StockVestuarioState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.inventory_2_outlined,
                      title: 'Stock de Vestuario',
                      subtitle: 'Gestión de inventario y almacén de vestuario',
                      addButtonLabel: 'Agregar Artículo',
                      stats: _buildHeaderStats(state),
                      onAdd: _showAddStockDialog,
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSizes.spacingXl),

              // Tabla de stock
              const Expanded(child: StockVestuarioTable()),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye estadísticas para el header
  List<HeaderStat> _buildHeaderStats(StockVestuarioState state) {
    String total = '-';
    String disponible = '-';
    String stockBajo = '-';
    String activo = '-';

    if (state is StockVestuarioLoaded) {
      total = state.items.length.toString();

      // Artículos con stock disponible (sin stock bajo y sin stock)
      disponible = state.items.where((StockVestuarioEntity item) {
        return !item.tieneStockBajo && !item.sinStock;
      }).length.toString();

      // Artículos con stock bajo
      stockBajo = state.items.where((StockVestuarioEntity item) {
        return item.tieneStockBajo && !item.sinStock;
      }).length.toString();

      // Artículos activos
      activo = state.items.where((StockVestuarioEntity item) {
        return item.activo;
      }).length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.inventory_2_outlined,
      ),
      HeaderStat(
        value: disponible,
        icon: Icons.check_circle_outline,
      ),
      HeaderStat(
        value: stockBajo,
        icon: Icons.warning_amber_outlined,
      ),
      HeaderStat(
        value: activo,
        icon: Icons.check_circle_outline,
      ),
    ];
  }

  /// Muestra el diálogo para crear nuevo artículo de stock
  Future<void> _showAddStockDialog() async {
    debugPrint('=== Botón Nuevo Artículo presionado ===');

    // Capturar el BLoC antes de mostrar el diálogo
    final StockVestuarioBloc stockVestuarioBloc = context.read<StockVestuarioBloc>();

    if (mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return BlocProvider<StockVestuarioBloc>.value(
            value: stockVestuarioBloc,
            child: const StockVestuarioFormDialog(),
          );
        },
      );
    }
  }
}
