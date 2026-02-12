import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/producto_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header de la página de productos con estadísticas integradas
class ProductosHeader extends StatelessWidget {
  const ProductosHeader({super.key});

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
            Icons.inventory_2,
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
              'Gestión de Productos',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Catálogo de medicamentos, material médico y electromedicina',
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
    return BlocBuilder<ProductoBloc, ProductoState>(
      builder: (BuildContext context, ProductoState state) {
        String total = '-';
        String medicacion = '-';
        String electromedicina = '-';
        String material = '-';

        if (state is ProductoLoaded) {
          total = state.productos.length.toString();
          medicacion = state.productos
              .where((ProductoEntity p) => p.categoria == CategoriaProducto.medicacion)
              .length
              .toString();
          electromedicina = state.productos
              .where((ProductoEntity p) => p.categoria == CategoriaProducto.electromedicina)
              .length
              .toString();
          material = state.productos
              .where((ProductoEntity p) => p.categoria == CategoriaProducto.materialAmbulancia)
              .length
              .toString();
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
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: medicacion,
                          icon: Icons.medication,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _MiniStatCard(
                          value: electromedicina,
                          icon: Icons.medical_services,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: material,
                          icon: Icons.inventory,
                          color: AppColors.primary,
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
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: medicacion,
                      icon: Icons.medication,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: electromedicina,
                      icon: Icons.medical_services,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: material,
                      icon: Icons.inventory,
                      color: AppColors.primary,
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

/// Botón para agregar producto
class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: () {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return BlocProvider<ProductoBloc>.value(
              value: context.read<ProductoBloc>(),
              child: const ProductoFormDialog(),
            );
          },
        );
      },
      label: 'Agregar Producto',
      icon: Icons.add,
    );
  }
}
