import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity;
// ignore: implementation_imports
import 'package:ambutrack_core_datasource/src/datasources/almacen/entities/movimiento_stock_entity.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/movimiento_stock/movimiento_stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/movimiento_stock/movimiento_stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/movimiento_stock/movimiento_stock_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/movimiento_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _maxUltimos = 20;

/// Indicador de carga pequeño para pestañas de la ficha
class _TabLoading extends StatelessWidget {
  const _TabLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

/// Mensaje de texto (vacío o error) dentro de una pestaña de la ficha
class _TabMessage extends StatelessWidget {
  const _TabMessage(this.message, {this.color = AppColors.gray500});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(message, style: TextStyle(fontSize: 12.5, color: color)),
    );
  }
}

/// Fila compacta de 30px para listados dentro de la ficha
class _MiniRow extends StatelessWidget {
  const _MiniRow({required this.leading, required this.middle, required this.trailing});

  final String leading;
  final Widget middle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(
              leading,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.gray800, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: middle),
          trailing,
        ],
      ),
    );
  }
}

/// Pestaña "Stock" de la ficha del producto (existencias por lote / nº serie)
class ProductoStockTab extends StatelessWidget {
  const ProductoStockTab({required this.productoId, super.key});

  final String productoId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StockBloc>(
      key: ValueKey<String>('stock_$productoId'),
      create: (BuildContext _) => getIt<StockBloc>()..add(StockLoadByProductoRequested(productoId)),
      child: BlocBuilder<StockBloc, StockState>(
        builder: (BuildContext context, StockState state) {
          if (state is StockError) {
            return GestionDetailBody(children: <Widget>[_TabMessage(state.message, color: AppColors.error)]);
          }
          if (state is! StockLoaded) {
            return const _TabLoading();
          }
          return _StockResumen(stocks: state.stocks);
        },
      ),
    );
  }
}

class _StockResumen extends StatelessWidget {
  const _StockResumen({required this.stocks});

  final List<StockEntity> stocks;

  @override
  Widget build(BuildContext context) {
    double sum(double Function(StockEntity) f) =>
        stocks.fold<double>(0, (double acc, StockEntity s) => acc + f(s));
    final List<StockEntity> conCaducidad = stocks
        .where((StockEntity s) => s.fechaCaducidad != null)
        .toList()
      ..sort((StockEntity a, StockEntity b) => a.fechaCaducidad!.compareTo(b.fechaCaducidad!));
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Existencias'),
        GestionDetailField(label: 'Cantidad actual', value: almacenCantidad(sum((StockEntity s) => s.cantidadActual))),
        GestionDetailField(label: 'Reservada', value: almacenCantidad(sum((StockEntity s) => s.cantidadReservada))),
        GestionDetailField(label: 'Disponible', value: almacenCantidad(sum((StockEntity s) => s.cantidadDisponible))),
        GestionDetailField(label: 'Registros', value: '${stocks.length}'),
        GestionDetailField(
          label: 'Próx. caducidad',
          value: conCaducidad.isEmpty ? null : GestionFormatters.fecha(conCaducidad.first.fechaCaducidad),
        ),
        const GestionDetailSection(title: 'Detalle'),
        if (stocks.isEmpty)
          const _TabMessage('Este producto no tiene stock registrado')
        else
          ...stocks.map((StockEntity s) => _StockRow(stock: s)),
      ],
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({required this.stock});

  final StockEntity stock;

  @override
  Widget build(BuildContext context) {
    final StockEntity s = stock;
    final Color color = s.caducado
        ? AppColors.error
        : s.proximoACaducar || s.bajoCantidadMinima
            ? AppColors.warning
            : AppColors.success;
    final String estado = s.caducado
        ? 'Caducado'
        : s.proximoACaducar
            ? 'Caduca ${GestionFormatters.fecha(s.fechaCaducidad)}'
            : s.bajoCantidadMinima
                ? 'Bajo mínimo'
                : (s.fechaCaducidad == null ? 'Correcto' : 'Cad. ${GestionFormatters.fecha(s.fechaCaducidad)}');
    return _MiniRow(
      leading: GestionFormatters.texto(s.lote ?? s.numeroSerie ?? s.ubicacionFisica),
      middle: GestionDotLabel(label: estado, color: color, fontSize: 11.5),
      trailing: Text(
        almacenCantidad(s.cantidadActual),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray800),
      ),
    );
  }
}

/// Pestaña "Movimientos" de la ficha del producto (últimos movimientos)
class ProductoMovimientosTab extends StatelessWidget {
  const ProductoMovimientosTab({required this.productoId, super.key});

  final String productoId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MovimientoStockBloc>(
      key: ValueKey<String>('movimientos_$productoId'),
      create: (BuildContext _) =>
          getIt<MovimientoStockBloc>()..add(MovimientoStockLoadByProductoRequested(productoId)),
      child: BlocBuilder<MovimientoStockBloc, MovimientoStockState>(
        builder: (BuildContext context, MovimientoStockState state) {
          if (state is MovimientoStockError) {
            return GestionDetailBody(children: <Widget>[_TabMessage(state.message, color: AppColors.error)]);
          }
          if (state is! MovimientoStockLoaded) {
            return const _TabLoading();
          }
          final List<MovimientoStockEntity> movimientos = List<MovimientoStockEntity>.of(state.movimientos)
            ..sort(
              (MovimientoStockEntity a, MovimientoStockEntity b) =>
                  (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)),
            );
          return GestionDetailBody(
            children: <Widget>[
              GestionDetailSection(
                title: movimientos.length > _maxUltimos ? 'Últimos $_maxUltimos movimientos' : 'Movimientos',
              ),
              if (movimientos.isEmpty)
                const _TabMessage('Este producto no tiene movimientos de stock')
              else
                ...movimientos.take(_maxUltimos).map(
                      (MovimientoStockEntity m) => _MiniRow(
                        leading: GestionFormatters.fecha(m.createdAt),
                        middle: GestionDotLabel(
                          label: m.tipo.label,
                          color: movimientoTipoColor(m.tipo),
                          fontSize: 11.5,
                        ),
                        trailing: Text(
                          movimientoCantidadConSigno(m),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: movimientoCantidadColor(m.tipo),
                          ),
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
