import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página de Movimientos de Stock (Historial)
///
/// Muestra el historial completo de todos los movimientos de stock:
/// - Entradas (compras, devoluciones)
/// - Salidas (transferencias, consumos, bajas)
/// - Ajustes de inventario
class MovimientosStockPage extends StatelessWidget {
  const MovimientosStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header
              _buildHeader(),
              const SizedBox(height: AppSizes.spacing),

              // Filtros
              _buildFilters(),
              const SizedBox(height: AppSizes.spacing),

              // Tabla de movimientos
              Expanded(
                child: _buildMovimientosTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header de la página
  Widget _buildHeader() {
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
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: const Icon(
              Icons.history,
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
                'Movimientos de Stock',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Text(
                'Historial completo de entradas, salidas y transferencias',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Filtros de búsqueda
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por producto, lote, referencia...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacing),
          OutlinedButton.icon(
            onPressed: () {
              debugPrint('🔍 Abrir filtros avanzados');
            },
            icon: const Icon(Icons.filter_list, size: 18),
            label: Text(
              'Filtros',
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Tabla de movimientos
  Widget _buildMovimientosTable() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Info de la tabla
          Text(
            'Últimos movimientos',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),

          // Tabla placeholder
          Expanded(
            child: _buildPlaceholderTable(),
          ),
        ],
      ),
    );
  }

  /// Tabla placeholder (implementación futura con BLoC)
  Widget _buildPlaceholderTable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.history,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Historial de Movimientos',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Aquí se mostrará el historial completo de movimientos de stock:',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacing),
          _buildMovimientoTipoLegend(),
        ],
      ),
    );
  }

  /// Leyenda de tipos de movimiento
  Widget _buildMovimientoTipoLegend() {
    return Wrap(
      spacing: AppSizes.spacingSmall,
      runSpacing: AppSizes.spacingSmall,
      children: <Widget>[
        _buildTipoBadge('Entrada Compra', AppColors.success),
        _buildTipoBadge('Transferencia a Vehículo', AppColors.info),
        _buildTipoBadge('Devolución de Vehículo', AppColors.secondary),
        _buildTipoBadge('Consumo en Servicio', AppColors.warning),
        _buildTipoBadge('Ajuste Inventario', AppColors.primary),
        _buildTipoBadge('Baja por Caducidad', AppColors.error),
      ],
    );
  }

  /// Badge de tipo de movimiento
  Widget _buildTipoBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.spacingXs),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
