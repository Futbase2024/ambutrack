import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/proveedor_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header de la página de proveedores con estadísticas integradas
class ProveedoresHeader extends StatelessWidget {
  const ProveedoresHeader({super.key});

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
        _TitleSection(),
        const SizedBox(width: AppSizes.spacingLarge),
        Expanded(child: _StatsCards()),
        const SizedBox(width: AppSizes.spacingLarge),
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
            Icons.business,
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
              'Gestión de Proveedores',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Administra tus proveedores de productos médicos',
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
    return BlocBuilder<ProveedoresBloc, ProveedoresState>(
      builder: (BuildContext context, ProveedoresState state) {
        String total = '-';
        String activos = '-';
        String inactivos = '-';

        if (state is ProveedoresLoaded) {
          total = state.proveedores.length.toString();
          activos = state.proveedores.where((ProveedorEntity p) => p.activo).length.toString();
          inactivos = state.proveedores.where((ProveedorEntity p) => !p.activo).length.toString();
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
                          icon: Icons.business,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: activos,
                          icon: Icons.check_circle,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _MiniStatCard(
                          value: inactivos,
                          icon: Icons.cancel,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  Expanded(
                    child: _MiniStatCard(
                      value: total,
                      icon: Icons.business,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: activos,
                      icon: Icons.check_circle,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: inactivos,
                      icon: Icons.cancel,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              );
      },
    );
  }
}

/// Mini tarjeta de estadística
class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: AppSizes.iconSmall,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón para agregar proveedor
class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: () {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return BlocProvider<ProveedoresBloc>.value(
              value: context.read<ProveedoresBloc>(),
              child: const ProveedorFormDialog(),
            );
          },
        );
      },
      label: 'Agregar Proveedor',
      icon: Icons.add,
    );
  }
}
