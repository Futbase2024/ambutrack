import 'package:ambutrack_web/core/lang/app_strings.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/vehiculo_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header de la página de vehículos con estadísticas integradas
class VehiculosHeader extends StatelessWidget {
  const VehiculosHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLarge,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: AppSizes.shadowMedium,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isDesktop
          ? const _DesktopLayout()
          : isTablet
              ? const _TabletLayout()
              : const _MobileLayout(),
    );
  }
}

/// Layout para desktop: Título | Stats | Botón (horizontal)
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Título a la izquierda
        _TitleSection(),
        const SizedBox(width: AppSizes.spacingLarge),
        // Stats cards en el centro (expandido)
        Expanded(child: _StatsCards()),
        const SizedBox(width: AppSizes.spacingLarge),
        // Botón a la derecha
        _AddButton(),
      ],
    );
  }
}

/// Layout para tablet: Título + Botón arriba, Stats abajo
class _TabletLayout extends StatelessWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _TitleSection()),
            const SizedBox(width: AppSizes.spacing),
            _AddButton(),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        _StatsCards(),
      ],
    );
  }
}

/// Layout para móvil: Todo en columna
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TitleSection(),
        const SizedBox(height: AppSizes.spacing),
        _StatsCards(),
        const SizedBox(height: AppSizes.spacing),
        SizedBox(
          width: double.infinity,
          child: _AddButton(),
        ),
      ],
    );
  }
}

/// Sección de título
class _TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: const Icon(
            Icons.directions_car,
            color: AppColors.primary,
            size: AppSizes.iconMedium,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppStrings.vehiculosTitulo,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              AppStrings.vehiculosSubtitulo,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontXs,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Cards de estadísticas
class _StatsCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehiculosBloc, VehiculosState>(
      builder: (BuildContext context, VehiculosState state) {
        String total = '-';
        String disponibles = '-';
        String enServicio = '-';
        String mantenimiento = '-';

        if (state is VehiculosLoaded) {
          total = state.total.toString();
          disponibles = state.disponibles.toString();
          enServicio = state.enServicio.toString();
          mantenimiento = state.mantenimiento.toString();
        }

        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 600;

        return isMobile
            ? Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _MiniStatCard(
                          value: total,
                          icon: Icons.directions_car,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: disponibles,
                          icon: Icons.check_circle,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _MiniStatCard(
                          value: enServicio,
                          icon: Icons.local_shipping,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: mantenimiento,
                          icon: Icons.build,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  Expanded(
                    child: _MiniStatCard(
                      value: total,
                      icon: Icons.directions_car,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: disponibles,
                      icon: Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: enServicio,
                      icon: Icons.local_shipping,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: mantenimiento,
                      icon: Icons.build,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              );
      },
    );
  }
}

/// Botón añadir vehículo
class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: () async {
        debugPrint('=== Botón Agregar Vehículo presionado ===');
        try {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              debugPrint('Construyendo VehiculoFormDialog con contexto del BLoC');
              // Proveer el BLoC al diálogo para que pueda enviar eventos
              return BlocProvider<VehiculosBloc>.value(
                value: context.read<VehiculosBloc>(),
                child: const VehiculoFormDialog(),
              );
            },
          );

          debugPrint('Diálogo cerrado');
        } catch (e, stack) {
          debugPrint('Error en showDialog: $e');
          debugPrint('Stack: $stack');
        }
      },
      icon: Icons.add,
      label: AppStrings.vehiculosAgregar,
    );
  }
}

/// Mini card de estadística para el header
class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.value,
    required this.icon,
    required this.color,
  });

  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: AppSizes.iconSmall),
          const SizedBox(width: AppSizes.spacingXs),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMedium,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
