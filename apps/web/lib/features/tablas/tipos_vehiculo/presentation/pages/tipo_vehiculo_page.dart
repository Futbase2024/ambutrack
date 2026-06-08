import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_state.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/widgets/tipo_vehiculo_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/widgets/tipo_vehiculo_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de tipos de vehículo
class TipoVehiculoPage extends StatelessWidget {
  const TipoVehiculoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<TipoVehiculoBloc>(
        create: (BuildContext context) => getIt<TipoVehiculoBloc>()..add(const TipoVehiculoLoadAllRequested()),
        child: const _TipoVehiculoView(),
      ),
    );
  }
}

/// Vista principal de tipos de vehículo
class _TipoVehiculoView extends StatefulWidget {
  const _TipoVehiculoView();

  @override
  State<_TipoVehiculoView> createState() => _TipoVehiculoViewState();
}

class _TipoVehiculoViewState extends State<_TipoVehiculoView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<TipoVehiculoBloc, TipoVehiculoState>(
        builder: (BuildContext context, TipoVehiculoState state) {
          if (state is TipoVehiculoLoading) {
            return const Center(
              child: AppLoadingIndicator(message: 'Cargando tipos de vehículo...'),
            );
          }

          if (state is TipoVehiculoError) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingXl),
                margin: const EdgeInsets.all(AppSizes.paddingXl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  border: Border.all(color: AppColors.error),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: AppSizes.spacing),
                    const Text(
                      'Error al cargar tipos de vehículo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingXl,
              AppSizes.paddingXl,
              AppSizes.paddingXl,
              AppSizes.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.directions_car,
                    title: 'Gestión de Tipos de Vehículo',
                    subtitle: 'Administra los tipos de vehículo disponibles en el sistema',
                    addButtonLabel: 'Nuevo Tipo',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                    extra: SizedBox(
                      width: 250,
                      child: TipoVehiculoSearchField(
                        searchQuery: _searchQuery,
                        onSearchChanged: (String query) {
                          setState(() => _searchQuery = query);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing),
                Expanded(
                  child: TipoVehiculoTable(searchQuery: _searchQuery),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(TipoVehiculoState state) {
    String total = '-';

    if (state is TipoVehiculoLoaded) {
      total = state.tiposVehiculo.length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.directions_car,
      ),
    ];
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<TipoVehiculoBloc>.value(
        value: context.read<TipoVehiculoBloc>(),
        child: const TipoVehiculoFormDialog(),
      ),
    );
  }
}
