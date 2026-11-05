import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/stock_vestuario/stock_asignaciones_tab.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/stock_vestuario/stock_vestuario_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del artículo de stock seleccionado
class StockVestuarioDetailPanel extends StatelessWidget {
  const StockVestuarioDetailPanel({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final StockVestuarioEntity? item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final StockVestuarioEntity? s = item;
    if (s == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona un artículo para ver su ficha',
      );
    }
    final NivelStock nivel = NivelStock.of(s);
    return GestionDetailPanel(
      key: ValueKey<String>(s.id),
      title: '${s.prenda} · ${s.talla}',
      badges: <Widget>[
        GestionDotLabel(label: nivel.label, color: nivel.color),
        StockEstadoDot(activo: s.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _StockGeneralTab(item: s)),
        GestionDetailTab(label: 'Asignaciones', child: StockAsignacionesTab(stock: s)),
      ],
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Editar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Eliminar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _StockGeneralTab extends StatelessWidget {
  const _StockGeneralTab({required this.item});

  final StockVestuarioEntity item;

  @override
  Widget build(BuildContext context) {
    final StockVestuarioEntity s = item;
    final double? precio = s.precioUnitario;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Artículo'),
        GestionDetailField(label: 'Prenda', value: s.prenda),
        GestionDetailField(label: 'Talla', value: s.talla),
        GestionDetailField(label: 'Marca', value: s.marca),
        GestionDetailField(label: 'Color', value: s.color),
        const GestionDetailSection(title: 'Existencias'),
        GestionDetailField(label: 'Total', value: '${s.cantidadTotal}'),
        GestionDetailField(label: 'Asignada', value: '${s.cantidadAsignada}'),
        GestionDetailField(label: 'Disponible', child: StockDisponibleDot(item: s)),
        GestionDetailField(label: 'Stock mínimo', value: s.stockMinimo?.toString()),
        GestionDetailField(
          label: '% disponible',
          value: '${s.porcentajeDisponible.round()} %',
        ),
        const GestionDetailSection(title: 'Almacén'),
        GestionDetailField(label: 'Proveedor', value: s.proveedor),
        GestionDetailField(label: 'Ubicación', value: s.ubicacionAlmacen),
        GestionDetailField(
          label: 'Precio unitario',
          value: precio == null ? null : GestionFormatters.moneda(precio),
        ),
        GestionDetailField(
          label: 'Valor stock',
          value: precio == null ? null : GestionFormatters.moneda(precio * s.cantidadTotal),
        ),
        const GestionDetailSection(title: 'Observaciones'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(s.observaciones),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: s.observaciones?.trim().isNotEmpty ?? false
                  ? AppColors.gray800
                  : AppColors.gray300,
            ),
          ),
        ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(s.createdAt)),
        GestionDetailField(
          label: 'Modificado',
          value: s.updatedAt == null ? null : GestionFormatters.fecha(s.updatedAt),
        ),
      ],
    );
  }
}
