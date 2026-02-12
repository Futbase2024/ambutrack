import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/stock_entrada_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header de la página de almacén con estadísticas integradas
class AlmacenHeader extends StatelessWidget {
  const AlmacenHeader({
    super.key,
    this.tabIndex = 0,
  });

  /// Índice del tab activo para preseleccionar categoría en formulario
  final int tabIndex;

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
          ? _DesktopLayout(tabIndex: tabIndex)
          : isTablet
              ? _TabletLayout(tabIndex: tabIndex)
              : _MobileLayout(tabIndex: tabIndex),
    );
  }
}

/// Layout para desktop: Título | Stats | Botón (horizontal)
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _TitleSection(),
        const SizedBox(width: AppSizes.spacingLarge),
        Expanded(child: _StatsCards()),
        const SizedBox(width: AppSizes.spacingLarge),
        _AddButton(tabIndex: tabIndex),
      ],
    );
  }
}

/// Layout para tablet: Título + Botón arriba, Stats abajo
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _TitleSection()),
            const SizedBox(width: AppSizes.spacing),
            _AddButton(tabIndex: tabIndex),
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
  const _MobileLayout({required this.tabIndex});

  final int tabIndex;

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
          child: _AddButton(tabIndex: tabIndex),
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
            Icons.warehouse,
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
              'Almacén General',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Gestión de inventario dividido por categorías',
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
        String total = '-';
        String stockBajo = '-';
        String reservado = '-';
        String disponible = '-';

        if (state is StockLoaded) {
          total = state.stocks.length.toString();

          // Calcular stock bajo usando getter bajoCantidadMinima
          final int bajo = state.stocks
              .where((StockEntity s) => s.bajoCantidadMinima)
              .length;
          stockBajo = bajo.toString();

          // Calcular reservado (cantidadReservada > 0)
          final int reservadoCount = state.stocks
              .where((StockEntity s) => s.cantidadReservada > 0)
              .length;
          reservado = reservadoCount.toString();

          // Calcular disponible (cantidadActual > 0)
          final int disponibleCount = state.stocks
              .where((StockEntity s) => s.cantidadActual > 0)
              .length;
          disponible = disponibleCount.toString();
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
                          icon: Icons.inventory_2,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: disponible,
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
                          value: stockBajo,
                          icon: Icons.warning,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: reservado,
                          icon: Icons.lock,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
                      icon: Icons.inventory_2,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: disponible,
                      icon: Icons.check_circle,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: stockBajo,
                      icon: Icons.warning,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: reservado,
                      icon: Icons.lock,
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

/// Botón añadir entrada
class _AddButton extends StatelessWidget {
  const _AddButton({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: () async {
        debugPrint('🚀 Abriendo formulario de nueva entrada... (Tab: $tabIndex)');

        final StockBloc stockBloc = context.read<StockBloc>();
        final ProductoBloc productoBloc = context.read<ProductoBloc>();

        // Mapear índice de tab a categoría
        CategoriaProducto categoriaInicial;
        switch (tabIndex) {
          case 0:
            categoriaInicial = CategoriaProducto.medicacion;
          case 1:
            categoriaInicial = CategoriaProducto.electromedicina;
          case 2:
            categoriaInicial = CategoriaProducto.materialAmbulancia;
          default:
            categoriaInicial = CategoriaProducto.medicacion;
        }

        debugPrint('📦 Categoría preseleccionada: ${categoriaInicial.label}');

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return MultiBlocProvider(
              providers: <BlocProvider<dynamic>>[
                BlocProvider<StockBloc>.value(value: stockBloc),
                BlocProvider<ProductoBloc>.value(value: productoBloc),
              ],
              child: StockEntradaFormDialog(
                categoriaInicial: categoriaInicial,
              ),
            );
          },
        );
      },
      icon: Icons.add,
      label: 'Nueva Entrada',
    );
  }
}

/// Mini card de estadística para el header
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.spacingXs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: AppSizes.iconLarge),
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
