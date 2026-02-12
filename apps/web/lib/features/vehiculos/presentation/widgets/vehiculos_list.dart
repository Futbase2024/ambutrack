import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/lang/app_strings.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/vehiculo_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lista de vehículos
class VehiculosList extends StatelessWidget {
  const VehiculosList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              AppStrings.vehiculosListaTitulo,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                // TODO(team): Implementar filtros
              },
              icon: const Icon(Icons.filter_list, size: AppSizes.iconMedium),
              label: const Text(AppStrings.filtros),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        BlocBuilder<VehiculosBloc, VehiculosState>(
          builder: (BuildContext context, VehiculosState state) {
            if (state is VehiculosLoading) {
              return Container(
                constraints: const BoxConstraints(minHeight: 400),
                child: const Center(
                  child: AppLoadingIndicator(
                    message: 'Cargando vehículos...',
                  ),
                ),
              );
            }

            if (state is VehiculosError) {
              return _ErrorView(message: state.message);
            }

            if (state is VehiculosLoaded) {
              if (state.vehiculos.isEmpty) {
                return const _EmptyView();
              }

              return Column(
                children: state.vehiculos.map((VehiculoEntity vehiculo) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
                    child: VehiculoCard(vehiculo: vehiculo),
                  );
                }).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMassive),
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: AppSizes.iconMassive,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              AppStrings.vehiculosErrorCarga,
              style: GoogleFonts.inter(
                fontSize: AppSizes.font,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing),
            ElevatedButton(
              onPressed: () {
                context.read<VehiculosBloc>().add(const VehiculosLoadRequested());
              },
              child: const Text(AppStrings.reintentar),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMassive),
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.directions_car_outlined,
              size: AppSizes.iconHuge,
              color: AppColors.gray400,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              AppStrings.vehiculosListaVacia,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              AppStrings.vehiculosListaVaciaDescripcion,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
