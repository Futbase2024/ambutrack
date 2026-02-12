import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header de la página del dashboard de almacén con estadísticas integradas
class DashboardAlmacenHeader extends StatelessWidget {
  const DashboardAlmacenHeader({super.key});

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

/// Layout para desktop: Título | Stats (horizontal)
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _TitleSection(),
        const SizedBox(width: AppSizes.spacingLarge),
        Expanded(child: _StatsCards()),
      ],
    );
  }
}

/// Layout para tablet: Título arriba, Stats abajo
class _TabletLayout extends StatelessWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TitleSection(),
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
            Icons.dashboard,
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
              'Dashboard de Almacén',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Vista general del estado del inventario',
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
    return BlocBuilder<StockBloc, StockState>(
      builder: (BuildContext context, StockState state) {
        String totalItems = '-';
        String stockBajo = '-';
        String proximosACaducar = '-';
        String valorTotal = '-';

        if (state is StockLoaded) {
          totalItems = state.stock.length.toString();

          final int bajo = state.stock.where((StockEntity s) => s.cantidadDisponible <= s.cantidadMinima).length;
          stockBajo = bajo.toString();

          final DateTime ahora = DateTime.now();
          final DateTime en30Dias = ahora.add(const Duration(days: 30));
          final int caducando = state.stock.where((StockEntity s) {
            if (s.fechaCaducidad == null) {
              return false;
            }
            return s.fechaCaducidad!.isBefore(en30Dias) && s.fechaCaducidad!.isAfter(ahora);
          }).length;
          proximosACaducar = caducando.toString();

          final double valor = state.stock.fold(
            0.0,
            (double sum, StockEntity s) => sum + ((s.precioUnitario ?? 0.0) * s.cantidadDisponible),
          );
          valorTotal = '${valor.toStringAsFixed(2)}€';
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
                          value: totalItems,
                          icon: Icons.inventory_2,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: stockBajo,
                          icon: Icons.warning_amber,
                          color: AppColors.warning,
                          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _MiniStatCard(
                          value: proximosACaducar,
                          icon: Icons.schedule,
                          color: AppColors.error,
                          backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: valorTotal,
                          icon: Icons.euro,
                          color: AppColors.success,
                          backgroundColor: AppColors.success.withValues(alpha: 0.1),
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
                      value: totalItems,
                      icon: Icons.inventory_2,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: stockBajo,
                      icon: Icons.warning_amber,
                      color: AppColors.warning,
                      backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: proximosACaducar,
                      icon: Icons.schedule,
                      color: AppColors.error,
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: valorTotal,
                      icon: Icons.euro,
                      color: AppColors.success,
                      backgroundColor: AppColors.success.withValues(alpha: 0.1),
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
