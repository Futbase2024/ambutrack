// ignore_for_file: implementation_imports
import 'package:ambutrack_core/src/datasources/stock/entities/stock_vehiculo_entity.dart';
import 'package:ambutrack_core/src/datasources/stock/stock_contract.dart'
    as legacy_stock;
import 'package:ambutrack_core/src/datasources/stock/stock_factory.dart'
    as legacy_stock;
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo para ver todo el equipamiento de un vehículo
class StockEquipamientoViewDialog extends StatefulWidget {
  const StockEquipamientoViewDialog({
    required this.vehiculoId,
    required this.matricula,
    required this.marca,
    required this.modelo,
    super.key,
  });

  final String vehiculoId;
  final String matricula;
  final String marca;
  final String modelo;

  @override
  State<StockEquipamientoViewDialog> createState() =>
      _StockEquipamientoViewDialogState();
}

class _StockEquipamientoViewDialogState
    extends State<StockEquipamientoViewDialog> {
  late final legacy_stock.StockDataSource _stockDataSource;
  List<StockVehiculoEntity>? _stock;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _stockDataSource = legacy_stock.StockDataSourceFactory.createSupabase();
    _loadStock();
  }

  Future<void> _loadStock() async {
    try {
      final List<StockVehiculoEntity> stock =
          await _stockDataSource.getStockVehiculo(widget.vehiculoId);
      if (mounted) {
        setState(() {
          _stock = stock;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header
            _buildHeader(),
            // Content
            Flexible(child: _buildContent()),
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLarge),
          topRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: Colors.white,
              size: AppSizes.iconMedium,
            ),
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Equipamiento del Vehículo',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontLarge,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.matricula} - ${widget.marca} ${widget.modelo}',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontSmall,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.paddingXl),
        child: Center(
          child: AppLoadingIndicator(message: 'Cargando equipamiento...'),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: AppSizes.spacing),
              Text(
                'Error al cargar equipamiento',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              Text(
                _error!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_stock == null || _stock!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.gray400,
                size: 64,
              ),
              const SizedBox(height: AppSizes.spacing),
              Text(
                'Sin equipamiento',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              Text(
                'Este vehículo no tiene items de equipamiento registrados',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Resumen
          _buildResumen(),
          const SizedBox(height: AppSizes.spacingLarge),
          // Lista de items
          _buildItemsList(),
        ],
      ),
    );
  }

  Widget _buildResumen() {
    int ok = 0;
    int caducados = 0;
    int stockBajo = 0;
    int proximosCaducar = 0;

    for (final StockVehiculoEntity item in _stock!) {
      if (item.estadoCaducidad == 'caducado') {
        caducados++;
      } else if (item.estadoCaducidad == 'critico' ||
          item.estadoCaducidad == 'proximo') {
        proximosCaducar++;
      }

      if (item.estadoStock == 'bajo' || item.estadoStock == 'sin_stock') {
        stockBajo++;
      }

      if (item.estadoStock == 'ok' &&
          item.estadoCaducidad != 'caducado' &&
          item.estadoCaducidad != 'critico') {
        ok++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          _buildResumenItem('Total', _stock!.length.toString(), AppColors.primary),
          _buildResumenItem('OK', ok.toString(), AppColors.success),
          _buildResumenItem('Caducados', caducados.toString(), AppColors.error),
          _buildResumenItem('Stock Bajo', stockBajo.toString(), AppColors.warning),
          _buildResumenItem('Próx. Caducar', proximosCaducar.toString(), AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        children: <Widget>[
          // Header de tabla
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingSmall,
            ),
            decoration: const BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusSmall),
                topRight: Radius.circular(AppSizes.radiusSmall),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text(
                    'PRODUCTO',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'CANTIDAD',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'CADUCIDAD',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'ESTADO',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Items
          ...List<Widget>.generate(_stock!.length, (int index) {
            final StockVehiculoEntity item = _stock![index];
            return _buildItemRow(item, index);
          }),
        ],
      ),
    );
  }

  Widget _buildItemRow(StockVehiculoEntity item, int index) {
    final bool isLast = index == _stock!.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : AppColors.gray50,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.radiusSmall),
                bottomRight: Radius.circular(AppSizes.radiusSmall),
              )
            : null,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.productoNombre ?? 'Sin nombre',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.lote != null && item.lote!.isNotEmpty)
                  Text(
                    'Lote: ${item.lote}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${item.cantidadActual}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _getCantidadColor(item),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              item.fechaCaducidad != null
                  ? _formatDate(item.fechaCaducidad!)
                  : '-',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _getCaducidadColor(item),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: StatusBadge(
                label: _getEstadoLabel(item),
                type: _getEstadoBadgeType(item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCantidadColor(StockVehiculoEntity item) {
    if (item.estadoStock == 'sin_stock') {
      return AppColors.error;
    }
    if (item.estadoStock == 'bajo') {
      return AppColors.warning;
    }
    return AppColors.textPrimaryLight;
  }

  Color _getCaducidadColor(StockVehiculoEntity item) {
    if (item.estadoCaducidad == 'caducado') {
      return AppColors.error;
    }
    if (item.estadoCaducidad == 'critico') {
      return AppColors.error;
    }
    if (item.estadoCaducidad == 'proximo') {
      return AppColors.warning;
    }
    return AppColors.textSecondaryLight;
  }

  String _getEstadoLabel(StockVehiculoEntity item) {
    if (item.estadoCaducidad == 'caducado') {
      return 'CADUCADO';
    }
    if (item.estadoStock == 'sin_stock') {
      return 'SIN STOCK';
    }
    if (item.estadoStock == 'bajo') {
      return 'BAJO';
    }
    if (item.estadoCaducidad == 'proximo' || item.estadoCaducidad == 'critico') {
      return 'PRÓXIMO';
    }
    return 'OK';
  }

  StatusBadgeType _getEstadoBadgeType(StockVehiculoEntity item) {
    if (item.estadoCaducidad == 'caducado') {
      return StatusBadgeType.error;
    }
    if (item.estadoStock == 'sin_stock') {
      return StatusBadgeType.error;
    }
    if (item.estadoStock == 'bajo') {
      return StatusBadgeType.warning;
    }
    if (item.estadoCaducidad == 'proximo' || item.estadoCaducidad == 'critico') {
      return StatusBadgeType.warning;
    }
    return StatusBadgeType.success;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cerrar',
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    );
  }
}
