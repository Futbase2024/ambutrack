import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/stock_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la línea de stock seleccionada
class StockDetailPanel extends StatelessWidget {
  const StockDetailPanel({
    required this.item,
    required this.productos,
    required this.onEdit,
    required this.onTransfer,
    super.key,
  });

  final StockEntity? item;
  final Map<String, ProductoEntity> productos;
  final VoidCallback onEdit;
  final VoidCallback onTransfer;

  @override
  Widget build(BuildContext context) {
    final StockEntity? s = item;
    if (s == null) {
      return const GestionDetailEmpty(message: 'Selecciona una línea de stock para ver su ficha');
    }
    final StockSituacion situacion = StockSituacion.de(s);
    return GestionDetailPanel(
      key: ValueKey<String>(s.id),
      title: stockProducto(s, productos),
      badges: <Widget>[GestionDotLabel(label: situacion.label, color: situacion.color)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _StockGeneralTab(item: s, producto: productos[s.idProducto])),
      ],
      actions: <Widget>[
        AlmacenDetailEditButton(onPressed: onEdit),
        OutlinedButton.icon(
          onPressed: onTransfer,
          icon: const Icon(Icons.local_shipping_outlined, size: 16),
          label: const Text('Transferir'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _StockGeneralTab extends StatelessWidget {
  const _StockGeneralTab({required this.item, required this.producto});

  final StockEntity item;
  final ProductoEntity? producto;

  @override
  Widget build(BuildContext context) {
    final StockEntity s = item;
    final ProductoEntity? p = producto;
    final String unidad = p?.unidadMedida ?? '';
    String cant(double v) => '${almacenCantidad(v)} $unidad'.trim();
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Producto'),
        GestionDetailField(label: 'Nombre', value: p?.nombre),
        GestionDetailField(label: 'Comercial', value: p?.nombreComercial),
        GestionDetailField(label: 'Código', value: p?.codigo),
        GestionDetailField(label: 'Categoría', value: p?.categoria?.label),
        const GestionDetailSection(title: 'Cantidades'),
        GestionDetailField(label: 'Actual', value: cant(s.cantidadActual)),
        GestionDetailField(label: 'Reservada', value: cant(s.cantidadReservada)),
        GestionDetailField(label: 'Disponible', value: cant(s.cantidadDisponible)),
        GestionDetailField(label: 'Mín / Máx', value: stockMinMax(s)),
        const GestionDetailSection(title: 'Trazabilidad'),
        GestionDetailField(label: 'Ubicación', value: s.ubicacionFisica),
        GestionDetailField(label: 'Lote', value: s.lote),
        GestionDetailField(label: 'Nº serie', value: s.numeroSerie),
        GestionDetailField(label: 'Caducidad', value: GestionFormatters.fecha(s.fechaCaducidad)),
        const GestionDetailSection(title: 'Compra'),
        GestionDetailField(label: 'Entrada', value: GestionFormatters.fecha(s.fechaEntrada)),
        GestionDetailField(label: 'Nº factura', value: s.numeroFactura),
        GestionDetailField(
          label: 'Precio unidad',
          value: s.precioUnitario == null ? null : GestionFormatters.moneda(s.precioUnitario!),
        ),
        GestionDetailField(
          label: 'Precio total',
          value: s.precioTotal == null ? null : GestionFormatters.moneda(s.precioTotal!),
        ),
        const GestionDetailSection(title: 'Observaciones'),
        AlmacenDetailText(s.observaciones),
      ],
    );
  }
}
