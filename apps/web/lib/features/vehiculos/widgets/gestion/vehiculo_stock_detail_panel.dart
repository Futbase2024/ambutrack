import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_stock_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del item de stock seleccionado (solo consulta)
class VehiculoStockDetailPanel extends StatelessWidget {
  const VehiculoStockDetailPanel({required this.item, super.key});

  final StockVehiculoEntity? item;

  @override
  Widget build(BuildContext context) {
    final StockVehiculoEntity? s = item;
    if (s == null) {
      return const GestionDetailEmpty(message: 'Selecciona un producto para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(s.id),
      title: GestionFormatters.texto(s.productoNombre),
      badges: <Widget>[StockItemEstadoDot(item: s)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: GestionDetailBody(
            children: <Widget>[
              const GestionDetailSection(title: 'Producto'),
              GestionDetailField(label: 'Nombre', value: s.productoNombre),
              GestionDetailField(label: 'Comercial', value: s.nombreComercial),
              GestionDetailField(label: 'Categoría', value: s.categoriaNombre),
              GestionDetailField(label: 'Cód. categoría', value: s.categoriaCodigo),
              const GestionDetailSection(title: 'Stock'),
              GestionDetailField(label: 'Cantidad', value: '${s.cantidadActual}'),
              GestionDetailField(label: 'Mínimo', value: s.cantidadMinima?.toString()),
              GestionDetailField(label: 'Estado', child: StockItemEstadoDot(item: s)),
              GestionDetailField(label: 'Ubicación', value: s.ubicacion),
              const GestionDetailSection(title: 'Caducidad'),
              GestionDetailField(
                label: 'Fecha',
                value: s.fechaCaducidad == null ? null : GestionFormatters.fecha(s.fechaCaducidad),
              ),
              GestionDetailField(label: 'Lote', value: s.lote),
              const GestionDetailSection(title: 'Observaciones'),
              FlotaNotes(s.observaciones),
              const GestionDetailSection(title: 'Registro'),
              GestionDetailField(label: 'Actualizado', value: GestionFormatters.fecha(s.updatedAt)),
            ],
          ),
        ),
      ],
    );
  }
}
