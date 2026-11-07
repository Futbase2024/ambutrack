import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/historial/registro_historial_tab.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/producto_gestion_columns.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/producto_relacionados_tabs.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del producto seleccionado
class ProductoDetailPanel extends StatelessWidget {
  const ProductoDetailPanel({
    required this.producto,
    required this.proveedorHabitual,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ProductoEntity? producto;

  /// Nombre del proveedor habitual (resuelto desde el catálogo de proveedores)
  final String? proveedorHabitual;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ProductoEntity? p = producto;
    if (p == null) {
      return const GestionDetailEmpty(message: 'Selecciona un producto para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(p.id),
      title: p.nombre,
      badges: <Widget>[
        ProductoCategoriaDot(categoria: p.categoria),
        AlmacenEstadoDot(activo: p.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _ProductoGeneralTab(producto: p, proveedorHabitual: proveedorHabitual),
        ),
        GestionDetailTab(label: 'Stock', child: ProductoStockTab(productoId: p.id)),
        GestionDetailTab(label: 'Movimientos', child: ProductoMovimientosTab(productoId: p.id)),
        GestionDetailTab(label: 'Cambios', child: RegistroHistorialTab(tabla: 'productos', registroId: p.id)),
      ],
      actions: <Widget>[
        AlmacenDetailEditButton(onPressed: onEdit),
        AlmacenDetailDeleteButton(onPressed: onDelete),
      ],
    );
  }
}

class _ProductoGeneralTab extends StatelessWidget {
  const _ProductoGeneralTab({required this.producto, required this.proveedorHabitual});

  final ProductoEntity producto;
  final String? proveedorHabitual;

  @override
  Widget build(BuildContext context) {
    final ProductoEntity p = producto;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Código', value: p.codigo),
        GestionDetailField(label: 'Nombre comercial', value: p.nombreComercial),
        GestionDetailField(label: 'Categoría', value: p.categoria?.label),
        GestionDetailField(label: 'Unidad', value: p.unidadMedida),
        const GestionDetailSection(title: 'Descripción'),
        AlmacenDetailText(p.descripcion),
        const GestionDetailSection(title: 'Almacenamiento'),
        GestionDetailField(label: 'Ubicación', value: p.ubicacionDefault),
        GestionDetailField(label: 'Refrigeración', value: almacenSiNo(value: p.requiereRefrigeracion)),
        GestionDetailField(label: 'Caducidad', value: almacenSiNo(value: p.tieneCaducidad)),
        if (p.tieneCaducidad)
          GestionDetailField(label: 'Alerta caducidad', value: '${p.diasAlertaCaducidad} días'),
        const GestionDetailSection(title: 'Compras'),
        GestionDetailField(
          label: 'Precio medio',
          value: p.precioMedio == null ? null : GestionFormatters.moneda(p.precioMedio!),
        ),
        GestionDetailField(label: 'Proveedor', value: proveedorHabitual),
        _ProductoCategoriaCampos(producto: p),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(
          label: 'Alta',
          value: p.createdAt == null ? null : GestionFormatters.fecha(p.createdAt),
        ),
        GestionDetailField(
          label: 'Modificado',
          value: p.updatedAt == null ? null : GestionFormatters.fecha(p.updatedAt),
        ),
      ],
    );
  }
}

/// Campos específicos de la categoría (medicación, electromedicina, material)
class _ProductoCategoriaCampos extends StatelessWidget {
  const _ProductoCategoriaCampos({required this.producto});

  final ProductoEntity producto;

  @override
  Widget build(BuildContext context) {
    final ProductoEntity p = producto;
    switch (p.categoria) {
      case CategoriaProducto.medicacion:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const GestionDetailSection(title: 'Medicación'),
            GestionDetailField(label: 'Principio activo', value: p.principioActivo),
            GestionDetailField(label: 'Requiere receta', value: almacenSiNo(value: p.requiereReceta)),
            GestionDetailField(label: 'Lote obligatorio', value: almacenSiNo(value: p.loteObligatorio)),
          ],
        );
      case CategoriaProducto.electromedicina:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const GestionDetailSection(title: 'Electromedicina'),
            GestionDetailField(label: 'Mantenimiento', value: almacenSiNo(value: p.requiereMantenimiento)),
            GestionDetailField(
              label: 'Frecuencia',
              value: p.frecuenciaMantenimientoDias == null ? null : '${p.frecuenciaMantenimientoDias} días',
            ),
            GestionDetailField(label: 'Calibración', value: almacenSiNo(value: p.requiereCalibracion)),
            GestionDetailField(label: 'Nº serie oblig.', value: almacenSiNo(value: p.numeroSerieObligatorio)),
          ],
        );
      case CategoriaProducto.materialAmbulancia:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const GestionDetailSection(title: 'Material'),
            GestionDetailField(label: 'Reutilizable', value: almacenSiNo(value: p.esReutilizable)),
          ],
        );
      case CategoriaProducto.fungibles:
      case CategoriaProducto.gasesMedicinales:
      case CategoriaProducto.otros:
      case null:
        return const SizedBox.shrink();
    }
  }
}
