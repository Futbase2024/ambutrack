// ignore_for_file: implementation_imports
import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_core/src/datasources/stock/entities/stock_vehiculo_entity.dart';
import 'package:ambutrack_core/src/datasources/stock/stock_contract.dart'
    as legacy_stock;
import 'package:ambutrack_core/src/datasources/stock/stock_factory.dart'
    as legacy_stock;
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/badges/status_badge.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/stock_manual_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página de visualización de stock de un vehículo específico
class VehiculoStockPage extends StatelessWidget {
  const VehiculoStockPage({required this.vehiculoId, super.key});

  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<VehiculosBloc>.value(
        value: getIt<VehiculosBloc>(),
        child: _VehiculoStockView(vehiculoId: vehiculoId),
      ),
    );
  }
}

/// Vista principal de stock del vehículo
class _VehiculoStockView extends StatefulWidget {
  const _VehiculoStockView({required this.vehiculoId});

  final String vehiculoId;

  @override
  State<_VehiculoStockView> createState() => _VehiculoStockViewState();
}

class _VehiculoStockViewState extends State<_VehiculoStockView> {
  late legacy_stock.StockDataSource _stockDataSource;
  List<StockVehiculoEntity> _stock = <StockVehiculoEntity>[];
  VehiculoEntity? _vehiculo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _stockDataSource = legacy_stock.StockDataSourceFactory.createSupabase();

    // Asegurar que el BLoC tenga los vehículos cargados
    final VehiculosBloc vehiculosBloc = context.read<VehiculosBloc>();
    if (vehiculosBloc.state is! VehiculosLoaded) {
      vehiculosBloc.add(const VehiculosLoadRequested());
    }

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      debugPrint('📦 ========================================');
      debugPrint('📦 CARGANDO STOCK DE VEHÍCULO (LEGACY SYSTEM)');
      debugPrint('📦 ID del vehículo recibido: ${widget.vehiculoId}');
      debugPrint('📦 ========================================');

      // Cargar vehículo desde BLoC
      final VehiculosState vehiculosState = context.read<VehiculosBloc>().state;
      if (vehiculosState is VehiculosLoaded) {
        _vehiculo = vehiculosState.vehiculos.firstWhere(
          (VehiculoEntity v) => v.id == widget.vehiculoId,
          orElse: () => throw Exception('Vehículo no encontrado'),
        );
        debugPrint(
            '📦 Vehículo encontrado: ${_vehiculo!.matricula} (${_vehiculo!.marca} ${_vehiculo!.modelo})');
        debugPrint('📦 ID confirmado: ${_vehiculo!.id}');
      } else {
        debugPrint('⚠️ Estado del BLoC no es VehiculosLoaded: $vehiculosState');
      }

      // Cargar stock del vehículo (sistema legacy: stock_vehiculo table)
      debugPrint(
          '🔍 Consultando tabla stock_vehiculo con vehiculo_id = ${widget.vehiculoId}');
      final List<StockVehiculoEntity> stock =
          await _stockDataSource.getStockVehiculo(widget.vehiculoId);

      debugPrint('✅ Stock cargado: ${stock.length} items');
      if (stock.isEmpty) {
        debugPrint('⚠️ No se encontró stock para este vehículo');
        debugPrint(
            '   Verificar que en la tabla "stock_vehiculo" existan registros con vehiculo_id = ${widget.vehiculoId}');
      } else {
        debugPrint('📦 Stock encontrado:');
        for (final StockVehiculoEntity item in stock) {
          debugPrint(
              '   - ${item.productoNombre ?? 'Sin nombre'}: ${item.cantidadActual} unidades');
        }
      }

      if (mounted) {
        setState(() {
          _stock = stock;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar stock: $e');
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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header personalizado con botón cerrar integrado
            _StockVehiculoHeader(
              vehiculoId: widget.vehiculoId,
              vehiculo: _vehiculo,
              stats: _buildHeaderStats(),
              onClose: () => context.goNamed('vehiculos'),
              onReload: _loadData, // Pasar método de recarga
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Contenido
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const _LoadingView();
    }

    if (_error != null) {
      return _ErrorView(message: _error!);
    }

    if (_stock.isEmpty) {
      return _EmptyStockView(onRefresh: _loadData);
    }

    return _StockTable(
      stock: _stock,
      onRefresh: _loadData,
    );
  }

  List<HeaderStat> _buildHeaderStats() {
    if (_isLoading) {
      return <HeaderStat>[
        const HeaderStat(value: '-', icon: Icons.inventory_2),
        const HeaderStat(value: '-', icon: Icons.check_circle),
        const HeaderStat(value: '-', icon: Icons.warning),
      ];
    }

    final int totalItems = _stock.length;
    final int itemsOk =
        _stock.where((StockVehiculoEntity s) => s.estadoStock == 'ok').length;
    final int itemsAlerta = _stock
        .where((StockVehiculoEntity s) =>
            s.estadoStock == 'bajo' || s.estadoStock == 'sin_stock')
        .length;

    return <HeaderStat>[
      HeaderStat(value: totalItems.toString(), icon: Icons.inventory_2),
      HeaderStat(value: itemsOk.toString(), icon: Icons.check_circle),
      HeaderStat(value: itemsAlerta.toString(), icon: Icons.warning),
    ];
  }
}

/// Header personalizado con botón cerrar integrado
class _StockVehiculoHeader extends StatelessWidget {
  const _StockVehiculoHeader({
    required this.vehiculoId,
    required this.vehiculo,
    required this.stats,
    required this.onClose,
    required this.onReload,
  });

  final String vehiculoId;
  final VehiculoEntity? vehiculo;
  final List<HeaderStat> stats;
  final VoidCallback onClose;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1024;

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
      child: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: <Widget>[
        _buildTitleSection(),
        const SizedBox(width: AppSizes.spacingLarge),
        Expanded(child: _buildStatsSection()),
        const SizedBox(width: AppSizes.spacingLarge),
        _buildAddButton(context),
        const SizedBox(width: AppSizes.spacing),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _buildTitleSection()),
            const SizedBox(width: AppSizes.spacing),
            _buildAddButton(context),
            const SizedBox(width: AppSizes.spacing),
            _buildCloseButton(),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        _buildStatsSection(),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: const Icon(
            Icons.medical_services,
            color: AppColors.primary,
            size: AppSizes.iconMedium,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              vehiculo != null
                  ? 'Stock - ${vehiculo!.matricula}'
                  : 'Stock de Vehículo',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              vehiculo != null
                  ? '${vehiculo!.marca} ${vehiculo!.modelo} (${vehiculo!.tipoVehiculo})'
                  : 'Visualización de equipamiento y stock',
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

  Widget _buildStatsSection() {
    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Expanded> widgets = stats
        .map(
          (HeaderStat s) => Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSmall,
                vertical: AppSizes.spacingXs,
              ),
              decoration: BoxDecoration(
                color: (s.color ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(
                    color: (s.color ?? AppColors.primary).withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(s.icon,
                      color: s.color ?? AppColors.primary,
                      size: AppSizes.iconLarge),
                  const SizedBox(width: AppSizes.spacingXs),
                  Text(
                    s.value,
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontMedium,
                      fontWeight: FontWeight.bold,
                      color: s.color ?? AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();

    return Row(
      children: widgets
          .expand((Expanded w) =>
              <Widget>[w, const SizedBox(width: AppSizes.spacingSmall)])
          .toList()
        ..removeLast(),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return AppButton(
      onPressed: () async {
        debugPrint('🆕 Abriendo formulario de stock manual');
        debugPrint('📦 vehiculoId: $vehiculoId');
        final bool? result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return StockManualFormDialog(
              vehiculoId: vehiculoId, // Usar vehiculoId del constructor, no vehiculo?.id
            );
          },
        );

        // Si se añadió stock exitosamente, recargar la tabla
        if (result == true) {
          debugPrint('🔄 Recargando stock del vehículo...');
          onReload(); // Recargar datos en lugar de cerrar la página
        }
      },
      icon: Icons.add,
      label: 'Añadir',
    );
  }

  Widget _buildCloseButton() {
    return ElevatedButton.icon(
      onPressed: onClose,
      icon: const Icon(Icons.close, size: AppSizes.iconSmall),
      label: const Text('Cerrar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error.withValues(alpha: 0.15),
        foregroundColor: AppColors.error,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
    );
  }
}

/// Vista de carga
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      constraints: const BoxConstraints(minHeight: 400),
      child: const Center(
        child: AppLoadingIndicator(
          message: 'Cargando stock...',
        ),
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Error al cargar stock',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Vista cuando no hay stock
class _EmptyStockView extends StatelessWidget {
  const _EmptyStockView({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.medical_services_outlined,
              color: AppColors.info, size: 64),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Sin stock registrado',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Este vehículo aún no tiene equipamiento registrado.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacing),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}

/// Tabla de stock
class _StockTable extends StatelessWidget {
  const _StockTable({
    required this.stock,
    required this.onRefresh,
  });

  final List<StockVehiculoEntity> stock;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Botón refrescar
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),

        // Tabla
        Expanded(
          child: AppDataGridV5<StockVehiculoEntity>(
            columns: const <DataGridColumn>[
              DataGridColumn(label: 'PRODUCTO', fixedWidth: 250),
              DataGridColumn(label: 'CATEGORÍA', fixedWidth: 150),
              DataGridColumn(label: 'CANTIDAD', fixedWidth: 120),
              DataGridColumn(label: 'LOTE', fixedWidth: 120),
              DataGridColumn(label: 'CADUCIDAD', fixedWidth: 120),
              DataGridColumn(label: 'UBICACIÓN', fixedWidth: 150),
              DataGridColumn(label: 'ESTADO', fixedWidth: 150),
            ],
            rows: stock,
            buildCells: _buildCells,
            emptyMessage: 'No hay stock en este vehículo',
          ),
        ),
      ],
    );
  }

  List<DataGridCell> _buildCells(StockVehiculoEntity item) {
    return <DataGridCell>[
      // Producto
      DataGridCell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.productoNombre ?? 'Sin nombre',
              style: AppTextStyles.tableCellBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.nombreComercial != null &&
                item.nombreComercial!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                item.nombreComercial!,
                style: AppTextStyles.tableCellSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),

      // Categoría
      DataGridCell(
        child: Text(
          item.categoriaNombre ?? '-',
          style: AppTextStyles.tableCell,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // Cantidad
      DataGridCell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              item.cantidadActual.toString(),
              style: AppTextStyles.tableCellBold.copyWith(
                color: _getCantidadColor(item),
              ),
            ),
            if (item.cantidadMinima != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                'Mín: ${item.cantidadMinima}',
                style: AppTextStyles.tableCellSmall,
              ),
            ],
          ],
        ),
      ),

      // Lote
      DataGridCell(
        child: Text(
          item.lote ?? '-',
          style: AppTextStyles.tableCell,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // Caducidad
      DataGridCell(
        child: Text(
          item.fechaCaducidad != null
              ? _formatFecha(item.fechaCaducidad!)
              : '-',
          style: AppTextStyles.tableCell.copyWith(
            color: _getCaducidadColor(item),
          ),
        ),
      ),

      // Ubicación
      DataGridCell(
        child: Text(
          item.ubicacion ?? '-',
          style: AppTextStyles.tableCell,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // Estado
      DataGridCell(
        child: Align(
          alignment: Alignment.centerLeft,
          child: StatusBadge(
            label: _getEstadoLabel(item),
            type: _getEstadoBadgeType(item),
          ),
        ),
      ),
    ];
  }

  String _getEstadoLabel(StockVehiculoEntity item) {
    // Priorizar caducidad crítica
    if (item.estadoCaducidad == 'caducado') {
      return 'CADUCADO';
    }
    if (item.estadoCaducidad == 'critico') {
      return 'CADUCA PRONTO';
    }
    if (item.estadoCaducidad == 'proximo') {
      return 'PRÓXIMO CADUCIDAD';
    }

    // Luego stock
    if (item.estadoStock == 'sin_stock') {
      return 'SIN STOCK';
    }
    if (item.estadoStock == 'bajo') {
      return 'STOCK BAJO';
    }

    // Estado normal
    return 'OK';
  }

  StatusBadgeType _getEstadoBadgeType(StockVehiculoEntity item) {
    // Caducidad tiene prioridad
    if (item.estadoCaducidad == 'caducado') {
      return StatusBadgeType.error;
    }
    if (item.estadoCaducidad == 'critico' ||
        item.estadoCaducidad == 'proximo') {
      return StatusBadgeType.warning;
    }

    // Estado de stock
    if (item.estadoStock == 'sin_stock') {
      return StatusBadgeType.error;
    }
    if (item.estadoStock == 'bajo') {
      return StatusBadgeType.warning;
    }

    return StatusBadgeType.success;
  }

  Color _getCantidadColor(StockVehiculoEntity item) {
    if (item.estadoStock == 'sin_stock') {
      return AppColors.error;
    }
    if (item.estadoStock == 'bajo') {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  Color _getCaducidadColor(StockVehiculoEntity item) {
    if (item.estadoCaducidad == 'caducado') {
      return AppColors.error;
    }
    if (item.estadoCaducidad == 'critico' ||
        item.estadoCaducidad == 'proximo') {
      return AppColors.warning;
    }
    return AppColors.textPrimaryLight;
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}
