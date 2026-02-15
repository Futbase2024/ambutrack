import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/consumo_combustible/consumo_combustible_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/consumo_combustible/consumo_combustible_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/consumo_combustible/consumo_combustible_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/consumo/consumo_data_table.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/consumo/consumo_filters.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/consumo/consumo_form_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Consumo y Kilometraje
///
/// Gestiona los registros de consumo de combustible de la flota.
/// Permite:
/// - Ver estadísticas de consumo
/// - Filtrar por vehículo y rango de fechas
/// - Crear, editar y eliminar registros de consumo
class ConsumoKmPage extends StatelessWidget {
  const ConsumoKmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ConsumoCombustibleBloc>(
        create: (BuildContext context) =>
            getIt<ConsumoCombustibleBloc>()..add(const ConsumoCombustibleEvent.started()),
        child: const _ConsumoKmView(),
      ),
    );
  }
}

/// Vista principal de Consumo y Kilometraje
class _ConsumoKmView extends StatelessWidget {
  const _ConsumoKmView();

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
        child: BlocListener<ConsumoCombustibleBloc, ConsumoCombustibleState>(
          listener: (BuildContext context, ConsumoCombustibleState state) {
            state.maybeWhen(
              error: (String message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              orElse: () {},
            );
          },
          child: BlocBuilder<ConsumoCombustibleBloc, ConsumoCombustibleState>(
            buildWhen: (ConsumoCombustibleState previous, ConsumoCombustibleState current) {
              return current.maybeWhen(
                loaded: (_, List<VehiculoEntity> v, int p1, int p2, Map<String, double> e, String? fv, DateTime? fi, DateTime? ff) => true,
                orElse: () => false,
              );
            },
            builder: (BuildContext context, ConsumoCombustibleState state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Header
                  const _ConsumoKmHeader(),
                  const SizedBox(height: AppSizes.spacingXl),

                  // Filtros
                  state.maybeWhen(
                    loaded: (
                      List<ConsumoCombustibleEntity> registros,
                      List<VehiculoEntity> vehiculos,
                      int currentPage,
                      int totalPages,
                      Map<String, double> estadisticas,
                      String? filtroVehiculoId,
                      DateTime? filtroFechaInicio,
                      DateTime? filtroFechaFin,
                    ) {
                      return ConsumoFilters(
                        vehiculos: vehiculos,
                        filtroVehiculoId: filtroVehiculoId,
                        filtroFechaInicio: filtroFechaInicio,
                        filtroFechaFin: filtroFechaFin,
                        onVehiculoChanged: (String? vehiculoId) {
                          context.read<ConsumoCombustibleBloc>().add(
                                ConsumoCombustibleEvent.filterByVehiculo(vehiculoId),
                              );
                        },
                        onFechaInicioChanged: (DateTime? fecha) {
                          context.read<ConsumoCombustibleBloc>().add(
                                ConsumoCombustibleEvent.filterByFecha(
                                  fecha,
                                  state.maybeWhen(
                                    loaded: (_, __, ___, _____, ______, _______, DateTime? fi, DateTime? f) => f,
                                    orElse: () => null,
                                  ),
                                ),
                              );
                        },
                        onFechaFinChanged: (DateTime? fecha) {
                          context.read<ConsumoCombustibleBloc>().add(
                                ConsumoCombustibleEvent.filterByFecha(
                                  state.maybeWhen(
                                    loaded: (_, __, ___, _____, ______, _______, DateTime? f, _) => f,
                                    orElse: () => null,
                                  ),
                                  fecha,
                                ),
                              );
                        },
                        onClearFilters: () {
                          context.read<ConsumoCombustibleBloc>().add(
                                const ConsumoCombustibleEvent.clearFilters(),
                              );
                        },
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSizes.spacingLarge),

                  // Contenido principal
                  const Expanded(
                    child: _ConsumoKmContent(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Header con PageHeader estándar
class _ConsumoKmHeader extends StatelessWidget {
  const _ConsumoKmHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConsumoCombustibleBloc, ConsumoCombustibleState>(
      buildWhen: (ConsumoCombustibleState previous, ConsumoCombustibleState current) {
        return current.maybeWhen(
          loaded: (_, List<VehiculoEntity> v, int p1, int p2, Map<String, double> e, String? fv, DateTime? fi, DateTime? ff) => true,
          orElse: () => false,
        );
      },
      builder: (BuildContext context, ConsumoCombustibleState state) {
        return state.maybeWhen(
          loaded: (
            List<ConsumoCombustibleEntity> registros,
            List<VehiculoEntity> vehiculos,
            int currentPage,
            int totalPages,
            Map<String, double> estadisticas,
            String? filtroVehiculoId,
            DateTime? filtroFechaInicio,
            DateTime? filtroFechaFin,
          ) {
            return PageHeader(
              config: PageHeaderConfig(
                icon: Icons.local_gas_station,
                title: 'Consumo y Kilometraje',
                subtitle: 'Control de combustible y kilometraje de la flota',
                stats: _buildHeaderStats(estadisticas),
                onAdd: () => _showConsumoForm(context, vehiculos),
                addButtonLabel: 'Registrar Consumo',
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(Map<String, double> estadisticas) {
    return <HeaderStat>[
      HeaderStat(
        value: '${estadisticas['consumo_promedio']?.toStringAsFixed(1) ?? '0.0'} L/100km',
        icon: Icons.speed,
      ),
      HeaderStat(
        value: '${estadisticas['km_recorridos']?.toStringAsFixed(0) ?? '0'} km',
        icon: Icons.timeline,
      ),
      HeaderStat(
        value: '${estadisticas['costo_total']?.toStringAsFixed(0) ?? '0'} €',
        icon: Icons.euro,
      ),
      HeaderStat(
        value: '${estadisticas['litros_totales']?.toStringAsFixed(0) ?? '0'} L',
        icon: Icons.local_gas_station,
      ),
    ];
  }

  void _showConsumoForm(BuildContext context, List<VehiculoEntity> vehiculos) {
    final ConsumoCombustibleBloc bloc = context.read<ConsumoCombustibleBloc>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => ConsumoFormModal(
        vehiculos: vehiculos,
        onSave: (ConsumoCombustibleEntity consumo) async {
          bloc.add(ConsumoCombustibleEvent.createRegistro(consumo));
        },
      ),
    );
  }
}

/// Contenido principal con tabla de datos
class _ConsumoKmContent extends StatelessWidget {
  const _ConsumoKmContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConsumoCombustibleBloc, ConsumoCombustibleState>(
      builder: (BuildContext context, ConsumoCombustibleState state) {
        return state.when(
          initial: () => const Center(
            child: AppLoadingOverlay(),
          ),
          loading: () => const Center(
            child: AppLoadingOverlay(),
          ),
          loaded: (
            List<ConsumoCombustibleEntity> registros,
            List<VehiculoEntity> vehiculos,
            int currentPage,
            int totalPages,
            Map<String, double> estadisticas,
            String? filtroVehiculoId,
            DateTime? filtroFechaInicio,
            DateTime? filtroFechaFin,
          ) {
            if (registros.isEmpty) {
              return _EmptyState(
                onClearFilters: () {
                  context.read<ConsumoCombustibleBloc>().add(
                        const ConsumoCombustibleEvent.clearFilters(),
                      );
                },
              );
            }

            return Column(
              children: <Widget>[
                Expanded(
                  child: ConsumoDataTable(
                    registros: registros,
                    vehiculos: vehiculos,
                    onEdit: (ConsumoCombustibleEntity consumo) =>
                        _showEditForm(context, consumo, vehiculos),
                    onDelete: (ConsumoCombustibleEntity consumo) =>
                        _showDeleteConfirmation(context, consumo),
                  ),
                ),
                _PaginationControls(
                  currentPage: currentPage,
                  totalPages: totalPages,
                ),
              ],
            );
          },
          error: (String message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar los datos',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    context.read<ConsumoCombustibleBloc>().add(
                          const ConsumoCombustibleEvent.loadRegistros(),
                        );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditForm(
    BuildContext context,
    ConsumoCombustibleEntity consumo,
    List<VehiculoEntity> vehiculos,
  ) {
    final ConsumoCombustibleBloc bloc = context.read<ConsumoCombustibleBloc>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => ConsumoFormModal(
        consumo: consumo,
        vehiculos: vehiculos,
        onSave: (ConsumoCombustibleEntity updatedConsumo) async {
          bloc.add(ConsumoCombustibleEvent.updateRegistro(updatedConsumo));
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    ConsumoCombustibleEntity consumo,
  ) async {
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar Registro de Consumo',
      message: '¿Estás seguro de que deseas eliminar este registro de consumo?\n\nEsta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      icon: Icons.delete_outline,
    );

    if (confirmed == true && context.mounted) {
      context
          .read<ConsumoCombustibleBloc>()
          .add(ConsumoCombustibleEvent.deleteRegistro(consumo.id));
    }
  }
}

/// Estado vacío cuando no hay registros
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.local_gas_station_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay registros de consumo',
            style: AppTextStyles.h5,
          ),
          const SizedBox(height: 8),
          Text(
            'Registra tu primer consumo de combustible',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onClearFilters,
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpiar Filtros'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Controles de paginación
class _PaginationControls extends StatelessWidget {
  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.gray200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Texto de página actual
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.padding,
              vertical: AppSizes.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              'Página $currentPage de $totalPages',
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),

          // Botones de paginación
          Row(
            children: <Widget>[
              IconButton(
                onPressed: currentPage > 1
                    ? () {
                        context.read<ConsumoCombustibleBloc>().add(
                              ConsumoCombustibleEvent.changePage(currentPage - 1),
                            );
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Anterior',
              ),
              IconButton(
                onPressed: currentPage < totalPages
                    ? () {
                        context.read<ConsumoCombustibleBloc>().add(
                              ConsumoCombustibleEvent.changePage(currentPage + 1),
                            );
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Siguiente',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
