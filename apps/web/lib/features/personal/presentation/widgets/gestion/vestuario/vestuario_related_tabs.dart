import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/vestuario/vestuario_gestion_columns.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Busca el artículo de stock que corresponde a la prenda asignada
/// (misma prenda, talla, marca y color)
StockVestuarioEntity? stockDeVestuario(List<StockVestuarioEntity> stock, VestuarioEntity v) {
  for (final StockVestuarioEntity s in stock) {
    if (s.prenda == v.prenda && s.talla == v.talla && s.marca == v.marca && s.color == v.color) {
      return s;
    }
  }
  return null;
}

/// Pestaña "Stock": existencias del artículo de almacén correspondiente
class VestuarioStockTab extends StatelessWidget {
  const VestuarioStockTab({required this.item, super.key});

  final VestuarioEntity item;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockVestuarioBloc, StockVestuarioState>(
      builder: (BuildContext context, StockVestuarioState state) {
        if (state is! StockVestuarioLoaded) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final StockVestuarioEntity? s = stockDeVestuario(state.items, item);
        if (s == null) {
          return const GestionDetailBody(
            children: <Widget>[
              GestionDetailSection(title: 'Stock'),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No hay un artículo de stock con la misma prenda, talla, marca y color',
                  style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
                ),
              ),
            ],
          );
        }
        final Color nivel = s.sinStock
            ? AppColors.error
            : s.tieneStockBajo
                ? AppColors.warning
                : AppColors.success;
        return GestionDetailBody(
          children: <Widget>[
            const GestionDetailSection(title: 'Existencias'),
            GestionDetailField(label: 'Total', value: '${s.cantidadTotal}'),
            GestionDetailField(label: 'Asignada', value: '${s.cantidadAsignada}'),
            GestionDetailField(
              label: 'Disponible',
              child: GestionDotLabel(label: '${s.cantidadDisponible}', color: nivel),
            ),
            GestionDetailField(label: 'Stock mínimo', value: s.stockMinimo?.toString()),
            const GestionDetailSection(title: 'Almacén'),
            GestionDetailField(label: 'Proveedor', value: s.proveedor),
            GestionDetailField(label: 'Ubicación', value: s.ubicacionAlmacen),
            GestionDetailField(
              label: 'Precio unitario',
              value: s.precioUnitario == null ? null : GestionFormatters.moneda(s.precioUnitario!),
            ),
          ],
        );
      },
    );
  }
}

/// Pestaña "Trabajador": prendas asignadas al mismo trabajador
class VestuarioTrabajadorTab extends StatelessWidget {
  const VestuarioTrabajadorTab({required this.items, required this.selectedId, super.key});

  final List<VestuarioEntity> items;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    final int asignadas = items
        .where((VestuarioEntity v) => v.estaAsignado)
        .fold<int>(0, (int sum, VestuarioEntity v) => sum + (v.cantidad ?? 1));
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Resumen'),
        GestionDetailField(label: 'Registros', value: '${items.length}'),
        GestionDetailField(label: 'Uds. asignadas', value: '$asignadas'),
        const GestionDetailSection(title: 'Vestuario del trabajador'),
        ...items.map(
          (VestuarioEntity v) => _VestuarioMiniRow(item: v, selected: v.id == selectedId),
        ),
      ],
    );
  }
}

class _VestuarioMiniRow extends StatelessWidget {
  const _VestuarioMiniRow({required this.item, required this.selected});

  final VestuarioEntity item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = TextStyle(
      fontSize: 12,
      color: AppColors.gray800,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
    );
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${item.prenda} (${item.talla}) x${item.cantidad ?? 1}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: base,
            ),
          ),
          const SizedBox(width: 6),
          VestuarioEstadoDot(item: item),
          const SizedBox(width: 8),
          Text(
            GestionFormatters.fecha(item.fechaEntrega),
            style: base.copyWith(color: AppColors.gray500, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
