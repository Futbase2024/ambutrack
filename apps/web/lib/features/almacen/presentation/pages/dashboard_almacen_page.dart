import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/dashboard_almacen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página de dashboard principal del Sistema de Almacén General
class DashboardAlmacenPage extends StatelessWidget {
  const DashboardAlmacenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<StockBloc>.value(
            value: getIt<StockBloc>(),
          ),
          BlocProvider<ProveedoresBloc>.value(
            value: getIt<ProveedoresBloc>(),
          ),
          BlocProvider<ProductoBloc>.value(
            value: getIt<ProductoBloc>(),
          ),
        ],
        child: const _DashboardAlmacenView(),
      ),
    );
  }
}

/// Vista principal del dashboard
class _DashboardAlmacenView extends StatefulWidget {
  const _DashboardAlmacenView();

  @override
  State<_DashboardAlmacenView> createState() => _DashboardAlmacenViewState();
}

class _DashboardAlmacenViewState extends State<_DashboardAlmacenView> {
  @override
  void initState() {
    super.initState();
    // Cargar datos de stock, proveedores y productos
    final StockBloc stockBloc = context.read<StockBloc>();
    if (stockBloc.state is StockInitial) {
      stockBloc.add(const StockLoadRequested());
    }

    final ProveedoresBloc proveedoresBloc = context.read<ProveedoresBloc>();
    if (proveedoresBloc.state is ProveedoresInitial) {
      proveedoresBloc.add(const ProveedoresLoadRequested());
    }

    final ProductoBloc productoBloc = context.read<ProductoBloc>();
    if (productoBloc.state is ProductoInitial) {
      productoBloc.add(const ProductoLoadAllRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header personalizado con estadísticas
            DashboardAlmacenHeader(),
            SizedBox(height: AppSizes.spacingXl),

            // Contenido del dashboard
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _StatsCardsSection(),
                    SizedBox(height: AppSizes.spacing),
                    _AlertsSection(),
                    SizedBox(height: AppSizes.spacing),
                    _RecentActivitySection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sección de tarjetas de estadísticas principales
class _StatsCardsSection extends StatelessWidget {
  const _StatsCardsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (BuildContext context, StockState stockState) {
        return BlocBuilder<ProveedoresBloc, ProveedoresState>(
          builder: (BuildContext context, ProveedoresState proveedoresState) {
            if (stockState is StockLoading || proveedoresState is ProveedoresLoading) {
              return const Center(
                child: AppLoadingIndicator(message: 'Cargando estadísticas...'),
              );
            }

            if (stockState is! StockLoaded || proveedoresState is! ProveedoresLoaded) {
              return const SizedBox.shrink();
            }

            final List<StockEntity> stock = stockState.stock;
            final List<ProveedorEntity> proveedores = proveedoresState.proveedores;

            // Calcular estadísticas
            final int totalItems = stock.length;
            final int stockActivo = stock.where((StockEntity s) => s.activo).length;
            final int stockBajo = stock.where((StockEntity s) =>
                s.cantidadDisponible <= s.cantidadMinima).length;

            final DateTime fechaLimite = DateTime.now().add(const Duration(days: 30));
            final int proximosACaducar = stock.where((StockEntity s) {
              if (s.fechaCaducidad == null) {
                return false;
              }
              return s.fechaCaducidad!.isBefore(fechaLimite) &&
                     s.fechaCaducidad!.isAfter(DateTime.now());
            }).length;

            double valorTotal = 0;
            for (final StockEntity item in stock) {
              if (item.precioUnitario != null) {
                valorTotal += item.precioUnitario! * item.cantidadDisponible;
              }
            }

            final int totalProveedores = proveedores.length;
            final int proveedoresActivos = proveedores.where((ProveedorEntity p) => p.activo).length;

            return Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    title: 'Total Items',
                    value: '$totalItems',
                    subtitle: '$stockActivo activos',
                    icon: Icons.inventory_2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing),
                Expanded(
                  child: _StatCard(
                    title: 'Stock Bajo Mínimo',
                    value: '$stockBajo',
                    subtitle: stockBajo > 0 ? '¡Requiere reposición!' : 'Todo OK',
                    icon: Icons.warning_amber,
                    color: stockBajo > 0 ? AppColors.warning : AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing),
                Expanded(
                  child: _StatCard(
                    title: 'Próximos a Caducar',
                    value: '$proximosACaducar',
                    subtitle: 'En los próximos 30 días',
                    icon: Icons.schedule,
                    color: proximosACaducar > 0 ? AppColors.error : AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing),
                Expanded(
                  child: _StatCard(
                    title: 'Valor Total Stock',
                    value: '${valorTotal.toStringAsFixed(2)}€',
                    subtitle: 'Valoración FIFO',
                    icon: Icons.euro,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing),
                Expanded(
                  child: _StatCard(
                    title: 'Proveedores',
                    value: '$totalProveedores',
                    subtitle: '$proveedoresActivos activos',
                    icon: Icons.business,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 24, color: color),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección de alertas y avisos
class _AlertsSection extends StatelessWidget {
  const _AlertsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (BuildContext context, StockState state) {
        if (state is! StockLoaded) {
          return const SizedBox.shrink();
        }

        final List<StockEntity> stock = state.stock;
        final List<StockEntity> stockBajo = stock.where((StockEntity s) =>
            s.cantidadDisponible <= s.cantidadMinima && s.activo).toList();

        final DateTime fechaLimite = DateTime.now().add(const Duration(days: 30));
        final List<StockEntity> proximosACaducar = stock.where((StockEntity s) {
          if (s.fechaCaducidad == null) {
            return false;
          }
          return s.fechaCaducidad!.isBefore(fechaLimite) &&
                 s.fechaCaducidad!.isAfter(DateTime.now()) &&
                 s.activo;
        }).toList();

        if (stockBajo.isEmpty && proximosACaducar.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(color: AppColors.gray200),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.notifications_active, color: AppColors.warning, size: 24),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Text(
                    'Alertas y Avisos',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),
              const Divider(),
              const SizedBox(height: AppSizes.spacing),

              // Stock bajo
              if (stockBajo.isNotEmpty) ...<Widget>[
                _AlertItem(
                  icon: Icons.warning_amber,
                  color: AppColors.warning,
                  title: 'Stock Bajo Mínimo',
                  count: stockBajo.length,
                  description: '${stockBajo.length} items requieren reposición urgente',
                ),
                const SizedBox(height: AppSizes.spacing),
              ],

              // Próximos a caducar
              if (proximosACaducar.isNotEmpty)
                _AlertItem(
                  icon: Icons.schedule,
                  color: AppColors.error,
                  title: 'Próximos a Caducar',
                  count: proximosACaducar.length,
                  description: '${proximosACaducar.length} items caducan en los próximos 30 días',
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.count,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final int count;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección de actividad reciente (placeholder)
class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.history, color: AppColors.info, size: 24),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                'Actividad Reciente',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          const Divider(),
          const SizedBox(height: AppSizes.spacing),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingXl),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.access_time,
                    size: 48,
                    color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSizes.spacing),
                  Text(
                    'Actividad reciente disponible próximamente',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aquí se mostrarán las entradas, transferencias y bajas recientes',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
